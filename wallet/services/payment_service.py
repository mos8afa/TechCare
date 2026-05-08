"""
payment_service.py
──────────────────
Placeholder for real payment gateway integration.

When you're ready to integrate a real gateway (Paymob, Stripe, Fawry, etc.),
replace the fake_* functions below with actual API calls.

The rest of the codebase calls these functions — so the integration surface
is limited to this single file.
"""
from decimal import Decimal

from wallet.models import Wallet
from .wallet_service import process_deposit, process_withdraw


# ─────────────────────────────────────────────
#  FAKE / TEST operations  (no real money moves)
# ─────────────────────────────────────────────

def fake_deposit(wallet: Wallet, amount: Decimal, description: str = 'Test deposit') -> dict:
    """
    Simulate a successful deposit without a real payment gateway.
    Returns a dict mimicking a gateway response.

    TODO: Replace with real gateway call, e.g.:
        response = paymob_client.charge(amount=amount, card_token=token)
        if response.success:
            process_deposit(wallet, amount, ...)
    """
    txn = process_deposit(
        wallet, amount,
        description=description,
        reference='FAKE-TEST',
        skip_validation=True,  # bypass min/max for test convenience
    )
    return {
        'success': True,
        'transaction_id': str(txn.id),
        'amount': float(amount),
        'gateway': 'fake',
        'message': 'Fake deposit processed successfully.',
    }


def fake_withdraw(wallet: Wallet, amount: Decimal, description: str = 'Test withdrawal') -> dict:
    """
    Simulate a successful withdrawal without a real payment gateway.

    TODO: Replace with real gateway call, e.g.:
        response = bank_api.transfer(amount=amount, account=account_number)
        if response.success:
            process_withdraw(wallet, amount, ...)
    """
    txn = process_withdraw(
        wallet, amount,
        description=description,
        reference='FAKE-TEST',
        skip_validation=True,  # bypass daily limit for test convenience
    )
    return {
        'success': True,
        'transaction_id': str(txn.id),
        'amount': float(amount),
        'gateway': 'fake',
        'message': 'Fake withdrawal processed successfully.',
    }


# ─────────────────────────────────────────────
#  FUTURE: Real gateway stubs
# ─────────────────────────────────────────────

def paymob_deposit(wallet: Wallet, amount: Decimal, card_token: str) -> dict:
    """
    TODO: Integrate Paymob payment gateway.
    Steps:
      1. Create order via Paymob Orders API
      2. Obtain payment token
      3. Charge card using card_token
      4. On success, call process_deposit(wallet, amount, ...)
    """
    raise NotImplementedError("Paymob integration not yet implemented.")


def stripe_deposit(wallet: Wallet, amount: Decimal, payment_method_id: str) -> dict:
    """
    TODO: Integrate Stripe payment gateway.
    Steps:
      1. Create PaymentIntent via Stripe API
      2. Confirm with payment_method_id
      3. On success, call process_deposit(wallet, amount, ...)
    """
    raise NotImplementedError("Stripe integration not yet implemented.")


def fawry_deposit(wallet: Wallet, amount: Decimal, reference_number: str) -> dict:
    """
    TODO: Integrate Fawry payment gateway.
    Steps:
      1. Generate Fawry reference number
      2. Poll for payment confirmation
      3. On success, call process_deposit(wallet, amount, ...)
    """
    raise NotImplementedError("Fawry integration not yet implemented.")
