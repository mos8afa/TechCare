from django.urls import path
from . import views

app_name = 'donor'

urlpatterns = [
    path('', views.donor_dashboard, name='donor_dashboard'),
    path('edit/', views.edit_donor_profile, name='edit_donor_profile'),
    path('requests/<str:category>/<str:type>/', views.donor_requests, name='donor_requests'),
    # doctor
    path('book-doctor/<int:doctor_id>/', views.book_doctor, name='book_doctor'),
    path('request/<int:request_id>/cancel/', views.cancel_doctor_request, name='cancel_doctor_request'),
    path('request/<int:request_id>/accept/', views.accept_doctor_reschedule, name='accept_doctor_reschedule'),
    path('request/<int:request_id>/done/', views.mark_doctor_done, name='mark_doctor_done'),
    # nurse
    path('book-nurse/<int:nurse_id>/', views.book_nurse, name='book_nurse'),
    path('nurse-request/<int:request_id>/cancel/', views.cancel_nurse_request, name='cancel_nurse_request'),
    path('nurse-request/<int:request_id>/accept/', views.accept_nurse_reschedule, name='accept_nurse_reschedule'),
    path('nurse-request/<int:request_id>/done/', views.mark_nurse_done, name='mark_nurse_done'),
]
