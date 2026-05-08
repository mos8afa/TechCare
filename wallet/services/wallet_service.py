"""
wallet/services/wallet_service.py
──────────────────────────────────
Core wallet business logic — production-grade financial operations.

Architecture:
  - Every balance mutation is wrapped in @db_transaction.atomic
  - select_for_update() prevents race conditions on concurrent requests
  - Every balance change creates an immutable LedgerEntry
  - Validation is centralised via _validate_amount() and _validate_limits()
  - Notification calls are delegated to notification_service
"""
from decimal import Decimal
from django.db import transaction as db_transaction
from django.utils import timezone

from wallet.models import (
    Wallet, Transaction, LedgerEntry,
    DepositRequest, WithdrawRequest,
)
from wallet.constants import (
    MIN_DEPOSIT_AMOUNT, MAX_DEPOSIT_AMOUNT,
    MIN_WITHDRAW_AMOUNT, MAX_WITHDRAW_AMOUNT,
    DAILY_WITHDRAW_LIMIT,
    MIN_TRANSFER_AMOUNT, MAX_TRANSFER_AMOUNT,
    TXN_TO_LEDGER,
    LEDGER_CREDIT, LEDGER_DEBIT, LEDGER_REFUND, LEDGER_FEE, LEDGER_TRANSFER,
)
from wallet.services.notification_service import (
    notify_deposit_success,
    notify_withdraw_success,
    notify_payment_deducted,
    notify_refund_received,
    notify_deposit_rejected,
    notify_withdraw_rejected,
)


# ─────────────────────────────────────────────
#  Internal helpers
# ─────────────────────────────────────────────

def _validate_amount(amount: Decimal, min_val: Decimal, max_val: Decimal, label: str = 'Amount') -> None:
    """Raise ValueError if amount is outside allowed range."""
    if not isinstance(amount, Decimal):
        amount = Decimal(str(amount))
    if amount <= 0:
        raise ValueError(f"{label} must be positive.")
    if amount < min_val:
        raise ValueError(f"{label} must be at least {min_val:.2f} EGP.")
    if amount > max_val:
        raise ValueError(f"{label} cannot exceed {max_val:.2f} EGP.")


def _check_daily_withdraw_limit(wallet: Wallet, amount: Decimal) -> None:
    """Raise ValueError if today's withdrawals would exceed the daily limit."""
    today = timezone.now().date()
    today_total = (
        wallet.transactions
        .filter(
            transaction_type='withdraw',
            status='completed',
            created_at__date=today,
        )
        .aggregate(total=__import__('django.db.models', fromlist=['Sum']).Sum('amount'))['total']
        or Decimal('0.00')
    )
    if today_total + amount > DAILY_WITHDRAW_LIMIT:
        remaining = DAILY_WITHDRAW_LIMIT - today_total
        raise ValueError(
            f"Daily withdrawal limit of {DAILY_WITHDRAW_LIMIT:.2f} EGP exceeded. "
            f"You can withdraw up to {max(remaining, Decimal('0.00')):.2f} EGP more today."
        )


def _create_ledger_entry(
    wallet: Wallet,
    transaction: Transaction,
    entry_type: str,
    amount: Decimal,
    balance_before: Decimal,
    balance_after: Decimal,
    description: str = '',
    reference: str = '',
) -> LedgerEntry:
    """
    Create an immutable ledger entry for every balance change.
    Called inside atomic blocks — never call directly from views.
    """
    return LedgerEntry.objects.create(
        wallet=wallet,
        transaction=transaction,
        entry_type=entry_type,
        amount=amount,
        balance_before=balance_before,
        balance_after=balance_after,
        description=description or transaction.description,
        reference=reference or transaction.reference,
    )


# ─────────────────────────────────────────────
#  Deposit
# ─────────────────────────────────────────────

@db_transaction.atomic
def process_deposit(
    wallet: Wallet,
    amount: Decimal,
    description: str = '',
    reference: str = '',
    skip_validation: bool = False,
) -> Transaction:
    """
    Add funds to wallet atomically.
    Creates Transaction + LedgerEntry + Notification.

    Args:
        skip_validation: Set True only for seeding/testing — bypasses min/max checks.
    """
    if not skip_validation:
        _validate_amount(amount, MIN_DEPOSIT_AMOUNT, MAX_DEPOSIT_AMOUNT, 'Deposit amount')

    # Lock the wallet row to prevent concurrent balance updates
    wallet = Wallet.objects.select_for_update().get(pk=wallet.pk)

    balance_before = wallet.balance
    wallet.balance += amount
    wallet.save(update_fields=['balance', 'updated_at'])
    balance_after = wallet.balance

    txn = Transaction.objects.create(
        wallet=wallet,
        transaction_type='deposit',
        amount=amount,
        description=description or f"Deposit of {amount:.2f} EGP",
        reference=reference,
        status='completed',
    )

    _create_ledger_entry(
        wallet=wallet,
        transaction=txn,
        entry_type=LEDGER_CREDIT,
        amount=amount,
        balance_before=balance_before,
        balance_after=balance_after,
        description=txn.description,
        reference=reference,
    )

    notify_deposit_success(wallet, amount, balance_after)
    return txn


