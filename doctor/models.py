from django.db import models
from accounts.models import Patient, Doctor, GOVERNORATES

STATUS = (

    ("pending", "Pending"),
    ("accepted", "Accepted"),
    ("rejected", "Rejected"),
    ("completed", "Completed"),
)

class DoctorRequest(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE)
    date = models.DateTimeField()
    time = models.TimeField()
    total_price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    disease_description = models.TextField()
    governrate = models.CharField(max_length=50, choices=GOVERNORATES)
    address = models.TextField()
    status = models.CharField(max_length=10, choices=STATUS, default="pending")
