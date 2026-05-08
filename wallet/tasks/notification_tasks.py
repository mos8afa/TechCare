"""
wallet/tasks/notification_tasks.py
────────────────────────────────────
Async task placeholders for notification delivery.
"""
import logging

logger = logging.getLogger(__name__)


def shared_task(func):
    func.delay = func
    func.apply_async = lambda args=(), kwargs={}, **opts: func(*args, **kwargs)
    return func


@shared_task
def send_notification_task(wallet_id: str, notif_type: str, title: str, message: str) -> dict:
    """
    Async task: create and deliver a wallet notification.

    TODO: Add push notification / email dispatch here.
    """
    try:
        from wallet.models import Wallet
        from wallet.services.notification_service import send_wallet_notification

        wallet = Wallet.objects.get(pk=wallet_id)
        notif = send_wallet_notification(wallet, notif_type, title, message)
        logger.info(f"[NOTIF TASK] Wallet {wallet_id}: '{title}'")
        return {'success': True, 'notification_id': str(notif.id)}

    except Exception as exc:
        logger.error(f"[NOTIF TASK] Failed for wallet {wallet_id}: {exc}")
        return {'success': False, 'error': str(exc)}


@shared_task
def take_wallet_snapshot_task(wallet_id: str) -> dict:
    """
    Async task: create a daily WalletSnapshot for analytics.
    Schedule via Celery Beat: daily at midnight.
    """
    try:
        from django.utils import timezone
        from wallet.models import Wallet, WalletSnapshot

        wallet = Wallet.objects.get(pk=wallet_id)
        today = timezone.now().date()
        snapshot, created = WalletSnapshot.objects.get_or_create(
            wallet=wallet,
            snapshot_date=today,
            defaults={'balance': wallet.balance},
        )
        logger.info(f"[SNAPSHOT TASK] Wallet {wallet_id}: {wallet.balance} EGP on {today}")
        return {'success': True, 'created': created, 'balance': str(wallet.balance)}

    except Exception as exc:
        logger.error(f"[SNAPSHOT TASK] Failed for wallet {wallet_id}: {exc}")
        return {'success': False, 'error': str(exc)}
