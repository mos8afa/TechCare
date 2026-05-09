import json
from decimal import Decimal, InvalidOperation

from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.shortcuts import redirect, render
from django.views.decorators.http import require_POST

from .models import SavedCard, Transaction, Wallet
from .services import (
    approve_deposit_request,
    approve_withdraw_request,
    create_deposit_request,
    create_withdraw_request,
    fake_deposit,
    fake_withdraw,
    get_dashboard_summary,
    get_provider_earnings,
    get_monthly_deposits,
)
from .constants import PLATFORM_FEE_PERCENT


# ─────────────────────────────────────────────
#  Helpers
# ─────────────────────────────────────────────

def _get_wallet(user) -> Wallet:
    wallet, _ = Wallet.objects.get_or_create(user=user)
    return wallet


def _profile_pic(user):
    for attr in ('doctor', 'nurse', 'patient', 'donor', 'pharmacist'):
        profile = getattr(user, attr, None)
        if profile and getattr(profile, 'profile_pic', None):
            return profile.profile_pic
    return None


def _base_context(request) -> dict:
    user   = request.user
    wallet = _get_wallet(user)
    return {
        'wallet':               wallet,
        'user':                 user,
        'name':                 f"{user.first_name} {user.last_name}".strip() or user.username,
        'role':                 getattr(user, 'role', ''),
        'profile_pic':          _profile_pic(user),
        'unread_notifications': wallet.notifications.filter(is_read=False).count(),
    }


# ─────────────────────────────────────────────
#  Dashboard / Wallet overview
# ─────────────────────────────────────────────

@login_required
def wallet_dashboard(request):
    ctx    = _base_context(request)
    wallet = ctx['wallet']
    role   = ctx['role']

    recent_txns = wallet.transactions.order_by('-created_at')[:5]
    saved_cards = wallet.saved_cards.all()

    if role in ('doctor', 'nurse'):
        # ── Provider view: real earnings from analytics service ──
        earnings = get_provider_earnings(wallet)

        monthly_chart = get_monthly_deposits(wallet, months=6)
        chart_labels  = [d['label'] for d in monthly_chart]
        chart_data    = [float(d['amount']) for d in monthly_chart]

        ctx.update({
            'template_variant':    'provider',
            'recent_transactions': recent_txns,
            # Real earnings data
            'consultation_income': earnings['month_income'],
            'platform_fees':       earnings['month_fees'],
            'net_profit':          earnings['month_net'],
            'total_income':        earnings['total_income'],
            'total_fees':          earnings['platform_fees'],
            'total_net':           earnings['net_profit'],
            'fee_percent':         PLATFORM_FEE_PERCENT,
            # Chart.js data (JSON-safe)
            'chart_labels_json':   json.dumps(chart_labels),
            'chart_data_json':     json.dumps(chart_data),
        })
    else:
        summary      = get_dashboard_summary(wallet)

        ctx.update({
            'template_variant':    'consumer',
            'recent_transactions': recent_txns,
            'saved_cards':         saved_cards,
            # Real summary data
            'total_spent':         summary['total_spent'],
            'month_deposits':      summary['month_deposits'],
            'month_payments':      summary['month_payments'],
            'last_30_spent':       summary['last_30_spent'],
            'last_30_tx_count':    summary['last_30_tx_count'],
        })

    return render(request, 'wallet/dashboard.html', ctx)


# ─────────────────────────────────────────────
#  All Transactions
# ─────────────────────────────────────────────

@login_required
def transaction_list(request):
    ctx    = _base_context(request)
    wallet = ctx['wallet']

    txn_type   = request.GET.get('type', '')
    txn_status = request.GET.get('status', '')

    qs = wallet.transactions.all()
    if txn_type:
        qs = qs.filter(transaction_type=txn_type)
    if txn_status:
        qs = qs.filter(status=txn_status)

    ctx.update({
        'transactions':    qs,
        'filter_type':     txn_type,
        'filter_status':   txn_status,
        'transaction_types': Transaction.TRANSACTION_TYPES,
        'status_choices':    Transaction.STATUS_CHOICES,
        'total_count':     wallet.transactions.count(),
        'filtered_count':  qs.count(),
    })
    return render(request, 'wallet/transactions.html', ctx)


# ─────────────────────────────────────────────
#  Deposit (Add Funds)
# ─────────────────────────────────────────────

