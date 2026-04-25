from django.urls import path
from . import views

app_name = 'nurse'

urlpatterns = [
    path('', views.nurse_dashboard, name='nurse_dashboard'),
    path('edit/', views.edit_nurse_profile, name='edit_nurse_profile'),
    path('add/service/', views.add_services, name='add_services'),
    path('delete-service/<int:service_id>/', views.delete_service, name='delete_service'),
    path('edit-service/<int:service_id>/', views.edit_service, name='edit_service'),
    path('edit-slots/', views.edit_time_slots, name='edit_slots'),
    path('slots/save', views.save_time_slots, name='save_time_slots'),
    path('request/<int:request_id>/action/', views.request_action, name='request_action'),
    path('request/<int:request_id>/done/', views.mark_done, name='mark_done'),
    path('blood/request/create/', views.create_blood_request, name='create_blood_request'),
    path('blood/request/my/', views.my_blood_requests, name='my_blood_requests'),
    path('blood/request/<int:request_id>/offers/', views.request_offers, name='request_offers'),
    path('blood/request/<int:request_id>/cancel/', views.cancel_blood_request, name='cancel_blood_request'),
    path('blood/offer/<int:offer_id>/accept/', views.accept_offer, name='accept_offer'),
    path('blood/offer/<int:offer_id>/requester-done/', views.requester_mark_done, name='requester_done'),
    path('<str:type>/', views.nurse_requests, name='nurse_requests'),
]
