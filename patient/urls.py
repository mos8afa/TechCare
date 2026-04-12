from django.urls import path
from . import views

app_name = 'patient'

urlpatterns = [
    path('', views.patient_dashboard, name='patient_dashboard'),
    path('edit/', views.edit_patient_profile, name='edit_patient_profile'),
    path('requests/<str:category>/<str:type>/', views.patient_requests, name='patient_requests'),
    path('book/<int:doctor_id>/', views.book_appointment, name='book_appointment'),
    path('request/<int:request_id>/cancel/', views.cancel_request, name='cancel_request'),
    path('request/<int:request_id>/accept/', views.accept_reschedule, name='accept_reschedule'),
    path('request/<int:request_id>/done/', views.mark_done, name='mark_done'),
]