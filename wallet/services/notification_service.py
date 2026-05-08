"""
wallet/services/notification_service.py
────────────────────────────────────────
Centralized notification creation for all wallet events.

All wallet operations that affect balance call these functions
so notifications are consistent and easy to extend (e.g. push
notifications, email, SMS) in one place.
"""
from decimal import Decimal
from wallet.models import Notification, Wallet


# ─────────────────────────────────────────────
#  Core creator
# ─────────────────────────────────────────────

def create_notification(
    wallet: Wallet,
    notif_type: str,
    title: str,
    message: str,
) -> Notification:
    """
    Persist a notification for the given wallet.
    This is the single entry point — all other helpers call this.
    """
    return Notification.objects.create(
        wallet=wallet,
        notif_type=notif_type,
        title=title,
        message=message,
    )


def send_wallet_notification(wallet: Wallet, notif_type: str, title: str, message: str) -> Notification:
    """
    Alias for create_notification.
    Kept separate so future push/email delivery can be added here
    without touching the core creator.

    TODO: Add push notification dispatch here, e.g.:
        push_service.send(wallet.user, title, message)
    """
    notif = create_notification(wallet, notif_type, title, message)
    # Future: dispatch push / email / SMS here
    return notif


# ─────────────────────────────────────────────
#  Event-specific helpers
# ─────────────────────────────────────────────

def notify_deposit_success(wallet: Wallet, amount: Decimal, new_balance: Decimal) -> Notification:
    return send_wallet_notification(
        wallet,
        notif_type='deposit',
        title='Funds Added Successfully',
        message=(
            f"{amount:.2f} EGP has been added to your wallet. "
            f"New balance: {new_balance:.2f} EGP."
        ),
    )


def notify_withdraw_success(wallet: Wallet, amount: Decimal, new_balance: Decimal) -> Notification:
    return send_wallet_notification(
        wallet,
        notif_type='withdraw',
        title='Withdrawal Processed',
        message=(
            f"{amount:.2f} EGP has been withdrawn from your wallet. "
            f"Remaining balance: {new_balance:.2f} EGP."
        ),
    )


def notify_payment_deducted(wallet: Wallet, amount: Decimal, description: str) -> Notification:
    return send_wallet_notification(
        wallet,
        notif_type='payment',
        title='Payment Deducted',
        message=f"{amount:.2f} EGP was charged for: {description}.",
    )


def notify_refund_received(wallet: Wallet, amount: Decimal) -> Notification:
    return send_wallet_notification(
        wallet,
        notif_type='deposit',
        title='Refund Received',
        message=f"{amount:.2f} EGP has been refunded to your wallet.",
    )


def notify_deposit_rejected(wallet: Wallet, amount: Decimal, reason: str = '') -> Notification:
    msg = f"Your deposit request of {amount:.2f} EGP was rejected."
    if reason:
        msg += f" Reason: {reason}"
    return send_wallet_notification(wallet, 'info', 'Deposit Request Rejected', msg)


def notify_withdraw_rejected(wallet: Wallet, amount: Decimal, reason: str = '') -> Notification:
    msg = f"Your withdrawal request of {amount:.2f} EGP was rejected."
    if reason:
        msg += f" Reason: {reason}"
    return send_wallet_notification(wallet, 'info', 'Withdrawal Request Rejected', msg)


def notify_welcome(wallet: Wallet) -> Notification:
    return send_wallet_notification(
        wallet,
        notif_type='info',
        title='Welcome to TechCare Wallet!',
        message=(
            'Your wallet is ready. You can add funds, pay for consultations, '
            'and track all your healthcare payments in one place.'
        ),
    )


def notify_low_balance(wallet: Wallet, balance: Decimal, threshold: Decimal) -> Notification:
    return send_wallet_notification(
        wallet,
        notif_type='alert',
        title='Low Balance Alert',
        message=(
            f"Your wallet balance ({balance:.2f} EGP) is below {threshold:.2f} EGP. "
            "Consider adding funds to avoid service interruptions."
        ),
    )
