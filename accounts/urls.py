from django.urls import path
from . import views


urlpatterns = [
    path('login/', views.user_login, name='login'),
    path('verify_otp_login/', views.verify_otp_login, name='verify_otp_l'),
    path('register/', views.user_register, name='register'),
    path('verify_otp_signup/', views.verify_otp_signup, name='verify_otp_s'),
    path("doctor/registration/", views.doctor_registration, name="doctor_registration"),
    path("patient/registration/", views.patient_registration, name="patient_registration"),
    path("nurse/registration/", views.nurse_registration, name="nurse_registration"),
    path("pharmacist/registration/", views.pharmacist_registration, name="pharmacist_registration"),
    path("donor/registration/", views.donor_registration, name="donor_registration"),
    path("doctor_registration_s2/", views.doctor_registration_s2, name="doctor_registration_s2"),
    path("nurse_registration_s2/", views.nurse_registration_s2, name="nurse_registration_s2"),
    path("pharmacist_registration_s2/", views.pharmacist_registration_s2, name="pharmacist_registration_s2"),

]
