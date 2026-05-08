"""
wallet/tasks/deposit_tasks.py
──────────────────────────────
Async task placeholders for deposit processing.

When Celery + Redis are configured, decorate these with @shared_task.
The function signatures and logic stay the same — just add the decorator.

Setup steps (when ready):
  1. pip install celery redis
  2. Add CELERY_BROKER_URL = 'redis://localhost:6379/0' to settings.py
  3. Replace the stub decorator below with: from celery import shared_task
  4. Run: celery -A project worker --loglevel=info
"""
import logging
from decimal import Decimal

logger = logging.getLogger(__name__)


# ── Stub decorator (replace with @shared_task when Celery is ready) ──
def shared_task(func):
    """Placeholder — makes tasks callable synchronously until Celery is wired up."""
    func.delay = func          # .delay() calls the function directly
    func.apply_async = lambda args=(), kwargs={}, **opts: func(*args, **kwargs)
    return func


@shared_task
def process_deposit_task(wallet_id: str, amount: str, description: str = '', reference: str = '') -> dict:
    """
    Async task: process a deposit for the given wallet.

    Args:
        wallet_id:   UUID string of the Wallet
        amount:      Decimal string (e.g. "500.00")
        description: Human-readable description
        reference:   External reference (e.g. gateway transaction ID)

    Returns:
        dict with success status and transaction ID
    """
    try:
        from wallet.models import Wallet
        from wallet.services.wallet_service import process_deposit

        wallet = Wallet.objects.get(pk=wallet_id)
        txn = process_deposit(
            wallet=wallet,
            amount=Decimal(amount),
            description=description,
            reference=reference,
        )
        logger.info(f"[DEPOSIT TASK] Wallet {wallet_id}: +{amount} EGP | txn={txn.id}")
        return {'success': True, 'transaction_id': str(txn.id)}

    except Exception as exc:
        logger.error(f"[DEPOSIT TASK] Failed for wallet {wallet_id}: {exc}")
        return {'success': False, 'error': str(exc)}


@shared_task
def approve_deposit_request_task(deposit_request_id: str) -> dict:
    """
    Async task: approve a pending deposit request.
    Called by payment gateway webhook handlers.
    """
    try:
        from wallet.models import DepositRequest
        from wallet.services.wallet_service import approve_deposit_request

        dep_req = DepositRequest.objects.get(pk=deposit_request_id)
        txn = approve_deposit_request(dep_req)
        logger.info(f"[APPROVE DEPOSIT TASK] Request {deposit_request_id} approved | txn={txn.id}")
        return {'success': True, 'transaction_id': str(txn.id)}

    except Exception as exc:
        logger.error(f"[APPROVE DEPOSIT TASK] Failed for {deposit_request_id}: {exc}")
        return {'success': False, 'error': str(exc)}
