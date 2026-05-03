from django.urls import path
from . import views

app_name = 'doctor'

urlpatterns = [
    path('', views.doctor_dashboard, name='doctor_dashboard'),
    path('edit/', views.edit_doctor_profile, name='edit_doctor_profile'),
    path('slots', views.edit_time_slots, name='edit_time_slots'),
    path('slots/save', views.save_time_slots, name='save_time_slots'),
    path('request/<int:request_id>/action/', views.request_action, name='request_action'),
    path('request/<int:request_id>/done/', views.mark_done_doctor, name='mark_done_doctor'),
    path('blood/request/create/', views.create_blood_request, name='create_blood_request'),
    path('blood/request/<int:request_id>/offers/', views.request_offers, name='request_offers'),
    path('blood/request/<int:request_id>/cancel/', views.cancel_blood_request, name='cancel_blood_request'),
    path('blood/offer/<int:offer_id>/accept/', views.accept_offer, name='accept_offer'),
    path('blood/offer/<int:offer_id>/requester-done/', views.requester_mark_done, name='requester_done'),
    path('blood/request/my/accepted/', views.my_blood_requests_accepted, name='my_blood_requests_accepted'),
    path('blood/request/my/done/', views.my_blood_requests_done, name='my_blood_requests_done'),
    path('blood/request/my/pending/', views.my_blood_requests_pending, name='my_blood_requests_pending'),
    path('<str:type>/', views.doctor_requests, name='doctor_requests'),
]