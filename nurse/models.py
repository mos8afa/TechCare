from django.db import models
from accounts.models import Patient, Nurse, GOVERNORATES, Donor

STATUS = (
    ("pending", "Pending"),
    ("accepted", "Accepted"),
    ("rejected", "Rejected"),
    ("completed", "Completed"),
    ("edited", "Edited"),
)

class Service(models.Model):
    name = models.CharField(max_length=150)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    nurse = models.ForeignKey(Nurse, on_delete=models.CASCADE, related_name='nurse_services')

class NurseRequest(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.SET_NULL, null=True, related_name='nurse_requests')
    donor = models.ForeignKey(Donor, on_delete=models.SET_NULL, null=True, related_name='nurse_requests')
    nurse = models.ForeignKey(Nurse, on_delete=models.SET_NULL, null=True, related_name='nurse_requests')
    date = models.DateTimeField()
    time = models.TimeField()
    governrate = models.CharField(max_length=50, choices=GOVERNORATES)
    address = models.TextField()
    disease_description = models.TextField()
    service = models.ManyToManyField(Service)
    net_income = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    status = models.CharField(max_length=10, choices=STATUS, default="pending")
    patient_done = models.BooleanField(default=False)
    nurse_done = models.BooleanField(default=False)

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

    @property
    def total_price(self):
        return sum(s.price for s in self.service.all())
    