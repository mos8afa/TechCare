import time
from django.utils import timezone
from .models import DoctorRequest

def auto_reject():
    now = timezone.now()
    appointments = DoctorRequest.objects.filter(status='pending')

    for appointment in appointments:
        if appointment.date < now.date() or (
            appointment.date == now.date() and appointment.time < now.time()
        ):
            appointment.status = 'rejected'
            appointment.save()

def start_auto_reject():
    while True:
        auto_reject()
        time.sleep(60)  