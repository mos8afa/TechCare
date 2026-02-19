from django.urls import path
from . import views


urlpatterns = [
    path('login/', views.user_login, name='login'),
    path('verify_otp/', views.verify_otp, name='verify_otp'),
    path('register/', views.user_register, name='register'),
]
