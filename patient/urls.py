from django.urls import path
from . import views

app_name = 'patient'

urlpatterns = [
    path('', views.patient_dashboard, name='patient_dashboard'),
    path('edit/', views.edit_patient_profile, name='edit_patient_profile'),
    path('requests/<str:category>/<str:type>/', views.patient_requests, name='patient_requests'),
    path('book/<int:doctor_id>/', views.book_appointment, name='book_appointment'),
]