# ─────────────────────────────────────────────
#  Withdraw
# ─────────────────────────────────────────────

@db_transaction.atomic
def process_withdraw(
    wallet: Wallet,
    amount: Decimal,
    description: str = '',
    reference: str = '',
    skip_validation: bool = False,
) -> Transaction:
    """
    Deduct funds from wallet atomically.
    Raises ValueError on insufficient balance or limit violations.
    """
    if not skip_validation:
        _validate_amount(amount, MIN_WITHDRAW_AMOUNT, MAX_WITHDRAW_AMOUNT, 'Withdrawal amount')

    wallet = Wallet.objects.select_for_update().get(pk=wallet.pk)

    if wallet.balance < amount:
        raise ValueError(
            f"Insufficient balance. Available: {wallet.balance:.2f} EGP, "
            f"Requested: {amount:.2f} EGP."
        )

    if not skip_validation:
        _check_daily_withdraw_limit(wallet, amount)

    balance_before = wallet.balance
    wallet.balance -= amount
    wallet.save(update_fields=['balance', 'updated_at'])
    balance_after = wallet.balance

    txn = Transaction.objects.create(
        wallet=wallet,
        transaction_type='withdraw',
        amount=amount,
        description=description or f"Withdrawal of {amount:.2f} EGP",
        reference=reference,
        status='completed',
    )

    _create_ledger_entry(
        wallet=wallet,
        transaction=txn,
        entry_type=LEDGER_DEBIT,
        amount=amount,
        balance_before=balance_before,
        balance_after=balance_after,
        description=txn.description,
        reference=reference,
    )

    notify_withdraw_success(wallet, amount, balance_after)
    return txn


# ─────────────────────────────────────────────
#  Payment  (charge for a service)
# ─────────────────────────────────────────────

@db_transaction.atomic
def charge_wallet(
    wallet: Wallet,
    amount: Decimal,
    description: str = '',
    reference: str = '',
) -> Transaction:
    """
    Charge the wallet for a service (appointment, pharmacy, etc.).
    No daily limit check — payments are service-driven, not user-initiated.
    """
    if amount <= 0:
        raise ValueError("Charge amount must be positive.")

    wallet = Wallet.objects.select_for_update().get(pk=wallet.pk)

    if wallet.balance < amount:
        raise ValueError(
            f"Insufficient balance. Available: {wallet.balance:.2f} EGP, "
            f"Required: {amount:.2f} EGP."
        )

    balance_before = wallet.balance
    wallet.balance -= amount
    wallet.save(update_fields=['balance', 'updated_at'])
    balance_after = wallet.balance

    txn = Transaction.objects.create(
        wallet=wallet,
        transaction_type='payment',
        amount=amount,
        description=description,
        reference=reference,
        status='completed',
    )

    _create_ledger_entry(
        wallet=wallet,
        transaction=txn,
        entry_type=LEDGER_DEBIT,
        amount=amount,
        balance_before=balance_before,
        balance_after=balance_after,
        description=description,
        reference=reference,
    )

    notify_payment_deducted(wallet, amount, description)
    return txn


# ─────────────────────────────────────────────
#  Refund
# ─────────────────────────────────────────────

@db_transaction.atomic
def refund_wallet(
    wallet: Wallet,
    amount: Decimal,
    description: str = '',
    reference: str = '',
) -> Transaction:
    """Refund an amount back to the wallet."""
    if amount <= 0:
        raise ValueError("Refund amount must be positive.")

    wallet = Wallet.objects.select_for_update().get(pk=wallet.pk)

    balance_before = wallet.balance
    wallet.balance += amount
    wallet.save(update_fields=['balance', 'updated_at'])
    balance_after = wallet.balance

    txn = Transaction.objects.create(
        wallet=wallet,
        transaction_type='refund',
        amount=amount,
        description=description or f"Refund of {amount:.2f} EGP",
        reference=reference,
        status='completed',
    )

    _create_ledger_entry(
        wallet=wallet,
        transaction=txn,
        entry_type=LEDGER_REFUND,
        amount=amount,
        balance_before=balance_before,
        balance_after=balance_after,
        description=txn.description,
        reference=reference,
    )

    notify_refund_received(wallet, amount)
    return txn


