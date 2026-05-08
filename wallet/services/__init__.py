# wallet/services — business logic package
# Import the most-used functions for convenience

from .wallet_service import (
    process_deposit,
    process_withdraw,
    charge_wallet,
    refund_wallet,
    transfer_between_wallets,
    create_deposit_request,
    approve_deposit_request,
    reject_deposit_request,
    create_withdraw_request,
    approve_withdraw_request,
    reject_withdraw_request,
    reconcile_wallet_balance,
)

from .payment_service import (
    fake_deposit,
    fake_withdraw,
)

from .notification_service import (
    create_notification,
    send_wallet_notification,
    notify_deposit_success,
    notify_withdraw_success,
    notify_payment_deducted,
    notify_refund_received,
    notify_deposit_rejected,
    notify_withdraw_rejected,
    notify_welcome,
)

from .analytics_service import (
    get_dashboard_summary,
    get_monthly_summary,
    get_monthly_deposits,
    get_monthly_spending,
    get_weekly_stats,
    get_recent_activity,
    get_provider_earnings,
)

from .provider_visibility_service import (
    can_view_doctor,
    can_view_nurse,
    filter_visible_doctors,
    filter_visible_nurses,
    get_provider_visibility_status,
    on_payment_success,
    on_payment_failed,
)
