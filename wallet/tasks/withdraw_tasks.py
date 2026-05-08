"""
wallet/tasks/withdraw_tasks.py
───────────────────────────────
Async task placeholders for withdrawal processing.
"""
import logging
from decimal import Decimal

logger = logging.getLogger(__name__)


def shared_task(func):
    func.delay = func
    func.apply_async = lambda args=(), kwargs={}, **opts: func(*args, **kwargs)
    return func


@shared_task
def process_withdraw_task(wallet_id: str, amount: str, description: str = '', reference: str = '') -> dict:
    """
    Async task: process a withdrawal for the given wallet.
    """
    try:
        from wallet.models import Wallet
        from wallet.services.wallet_service import process_withdraw

        wallet = Wallet.objects.get(pk=wallet_id)
        txn = process_withdraw(
            wallet=wallet,
            amount=Decimal(amount),
            description=description,
            reference=reference,
        )
        logger.info(f"[WITHDRAW TASK] Wallet {wallet_id}: -{amount} EGP | txn={txn.id}")
        return {'success': True, 'transaction_id': str(txn.id)}

    except Exception as exc:
        logger.error(f"[WITHDRAW TASK] Failed for wallet {wallet_id}: {exc}")
        return {'success': False, 'error': str(exc)}


@shared_task
def approve_withdraw_request_task(withdraw_request_id: str) -> dict:
    """Async task: approve a pending withdrawal request."""
    try:
        from wallet.models import WithdrawRequest
        from wallet.services.wallet_service import approve_withdraw_request

        wr = WithdrawRequest.objects.get(pk=withdraw_request_id)
        txn = approve_withdraw_request(wr)
        logger.info(f"[APPROVE WITHDRAW TASK] Request {withdraw_request_id} approved | txn={txn.id}")
        return {'success': True, 'transaction_id': str(txn.id)}

    except Exception as exc:
        logger.error(f"[APPROVE WITHDRAW TASK] Failed for {withdraw_request_id}: {exc}")
        return {'success': False, 'error': str(exc)}
