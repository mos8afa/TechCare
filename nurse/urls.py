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
    path('<str:type>/', views.nurse_requests, name='nurse_requests'),
]
