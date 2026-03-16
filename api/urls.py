from api.views import login, Verify_OTP_login, register, verify_OTP_register, patient_register, doctor_register, nurse_register, forget_password, verify_OTP_forget_password, reset_password , resend_otp
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
    path('auth/forget-password/', forget_password, name='forget_password'),
    path('auth/verify-otp-forget-password/', verify_OTP_forget_password, name='verify_otp_forget_password'),
    path('auth/reset-password/', reset_password, name='reset_password'),
    path('auth/resend-otp/', resend_otp, name='resend_otp'),
]

