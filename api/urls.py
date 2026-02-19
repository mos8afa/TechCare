from api.views import Login, VerifyOTP, Register
from django.urls import path
from rest_framework_simplejwt.views import (
    TokenRefreshView,
)


urlpatterns = [
    path('auth/login/', Login, name='login'),
    path('auth/verify-otp/', VerifyOTP, name='verify_otp'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/register/', Register,name='register'),
]

