"""
wallet/services/analytics_service.py
──────────────────────────────────────
Backend analytics for wallet dashboard cards, charts, and Flutter API.

All methods return plain dicts — easy to serialize for both
Django templates and DRF JSON responses.
"""
from decimal import Decimal
from datetime import date, timedelta
from django.db.models import Sum, Count, Avg, Q
from django.utils import timezone

from wallet.models import Wallet, Transaction


# ─────────────────────────────────────────────
#  Monthly stats
# ─────────────────────────────────────────────

def get_monthly_summary(wallet: Wallet, year: int = None, month: int = None) -> dict:
    """
    Return deposit, withdrawal, payment, and net totals for a given month.
    Defaults to the current month.
    """
    now = timezone.now()
    year  = year  or now.year
    month = month or now.month

    qs = wallet.transactions.filter(
        status='completed',
        created_at__year=year,
        created_at__month=month,
    )

    def _sum(txn_type):
        return qs.filter(transaction_type=txn_type).aggregate(
            total=Sum('amount')
        )['total'] or Decimal('0.00')

    deposits     = _sum('deposit')
    withdrawals  = _sum('withdraw')
    payments     = _sum('payment')
    refunds      = _sum('refund')
    fees         = _sum('deduction')
    net_flow     = deposits + refunds - withdrawals - payments - fees

    return {
        'year':        year,
        'month':       month,
        'deposits':    deposits,
        'withdrawals': withdrawals,
        'payments':    payments,
        'refunds':     refunds,
        'fees':        fees,
        'net_flow':    net_flow,
        'tx_count':    qs.count(),
    }


def get_monthly_deposits(wallet: Wallet, months: int = 6) -> list:
    """
    Return monthly deposit totals for the last N months.
    Useful for bar/line charts in Flutter and Django dashboard.
    """
    results = []
    now = timezone.now()

    for i in range(months - 1, -1, -1):
        # Go back i months from current month
        target = (now.replace(day=1) - timedelta(days=i * 28)).replace(day=1)
        total = (
            wallet.transactions
            .filter(
                transaction_type='deposit',
                status='completed',
                created_at__year=target.year,
                created_at__month=target.month,
            )
            .aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
        )
        results.append({
            'year':   target.year,
            'month':  target.month,
            'label':  target.strftime('%b %Y'),
            'amount': total,
        })

    return results


def get_monthly_spending(wallet: Wallet, months: int = 6) -> list:
    """Return monthly payment totals for the last N months."""
    results = []
    now = timezone.now()

    for i in range(months - 1, -1, -1):
        target = (now.replace(day=1) - timedelta(days=i * 28)).replace(day=1)
        total = (
            wallet.transactions
            .filter(
                transaction_type='payment',
                status='completed',
                created_at__year=target.year,
                created_at__month=target.month,
            )
            .aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
        )
        results.append({
            'year':   target.year,
            'month':  target.month,
            'label':  target.strftime('%b %Y'),
            'amount': total,
        })

    return results


# ─────────────────────────────────────────────
#  Weekly stats
# ─────────────────────────────────────────────

def get_weekly_stats(wallet: Wallet) -> dict:
    """
    Return transaction stats for the current week (Mon–Sun).
    """
    today = timezone.now().date()
    week_start = today - timedelta(days=today.weekday())  # Monday
    week_end   = week_start + timedelta(days=6)           # Sunday

    qs = wallet.transactions.filter(
        status='completed',
        created_at__date__gte=week_start,
        created_at__date__lte=week_end,
    )

    daily = []
    for i in range(7):
        day = week_start + timedelta(days=i)
        day_qs = qs.filter(created_at__date=day)
        daily.append({
            'date':       day.isoformat(),
            'day_name':   day.strftime('%a'),
            'deposits':   day_qs.filter(transaction_type='deposit').aggregate(t=Sum('amount'))['t'] or Decimal('0.00'),
            'payments':   day_qs.filter(transaction_type='payment').aggregate(t=Sum('amount'))['t'] or Decimal('0.00'),
            'tx_count':   day_qs.count(),
        })

    return {
        'week_start': week_start.isoformat(),
        'week_end':   week_end.isoformat(),
        'daily':      daily,
        'total_in':   qs.filter(transaction_type__in=['deposit', 'refund']).aggregate(t=Sum('amount'))['t'] or Decimal('0.00'),
        'total_out':  qs.filter(transaction_type__in=['withdraw', 'payment']).aggregate(t=Sum('amount'))['t'] or Decimal('0.00'),
    }


