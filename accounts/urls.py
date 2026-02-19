from django.urls import path
from . import views


urlpatterns = [
    path('Login/', views.user_login, name='login'),
    path('verify_otp/', views.verify_otp, name='verify_otp'),
]
