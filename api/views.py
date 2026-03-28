from email import errors
import random
from cryptography.fernet import Fernet
import json
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from django.contrib.auth import authenticate, get_user_model
from django.core.cache import cache
from django.core.mail import send_mail
from project.settings import EMAIL_HOST_USER, FERNET_KEY
from rest_framework_simplejwt.tokens import RefreshToken
import accounts.validations
from accounts.models import Nurse, Patient, PendingUser, Doctor, Donor , Pharmacist
from django.contrib.auth.hashers import make_password
from rest_framework.permissions import IsAuthenticated


User = get_user_model()


def generate_otp(user):
    otp = random.randint(100000, 999999)

    pending_data = {
        "otp": otp,
        "attempts": 0,
    }

    key = Fernet(FERNET_KEY)

    data = json.dumps(pending_data).encode()
    encrypted = key.encrypt(data)

    cache.set(f"pending_data_{user.id}", encrypted, timeout=300)

    send_mail(
        subject="TechCare Team",
        message=f"your verification OTP is {otp}",
        from_email=EMAIL_HOST_USER,
        recipient_list=[user.email]
    )

    return True, "OTP sent to your email"


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

    otp, message = generate_otp(user)
    if not otp:
        return Response({"error": message}, status=404)

    return Response({"message": message}, status=200)


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
        "access": str(refresh.access_token),
        "refresh": str(refresh)
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
        role=role
    )

    pending_user.save()

    otp, message = generate_otp(pending_user)
    if not otp:
        pending_user.delete()
        return Response({"error": message}, status=404)

    return Response({"message": message, "pending_user_id": pending_user.id}, status=200)


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
        return Response({"error": error_message}, status=400)

    user = User.objects.create(
        username=pending_user.username,
        email=pending_user.email,
        first_name=pending_user.first_name,
        last_name=pending_user.last_name,
        password=pending_user.password,
        role=pending_user.role,
        is_active=True
    )

    user.save()
    pending_user.delete()

    refresh = RefreshToken.for_user(user)

    return Response({
        "access": str(refresh.access_token),
        "refresh": str(refresh),
        "message": "Registration successful"
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def patient_register(request):
    gender = request.data.get('gender')
    phone_number = request.data.get('phone_number')
    address = request.data.get('address')
    governorate = request.data.get('governorate')
    profile_pic = request.data.get('profile_pic')
    national_id_pic_front = request.data.get('national_id_pic_front')
    national_id_pic_back = request.data.get('national_id_pic_back')

    if not accounts.validations.validate_phone(phone_number):
        return Response({"error": "Phone number must start with 0 or 1."}, status=400)

    if not accounts.validations.validate_address(address):
        return Response({"error": "can't use <,> or forbidden words"}, status=400)

    patient = Patient.objects.create(
        user=request.user,
        gender=gender,
        address=address,
        governorate=governorate,
        phone_number=phone_number,
        profile_pic=profile_pic,
        national_id_pic_back=national_id_pic_back,
        national_id_pic_front=national_id_pic_front,
    )

    patient.save()

    return Response({"message": "Patient profile created successfully"})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def doctor_register(request):
    gender = request.data.get('gender')
    phone_number = request.data.get('phone_number')
    address = request.data.get('address')
    governorate = request.data.get('governorate')
    profile_pic = request.data.get('profile_pic')
    national_id_pic_front = request.data.get('national_id_pic_front')
    national_id_pic_back = request.data.get('national_id_pic_back')
    price = request.data.get('price')
    date_of_birth = request.data.get('date_of_birth')
    specification = request.data.get('specification')
    university = request.data.get('university')
    syndicate_card = request.data.get('syndicate_card')
    practice_permit = request.data.get('practice_permit')
    graduation_certificate = request.data.get('graduation_certificate')
    excellence_certificate = request.data.get('excellence_certificate')

    if not accounts.validations.validate_phone(phone_number):
        return Response({"error": "Phone number must start with 0 or 1."}, status=400)

    if not accounts.validations.validate_address(address):
        return Response({"error": "can't use <,> or forbidden words"}, status=400)

    if not accounts.validations.validate_dop(date_of_birth, 22):
        return Response({"error": "You must be at least 22 years old."}, status=400)

    doctor = Doctor.objects.create(
        user=request.user,
        gender=gender,
        address=address,
        governorate=governorate,
        phone_number=phone_number,
        profile_pic=profile_pic,
        national_id_pic_back=national_id_pic_back,
        national_id_pic_front=national_id_pic_front,
        price=price,
        date_of_birth=date_of_birth,
        specification=specification,
        university=university,
        syndicate_card=syndicate_card,
        practice_permit=practice_permit,
        graduation_certificate=graduation_certificate,
        excellence_certificate=excellence_certificate,
    )

    doctor.save()

    return Response({"message": "Doctor profile created successfully"})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def nurse_register(request):
    gender = request.data.get('gender')
    phone_number = request.data.get('phone_number')
    gender = request.data.get('gender')
    phone_number = request.data.get('phone_number')
    address = request.data.get('address')
    governorate = request.data.get('governorate')
    profile_pic = request.data.get('profile_pic')
    national_id_pic_front = request.data.get('national_id_pic_front')
    national_id_pic_back = request.data.get('national_id_pic_back')
    date_of_birth = request.data.get('date_of_birth')
    excellence_certificate = request.data.get('excellence_certificate')
    syndicate_card = request.data.get('syndicate_card')
    practice_permit = request.data.get('practice_permit')
    graduation_certificate = request.data.get('graduation_certificate')

    if not accounts.validations.validate_phone(phone_number):
        return Response({"error": "Phone number must start with 0 or 1."}, status=400)

    if not accounts.validations.validate_address(address):
        return Response({"error": "can't use <,> or forbidden words"}, status=400)

    if not accounts.validations.validate_dop(date_of_birth, 18):
        return Response({"error": "You must be at least 18 years old."}, status=400)

    nurse = Nurse.objects.create(
        user=request.user,
        gender=gender,
        address=address,
        governorate=governorate,
        phone_number=phone_number,
        profile_pic=profile_pic,
        national_id_pic_back=national_id_pic_back,
        national_id_pic_front=national_id_pic_front,
        date_of_birth=date_of_birth,
        excellence_certificate=excellence_certificate,
        syndicate_card=syndicate_card,
        practice_permit=practice_permit,
        graduation_certificate=graduation_certificate,
    )
    nurse.save()

    return Response({"message": "Nurse profile created successfully"})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def donor_register(request):
    blood_type = request.data.get('blood_type')
    phone_number = request.data.get('phone_number')
    address = request.data.get('address')
    governorate = request.data.get('governorate')
    profile_pic = request.data.get('profile_pic')
    national_id_pic_front = request.data.get('national_id_pic_front')
    national_id_pic_back = request.data.get('national_id_pic_back')
    date_of_birth = request.data.get('date_of_birth')
    last_donation_date = request.data.get('last_donation_date')

    if not accounts.validations.validate_phone(phone_number):
        return Response({"error": "Phone number must start with 0 or 1."}, status=400)

    if not accounts.validations.validate_address(address):
        return Response({"error": "can't use <,> or forbidden words"}, status=400)

    if not accounts.validations.validate_dop(date_of_birth, 18):
        return Response({"error": "You must be at least 18 years old."}, status=400)

    # Handle last_donation_date - if not provided, use date_of_birth as default
    donation_date = last_donation_date if last_donation_date else date_of_birth

    donor = Donor.objects.create(
        user=request.user,
        blood_type=blood_type,
        address=address,
        governorate=governorate,
        phone_number=phone_number,
        profile_pic=profile_pic,
        national_id_pic_back=national_id_pic_back,
        national_id_pic_front=national_id_pic_front,
        date_of_birth=date_of_birth,
        last_donation_date=donation_date,
    )

    donor.save()

    return Response({"message": "Donor profile created successfully"})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def pharmacist_register(request):
    gender = request.data.get('gender')
    phone_number = request.data.get('phone_number')
    date_of_birth = request.data.get('date_of_birth')
    profile_pic = request.FILES.get('profile_pic')
    national_id_pic_front = request.FILES.get('national_id_pic_front')
    national_id_pic_back = request.FILES.get('national_id_pic_back')
    pharmacy_name = request.data.get('pharmacy_name')
    pharmacy_address = request.data.get('pharmacy_address')
    governorate = request.data.get('governorate')
    university = request.data.get('university')
    syndicate_card = request.FILES.get('syndicate_card')
    practice_permit = request.FILES.get('practice_permit')
    graduation_certificate = request.FILES.get('graduation_certificate')

    if not accounts.validations.validate_phone(phone_number):
        return Response({"error": "Phone number must start with 0 or 1."}, status=400)

    if not accounts.validations.validate_dop(date_of_birth, 18):
        return Response({"error": "You must be at least 18 years old."}, status=400)

    if not accounts.validations.validate_pharmacy_name(pharmacy_name):
        return Response({"error": "Pharmacy name must be at most 60 letters."}, status=400)

    if not accounts.validations.validate_address(pharmacy_address):
        return Response({"error": "can't use <,> or forbidden words"}, status=400)

    pharmacist = Pharmacist.objects.create(
        user=request.user,
        gender=gender,
        phone_number=phone_number,
        date_of_birth=date_of_birth,
        profile_pic=profile_pic,
        national_id_pic_front=national_id_pic_front,
        national_id_pic_back=national_id_pic_back,
        pharmacy_name=pharmacy_name,
        pharmacy_address=pharmacy_address,
        governorate=governorate,
        university=university,
        syndicate_card=syndicate_card,
        practice_permit=practice_permit,
        graduation_certificate=graduation_certificate,
    )
    pharmacist.save()

    return Response({"message": "Pharmacist profile created successfully"})

@api_view(['POST'])
def forget_password(request):
    email = request.data.get('email')

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({"error": "User with this email does not exist"}, status=404)

    otp, message = generate_otp(user)
    if not otp:
        return Response({"error": message}, status=404)

    return Response({"message": message}, status=200)


@api_view(['POST'])
def verify_OTP_forget_password(request):
    try:
        user = User.objects.get(email=request.data.get('email'))
    except User.DoesNotExist:
        return Response({"error": "User with this email does not exist"}, status=404)

    otp = request.data.get('otp')

    if not otp:
        return Response({"error": "OTP is required"}, status=400)

    success, error_message = verify_otp(user.id, otp)

    if not success:
        return Response({"error": error_message}, status=400)

    return Response({"message": "OTP verified successfully"}, status=200)


@api_view(['POST'])
def reset_password(request):
    email = request.data.get('email')
    password = request.data.get('password')
    confirm = request.data.get('confirm')

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({"error": "User with this email does not exist"}, status=404)

    if password != confirm:
        return Response({"error": "Passwords do not match"}, status=400)

    if not accounts.validations.validate_password(password):
        return Response({"error": "Password must be at least 8 chars and include at least one uppercase, one lowercase, one number, and one special char (!@#&?$%*.-~)."}, status=400)

    user.password = make_password(password)
    user.save()

    return Response({"message": "Password reset successfully"}, status=200)


@api_view(['POST'])
def resend_otp(request):
    source = request.data.get('source')  # 'login', 'signup', 'forget'

    if source == 'login':
        username = request.data.get('username')
        try:
            user = User.objects.get(username=username)
            generate_otp(user)
            return Response({"message": "OTP resent"}, status=200)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=404)

    elif source == 'signup':
        pending_user_id = request.data.get('pending_user_id')
        try:
            pending_user = PendingUser.objects.get(id=pending_user_id)
            generate_otp(pending_user)
            return Response({"message": "OTP resent"}, status=200)
        except PendingUser.DoesNotExist:
            return Response({"error": "User not found"}, status=404)

    elif source == 'forget':
        email = request.data.get('email')
        try:
            user = User.objects.get(email=email)
            generate_otp(user)
            return Response({"message": "OTP resent"}, status=200)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=404)

    return Response({"error": "Invalid source"}, status=400)