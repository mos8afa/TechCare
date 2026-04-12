from django.urls import path
from . import views

app_name = 'nurse'

urlpatterns = [
    path('edit/', views.edit_nurse_profile, name='edit_nurse_profile'),
    path('<str:type>/', views.nurse_requests, name='nurse_requests'),
    path('', views.nurse_dashboard, name='nurse_dashboard'),
    path('add/service/',views.add_services, name='add_services'),
    path('delete-service/<int:service_id>/', views.delete_service, name='delete_service'),
    path('edit-service/<int:service_id>/', views.edit_service, name='edit_service'),
    path('edit-slots/', views.edit_time_slots, name='edit_slots'),
]