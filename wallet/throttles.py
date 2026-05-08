from rest_framework.throttling import UserRateThrottle, AnonRateThrottle


class DepositThrottle(UserRateThrottle):
    """Limit deposit requests to prevent abuse."""
    scope = 'wallet_deposit'
    # Override in settings: REST_FRAMEWORK['DEFAULT_THROTTLE_RATES']['wallet_deposit'] = '10/min'
    THROTTLE_RATES = {'wallet_deposit': '10/min'}


class WithdrawThrottle(UserRateThrottle):
    """Stricter limit on withdrawal requests."""
    scope = 'wallet_withdraw'
    THROTTLE_RATES = {'wallet_withdraw': '5/min'}


class WalletReadThrottle(UserRateThrottle):
    """General read throttle for wallet API."""
    scope = 'wallet_read'
    THROTTLE_RATES = {'wallet_read': '60/min'}


class WalletAnonThrottle(AnonRateThrottle):
    """Block unauthenticated requests to wallet endpoints."""
    scope = 'wallet_anon'
    THROTTLE_RATES = {'wallet_anon': '5/min'}
