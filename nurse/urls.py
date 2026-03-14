from django.urls import path
from . import views

app_name = 'nurse'

urlpatterns = [
    path('edit/', views.edit_nurse_profile, name='edit_nurse_profile'),
    path('<str:type>/', views.nurse_requests, name='nurse_requests'),
    path('', views.nurse_dashboard, name='nurse_dashboard'),
]