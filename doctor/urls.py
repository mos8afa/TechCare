from django.urls import path
from . import views

app_name = 'doctor'

urlpatterns = [
    path('<slug:slug>', views.doctor_dashboard, name='doctor_dashboard'),
]