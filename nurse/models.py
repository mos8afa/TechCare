from django.db import models
from accounts.models import Patient, Nurse, GOVERNORATES

STATUS = (
    ("pending", "Pending"),
    ("accepted", "Accepted"),
    ("rejected", "Rejected"),
    ("completed", "Completed"),
)

class NurseRequest(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.SET_DEFAULT, related_name='nurse_requests', default='anonymous patient')
    nurse = models.ForeignKey(Nurse, on_delete=models.SET_DEFAULT, related_name='nurse_requests', default='anonymous nurse')
    date = models.DateTimeField()
    time = models.TimeField()
    governrate = models.CharField(max_length=50, choices=GOVERNORATES)
    address = models.TextField()
    disease_description = models.TextField()
    Service = models.ManyToManyField(Service)
    net_income = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    status = models.CharField(max_length=10, choices=STATUS, default="pending")

class Service(models.Model):
    name = models.CharField(max_length=150)
    description = models.TextField()
    price = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    nurse = models.ForeignKey(Nurse, on_delete=models.CASCADE, related_name='nurse_services')