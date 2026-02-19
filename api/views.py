import random
from rest_framework.response import Response
from rest_framework.decorators import api_view , permission_classes
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth import authenticate
from django.core.cache import cache
from django.core.mail import send_mail
from project.settings import EMAIL_HOST_USER


@api_view(['POST'])
def Login(request):
    username = request.data.get('username')
    password = request.data.get('password')

    user = authenticate(username=username, password=password)

    if user is None:
        return Response({"error": "Invalid credentials"}, status=401)

    otp = random.randint(10000,99999)

    cache.set(f"otp_{user.id}", otp, timeout=300)

    send_mail(
        subject = "TechCare Team",
        message = f"your verification OTP is {otp}",
        from_email = EMAIL_HOST_USER,
        recipient_list = [user.email]
    )

    return Response({"message": "OTP sent to your email"})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def VerifyOTP():
    pass



@api_view(['POST'])
@permission_classes([IsAuthenticated])
def Register():
    pass