# ─────────────────────────────────────────────
#  Transfer between wallets
# ─────────────────────────────────────────────

@db_transaction.atomic
def transfer_between_wallets(
    sender_wallet: Wallet,
    receiver_wallet: Wallet,
    amount: Decimal,
    description: str = '',
) -> tuple:
    """
    Transfer funds atomically between two wallets.
    Both wallets are locked with select_for_update() to prevent deadlocks
    (always lock in consistent pk order).
    """
    _validate_amount(amount, MIN_TRANSFER_AMOUNT, MAX_TRANSFER_AMOUNT, 'Transfer amount')

    # Lock both wallets in consistent order to prevent deadlocks
    pks = sorted([str(sender_wallet.pk), str(receiver_wallet.pk)])
    wallets = {str(w.pk): w for w in Wallet.objects.select_for_update().filter(pk__in=pks)}
    sender   = wallets[str(sender_wallet.pk)]
    receiver = wallets[str(receiver_wallet.pk)]

    if sender.balance < amount:
        raise ValueError(
            f"Insufficient balance for transfer. Available: {sender.balance:.2f} EGP."
        )

    # Debit sender
    sender_before = sender.balance
    sender.balance -= amount
    sender.save(update_fields=['balance', 'updated_at'])

    # Credit receiver
    receiver_before = receiver.balance
    receiver.balance += amount
    receiver.save(update_fields=['balance', 'updated_at'])

    out_desc = description or f"Transfer to {receiver.user.username}"
    in_desc  = description or f"Received from {sender.user.username}"

    out_txn = Transaction.objects.create(
        wallet=sender,
        transaction_type='transfer',
        amount=amount,
        description=out_desc,
        status='completed',
    )
    in_txn = Transaction.objects.create(
        wallet=receiver,
        transaction_type='deposit',
        amount=amount,
        description=in_desc,
        status='completed',
    )

    _create_ledger_entry(
        wallet=sender, transaction=out_txn,
        entry_type=LEDGER_TRANSFER, amount=amount,
        balance_before=sender_before, balance_after=sender.balance,
        description=out_desc,
    )
    _create_ledger_entry(
        wallet=receiver, transaction=in_txn,
        entry_type=LEDGER_CREDIT, amount=amount,
        balance_before=receiver_before, balance_after=receiver.balance,
        description=in_desc,
    )

    return out_txn, in_txn


# ─────────────────────────────────────────────
#  Deposit Request lifecycle
# ─────────────────────────────────────────────

def create_deposit_request(
    wallet: Wallet,
    amount: Decimal,
    cardholder_name: str = '',
    card_last4: str = '',
    card_type: str = 'visa',
    idempotency_key: str = '',
) -> DepositRequest:
    """
    Create a pending deposit request.
    If idempotency_key is provided and a matching pending request exists,
    return the existing one instead of creating a duplicate.
    """
    _validate_amount(amount, MIN_DEPOSIT_AMOUNT, MAX_DEPOSIT_AMOUNT, 'Deposit amount')

    # Idempotency check — prevent double-submit
    if idempotency_key:
        existing = DepositRequest.objects.filter(
            wallet=wallet,
            idempotency_key=idempotency_key,
            status='pending',
        ).first()
        if existing:
            return existing

    return DepositRequest.objects.create(
        wallet=wallet,
        amount=amount,
        cardholder_name=cardholder_name,
        card_last4=card_last4,
        card_type=card_type,
        idempotency_key=idempotency_key,
        status='pending',
    )


@db_transaction.atomic
def approve_deposit_request(deposit_request: DepositRequest) -> Transaction:
    """Approve a pending deposit request and credit the wallet."""
    deposit_request = DepositRequest.objects.select_for_update().get(pk=deposit_request.pk)

    if deposit_request.status != 'pending':
        raise ValueError(
            f"Cannot approve a deposit request with status '{deposit_request.status}'. "
            "Only pending requests can be approved."
        )

    deposit_request.status = 'approved'
    deposit_request.processed_at = timezone.now()
    deposit_request.save(update_fields=['status', 'processed_at'])

    return process_deposit(
        deposit_request.wallet,
        deposit_request.amount,
        description=(
            f"Deposit via {deposit_request.card_type.upper()} "
            f"•••• {deposit_request.card_last4}"
        ),
        skip_validation=True,  # already validated at creation
    )


