from django.urls import path
from . import views

app_name = 'doctor'

urlpatterns = [
    path('edit/', views.edit_doctor_profile, name='edit_doctor_profile'),
    path('<str:type>/', views.doctor_requests, name='doctor_requests'),
    path('', views.doctor_dashboard, name='doctor_dashboard'),
]   