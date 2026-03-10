from api.views import login, Verify_OTP_login, register, verify_OTP_register, patient_register, doctor_register, nurse_register
from django.urls import path
from rest_framework_simplejwt.views import (
    TokenRefreshView,
)

urlpatterns = [
    path('auth/login/', login, name='login'),
    path('auth/verify-otp-login/', Verify_OTP_login, name='verify_otp_login'),
    path('auth/register/', register, name='register'),
    path('auth/verify-otp-register/<str:user_id>/', verify_OTP_register, name='verify_otp_register'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/patient/', patient_register, name='patient_register'),
    path('auth/doctor/', doctor_register, name='doctor_register'),
    path('auth/nurse/', nurse_register, name='nurse_register'),
]