def reject_deposit_request(deposit_request: DepositRequest, notes: str = '') -> None:
    """Reject a pending deposit request."""
    if deposit_request.status != 'pending':
        raise ValueError("Only pending deposit requests can be rejected.")

    deposit_request.status = 'rejected'
    deposit_request.notes = notes
    deposit_request.processed_at = timezone.now()
    deposit_request.save(update_fields=['status', 'notes', 'processed_at'])

    notify_deposit_rejected(deposit_request.wallet, deposit_request.amount, notes)


# ─────────────────────────────────────────────
#  Withdraw Request lifecycle
# ─────────────────────────────────────────────

def create_withdraw_request(
    wallet: Wallet,
    amount: Decimal,
    bank_name: str = '',
    account_number: str = '',
    account_holder: str = '',
    idempotency_key: str = '',
) -> WithdrawRequest:
    """
    Create a pending withdrawal request.
    Validates balance and daily limit upfront.
    """
    _validate_amount(amount, MIN_WITHDRAW_AMOUNT, MAX_WITHDRAW_AMOUNT, 'Withdrawal amount')

    # Re-read balance inside a fresh query (not locked — just a pre-check)
    current_balance = Wallet.objects.values_list('balance', flat=True).get(pk=wallet.pk)
    if current_balance < amount:
        raise ValueError(
            f"Insufficient balance. Available: {current_balance:.2f} EGP, "
            f"Requested: {amount:.2f} EGP."
        )

    _check_daily_withdraw_limit(wallet, amount)

    # Idempotency check
    if idempotency_key:
        existing = WithdrawRequest.objects.filter(
            wallet=wallet,
            idempotency_key=idempotency_key,
            status='pending',
        ).first()
        if existing:
            return existing

    return WithdrawRequest.objects.create(
        wallet=wallet,
        amount=amount,
        bank_name=bank_name,
        account_number=account_number,
        account_holder=account_holder,
        idempotency_key=idempotency_key,
        status='pending',
    )


@db_transaction.atomic
def approve_withdraw_request(withdraw_request: WithdrawRequest) -> Transaction:
    """Approve a pending withdrawal request and debit the wallet."""
    withdraw_request = WithdrawRequest.objects.select_for_update().get(pk=withdraw_request.pk)

    if withdraw_request.status != 'pending':
        raise ValueError(
            f"Cannot approve a withdrawal request with status '{withdraw_request.status}'."
        )

    withdraw_request.status = 'approved'
    withdraw_request.processed_at = timezone.now()
    withdraw_request.save(update_fields=['status', 'processed_at'])

    return process_withdraw(
        withdraw_request.wallet,
        withdraw_request.amount,
        description=(
            f"Withdrawal to {withdraw_request.bank_name} — "
            f"{withdraw_request.account_holder}"
        ),
        skip_validation=True,  # already validated at creation
    )


def reject_withdraw_request(withdraw_request: WithdrawRequest, notes: str = '') -> None:
    """Reject a pending withdrawal request."""
    if withdraw_request.status != 'pending':
        raise ValueError("Only pending withdrawal requests can be rejected.")

    withdraw_request.status = 'rejected'
    withdraw_request.notes = notes
    withdraw_request.processed_at = timezone.now()
    withdraw_request.save(update_fields=['status', 'notes', 'processed_at'])

    notify_withdraw_rejected(withdraw_request.wallet, withdraw_request.amount, notes)


# ─────────────────────────────────────────────
#  Ledger reconciliation utility
# ─────────────────────────────────────────────

def reconcile_wallet_balance(wallet: Wallet) -> dict:
    """
    Verify that Wallet.balance matches the sum of all ledger entries.
    Returns a dict with reconciliation result.
    Used for auditing and debugging.
    """
    from django.db.models import Sum as DSum

    credits = (
        wallet.ledger_entries
        .filter(entry_type__in=['credit', 'refund'])
        .aggregate(total=DSum('amount'))['total'] or Decimal('0.00')
    )
    debits = (
        wallet.ledger_entries
        .filter(entry_type__in=['debit', 'fee', 'transfer'])
        .aggregate(total=DSum('amount'))['total'] or Decimal('0.00')
    )
    ledger_balance = credits - debits

    return {
        'wallet_balance':  wallet.balance,
        'ledger_balance':  ledger_balance,
        'credits':         credits,
        'debits':          debits,
        'is_reconciled':   wallet.balance == ledger_balance,
        'discrepancy':     wallet.balance - ledger_balance,
    }
