from api.views import (
    login, Verify_OTP_login, register, verify_OTP_register,
    patient_register, doctor_register, nurse_register, donor_register,
    pharmacist_register, forget_password, verify_OTP_forget_password,
    reset_password, resend_otp,
)
from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views_2

urlpatterns = [
    # ── AUTH ──────────────────────────────────────────────────────────────────
    path('auth/login/',                                    login,                        name='login'),
    path('auth/verify-otp-login/',                         Verify_OTP_login,             name='verify_otp_login'),
    path('auth/register/',                                 register,                     name='register'),
    path('auth/verify-otp-register/<str:user_id>/',        verify_OTP_register,          name='verify_otp_register'),
    path('token/refresh/',                                 TokenRefreshView.as_view(),   name='token_refresh'),
    path('auth/patient/',                                  patient_register,             name='patient_register'),
    path('auth/doctor/',                                   doctor_register,              name='doctor_register'),
    path('auth/nurse/',                                    nurse_register,               name='nurse_register'),
    path('auth/donor/',                                    donor_register,               name='donor_register'),
    path('auth/pharmacist/',                               pharmacist_register,          name='pharmacist_register'),
    path('auth/forget-password/',                          forget_password,              name='forget_password'),
    path('auth/verify-otp-forget-password/',               verify_OTP_forget_password,   name='verify_otp_forget_password'),
    path('auth/reset-password/',                           reset_password,               name='reset_password'),
    path('auth/resend-otp/',                               resend_otp,                   name='resend_otp'),
    path('auth/user-role/',                                views_2.get_user_role,        name='get_user_role'),

    # ── DOCTOR ────────────────────────────────────────────────────────────────
    path('dashboard/doctor/',                              views_2.doctor_dashboard,         name='doctor_dashboard'),
    path('doctor/profile/edit/',                           views_2.edit_doctor_profile,      name='edit_doctor_profile'),

    path('doctor/requests/<str:type>/',                    views_2.doctor_requests,          name='doctor_requests'),
    path('doctor/requests/action/<int:request_id>/',       views_2.request_action,           name='doctor_request_action'),
    path('doctor/requests/done/<int:request_id>/',         views_2.mark_done_doctor,         name='mark_done_doctor'),

    path('doctor/slots/',                                  views_2.get_time_slots,           name='doctor_get_time_slots'),
    path('doctor/slots/save/',                             views_2.save_time_slots,          name='doctor_save_time_slots'),
    path('doctor/slots/<int:slot_id>/delete/',             views_2.delete_time_slot,         name='doctor_delete_time_slot'),

    # ── NURSE ─────────────────────────────────────────────────────────────────
    path('dashboard/nurse/',                               views_2.nurse_dashboard,          name='nurse_dashboard'),
    path('nurse/profile/edit/',                            views_2.edit_nurse_profile,       name='edit_nurse_profile'),

    path('nurse/requests/<str:type>/',                     views_2.nurse_requests,           name='nurse_requests'),
    path('nurse/requests/action/<int:request_id>/',        views_2.nurse_request_action,     name='nurse_request_action'),  
    path('nurse/requests/done/<int:request_id>/',          views_2.nurse_mark_done,          name='nurse_mark_done'),     

    path('nurse/slots/',                        views_2.get_nurse_time_slots,    name='nurse_get_time_slots'),
    path('nurse/slots/save/',                   views_2.save_nurse_time_slots,   name='nurse_save_time_slots'),
    path('nurse/slots/<int:slot_id>/delete/',   views_2.delete_nurse_time_slot,  name='nurse_delete_time_slot'),

    path('services/add/',                                  views_2.add_service,              name='add_service'),
    path('services/<int:service_id>/edit/',                views_2.edit_service,             name='edit_service'),
    path('services/<int:service_id>/delete/',              views_2.delete_service,           name='delete_service'),

    # ── PATIENT ───────────────────────────────────────────────────────────────
    path('dashboard/patient/',                             views_2.patient_dashboard,        name='patient_dashboard'),
    path('patient/profile/edit/',                          views_2.edit_patient_profile,     name='edit_patient_profile'),

    path('patient/requests/<str:category>/<str:type>/',    views_2.patient_requests,         name='patient_requests'),

    path('doctor/<int:doctor_id>/book/',                   views_2.book_appointment,         name='book_appointment'),
    path('doctor/cancel/<int:request_id>/',                views_2.cancel_request,           name='cancel_request'),
    path('doctor/reschedule/<int:request_id>/',            views_2.accept_reschedule,        name='accept_reschedule'),
    path('doctor/done/<int:request_id>/',                  views_2.mark_done,                name='mark_done'),

    path('nurse/<int:nurse_id>/book/',                     views_2.book_nurse,               name='book_nurse'),
    path('nurse/cancel/<int:request_id>/',                 views_2.cancel_nurse_request,     name='cancel_nurse_request'),
    path('nurse/reschedule/<int:request_id>/',             views_2.accept_nurse_reschedule,  name='accept_nurse_reschedule'),
    path('nurse/done/<int:request_id>/',                   views_2.mark_nurse_done,          name='mark_nurse_done'),
]