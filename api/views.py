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
from accounts.models import Nurse, Patient, PendingUser, Doctor, Donor , Pharmacist, get_provider_days_with_dates, TimeSlots

from django.contrib.auth.hashers import make_password
from rest_framework.permissions import IsAuthenticated

from django.db.models import Avg
from datetime import date, time, timedelta


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

    if not accounts.validations.validate_donation_date(last_donation_date,date_of_birth):
        return Response({'error':"Last blood donation must be after you turned 16."}, status=400)
    
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
    source = request.data.get('source')

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


########################################################
####################### DOCTOR #########################
########################################################


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def doctor_dashboard(request):
    if request.user.role != "doctor":
        return Response({"error": "Unauthorized"}, status=401)

    doctor = Doctor.objects.get(user=request.user)

    name = "Dr. " + doctor.user.first_name + " " + doctor.user.last_name
    specification = doctor.get_specification_display()
    price = doctor.price
    governorate = doctor.get_governorate_display()
    address = doctor.address
    brief = doctor.brief
    profile_pic = doctor.profile_pic.url if doctor.profile_pic else None
    email = doctor.user.email
    phone_num = doctor.phone_number

    doctor_requests = doctor.doctor_requests.all()
    pending = doctor_requests.filter(status__in=['pending', 'edited']).count()
    completed = doctor_requests.filter(status='completed').count()

    if doctor.rates.exists():
        average_rating = doctor.rates.aggregate(Avg('rate'))['rate__avg'] or 0
        average_rating = round(average_rating)
    else:
        average_rating = 0

    days = TimeSlots.objects.filter(doctor=doctor).values_list('day', flat=True).distinct()
    days = get_provider_days_with_dates(days)

    selected_day = request.GET.get('day')

    morning_slots = []
    evening_slots = []

    def build_slot(slot):
        return {
            "id": slot.id,
            "time": slot.time.strftime("%H:%M"),
            "day": slot.day,
        }

    if selected_day:
        slots = TimeSlots.objects.filter(doctor=doctor, day=selected_day).order_by('time')
        for slot in slots:
            if slot.time < time(12, 0):
                morning_slots.append(build_slot(slot))
            else:
                evening_slots.append(build_slot(slot))

    if not selected_day and days:
        selected_day = days[0]['day']
        slots = TimeSlots.objects.filter(doctor=doctor, day=selected_day).order_by('time')
        for slot in slots:
            if slot.time < time(12, 0):
                morning_slots.append(build_slot(slot))
            else:
                evening_slots.append(build_slot(slot))

    return Response({
        "name": name,
        "specification": specification,
        "price": price,
        "governorate": governorate,
        "address": address,
        "average_rating": average_rating,
        "brief": brief,
        "profile_pic": profile_pic,
        "pending": pending,
        "completed": completed,
        "phone_number": phone_num,
        "email": email,
        "days": [{"day": d["day"], "date": str(d["date"])} for d in days],
        "selected_day": selected_day,
        "morning_slots": morning_slots,
        "evening_slots": evening_slots,
    }, status=200)


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def edit_doctor_profile(request):
    doctor = Doctor.objects.get(user=request.user)

    name = "Dr. " + doctor.user.first_name + " " + doctor.user.last_name
    specification = doctor.get_specification_display()
    profile_pic = doctor.profile_pic.url if doctor.profile_pic else None

    if request.method == 'GET':
        return Response({
            "name": name,
            "specification": specification,
            "profile_pic": profile_pic,
            "username": doctor.user.username,
            "phone_number": doctor.phone_number,
            "address": doctor.address,
            "brief": doctor.brief,
            "price": doctor.price,
            "governorate": doctor.governorate,
        }, status=200)

    User = get_user_model()

    phone_number = request.data.get('phone_number')
    address = request.data.get('address')
    brief = request.data.get('brief')
    username = request.data.get('username')
    price = request.data.get('price')
    governorate = request.data.get('governorate')

    if User.objects.filter(username=username).exclude(id=request.user.id).exists():
        return Response({"error": "Username already exists"}, status=400)

    if not validations.validate_username(username):
        return Response({"error": "Username must be lowercase, allowed letters, numbers, _ or ., and cannot contain forbidden words."}, status=400)

    if not validations.validate_phone(phone_number):
        return Response({"error": "Phone number must start with 0 or 1."}, status=400)

    if not validations.validate_address(address):
        return Response({"error": "can't use <,> or forbidden words"}, status=400)

    if not validations.validate_address(brief):
        return Response({"error": "Brief can't contain forbidden words."}, status=400)

    doctor.user.username = username
    doctor.phone_number = phone_number
    doctor.address = address
    doctor.brief = brief
    doctor.price = price
    doctor.governorate = governorate
    doctor.profile_pic = request.FILES.get('profile_pic') or doctor.profile_pic
    doctor.user.save()
    doctor.save()

    return Response({"message": "Profile updated successfully"}, status=200)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def doctor_requests(request, type):
    if request.user.role != 'doctor':
        return Response({"error": "Unauthorized"}, status=401)

    doctor = Doctor.objects.get(user=request.user)

    name = "Dr. " + doctor.user.first_name + " " + doctor.user.last_name
    specification = doctor.get_specification_display()
    profile_pic = doctor.profile_pic.url if doctor.profile_pic else None

    all_requests = doctor.doctor_requests.all()

    def serialize_request(req):
        return {
            "id": req.id,
            "status": req.status,
            "date": str(req.date),
            "time": str(req.time),
        }

    base = {
        "name": name,
        "specification": specification,
        "profile_pic": profile_pic,
    }

    if type in ('pending', 'edited') or type is None:
        pending = list(map(serialize_request, all_requests.filter(status='pending').order_by('-date', '-time')))
        edited = list(map(serialize_request, all_requests.filter(status='edited').order_by('-date', '-time')))
        return Response({**base, "pending": pending, "edited": edited}, status=200)

    elif type == 'accepted':
        accepted = list(map(serialize_request, all_requests.filter(status='accepted').order_by('-date', '-time')))
        return Response({**base, "accepted": accepted}, status=200)

    elif type == 'completed':
        completed = list(map(serialize_request, all_requests.filter(status='completed').order_by('-date', '-time')))
        return Response({**base, "completed": completed}, status=200)

    else:
        return Response({"error": "Invalid request type"}, status=400)


