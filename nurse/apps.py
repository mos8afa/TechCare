from django.apps import AppConfig
import os
import threading

class NurseConfig(AppConfig):
    name = 'nurse'

    def ready(self):
        if os.environ.get('RUN_MAIN') != 'true':
            return

        from .tasks import start_auto_reject_nurse
        threading.Thread(target=start_auto_reject_nurse, daemon=True).start()