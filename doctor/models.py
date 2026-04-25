from django.db import models
from accounts.models import Patient, Doctor, GOVERNORATES,Donor

STATUS = (

    ("pending", "Pending"),
    ("accepted", "Accepted"),
    ("rejected", "Rejected"),
    ("completed", "Completed"),
    ("edited", "Edited"),
)

class DoctorRequest(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.SET_NULL, null=True, related_name='doctor_requests')
    donor = models.ForeignKey(Donor, on_delete=models.SET_NULL, null=True, related_name='doctor_requests')
    doctor = models.ForeignKey(Doctor, on_delete=models.SET_NULL, null=True, related_name='doctor_requests')
    date = models.DateTimeField()
    time = models.TimeField()
    total_price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    net_income = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    disease_description = models.TextField()
    governorate = models.CharField(max_length=50, choices=GOVERNORATES)
    address = models.TextField()
    status = models.CharField(max_length=10, choices=STATUS, default="pending")
    patient_done = models.BooleanField(default=False)
    doctor_done = models.BooleanField(default=False)

    @property
    def requester(self):
        """Returns the patient or donor who made this request."""
        return self.patient or self.donor

    @property
    def requester_name(self):
        r = self.requester
        if r is None:
            return "Unknown"
        return f"{r.user.first_name} {r.user.last_name}"

    @property
    def requester_phone(self):
        r = self.requester
        return r.phone_number if r else ""

    @property
    def is_donor(self):
        return self.donor is not None and self.patient is None
