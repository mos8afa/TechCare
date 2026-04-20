from django.apps import AppConfig
import os
import threading

class DoctorConfig(AppConfig):
    name = 'doctor'

    def ready(self):
        if os.environ.get('RUN_MAIN') != 'true':
            return

        from .tasks import start_auto_reject
        threading.Thread(target=start_auto_reject, daemon=True).start()