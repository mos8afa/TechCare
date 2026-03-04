from django.urls import path
from . import views

app_name = 'doctor'

urlpatterns = [
    path('<slug:slug>', views.doctor_dashboard, name='doctor_dashboard'),
    path('<slug:slug>/edit/', views.edit_doctor_profile, name='edit_doctor_profile'),
    path('<slug:slug>/<str:type>/', views.doctor_requests, name='doctor_requests'),
]