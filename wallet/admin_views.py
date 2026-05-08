from decimal import Decimal
from django.contrib.admin.views.decorators import staff_member_required
from django.db.models import Sum, Count, Q
from django.shortcuts import render, get_object_or_404
from django.contrib.auth import get_user_model

from .models import Wallet, Transaction, LedgerEntry, DepositRequest, WithdrawRequest, Notification
from .services.provider_visibility_service import (
    filter_visible_doctors,
    filter_visible_nurses,
    get_provider_visibility_status,
)

User = get_user_model()


# ─────────────────────────────────────────────
#  Main admin dashboard
# ─────────────────────────────────────────────

@staff_member_required
def admin_wallet_dashboard(request):
    # ── System totals ──
    wallet_stats = Wallet.objects.aggregate(
        total_balance=Sum('balance'),
        active_count=Count('id', filter=Q(is_active=True)),
        total_count=Count('id'),
    )

    txn_stats = Transaction.objects.filter(status='completed').aggregate(
        total_deposits=Sum('amount', filter=Q(transaction_type='deposit')),
        total_withdrawals=Sum('amount', filter=Q(transaction_type='withdraw')),
        total_payments=Sum('amount', filter=Q(transaction_type='payment')),
        total_refunds=Sum('amount', filter=Q(transaction_type='refund')),
    )

    # ── Pending requests ──
    pending_deposits  = DepositRequest.objects.filter(status='pending').count()
    pending_withdraws = WithdrawRequest.objects.filter(status='pending').count()

    # ── Recent transactions (last 20) ──
    recent_txns = Transaction.objects.select_related('wallet__user').order_by('-created_at')[:20]

    # ── Provider visibility ──
    from accounts.models import Doctor, Nurse
    from django.db.models import Avg

    all_doctors = Doctor.objects.filter(slots__isnull=False).distinct().select_related('user').prefetch_related('user__wallet')
    all_nurses  = Nurse.objects.filter(slots__isnull=False).distinct().select_related('user').prefetch_related('user__wallet', 'nurse_services')

    visible_doctors   = filter_visible_doctors(all_doctors)
    visible_nurses    = filter_visible_nurses(all_nurses)
    invisible_doctors = [d for d in all_doctors if d not in visible_doctors]
    invisible_nurses  = [n for n in all_nurses  if n not in visible_nurses]

    # Attach visibility info to invisible providers
    for doc in invisible_doctors:
        status = get_provider_visibility_status(doctor=doc)
        doc._visibility_threshold = status['threshold']
        doc._wallet_balance       = status['balance']
        doc._shortfall            = status['shortfall']

    for nurse in invisible_nurses:
        status = get_provider_visibility_status(nurse=nurse)
        nurse._visibility_threshold = status['threshold']
        nurse._wallet_balance       = status['balance']
        nurse._shortfall            = status['shortfall']

    # ── Unread notifications count ──
    unread_notifs = Notification.objects.filter(is_read=False).count()

    # ── Top wallets by balance ──
    top_wallets = Wallet.objects.select_related('user').order_by('-balance')[:10]

    context = {
        # System totals
        'total_system_balance': wallet_stats['total_balance'] or Decimal('0.00'),
        'active_wallets':       wallet_stats['active_count'] or 0,
        'total_wallets':        wallet_stats['total_count'] or 0,
        'total_deposits':       txn_stats['total_deposits']    or Decimal('0.00'),
        'total_withdrawals':    txn_stats['total_withdrawals'] or Decimal('0.00'),
        'total_payments':       txn_stats['total_payments']    or Decimal('0.00'),
        'total_refunds':        txn_stats['total_refunds']     or Decimal('0.00'),
        # Pending
        'pending_deposits':     pending_deposits,
        'pending_withdraws':    pending_withdraws,
        'unread_notifs':        unread_notifs,
        # Recent activity
        'recent_transactions':  recent_txns,
        # Provider visibility
        'visible_doctors_count':   len(visible_doctors),
        'invisible_doctors_count': len(invisible_doctors),
        'visible_nurses_count':    len(visible_nurses),
        'invisible_nurses_count':  len(invisible_nurses),
        'invisible_doctors':       invisible_doctors[:10],
        'invisible_nurses':        invisible_nurses[:10],
        # Top wallets
        'top_wallets': top_wallets,
    }
    return render(request, 'wallet/admin/dashboard.html', context)


# ─────────────────────────────────────────────
#  Per-user wallet detail
# ─────────────────────────────────────────────

@staff_member_required
def admin_wallet_detail(request, user_id):
    user   = get_object_or_404(User, pk=user_id)
    wallet = get_object_or_404(Wallet, user=user)

    transactions = wallet.transactions.order_by('-created_at')[:50]
    ledger       = wallet.ledger_entries.order_by('-created_at')[:50]
    dep_requests = wallet.deposit_requests.order_by('-created_at')[:20]
    wd_requests  = wallet.withdraw_requests.order_by('-created_at')[:20]
    notifications= wallet.notifications.order_by('-created_at')[:20]
    snapshots    = wallet.snapshots.order_by('-snapshot_date')[:12]

    # Reconciliation
    from .services.wallet_service import reconcile_wallet_balance
    reconciliation = reconcile_wallet_balance(wallet)

    # Provider visibility (if applicable)
    visibility_status = None
    role = getattr(user, 'role', '')
    if role == 'doctor':
        try:
            visibility_status = get_provider_visibility_status(doctor=user.doctor)
        except Exception:
            pass
    elif role == 'nurse':
        try:
            visibility_status = get_provider_visibility_status(nurse=user.nurse)
        except Exception:
            pass

    context = {
        'target_user':      user,
        'wallet':           wallet,
        'transactions':     transactions,
        'ledger':           ledger,
        'dep_requests':     dep_requests,
        'wd_requests':      wd_requests,
        'notifications':    notifications,
        'snapshots':        snapshots,
        'reconciliation':   reconciliation,
        'visibility_status':visibility_status,
    }
    return render(request, 'wallet/admin/wallet_detail.html', context)


# ─────────────────────────────────────────────
#  Provider visibility report
# ─────────────────────────────────────────────

@staff_member_required
def admin_provider_visibility(request):
    from accounts.models import Doctor, Nurse

    all_doctors = Doctor.objects.select_related('user').prefetch_related('user__wallet').order_by('user__last_name')
    all_nurses  = Nurse.objects.select_related('user').prefetch_related('user__wallet', 'nurse_services').order_by('user__last_name')

    doctor_statuses = []
    for doc in all_doctors:
        try:
            s = get_provider_visibility_status(doctor=doc)
            doctor_statuses.append(s)
        except Exception:
            pass

    nurse_statuses = []
    for nurse in all_nurses:
        try:
            s = get_provider_visibility_status(nurse=nurse)
            nurse_statuses.append(s)
        except Exception:
            pass

    context = {
        'doctor_statuses': doctor_statuses,
        'nurse_statuses':  nurse_statuses,
        'visible_doctors': sum(1 for s in doctor_statuses if s['is_visible']),
        'visible_nurses':  sum(1 for s in nurse_statuses  if s['is_visible']),
    }
    return render(request, 'wallet/admin/provider_visibility.html', context)