def get_ordered_week_days():
    today = date.today()

    days_map = [
        'monday', 'tuesday', 'wednesday',
        'thursday', 'friday', 'saturday', 'sunday'
    ]

    today_index = today.weekday()
    ordered_days = []

    for i in range(7):
        day_index = (today_index + i) % 7
        day_name = days_map[day_index]
        day_date = today + timedelta(days=i)
        ordered_days.append({
            'day': day_name,
            'date': day_date
        })

    return ordered_days


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def edit_time_slots(request):
    if request.user.role != 'doctor':
        return Response({"error": "Unauthorized"}, status=401)

    doctor = Doctor.objects.get(user=request.user)
    days = get_ordered_week_days()

    selected_day = request.GET.get('day') or days[0]['day']

    def build_slot(slot):
        return {
            "id": slot.id,
            "time": slot.time.strftime("%H:%M"),
            "day": slot.day,
        }

    if request.method == 'POST':
        input_day = request.data.get('day')
        input_time = request.data.get('time')

        if not input_day:
            return Response({"error": "Day is required"}, status=400)

        if not input_time:
            return Response({"error": "Time is required"}, status=400)

        exists = TimeSlots.objects.filter(
            doctor=doctor,
            day=input_day,
            time=input_time
        ).exists()

        if not exists:
            TimeSlots.objects.create(
                doctor=doctor,
                day=input_day,
                time=input_time
            )

        slots = TimeSlots.objects.filter(doctor=doctor, day=input_day).order_by('time')
        morning_slots = []
        evening_slots = []

        for slot in slots:
            if slot.time < time(12, 0):
                morning_slots.append(build_slot(slot))
            else:
                evening_slots.append(build_slot(slot))

        return Response({
            "message": "Time slot added successfully",
            "selected_day": input_day,
            "morning_slots": morning_slots,
            "evening_slots": evening_slots,
        }, status=201)

    slots = TimeSlots.objects.filter(doctor=doctor, day=selected_day).order_by('time')
    morning_slots = []
    evening_slots = []

    for slot in slots:
        if slot.time < time(12, 0):
            morning_slots.append(build_slot(slot))
        else:
            evening_slots.append(build_slot(slot))

    return Response({
        "days": [{"day": d["day"], "date": str(d["date"])} for d in days],
        "selected_day": selected_day,
        "morning_slots": morning_slots,
        "evening_slots": evening_slots,
    }, status=200)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_time_slot(request, slot_id):
    if request.user.role != 'doctor':
        return Response({"error": "Unauthorized"}, status=401)

    doctor = Doctor.objects.get(user=request.user)

    try:
        slot = TimeSlots.objects.get(id=slot_id, doctor=doctor)
        slot.delete()
        return Response({"message": "Time slot deleted successfully"}, status=200)
    except TimeSlots.DoesNotExist:
        return Response({"error": "Time slot not found"}, status=404)