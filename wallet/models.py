import uuid
from decimal import Decimal
from django.conf import settings
from django.db import models
from django.utils import timezone

from .constants import LEDGER_ENTRY_TYPES


# ─────────────────────────────────────────────
#  Wallet
# ─────────────────────────────────────────────
class Wallet(models.Model):
    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user       = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='wallet',
    )
    balance    = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0.00'))
    is_active  = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [models.Index(fields=['user'])]

    def __str__(self):
        return f"{self.user.username} — {self.balance} EGP"

    # ── Aggregate helpers (used by serializers & dashboard) ──

    @property
    def total_deposits(self):
        return (
            self.transactions.filter(transaction_type='deposit', status='completed')
            .aggregate(total=models.Sum('amount'))['total'] or Decimal('0.00')
        )

    @property
    def total_withdrawals(self):
        return (
            self.transactions.filter(transaction_type='withdraw', status='completed')
            .aggregate(total=models.Sum('amount'))['total'] or Decimal('0.00')
        )

    @property
    def total_spent(self):
        return (
            self.transactions.filter(transaction_type='payment', status='completed')
            .aggregate(total=models.Sum('amount'))['total'] or Decimal('0.00')
        )

    @property
    def total_fees(self):
        return (
            self.transactions.filter(transaction_type='deduction', status='completed')
            .aggregate(total=models.Sum('amount'))['total'] or Decimal('0.00')
        )


# ─────────────────────────────────────────────
#  Transaction  (user-facing record)
# ─────────────────────────────────────────────
class Transaction(models.Model):
    TRANSACTION_TYPES = (
        ('deposit',   'Deposit'),
        ('withdraw',  'Withdraw'),
        ('transfer',  'Transfer'),
        ('payment',   'Payment'),
        ('refund',    'Refund'),
        ('deduction', 'Deduction'),
    )

    STATUS_CHOICES = (
        ('pending',   'Pending'),
        ('completed', 'Completed'),
        ('failed',    'Failed'),
    )

    id               = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wallet           = models.ForeignKey(Wallet, on_delete=models.CASCADE, related_name='transactions')
    transaction_type = models.CharField(max_length=20, choices=TRANSACTION_TYPES)
    amount           = models.DecimalField(max_digits=12, decimal_places=2)
    description      = models.TextField(blank=True)
    reference        = models.CharField(max_length=100, blank=True, db_index=True)
    status           = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at       = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        indexes  = [
            models.Index(fields=['wallet', 'transaction_type']),
            models.Index(fields=['wallet', 'status']),
            models.Index(fields=['created_at']),
        ]

    def __str__(self):
        return f"{self.transaction_type} — {self.amount} EGP ({self.status})"

    @property
    def is_credit(self):
        return self.transaction_type in ('deposit', 'refund')

    @property
    def signed_amount(self):
        """Positive for credits, negative for debits."""
        return self.amount if self.is_credit else -self.amount


# ─────────────────────────────────────────────
#  LedgerEntry  (immutable accounting record)
# ─────────────────────────────────────────────
class LedgerEntry(models.Model):
    id             = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wallet         = models.ForeignKey(Wallet, on_delete=models.CASCADE, related_name='ledger_entries')
    transaction    = models.OneToOneField(
        Transaction,
        on_delete=models.CASCADE,
        related_name='ledger_entry',
        null=True, blank=True,
    )
    entry_type     = models.CharField(max_length=20, choices=LEDGER_ENTRY_TYPES)
    amount         = models.DecimalField(max_digits=12, decimal_places=2)  # always positive
    balance_before = models.DecimalField(max_digits=12, decimal_places=2)
    balance_after  = models.DecimalField(max_digits=12, decimal_places=2)
    description    = models.TextField(blank=True)
    reference      = models.CharField(max_length=100, blank=True, db_index=True)
    created_at     = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        indexes  = [
            models.Index(fields=['wallet', 'entry_type']),
            models.Index(fields=['created_at']),
        ]
        # Prevent accidental updates at the DB level via app-layer convention
        # (enforce immutability in save() override below)

    def save(self, *args, **kwargs):
        if self.pk and LedgerEntry.objects.filter(pk=self.pk).exists():
            raise PermissionError("LedgerEntry records are immutable and cannot be modified.")
        super().save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        raise PermissionError("LedgerEntry records are immutable and cannot be deleted.")

    def __str__(self):
        return f"[{self.entry_type.upper()}] {self.amount} EGP | {self.balance_before} → {self.balance_after}"


