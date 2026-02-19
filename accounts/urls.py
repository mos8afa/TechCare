from django.urls import path
from . import views


urlpatterns = [
    path('Login/', views.login, name='login'),
    path('verify_otp/', views.VerifyOTP, name='verify_otp'),
]