# ─────────────────────────────────────────────
#  Recent activity summary
# ─────────────────────────────────────────────

def get_recent_activity(wallet: Wallet, limit: int = 10) -> list:
    """
    Return the most recent transactions formatted for dashboard cards.
    """
    txns = wallet.transactions.filter(status='completed').order_by('-created_at')[:limit]
    return [
        {
            'id':          str(t.id),
            'type':        t.transaction_type,
            'amount':      t.amount,
            'signed':      t.signed_amount,
            'description': t.description,
            'reference':   t.reference,
            'date':        t.created_at.isoformat(),
            'is_credit':   t.is_credit,
        }
        for t in txns
    ]


# ─────────────────────────────────────────────
#  Dashboard summary card data
# ─────────────────────────────────────────────

def get_dashboard_summary(wallet: Wallet) -> dict:
    """
    Single call that returns all data needed for the wallet dashboard.
    Used by both Django views and the Flutter API endpoint.
    """
    now = timezone.now()

    # Current month
    monthly = get_monthly_summary(wallet)

    # Last 30 days
    thirty_days_ago = now - timedelta(days=30)
    recent_qs = wallet.transactions.filter(
        status='completed',
        created_at__gte=thirty_days_ago,
    )

    return {
        'balance':          wallet.balance,
        'total_deposits':   wallet.total_deposits,
        'total_withdrawals':wallet.total_withdrawals,
        'total_spent':      wallet.total_spent,
        # This month
        'month_deposits':   monthly['deposits'],
        'month_payments':   monthly['payments'],
        'month_net':        monthly['net_flow'],
        # Last 30 days
        'last_30_tx_count': recent_qs.count(),
        'last_30_spent':    recent_qs.filter(transaction_type='payment').aggregate(t=Sum('amount'))['t'] or Decimal('0.00'),
        # Charts
        'monthly_deposits': get_monthly_deposits(wallet, months=6),
        'monthly_spending': get_monthly_spending(wallet, months=6),
        'weekly_stats':     get_weekly_stats(wallet),
        'recent_activity':  get_recent_activity(wallet, limit=5),
    }


# ─────────────────────────────────────────────
#  Provider-specific (Doctor / Nurse)
# ─────────────────────────────────────────────

def get_provider_earnings(wallet: Wallet) -> dict:
    """
    Earnings breakdown for doctors and nurses.
    """
    from wallet.constants import PLATFORM_FEE_PERCENT

    total_income = wallet.total_deposits
    platform_fees = (total_income * PLATFORM_FEE_PERCENT / Decimal('100')).quantize(Decimal('0.01'))
    net_profit = total_income - platform_fees

    monthly = get_monthly_summary(wallet)
    month_income = monthly['deposits']
    month_fees   = (month_income * PLATFORM_FEE_PERCENT / Decimal('100')).quantize(Decimal('0.01'))
    month_net    = month_income - month_fees

    return {
        'total_income':    total_income,
        'platform_fees':   platform_fees,
        'net_profit':      net_profit,
        'fee_percent':     PLATFORM_FEE_PERCENT,
        'month_income':    month_income,
        'month_fees':      month_fees,
        'month_net':       month_net,
        'monthly_chart':   get_monthly_deposits(wallet, months=6),
        'recent_activity': get_recent_activity(wallet, limit=5),
    }