# ─────────────────────────────────────────────
#  WalletSnapshot  (periodic balance checkpoint)
# ─────────────────────────────────────────────
class WalletSnapshot(models.Model):
    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wallet     = models.ForeignKey(Wallet, on_delete=models.CASCADE, related_name='snapshots')
    balance    = models.DecimalField(max_digits=12, decimal_places=2)
    snapshot_date = models.DateField(db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering            = ['-snapshot_date']
        unique_together     = ('wallet', 'snapshot_date')

    def __str__(self):
        return f"{self.wallet.user.username} snapshot {self.snapshot_date}: {self.balance} EGP"


# ─────────────────────────────────────────────
#  DepositRequest
# ─────────────────────────────────────────────
class DepositRequest(models.Model):
    STATUS_CHOICES = (
        ('pending',  'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    )

    id              = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wallet          = models.ForeignKey(Wallet, on_delete=models.CASCADE, related_name='deposit_requests')
    amount          = models.DecimalField(max_digits=12, decimal_places=2)
    cardholder_name = models.CharField(max_length=100, blank=True)
    card_last4      = models.CharField(max_length=4, blank=True)
    card_type       = models.CharField(max_length=20, blank=True, default='visa')
    status          = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    notes           = models.TextField(blank=True)
    # Idempotency key — prevents duplicate submissions
    idempotency_key = models.CharField(max_length=64, blank=True, db_index=True)
    created_at      = models.DateTimeField(auto_now_add=True)
    processed_at    = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Deposit {self.amount} EGP — {self.status}"


# ─────────────────────────────────────────────
#  WithdrawRequest
# ─────────────────────────────────────────────
class WithdrawRequest(models.Model):
    STATUS_CHOICES = (
        ('pending',  'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    )

    id              = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wallet          = models.ForeignKey(Wallet, on_delete=models.CASCADE, related_name='withdraw_requests')
    amount          = models.DecimalField(max_digits=12, decimal_places=2)
    bank_name       = models.CharField(max_length=100, blank=True)
    account_number  = models.CharField(max_length=30, blank=True)
    account_holder  = models.CharField(max_length=100, blank=True)
    status          = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    notes           = models.TextField(blank=True)
    idempotency_key = models.CharField(max_length=64, blank=True, db_index=True)
    created_at      = models.DateTimeField(auto_now_add=True)
    processed_at    = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Withdraw {self.amount} EGP — {self.status}"


# ─────────────────────────────────────────────
#  SavedCard  (UI display only)
# ─────────────────────────────────────────────
class SavedCard(models.Model):
    CARD_TYPES = (
        ('visa',       'Visa'),
        ('mastercard', 'Mastercard'),
    )

    id              = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wallet          = models.ForeignKey(Wallet, on_delete=models.CASCADE, related_name='saved_cards')
    card_type       = models.CharField(max_length=20, choices=CARD_TYPES, default='visa')
    cardholder_name = models.CharField(max_length=100)
    last4           = models.CharField(max_length=4)
    expiry          = models.CharField(max_length=7)  # MM/YY
    is_default      = models.BooleanField(default=False)
    created_at      = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-is_default', '-created_at']

    def __str__(self):
        return f"{self.card_type.upper()} •••• {self.last4}"


# ─────────────────────────────────────────────
#  Notification
# ─────────────────────────────────────────────
class Notification(models.Model):
    NOTIF_TYPES = (
        ('deposit',  'Deposit'),
        ('withdraw', 'Withdraw'),
        ('payment',  'Payment'),
        ('info',     'Info'),
        ('alert',    'Alert'),
    )

    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wallet     = models.ForeignKey(Wallet, on_delete=models.CASCADE, related_name='notifications')
    notif_type = models.CharField(max_length=20, choices=NOTIF_TYPES, default='info')
    title      = models.CharField(max_length=200)
    message    = models.TextField()
    is_read    = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        indexes  = [models.Index(fields=['wallet', 'is_read'])]

    def __str__(self):
        return self.title
