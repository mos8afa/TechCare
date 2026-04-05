from api.views import delete_time_slot, doctor_dashboard, doctor_requests, edit_time_slots, login, Verify_OTP_login, register, verify_OTP_register, patient_register, doctor_register, nurse_register, donor_register, pharmacist_register , forget_password, verify_OTP_forget_password, reset_password, resend_otp, edit_doctor_profile
from django.urls import path
from rest_framework_simplejwt.views import (
    TokenRefreshView,
)

from doctor import views

urlpatterns = [
    path('auth/login/', login, name='login'),
    path('auth/verify-otp-login/', Verify_OTP_login, name='verify_otp_login'),
    path('auth/register/', register, name='register'),
    path('auth/verify-otp-register/<str:user_id>/',verify_OTP_register, name='verify_otp_register'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/patient/', patient_register, name='patient_register'),
    path('auth/doctor/', doctor_register, name='doctor_register'),
    path('auth/nurse/', nurse_register, name='nurse_register'),
    path('auth/donor/', donor_register, name='donor_register'),
    path('auth/pharmacist/', pharmacist_register, name='pharmacist_register'),
    path('auth/forget-password/', forget_password, name='forget_password'),
    path('auth/verify-otp-forget-password/',verify_OTP_forget_password, name='verify_otp_forget_password'),
    path('auth/reset-password/', reset_password, name='reset_password'),
    path('auth/resend-otp/', resend_otp, name='resend_otp'),
#################################################################################################
    path('dashboard/', doctor_dashboard, name='doctor_dashboard'),
    path('profile/edit/', edit_doctor_profile, name='edit_doctor_profile'),
    path('requests/<str:type>/',doctor_requests, name='doctor_requests'),
    path('time-slots/', edit_time_slots, name='edit_time_slots'),
    path('time-slots/<int:slot_id>/delete/', delete_time_slot, name='delete_time_slot'),
]
