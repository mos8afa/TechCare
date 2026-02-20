from django.urls import path
from . import views


urlpatterns = [
    path('login/', views.user_login, name='login'),
    path('verify/otp/login/', views.verify_otp_login, name='verify_otp_l'),
    path('register/', views.user_register, name='register'),
    path('verify/otp/signup/', views.verify_otp_signup, name='verify_otp_s'),
    path("doctor/registration/", views.doctor_registration, name="doctor_registration"),
    path("patient/registration/", views.patient_registration, name="patient_registration"),
    path("nurse/registration/", views.nurse_registration_step1, name="nurse_registration"),
    path("pharmacist/registration/", views.pharmacist_registration_step1, name="pharmacist_registration"),
    path("donor/registration/", views.donor_registration, name="donor_registration"),
    path("doctor/registration/s2/", views.doctor_registration_s2, name="doctor_registration_s2"),
    path("nurse/registration/s2/", views.nurse_registration_step2, name="nurse_registration_s2"),
    path("pharmacist/registration/s2/", views.pharmacist_registration_step2, name="pharmacist_registration_s2"),
    path("verify/otp/faild", views.verify_otp_faild, name="verify_otp_faild")

]
