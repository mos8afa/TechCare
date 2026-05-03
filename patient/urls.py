from django.urls import path
from . import views

app_name = 'patient'

urlpatterns = [
    path('', views.patient_dashboard, name='patient_dashboard'),
    path('edit/', views.edit_patient_profile, name='edit_patient_profile'),
    path('requests/<str:category>/<str:type>/', views.patient_requests, name='patient_requests'),
    # doctor
    path('book/<int:doctor_id>/', views.book_appointment, name='book_appointment'),
    path('request/<int:request_id>/cancel/', views.cancel_request, name='cancel_request'),
    path('request/<int:request_id>/accept/', views.accept_reschedule, name='accept_reschedule'),
    path('request/<int:request_id>/done/', views.mark_done, name='mark_done'),
    path('request/<int:request_id>/accept-done/', views.accept_reschedule, name='accept_reschedule'),
    # nurse
    path('book-nurse/<int:nurse_id>/', views.book_nurse, name='book_nurse'),
    path('nurse-request/<int:request_id>/cancel/', views.cancel_nurse_request, name='cancel_nurse_request'),
    path('nurse-request/<int:request_id>/accept/', views.accept_nurse_reschedule, name='accept_nurse_reschedule'),
    path('nurse-request/<int:request_id>/done/', views.mark_nurse_done, name='mark_nurse_done'),
    path('blood/request/create/', views.create_blood_request, name='create_blood_request'),
    path('blood/request/<int:request_id>/offers/', views.request_offers, name='request_offers'),
    path('blood/request/<int:request_id>/cancel/', views.cancel_blood_request, name='cancel_blood_request'),
    path('blood/offer/<int:offer_id>/accept/', views.accept_offer, name='accept_offer'),
    path('blood/offer/<int:offer_id>/requester-done/', views.requester_mark_done, name='requester_done'),
    path('blood/request/my/accepted/', views.my_blood_requests_accepted, name='my_blood_requests_accepted'),
    path('blood/request/my/done/', views.my_blood_requests_done, name='my_blood_requests_done'),
]
