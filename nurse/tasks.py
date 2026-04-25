import time
from django.utils import timezone
from .models import NurseRequest

def auto_reject_nurse():
    now = timezone.now()
    requests = NurseRequest.objects.filter(status='pending')

    for req in requests:
        if req.date.date() < now.date() or (
            req.date.date() == now.date() and req.time < now.time()
        ):
            req.status = 'rejected'
            req.save()

def start_auto_reject_nurse():
    while True:
        auto_reject_nurse()
        time.sleep(60)  