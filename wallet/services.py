from decimal import Decimal
from django.db import transaction
from .models import Wallet, Transaction


@transaction.atomic
def transfer_money(sender_wallet_id, receiver_wallet_id, amount):

    amount = Decimal(amount)
    sender_wallet = Wallet.objects.select_for_update().get(id=sender_wallet_id)
    receiver_wallet = Wallet.objects.select_for_update().get(id=receiver_wallet_id)

    if amount <= 0:
        raise ValueError("Invalid amount")

    if sender_wallet.balance < amount:
        raise ValueError("Insufficient balance")

    sender_wallet.balance -= amount
    receiver_wallet.balance += amount
    sender_wallet.save()
    receiver_wallet.save()

    Transaction.objects.create(
        wallet=sender_wallet,
        transaction_type='transfer',
        amount=amount,
        status='completed',
        description=f"Transfer to {receiver_wallet.user.username}"
    )

    Transaction.objects.create(
        wallet=receiver_wallet,
        transaction_type='deposit',
        amount=amount,
        status='completed',
        description=f"Received from {sender_wallet.user.username}"
    )