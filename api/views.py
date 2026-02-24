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

    otp = random.randint(100000,999999)

    cache.set(f"otp_{user.id}", otp, timeout=300)
    cache.set(f"otp_attempts_{user.id}", 0, timeout=300)

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

    user = User.objects.filter(username=username).first()

    list_otp = [
                request.data.get('otp1'),
                request.data.get('otp2'),
                request.data.get('otp3'),
                request.data.get('otp4'),
                request.data.get('otp5'),
                request.data.get('otp6')
            ]
    for otp in list_otp:
        if not otp or not otp.isdigit():
            return Response({"error": "Invalid OTP format"}, status=400 )

    otp_str = "".join(list_otp)
    otp_input = int(otp_str)

    if not user:
        return Response({"error": "User not found"}, status=404)
    
    attempts = cache.get(f"otp_attempts_{user.id}")
    if attempts is not None and attempts >= 5:
        return Response({"error": "Too many OTP attempts. Please try again later."}, status=429)
    
    saved_otp = cache.get(f"otp_{user.id}")

    if not saved_otp:
        return Response({"error":"OTP expired"},status=400)
    
    if str(saved_otp) != str(otp_input):
        cache.incr(f"otp_attempts_{user.id}")
        return Response({"error":"Invalid OTP"},status=400)
    
    cache.delete(f"otp_{user.id}")
    cache.delete(f"otp_attempts_{user.id}")

    refresh = RefreshToken.for_user(user)

    return Response({
        "access":str(refresh.access_token),
        "refresh":str(refresh)
    })


@api_view(['POST'])
def Register():
    pass
