from decimal import Decimal
from rest_framework import serializers

from .models import (
    Wallet, Transaction, LedgerEntry,
    DepositRequest, WithdrawRequest,
    SavedCard, Notification,
)
from .constants import (
    MIN_DEPOSIT_AMOUNT, MAX_DEPOSIT_AMOUNT,
    MIN_WITHDRAW_AMOUNT, MAX_WITHDRAW_AMOUNT,
)


# ─────────────────────────────────────────────
#  Wallet
# ─────────────────────────────────────────────

class WalletSerializer(serializers.ModelSerializer):
    username          = serializers.CharField(source='user.username', read_only=True)
    role              = serializers.CharField(source='user.role',     read_only=True)
    total_deposits    = serializers.DecimalField(max_digits=12, decimal_places=2, read_only=True)
    total_withdrawals = serializers.DecimalField(max_digits=12, decimal_places=2, read_only=True)
    total_spent       = serializers.DecimalField(max_digits=12, decimal_places=2, read_only=True)
    total_fees        = serializers.DecimalField(max_digits=12, decimal_places=2, read_only=True)

    class Meta:
        model  = Wallet
        fields = [
            'id', 'username', 'role', 'balance', 'is_active',
            'total_deposits', 'total_withdrawals', 'total_spent', 'total_fees',
            'created_at', 'updated_at',
        ]
        read_only_fields = fields


# ─────────────────────────────────────────────
#  Transaction
# ─────────────────────────────────────────────

class TransactionSerializer(serializers.ModelSerializer):
    is_credit     = serializers.BooleanField(read_only=True)
    signed_amount = serializers.DecimalField(max_digits=12, decimal_places=2, read_only=True)
    type_display  = serializers.CharField(source='get_transaction_type_display', read_only=True)
    status_display= serializers.CharField(source='get_status_display',           read_only=True)

    class Meta:
        model  = Transaction
        fields = [
            'id', 'transaction_type', 'type_display',
            'amount', 'signed_amount', 'is_credit',
            'description', 'reference',
            'status', 'status_display',
            'created_at',
        ]
        read_only_fields = fields


# ─────────────────────────────────────────────
#  LedgerEntry  (read-only — immutable)
# ─────────────────────────────────────────────

class LedgerEntrySerializer(serializers.ModelSerializer):
    entry_type_display = serializers.CharField(source='get_entry_type_display', read_only=True)
    net_change = serializers.SerializerMethodField()

    class Meta:
        model  = LedgerEntry
        fields = [
            'id', 'entry_type', 'entry_type_display',
            'amount', 'net_change',
            'balance_before', 'balance_after',
            'description', 'reference',
            'created_at',
        ]
        read_only_fields = fields

    def get_net_change(self, obj) -> Decimal:
        """Positive for credits/refunds, negative for debits/fees/transfers."""
        if obj.entry_type in ('credit', 'refund'):
            return obj.amount
        return -obj.amount


# ─────────────────────────────────────────────
#  DepositRequest
# ─────────────────────────────────────────────

class DepositRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model  = DepositRequest
        fields = [
            'id', 'amount', 'cardholder_name', 'card_last4',
            'card_type', 'status', 'notes',
            'created_at', 'processed_at',
        ]
        read_only_fields = ['id', 'status', 'notes', 'created_at', 'processed_at']

    def validate_amount(self, value):
        if value < MIN_DEPOSIT_AMOUNT:
            raise serializers.ValidationError(
                f"Minimum deposit is {MIN_DEPOSIT_AMOUNT:.2f} EGP."
            )
        if value > MAX_DEPOSIT_AMOUNT:
            raise serializers.ValidationError(
                f"Maximum deposit is {MAX_DEPOSIT_AMOUNT:.2f} EGP."
            )
        return value


# ─────────────────────────────────────────────
#  WithdrawRequest
# ─────────────────────────────────────────────

class WithdrawRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model  = WithdrawRequest
        fields = [
            'id', 'amount', 'bank_name', 'account_number',
            'account_holder', 'status', 'notes',
            'created_at', 'processed_at',
        ]
        read_only_fields = ['id', 'status', 'notes', 'created_at', 'processed_at']

    def validate_amount(self, value):
        if value < MIN_WITHDRAW_AMOUNT:
            raise serializers.ValidationError(
                f"Minimum withdrawal is {MIN_WITHDRAW_AMOUNT:.2f} EGP."
            )
        if value > MAX_WITHDRAW_AMOUNT:
            raise serializers.ValidationError(
                f"Maximum withdrawal is {MAX_WITHDRAW_AMOUNT:.2f} EGP."
            )
        return value


# ─────────────────────────────────────────────
#  SavedCard
# ─────────────────────────────────────────────

class SavedCardSerializer(serializers.ModelSerializer):
    class Meta:
        model  = SavedCard
        fields = ['id', 'card_type', 'cardholder_name', 'last4', 'expiry', 'is_default', 'created_at']
        read_only_fields = ['id', 'created_at']

    def validate_last4(self, value):
        if not value.isdigit() or len(value) != 4:
            raise serializers.ValidationError("last4 must be exactly 4 digits.")
        return value

    def validate_expiry(self, value):
        import re
        if not re.match(r'^\d{2}/\d{2}$', value):
            raise serializers.ValidationError("Expiry must be in MM/YY format.")
        return value


# ─────────────────────────────────────────────
#  Notification
# ─────────────────────────────────────────────

class NotificationSerializer(serializers.ModelSerializer):
    type_display = serializers.CharField(source='get_notif_type_display', read_only=True)

    class Meta:
        model  = Notification
        fields = ['id', 'notif_type', 'type_display', 'title', 'message', 'is_read', 'created_at']
        read_only_fields = ['id', 'notif_type', 'title', 'message', 'created_at']


# ─────────────────────────────────────────────
#  Analytics (for API documentation)
# ─────────────────────────────────────────────

class MonthlyDataPointSerializer(serializers.Serializer):
    year   = serializers.IntegerField()
    month  = serializers.IntegerField()
    label  = serializers.CharField()
    amount = serializers.DecimalField(max_digits=12, decimal_places=2)


class AnalyticsSummarySerializer(serializers.Serializer):
    balance           = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_deposits    = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_withdrawals = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_spent       = serializers.DecimalField(max_digits=12, decimal_places=2)
    month_deposits    = serializers.DecimalField(max_digits=12, decimal_places=2)
    month_payments    = serializers.DecimalField(max_digits=12, decimal_places=2)
    month_net         = serializers.DecimalField(max_digits=12, decimal_places=2)
    last_30_tx_count  = serializers.IntegerField()
    last_30_spent     = serializers.DecimalField(max_digits=12, decimal_places=2)
    monthly_deposits  = MonthlyDataPointSerializer(many=True)
    monthly_spending  = MonthlyDataPointSerializer(many=True)
