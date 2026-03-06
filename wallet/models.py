import uuid
from decimal import Decimal
from django.conf import settings
from django.db import models


class Wallet(models.Model):
    id = models.UUIDField( primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField( settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='wallet')
    balance = models.DecimalField( max_digits=12, decimal_places=2, default=Decimal('0.00'))
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username} Wallet"


#-------------------- Transaction ------------------------  
class Transaction(models.Model):

    TRANSACTION_TYPES = (
        ('deposit', 'Deposit'),
        ('withdraw', 'Withdraw'),
        ('transfer', 'Transfer'),
        ('payment', 'Payment'),
        ('refund', 'Refund'),
    )

    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    )

    id = models.UUIDField( primary_key=True, default=uuid.uuid4, editable=False)
    wallet = models.ForeignKey( Wallet, on_delete=models.CASCADE, related_name='transactions')
    transaction_type = models.CharField( max_length=20, choices=TRANSACTION_TYPES)
    amount = models.DecimalField( max_digits=12, decimal_places=2)
    description = models.TextField(blank=True)
    status = models.CharField( max_length=20, choices=STATUS_CHOICES,default='pending')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.transaction_type} - {self.amount}"