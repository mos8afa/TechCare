from django.urls import path
from . import views

app_name = 'doctor'

urlpatterns = [
    path('', views.doctor_dashboard, name='doctor_dashboard'),
    path('edit/', views.edit_doctor_profile, name='edit_doctor_profile'),
    path('slots', views.edit_time_slots, name='edit_time_slots'),
    path('slots/save', views.save_time_slots, name='save_time_slots'),
    path('<str:type>/', views.doctor_requests, name='doctor_requests'),
]