"""
Shared utility for blood donation request creation rules.

A user can only create a new blood request if their latest active request
meets at least one of these conditions:

1. Created more than 1 hour ago with ZERO offers (no one responded)
2. Status is 'completed' (done)
3. Has offers but was created more than 3 hours ago with no accepted offer
   (offers exist but requester never accepted any of them)
"""

from django.utils import timezone
from datetime import timedelta


def can_create_blood_request(user):
    """
    Returns (allowed: bool, blocking_request: BloodDonationRequest | None)
    If allowed is False, blocking_request is the request preventing creation.
    """
    from donor.models import BloodDonationRequest

    # Get the most recent non-cancelled request
    latest = BloodDonationRequest.objects.filter(
        requester=user
    ).exclude(status='cancelled').order_by('-created_at').first()

    # No previous request → always allowed
    if not latest:
        return True, None

    # Condition 2: already completed → allowed
    if latest.status == 'completed':
        return True, None

    now = timezone.now()
    age = now - latest.created_at
    offer_count = latest.offers.count()
    accepted_count = latest.offers.filter(status='accepted').count()

    # Condition 1: older than 1 hour with zero offers → allowed (expired with no interest)
    if age > timedelta(hours=1) and offer_count == 0:
        # Auto-cancel the stale request
        latest.status = 'cancelled'
        latest.save()
        return True, None

    # Condition 3: has offers but older than 3 hours with no accepted offer → allowed
    if offer_count > 0 and accepted_count == 0 and age > timedelta(hours=3):
        # Auto-cancel the stale request
        latest.status = 'cancelled'
        latest.save()
        return True, None

    # None of the conditions met → blocked
    return False, latest
