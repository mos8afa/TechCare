"""
wallet/services/provider_visibility_service.py
───────────────────────────────────────────────
Business rule: providers (doctors/nurses) are only visible to patients/donors
if their wallet balance meets the minimum threshold.

RULE 1 — DOCTOR:
  doctor.wallet.balance >= 20% of doctor.price

RULE 2 — NURSE:
  nurse.wallet.balance >= 20% of nurse's highest service price

Rationale: ensures providers have skin in the game before accepting bookings.
When a real payment gateway is integrated, this threshold will be funded by
the platform commission held in escrow.

All filtering is server-side — never trust the frontend to enforce this.
"""
from decimal import Decimal
from django.db.models import Max, QuerySet

from accounts.models import Doctor, Nurse


# ─────────────────────────────────────────────
#  Constants
# ─────────────────────────────────────────────

VISIBILITY_THRESHOLD_PERCENT = Decimal('20')   # 20% of consultation price
MIN_ABSOLUTE_THRESHOLD       = Decimal('0.00') # fallback when price is 0


# ─────────────────────────────────────────────
#  Internal helpers
# ─────────────────────────────────────────────

def _get_wallet_balance(user) -> Decimal:
    """Safely return wallet balance for any user, defaulting to 0."""
    try:
        return user.wallet.balance
    except Exception:
        return Decimal('0.00')


def _doctor_threshold(doctor: Doctor) -> Decimal:
    """
    Minimum wallet balance required for a doctor to be visible.
    = 20% of their consultation price.
    """
    price = doctor.price or Decimal('0.00')
    threshold = (price * VISIBILITY_THRESHOLD_PERCENT / Decimal('100')).quantize(Decimal('0.01'))
    return max(threshold, MIN_ABSOLUTE_THRESHOLD)


def _nurse_threshold(nurse: Nurse) -> Decimal:
    """
    Minimum wallet balance required for a nurse to be visible.
    = 20% of their highest service price.
    """
    max_price = nurse.nurse_services.aggregate(max_price=Max('price'))['max_price']
    if not max_price:
        return MIN_ABSOLUTE_THRESHOLD
    threshold = (Decimal(str(max_price)) * VISIBILITY_THRESHOLD_PERCENT / Decimal('100')).quantize(Decimal('0.01'))
    return max(threshold, MIN_ABSOLUTE_THRESHOLD)


# ─────────────────────────────────────────────
#  Public API
# ─────────────────────────────────────────────

def can_view_doctor(doctor: Doctor) -> bool:
    """
    Return True if the doctor meets the wallet visibility threshold.
    Called server-side before returning doctor listings.
    """
    try:
        balance   = _get_wallet_balance(doctor.user)
        threshold = _doctor_threshold(doctor)
        return balance >= threshold
    except Exception:
        # If wallet check fails for any reason, default to visible
        # (fail-open for providers — prevents accidental lockout)
        return True


def can_view_nurse(nurse: Nurse) -> bool:
    """
    Return True if the nurse meets the wallet visibility threshold.
    """
    try:
        balance   = _get_wallet_balance(nurse.user)
        threshold = _nurse_threshold(nurse)
        return balance >= threshold
    except Exception:
        return True


def filter_visible_doctors(doctors_qs: QuerySet) -> list:
    """
    Filter a Doctor queryset to only those meeting the visibility rule.
    Returns a list (not queryset) with threshold info attached to each doctor.

    Usage:
        doctors = Doctor.objects.filter(slots__isnull=False).distinct()
        visible = filter_visible_doctors(doctors)
    """
    visible = []
    for doctor in doctors_qs.select_related('user').prefetch_related('user__wallet'):
        threshold = _doctor_threshold(doctor)
        balance   = _get_wallet_balance(doctor.user)
        if balance >= threshold:
            # Attach debug info (useful for admin views)
            doctor._visibility_threshold = threshold
            doctor._wallet_balance       = balance
            visible.append(doctor)
    return visible


def filter_visible_nurses(nurses_qs: QuerySet) -> list:
    """
    Filter a Nurse queryset to only those meeting the visibility rule.
    Returns a list with threshold info attached.
    """
    visible = []
    for nurse in nurses_qs.select_related('user').prefetch_related('user__wallet', 'nurse_services'):
        threshold = _nurse_threshold(nurse)
        balance   = _get_wallet_balance(nurse.user)
        if balance >= threshold:
            nurse._visibility_threshold = threshold
            nurse._wallet_balance       = balance
            visible.append(nurse)
    return visible


def get_provider_visibility_status(doctor: Doctor = None, nurse: Nurse = None) -> dict:
    """
    Return detailed visibility status for a single provider.
    Used by admin dashboard and provider self-check.
    """
    if doctor:
        balance   = _get_wallet_balance(doctor.user)
        threshold = _doctor_threshold(doctor)
        return {
            'provider_type': 'doctor',
            'name':          f"Dr. {doctor.user.first_name} {doctor.user.last_name}",
            'price':         doctor.price,
            'threshold':     threshold,
            'balance':       balance,
            'is_visible':    balance >= threshold,
            'shortfall':     max(threshold - balance, Decimal('0.00')),
        }
    if nurse:
        balance   = _get_wallet_balance(nurse.user)
        threshold = _nurse_threshold(nurse)
        max_price = nurse.nurse_services.aggregate(max_price=Max('price'))['max_price'] or Decimal('0.00')
        return {
            'provider_type': 'nurse',
            'name':          f"{nurse.user.first_name} {nurse.user.last_name}",
            'max_service_price': max_price,
            'threshold':     threshold,
            'balance':       balance,
            'is_visible':    balance >= threshold,
            'shortfall':     max(threshold - balance, Decimal('0.00')),
        }
    raise ValueError("Provide either doctor or nurse.")


# ─────────────────────────────────────────────
#  Payment gateway hooks (Phase 4 placeholders)
# ─────────────────────────────────────────────

def on_payment_success(provider_user, amount: Decimal, reference: str = '') -> None:
    """
    Hook called after a successful payment to/from a provider.
    TODO: When real gateway is integrated, call this from the webhook handler.

    Example usage:
        on_payment_success(doctor.user, amount=450.00, reference='booking-123')
    """
    from wallet.services.wallet_service import process_deposit
    from wallet.models import Wallet

    wallet, _ = Wallet.objects.get_or_create(user=provider_user)
    process_deposit(
        wallet=wallet,
        amount=amount,
        description=f"Consultation payment received",
        reference=reference,
        skip_validation=True,
    )


def on_payment_failed(provider_user, amount: Decimal, reason: str = '') -> None:
    """
    Hook called when a payment to a provider fails.
    TODO: Notify provider and log the failure.
    """
    from wallet.services.notification_service import send_wallet_notification
    from wallet.models import Wallet

    try:
        wallet, _ = Wallet.objects.get_or_create(user=provider_user)
        send_wallet_notification(
            wallet,
            notif_type='alert',
            title='Payment Failed',
            message=f"A payment of {amount:.2f} EGP failed. Reason: {reason or 'Unknown'}.",
        )
    except Exception:
        pass