@login_required
def deposit_view(request):
    ctx = _base_context(request)

    if request.method == 'POST':
        raw_amount  = request.POST.get('amount', '0')
        cardholder  = request.POST.get('cardholder_name', '').strip()
        card_number = request.POST.get('card_number', '').replace(' ', '')
        card_last4  = card_number[-4:] if len(card_number) >= 4 else '0000'
        card_type   = request.POST.get('card_type', 'visa')

        try:
            amount = Decimal(raw_amount)
            if amount <= 0:
                raise ValueError("Amount must be positive.")
        except (InvalidOperation, ValueError) as exc:
            messages.error(request, str(exc))
            return render(request, 'wallet/deposit.html', ctx)

        wallet  = ctx['wallet']
        dep_req = create_deposit_request(
            wallet=wallet,
            amount=amount,
            cardholder_name=cardholder,
            card_last4=card_last4,
            card_type=card_type,
        )
        approve_deposit_request(dep_req)
        messages.success(request, f"{amount:.2f} EGP has been added to your wallet successfully.")
        return redirect('wallet:dashboard')

    return render(request, 'wallet/deposit.html', ctx)


# ─────────────────────────────────────────────
#  Withdraw
# ─────────────────────────────────────────────

@login_required
def withdraw_view(request):
    ctx = _base_context(request)

    if request.method == 'POST':
        raw_amount     = request.POST.get('amount', '0')
        bank_name      = request.POST.get('bank_name', '').strip()
        account_number = request.POST.get('account_number', '').strip()
        account_holder = request.POST.get('account_holder', '').strip()

        try:
            amount = Decimal(raw_amount)
            if amount <= 0:
                raise ValueError("Amount must be positive.")
        except (InvalidOperation, ValueError) as exc:
            messages.error(request, str(exc))
            return render(request, 'wallet/withdraw.html', ctx)

        wallet = ctx['wallet']
        try:
            wr = create_withdraw_request(
                wallet=wallet,
                amount=amount,
                bank_name=bank_name,
                account_number=account_number,
                account_holder=account_holder,
            )
            approve_withdraw_request(wr)
            messages.success(request, f"Withdrawal of {amount:.2f} EGP has been processed.")
            return redirect('wallet:dashboard')
        except ValueError as exc:
            messages.error(request, str(exc))
            return render(request, 'wallet/withdraw.html', ctx)

    return render(request, 'wallet/withdraw.html', ctx)


# ─────────────────────────────────────────────
#  Notifications
# ─────────────────────────────────────────────

@login_required
def notifications_view(request):
    ctx    = _base_context(request)
    wallet = ctx['wallet']

    wallet.notifications.filter(is_read=False).update(is_read=True)

    ctx['notifications'] = wallet.notifications.all()
    return render(request, 'wallet/notifications.html', ctx)


# ─────────────────────────────────────────────
#  Saved Cards
# ─────────────────────────────────────────────

@login_required
def saved_cards_view(request):
    ctx    = _base_context(request)
    wallet = ctx['wallet']

    if request.method == 'POST':
        action = request.POST.get('action')

        if action == 'add':
            card_type   = request.POST.get('card_type', 'visa')
            cardholder  = request.POST.get('cardholder_name', '').strip()
            card_number = request.POST.get('card_number', '').replace(' ', '')
            last4       = card_number[-4:] if len(card_number) >= 4 else '0000'
            expiry      = request.POST.get('expiry', '').strip()
            SavedCard.objects.create(
                wallet=wallet, card_type=card_type,
                cardholder_name=cardholder, last4=last4, expiry=expiry,
            )
            messages.success(request, "Card saved successfully.")

        elif action == 'delete':
            card_id = request.POST.get('card_id')
            SavedCard.objects.filter(pk=card_id, wallet=wallet).delete()
            messages.success(request, "Card removed.")

        elif action == 'set_default':
            card_id = request.POST.get('card_id')
            wallet.saved_cards.update(is_default=False)
            SavedCard.objects.filter(pk=card_id, wallet=wallet).update(is_default=True)
            messages.success(request, "Default card updated.")

        return redirect('wallet:saved_cards')

    ctx['saved_cards'] = wallet.saved_cards.all()
    return render(request, 'wallet/saved_cards.html', ctx)


# ─────────────────────────────────────────────
#  Fake / Test operations (dev only)
# ─────────────────────────────────────────────

@login_required
@require_POST
def fake_deposit_view(request):
    """Quick test deposit — guard with DEBUG check in production."""
    wallet = _get_wallet(request.user)
    try:
        amount = Decimal(request.POST.get('amount', '100'))
        fake_deposit(wallet, amount, description='Test deposit (fake)')
        messages.success(request, f"Fake deposit of {amount:.2f} EGP added.")
    except (InvalidOperation, ValueError) as exc:
        messages.error(request, str(exc))
    return redirect('wallet:dashboard')


@login_required
@require_POST
def fake_withdraw_view(request):
    """Quick test withdrawal — guard with DEBUG check in production."""
    wallet = _get_wallet(request.user)
    try:
        amount = Decimal(request.POST.get('amount', '50'))
        fake_withdraw(wallet, amount, description='Test withdrawal (fake)')
        messages.success(request, f"Fake withdrawal of {amount:.2f} EGP processed.")
    except (InvalidOperation, ValueError) as exc:
        messages.error(request, str(exc))
    return redirect('wallet:dashboard')
