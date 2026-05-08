from django.contrib import admin
from .models import (
    DepositRequest, LedgerEntry, Notification, SavedCard,
    Transaction, Wallet, WalletSnapshot, WithdrawRequest,
)
from .services import (
    approve_deposit_request, approve_withdraw_request,
    reject_deposit_request, reject_withdraw_request,
    reconcile_wallet_balance,
)


# ─────────────────────────────────────────────
#  Inline: Transactions inside Wallet
# ─────────────────────────────────────────────
class TransactionInline(admin.TabularInline):
    model = Transaction
    extra = 0
    readonly_fields = ('id', 'transaction_type', 'amount', 'description', 'reference', 'status', 'created_at')
    can_delete = False


class SavedCardInline(admin.TabularInline):
    model = SavedCard
    extra = 0


# ─────────────────────────────────────────────
#  Wallet Admin
# ─────────────────────────────────────────────
@admin.register(Wallet)
class WalletAdmin(admin.ModelAdmin):
    list_display = ('user', 'balance', 'is_active', 'created_at')
    list_filter = ('is_active',)
    search_fields = ('user__username', 'user__email')
    readonly_fields = ('id', 'created_at', 'updated_at')
    inlines = [TransactionInline, SavedCardInline]


# ─────────────────────────────────────────────
#  Transaction Admin
# ─────────────────────────────────────────────
@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('wallet', 'transaction_type', 'amount', 'status', 'created_at')
    list_filter = ('transaction_type', 'status')
    search_fields = ('wallet__user__username', 'description', 'reference')
    readonly_fields = ('id', 'created_at')


# ─────────────────────────────────────────────
#  Deposit Request Admin
# ─────────────────────────────────────────────
def action_approve_deposit(modeladmin, request, queryset):
    for dep in queryset.filter(status='pending'):
        try:
            approve_deposit_request(dep)
        except ValueError:
            pass
action_approve_deposit.short_description = "Approve selected deposit requests"


def action_reject_deposit(modeladmin, request, queryset):
    for dep in queryset.filter(status='pending'):
        reject_deposit_request(dep, notes='Rejected by admin')
action_reject_deposit.short_description = "Reject selected deposit requests"


@admin.register(DepositRequest)
class DepositRequestAdmin(admin.ModelAdmin):
    list_display = ('wallet', 'amount', 'card_type', 'card_last4', 'status', 'created_at')
    list_filter = ('status', 'card_type')
    search_fields = ('wallet__user__username', 'cardholder_name')
    readonly_fields = ('id', 'created_at', 'processed_at')
    actions = [action_approve_deposit, action_reject_deposit]


# ─────────────────────────────────────────────
#  Withdraw Request Admin
# ─────────────────────────────────────────────
def action_approve_withdraw(modeladmin, request, queryset):
    for wr in queryset.filter(status='pending'):
        try:
            approve_withdraw_request(wr)
        except ValueError:
            pass
action_approve_withdraw.short_description = "Approve selected withdrawal requests"


def action_reject_withdraw(modeladmin, request, queryset):
    for wr in queryset.filter(status='pending'):
        reject_withdraw_request(wr, notes='Rejected by admin')
action_reject_withdraw.short_description = "Reject selected withdrawal requests"


@admin.register(WithdrawRequest)
class WithdrawRequestAdmin(admin.ModelAdmin):
    list_display = ('wallet', 'amount', 'bank_name', 'account_holder', 'status', 'created_at')
    list_filter = ('status',)
    search_fields = ('wallet__user__username', 'account_holder', 'bank_name')
    readonly_fields = ('id', 'created_at', 'processed_at')
    actions = [action_approve_withdraw, action_reject_withdraw]


# ─────────────────────────────────────────────
#  Notification Admin
# ─────────────────────────────────────────────
@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('wallet', 'notif_type', 'title', 'is_read', 'created_at')
    list_filter = ('notif_type', 'is_read')
    search_fields = ('wallet__user__username', 'title')
    readonly_fields = ('id', 'created_at')


# ─────────────────────────────────────────────
#  Saved Card Admin
# ─────────────────────────────────────────────
@admin.register(SavedCard)
class SavedCardAdmin(admin.ModelAdmin):
    list_display = ('wallet', 'card_type', 'last4', 'cardholder_name', 'is_default')
    list_filter = ('card_type', 'is_default')
    search_fields = ('wallet__user__username', 'cardholder_name')


# ─────────────────────────────────────────────
#  LedgerEntry Admin  (read-only — immutable)
# ─────────────────────────────────────────────
@admin.register(LedgerEntry)
class LedgerEntryAdmin(admin.ModelAdmin):
    list_display    = ("wallet", "entry_type", "amount", "balance_before", "balance_after", "created_at")
    list_filter     = ("entry_type",)
    search_fields   = ("wallet__user__username", "reference", "description")
    readonly_fields = ("id", "wallet", "transaction", "entry_type", "amount",
                       "balance_before", "balance_after", "description", "reference", "created_at")

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False


# ─────────────────────────────────────────────
#  WalletSnapshot Admin
# ─────────────────────────────────────────────
@admin.register(WalletSnapshot)
class WalletSnapshotAdmin(admin.ModelAdmin):
    list_display    = ("wallet", "balance", "snapshot_date", "created_at")
    list_filter     = ("snapshot_date",)
    search_fields   = ("wallet__user__username",)
    readonly_fields = ("id", "created_at")
