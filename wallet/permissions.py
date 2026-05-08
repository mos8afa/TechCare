from rest_framework.permissions import BasePermission


class IsWalletOwner(BasePermission):
    message = "You do not have permission to access this wallet."

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated)

    def has_object_permission(self, request, view, obj):
        # obj can be Wallet, Transaction, LedgerEntry, etc.
        wallet = getattr(obj, 'wallet', obj)
        return wallet.user == request.user


class IsProvider(BasePermission):
    message = "This endpoint is only available to doctors and nurses."

    def has_permission(self, request, view):
        if not (request.user and request.user.is_authenticated):
            return False
        return getattr(request.user, 'role', '') in ('doctor', 'nurse')


class IsConsumer(BasePermission):
    message = "This endpoint is only available to patients and donors."

    def has_permission(self, request, view):
        if not (request.user and request.user.is_authenticated):
            return False
        return getattr(request.user, 'role', '') in ('patient', 'donor')


class IsWalletActive(BasePermission):
    message = "Your wallet has been deactivated. Please contact support."

    def has_permission(self, request, view):
        if not (request.user and request.user.is_authenticated):
            return False
        try:
            return request.user.wallet.is_active
        except Exception:
            return True  # wallet doesn't exist yet — allow creation
