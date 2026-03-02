from django.urls import path
from . import views


urlpatterns = [
    path('int/<slug:slug>/dashboard/', views.doctor_dashboard, name='doctor_dashboard'),
]