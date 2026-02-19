import random
from rest_framework.response import Response
from rest_framework.decorators import api_view 
from django.contrib.auth import authenticate, get_user_model
from django.core.cache import cache
from django.core.mail import send_mail
from project.settings import EMAIL_HOST_USER
from rest_framework_simplejwt.tokens import RefreshToken


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


User = get_user_model

@api_view(['POST'])
def VerifyOTP(request):
    username = request.data.get('username')
    otp = request.data.get('otp')

    user = User.objects.filter(username=username)

    if not user:
        return Response({"error": "User not found"}, status=404)
    
    saved_otp = cache.get(f"otp_{user.id}")

    if not saved_otp:
        return Response({"error":"OTP expired"},status=400)
    
    if str(saved_otp) != str(otp):
        return Response({"error":"Invalid OTP"},status=400)
    
    cache.delete(f"otp_{user.id}")

    refresh = RefreshToken.for_user(user)

    return Response({
        "access":str(refresh.access_token),
        "refresh":str(refresh)
    })


@api_view(['POST'])
def Register():
    pass
