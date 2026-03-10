import random
from cryptography.fernet import Fernet
import json
from rest_framework.response import Response
from rest_framework.decorators import api_view 
from django.contrib.auth import authenticate, get_user_model
from django.core.cache import cache
from django.core.mail import send_mail
from project.settings import EMAIL_HOST_USER, FERNET_KEY
from rest_framework_simplejwt.tokens import RefreshToken
import accounts.validations 
from accounts.models import PendingUser
from django.contrib.auth.hashers import make_password


User = get_user_model()

def verify_otp(user_id, otp_input):
    encrypted = cache.get(f"pending_data_{user_id}")

    if not encrypted:
        return False, "OTP expired"

    key = Fernet(FERNET_KEY)

    data = key.decrypt(encrypted)
    pending_data = json.loads(data.decode())

    saved_otp = pending_data["otp"]
    attempts = pending_data["attempts"]

    if attempts >= 3:
        return False, "Too many attempts"

    if str(saved_otp) != str(otp_input):
        pending_data["attempts"] += 1

        new_encrypted = key.encrypt(json.dumps(pending_data).encode())

        cache.set(f"pending_data_{user_id}", new_encrypted, timeout=300)

        return False, "Invalid OTP"

    cache.delete(f"pending_data_{user_id}")

    return True, None


@api_view(['POST'])
def login(request):
    username = request.data.get('username')
    password = request.data.get('password')

    user = authenticate(username=username, password=password)

    if user is None:
        return Response({"error": "Invalid credentials"}, status=401)

    otp = random.randint(100000,999999)

    pending_data = {
        "otp": otp,
        "attempts":0,
        }

    key = Fernet(FERNET_KEY)

    data = json.dumps(pending_data).encode()
    encrypted = key.encrypt(data)

    cache.set(f"pending_data_{user.id}", encrypted, timeout=300)

    send_mail(
        subject = "TechCare Team",
        message = f"your verification OTP is {otp}",
        from_email = EMAIL_HOST_USER,
        recipient_list = [user.email]
    )

    return Response({"message": "OTP sent to your email"})

@api_view(['POST'])
def Verify_OTP_login(request):
    username = request.data.get('username')
    try:
        user = User.objects.get(username=username)
    except User.DoesNotExist:
        return Response({"error": "User not found"}, status=404)
    
    otp = request.data.get('otp')

    if not otp:
        return Response({"error": "OTP is required"}, status=400)
    
    success, error_message = verify_otp(user.id, otp)

    if not success:
        return Response({"error": error_message}, status=400)
    
    refresh = RefreshToken.for_user(user)

    return Response({
        "access":str(refresh.access_token),
        "refresh":str(refresh)
    })


@api_view(['POST'])
def register(request):
    username = request.data.get('username')
    email = request.data.get('email')
    first_name = request.data.get('first_name')
    last_name = request.data.get('last_name')
    password = request.data.get('password')
    role = request.data.get('role')

    if User.objects.filter(username=username).exists():
        return Response({"error": "Username already exists"}, status=400)
    
    if User.objects.filter(email=email).exists():
        return Response({"error": "Email already exists"}, status=400)
    
    if not accounts.validations.validate_password(password):
        return Response({"error": "Password does not meet complexity requirements"}, status=400)
    
    if not accounts.validations.validate_email(email):
        return Response({"error": "Invalid email format"}, status=400)
    
    if not accounts.validations.validate_name(first_name) or not accounts.validations.validate_name(last_name):
        return Response({"error": "Names can only contain letters"}, status=400)
    
    pending_user = PendingUser.objects.create(
        username=username,
        email=email,
        first_name=first_name,
        last_name=last_name,
        password=make_password(password),
        role = role
    )

    otp = random.randint(100000,999999)

    pending_data = {
        "otp": otp,
        "attempts":0,
        }

    key = Fernet(FERNET_KEY)

    data = json.dumps(pending_data).encode()
    encrypted = key.encrypt(data)

    cache.set(f"pending_data_{pending_user.id}", encrypted, timeout=300)

    send_mail(
        subject = "TechCare Team",
        message = f"your verification OTP is {otp}",
        from_email = EMAIL_HOST_USER,
        recipient_list = [email]
    )
    
    return Response({"message": "OTP sent to your email"})

@api_view(['POST'])
def verify_OTP_register(request, user_id):
    try:
        pending_user = PendingUser.objects.get(id=user_id)
    except PendingUser.DoesNotExist:
        return Response({"error": "User not found"}, status=404)
    
    otp = request.data.get('otp')

    if not otp:
        return Response({"error": "OTP is required"}, status=400)

    success, error_message = verify_otp(pending_user.id, otp)

    if not success:
        pending_user.delete()
        return Response({"error": error_message}, status=400)
    

    user = User.objects.create(
        username=pending_user.username,
        email=pending_user.email,
        first_name=pending_user.first_name,
        last_name=pending_user.last_name,
        password=pending_user.password,
        role = pending_user.role,
        is_active=True
    )

    user.save()
    pending_user.delete()

    refresh = RefreshToken.for_user(user)

    return Response({
        "access":str(refresh.access_token),
        "refresh":str(refresh),
        "message": "Registration successful"
    })

