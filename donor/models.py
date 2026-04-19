from django.db import models
from accounts.models import Donor, GOVERNORATES, BLOOD_TYPES
from django.contrib.auth import get_user_model

User = get_user_model()

REQUEST_STATUS = (
    ("open",      "Open"),       # waiting for donors to offer
    ("matched",   "Matched"),    # requester accepted a donor
    ("completed", "Completed"),  # both marked done
    ("cancelled", "Cancelled"),
)

OFFER_STATUS = (
    ("offered",   "Offered"),    # donor offered to donate
    ("accepted",  "Accepted"),   # requester accepted this donor
    ("rejected",  "Rejected"),   # requester chose another donor
    ("completed", "Completed"),  # both marked done
)


class BloodDonationRequest(models.Model):
    """Submitted by any user who needs blood."""
    requester       = models.ForeignKey(User, on_delete=models.CASCADE, related_name='blood_requests')
    blood_type      = models.CharField(max_length=3, choices=BLOOD_TYPES)
    governorate     = models.CharField(max_length=50, choices=GOVERNORATES)
    address         = models.TextField()
    medical_condition = models.TextField()
    status          = models.CharField(max_length=10, choices=REQUEST_STATUS, default='open')
    created_at      = models.DateTimeField(auto_now_add=True)
    requester_done  = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.requester.username} needs {self.blood_type} in {self.governorate}"


class DonorOffer(models.Model):
    """A donor offering to fulfill a BloodDonationRequest."""
    request     = models.ForeignKey(BloodDonationRequest, on_delete=models.CASCADE, related_name='offers')
    donor       = models.ForeignKey(Donor, on_delete=models.CASCADE, related_name='donation_offers')
    status      = models.CharField(max_length=10, choices=OFFER_STATUS, default='offered')
    created_at  = models.DateTimeField(auto_now_add=True)
    donor_done  = models.BooleanField(default=False)

    class Meta:
        unique_together = ('request', 'donor')   # one offer per donor per request

    def __str__(self):
        return f"{self.donor.user.username} → {self.request}"
