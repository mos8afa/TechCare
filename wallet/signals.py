import logging
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model

logger = logging.getLogger(__name__)

User = get_user_model()


@receiver(post_save, sender=User)
def create_wallet_on_user_creation(sender, instance, created, **kwargs):
    if not created:
        return

    try:
        from wallet.models import Wallet
        from wallet.services.notification_service import notify_welcome

        wallet, wallet_created = Wallet.objects.get_or_create(user=instance)

        if wallet_created:
            logger.info(f"[WALLET SIGNAL] Created wallet for user: {instance.username}")
            # Send welcome notification
            try:
                notify_welcome(wallet)
            except Exception as notif_err:
                # Never let notification failure block user creation
                logger.warning(f"[WALLET SIGNAL] Welcome notification failed: {notif_err}")

    except Exception as exc:
        # Never let wallet creation failure block user creation
        logger.error(f"[WALLET SIGNAL] Failed to create wallet for {instance.username}: {exc}")
