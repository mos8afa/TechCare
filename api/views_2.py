# Standard Library
import json
from decimal import Decimal
from datetime import date, time, timedelta, datetime as dt, time as time_type

# Django
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from django.db.models import Avg, Min

# Django REST Framework
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

# Local Apps - Accounts
from accounts.models import (
    Patient, Doctor, Nurse,
    SPECIFICATIONS, GOVERNORATES,
    TimeSlots, get_provider_days_with_dates
)
import accounts.validations as validations

# Local Apps - Doctor
from doctor.models import DoctorRequest

# Local Apps - Nurse
from nurse.models import NurseRequest, Service

###################################### Nurse Rooole ###########################################
# ─────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────


def _nurse_name(nurse):
    prefix = "Mr. " if nurse.gender == "male" else "Mrs. "
    return prefix + nurse.user.first_name + " " + nurse.user.last_name


def get_ordered_week_days():
    today = date.today()
    days_map = ['monday', 'tuesday', 'wednesday',
                'thursday', 'friday', 'saturday', 'sunday']
    today_index = today.weekday()
    ordered_days = []
    for i in range(7):
        day_index = (today_index + i) % 7
        ordered_days.append({
            'day': days_map[day_index],
            'date': today + timedelta(days=i)
        })
    return ordered_days


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user_role(request):
    return Response({"role": request.user.role}, status=200)

# ─────────────────────────────────────────────
# DASHBOARD
# ─────────────────────────────────────────────


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def nurse_dashboard(request):
    if request.user.role != 'nurse':
        return Response({"error": "Unauthorized"}, status=401)

    nurse = Nurse.objects.get(user=request.user)

    name = _nurse_name(nurse)
    governorate = nurse.get_governorate_display()
    address = nurse.address
    phone_number = nurse.phone_number
    email = nurse.user.email
    brief = nurse.brief
    profile_pic = nurse.profile_pic.url if nurse.profile_pic else None

    nurse_reqs = nurse.nurse_requests.all()
    pending = nurse_reqs.filter(status__in=['pending', 'edited']).count()
    completed = nurse_reqs.filter(status='completed').count()

    average_rating = (
        round(nurse.rates.aggregate(Avg('rate'))['rate__avg'] or 0)
        if nurse.rates.exists() else 0
    )

    services = []
    for s in nurse.nurse_services.all():
        services.append({
            "id": s.id,
            "name": s.name,
            "description": s.description,
            "price": str(s.price),
        })

    days = list(
        get_provider_days_with_dates(
            TimeSlots.objects.filter(nurse=nurse).values_list(
                'day', flat=True).distinct()
        )
    )

    selected_day = request.GET.get('day') or (days[0]['day'] if days else None)

    morning_slots = []
    evening_slots = []

    if selected_day:
        slots = TimeSlots.objects.filter(
            nurse=nurse, day=selected_day).order_by('time')
        for slot in slots:
            slot_data = {
                "id": slot.id,
                "time": slot.time.strftime("%H:%M"),
                "day": slot.day,
            }
            if slot.time < time(12, 0):
                morning_slots.append(slot_data)
            else:
                evening_slots.append(slot_data)

    return Response({
        "name": name,
        "governorate": governorate,
        "address": address,
        "phone_number": phone_number,
        "email": email,
        "average_rating": average_rating,
        "brief": brief,
        "profile_pic": profile_pic,
        "pending": pending,
        "completed": completed,
        "services": services,
        "days": [{"day": d["day"], "date": str(d["date"])} for d in days],
        "selected_day": selected_day,
        "morning_slots": morning_slots,
        "evening_slots": evening_slots,
    }, status=200)


# ─────────────────────────────────────────────
# EDIT PROFILE
# ─────────────────────────────────────────────

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def edit_nurse_profile(request):
    if request.user.role != 'nurse':
        return Response({"error": "Unauthorized"}, status=401)

    User = get_user_model()
    nurse = Nurse.objects.get(user=request.user)

    if request.method == 'GET':
        return Response({
            "name": _nurse_name(nurse),
            "username": nurse.user.username,
            "phone_number": nurse.phone_number,
            "address": nurse.address,
            "brief": nurse.brief,
            "governorate": nurse.governorate,
            "profile_pic": nurse.profile_pic.url if nurse.profile_pic else None,
        }, status=200)

    phone_number = request.data.get('phone_number')
    address = request.data.get('address')
    brief = request.data.get('brief')
    username = request.data.get('username')
    governorate = request.data.get('governorate')

    if User.objects.filter(username=username).exclude(id=request.user.id).exists():
        return Response({"error": "Username already exists"}, status=400)

    if not validations.validate_username(username):
        return Response({"error": "Username must be lowercase, allowed letters, numbers, _ or ., and cannot contain forbidden words."}, status=400)

    if not validations.validate_phone(phone_number):
        return Response({"error": "Phone number must start with 0 or 1."}, status=400)

    if not validations.validate_address(address):
        return Response({"error": "Can't use <,> or forbidden words."}, status=400)

    if not validations.validate_address(brief):
        return Response({"error": "Brief can't contain forbidden words."}, status=400)

    nurse.user.username = username
    nurse.phone_number = phone_number
    nurse.address = address
    nurse.brief = brief
    nurse.governorate = governorate
    nurse.profile_pic = request.FILES.get('profile_pic') or nurse.profile_pic
    nurse.user.save()
    nurse.save()

    return Response({"message": "Profile updated successfully"}, status=200)


# ─────────────────────────────────────────────
# REQUESTS
# ─────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def nurse_requests(request, type):
    if request.user.role != 'nurse':
        return Response({"error": "Unauthorized"}, status=401)

    nurse = Nurse.objects.get(user=request.user)
    all_reqs = nurse.nurse_requests.all()

    def base_fields(req):
        """Shared fields across all statuses."""
        return {
            "id":                  req.id,
            "status":              req.status,
            "date":                str(req.date),
            "time":                str(req.time),
            "requester_name":      req.requester_name,
            "requester_phone":     req.requester_phone,
            "is_donor":            req.is_donor,
            "disease_description": req.disease_description,
            "address":             req.address,
            "governorate":         req.governrate,
            "services": [
                {"id": s.id, "name": s.name, "price": str(s.price)}
                for s in req.service.all()
            ],
        }

    if type in ('pending', 'edited') or type is None:
        pending_list = []
        for req in all_reqs.filter(status='pending').order_by('-date', '-time'):
            req_day = req.date.strftime('%A').lower()
            day_slots = TimeSlots.objects.filter(
                nurse=nurse, day=req_day).order_by('time')
            pending_list.append({
                **base_fields(req),
                "available_slots": [s.time.strftime("%H:%M") for s in day_slots],
            })

        edited_list = []
        for req in all_reqs.filter(status='edited').order_by('-date', '-time'):
            req_day = req.date.strftime('%A').lower()
            day_slots = TimeSlots.objects.filter(
                nurse=nurse, day=req_day).order_by('time')
            edited_list.append({
                **base_fields(req),
                "available_slots": [s.time.strftime("%H:%M") for s in day_slots],
            })

        return Response({"pending": pending_list, "edited": edited_list}, status=200)

    elif type == 'accepted':
        accepted_list = [base_fields(req)
                        for req in all_reqs.filter(status='accepted').order_by('-date', '-time')]
        return Response({"accepted": accepted_list}, status=200)

    elif type == 'completed':
        completed_list = [base_fields(req)
                        for req in all_reqs.filter(status='completed').order_by('-date', '-time')]
        return Response({"completed": completed_list}, status=200)

    return Response({"error": "Invalid request type"}, status=400)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def nurse_request_action(request, request_id):
    if request.user.role != 'nurse':
        return Response({"error": "Unauthorized"}, status=401)

    nurse = Nurse.objects.get(user=request.user)
    req = get_object_or_404(NurseRequest, id=request_id, nurse=nurse)
    action = request.data.get('action')

    if action == 'reject':
        req.status = 'rejected'
        req.save()
        return Response({"message": "Request rejected"}, status=200)

    elif action == 'accept':
        req.status = 'accepted'
        req.save()
        return Response({"message": "Request accepted"}, status=200)

    elif action == 'reschedule':
        new_time = request.data.get('new_time')
        if not new_time:
            return Response({"error": "new_time is required for reschedule."}, status=400)
        try:
            h, m = new_time.split(':')
            new_t = time(int(h), int(m))
            # Compare BEFORE overwriting req.time (fixes the original bug)
            if new_t == req.time:
                req.status = 'accepted'
            else:
                req.time = new_t
                req.status = 'edited'
            req.save()
            return Response({"message": f"Request {req.status}"}, status=200)
        except (ValueError, AttributeError):
            return Response({"error": "Invalid time format. Use HH:MM."}, status=400)

    return Response({"error": "Invalid action. Use 'accept', 'reject', or 'reschedule'."}, status=400)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def nurse_mark_done(request, request_id):
    if request.user.role != 'nurse':
        return Response({"error": "Unauthorized"}, status=401)

    nurse = Nurse.objects.get(user=request.user)
    req = get_object_or_404(NurseRequest, id=request_id,
                            nurse=nurse, status='accepted')

    req.nurse_done = True
    if req.patient_done:
        req.status = 'completed'
    req.save()

    return Response({
        "message": "Marked as done",
        "status":  req.status,
    }, status=200)

# ─────────────────────────────────────────────
# SERVICES
# ─────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_service(request):
    if request.user.role != 'nurse':
        return Response({"error": "Unauthorized"}, status=401)

    nurse = Nurse.objects.get(user=request.user)
    service_name = request.data.get('name')
    description = request.data.get('description')
    price = request.data.get('price')

    if not service_name or not price:
        return Response({"error": "Name and price are required."}, status=400)

    try:
        price = Decimal(price)
    except Exception:
        return Response({"error": "Invalid price value."}, status=400)

    service = nurse.nurse_services.create(
        name=service_name,
        description=description,
        price=price,
    )

    return Response({
        "message": "Service added successfully",
        "service": {
            "id": service.id,
            "name": service.name,
            "description": service.description,
            "price": str(service.price),
        },
    }, status=201)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def edit_service(request, service_id):
    if request.user.role != 'nurse':
        return Response({"error": "Unauthorized"}, status=401)

    nurse = Nurse.objects.get(user=request.user)
    service = get_object_or_404(Service, id=service_id, nurse=nurse)

    name = request.data.get('name')
    description = request.data.get('description')
    price = request.data.get('price')

    if not name or not price:
        return Response({"error": "Name and price are required."}, status=400)

    try:
        service.price = Decimal(price)
    except Exception:
        return Response({"error": "Invalid price value."}, status=400)

    service.name = name
    service.description = description
    service.save()

    return Response({
        "message": "Service updated successfully",
        "service": {
            "id": service.id,
            "name": service.name,
            "description": service.description,
            "price": str(service.price),
        },
    }, status=200)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_service(request, service_id):
    if request.user.role != 'nurse':
        return Response({"error": "Unauthorized"}, status=401)

    nurse = Nurse.objects.get(user=request.user)
    service = get_object_or_404(Service, id=service_id, nurse=nurse)
    service.delete()

    return Response({"message": "Service deleted successfully"}, status=200)


# ─────────────────────────────────────────────
# TIME SLOTS
# ─────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_nurse_time_slots(request):
    if request.user.role != 'nurse':
        return Response({"error": "Unauthorized"}, status=401)

    nurse = Nurse.objects.get(user=request.user)
    days = get_ordered_week_days()
    selected_day = request.GET.get('day') or days[0]['day']

    morning_slots = []
    evening_slots = []

    for slot in TimeSlots.objects.filter(nurse=nurse, day=selected_day).order_by('time'):
        slot_data = {
            "id": slot.id,
            "time": slot.time.strftime("%H:%M"),
            "day": slot.day,
        }
        if slot.time < time(12, 0):
            morning_slots.append(slot_data)
        else:
            evening_slots.append(slot_data)

    return Response({
        "days": [{"day": d["day"], "date": str(d["date"])} for d in days],
        "selected_day": selected_day,
        "morning_slots": morning_slots,
        "evening_slots": evening_slots,
    }, status=200)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def save_nurse_time_slots(request):
    if request.user.role != 'nurse':
        return Response({"error": "Unauthorized"}, status=401)

    nurse = Nurse.objects.get(user=request.user)

    days_data = request.data.get('days')

    if not days_data:
        day = request.data.get('day')
        times = request.data.get('times', [])
        if not day:
            return Response({"error": "Missing 'day' field."}, status=400)
        days_data = {day: times}

    saved = {}
    for day, times in days_data.items():
        TimeSlots.objects.filter(nurse=nurse, day=day).delete()
        created = []
        for t_str in times:
            try:
                h, m = t_str.split(':')
                TimeSlots.objects.create(
                    nurse=nurse, day=day, time=time(int(h), int(m)))
                created.append(t_str)
            except (ValueError, AttributeError):
                continue
        saved[day] = created

    return Response({
        "message": "Time slots saved successfully",
        "saved": saved,
    }, status=200)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_nurse_time_slot(request, slot_id):
    if request.user.role != 'nurse':
        return Response({"error": "Unauthorized"}, status=401)

    nurse = Nurse.objects.get(user=request.user)
    slot = get_object_or_404(TimeSlots, id=slot_id, nurse=nurse)
    slot.delete()

    return Response({"message": "Time slot deleted successfully"}, status=200)


############################### DOCTOR ROOOLE ######################################
# ─────────────────────────────────────────────
# DASHBOARD
# ─────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def doctor_dashboard(request):
    if request.user.role != 'doctor':
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

    doctor_reqs = doctor.doctor_requests.all()
    pending = doctor_reqs.filter(status__in=['pending', 'edited']).count()
    completed = doctor_reqs.filter(status='completed').count()

    average_rating = (
        round(doctor.rates.aggregate(Avg('rate'))['rate__avg'] or 0)
        if doctor.rates.exists() else 0
    )

    days = list(
        get_provider_days_with_dates(
            TimeSlots.objects.filter(doctor=doctor).values_list(
                'day', flat=True).distinct()
        )
    )

    selected_day = request.GET.get('day') or (days[0]['day'] if days else None)

    morning_slots = []
    evening_slots = []

    if selected_day:
        for slot in TimeSlots.objects.filter(doctor=doctor, day=selected_day).order_by('time'):
            slot_data = {
                "id":   slot.id,
                "time": slot.time.strftime("%H:%M"),
                "day":  slot.day,
            }
            if slot.time < time(12, 0):
                morning_slots.append(slot_data)
            else:
                evening_slots.append(slot_data)

    return Response({
        "name":           name,
        "specification":  specification,
        "price":          price,
        "governorate":    governorate,
        "address":        address,
        "average_rating": average_rating,
        "brief":          brief,
        "profile_pic":    profile_pic,
        "pending":        pending,
        "completed":      completed,
        "phone_number":   phone_num,
        "email":          email,
        "days":           [{"day": d["day"], "date": str(d["date"])} for d in days],
        "selected_day":   selected_day,
        "morning_slots":  morning_slots,
        "evening_slots":  evening_slots,
    }, status=200)


# ─────────────────────────────────────────────
# EDIT PROFILE
# ─────────────────────────────────────────────

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def edit_doctor_profile(request):
    if request.user.role != 'doctor':
        return Response({"error": "Unauthorized"}, status=401)

    User = get_user_model()
    doctor = Doctor.objects.get(user=request.user)

    if request.method == 'GET':
        return Response({
            "name":         "Dr. " + doctor.user.first_name + " " + doctor.user.last_name,
            "specification": doctor.get_specification_display(),
            "profile_pic":  doctor.profile_pic.url if doctor.profile_pic else None,
            "username":     doctor.user.username,
            "phone_number": doctor.phone_number,
            "address":      doctor.address,
            "brief":        doctor.brief,
            "price":        doctor.price,
            "governorate":  doctor.governorate,
        }, status=200)

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
        return Response({"error": "Can't use <,> or forbidden words."}, status=400)

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


# ─────────────────────────────────────────────
# REQUESTS
# ─────────────────────────────────────────────
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def doctor_requests(request, type):
    if request.user.role != 'doctor':
        return Response({"error": "Unauthorized"}, status=401)

    doctor = Doctor.objects.get(user=request.user)
    all_reqs = doctor.doctor_requests.all()

    def base_fields(req):
        """Shared fields across all statuses."""
        return {
            "id":                  req.id,
            "status":              req.status,
            "date":                str(req.date),
            "time":                str(req.time),
            "requester_name":      req.requester_name,
            "requester_phone":     req.requester_phone,
            "is_donor":            req.is_donor,
            "disease_description": req.disease_description,
            "address":             req.address,
            "governorate":         req.governorate,
            "total_price":         str(req.total_price),
            "net_income":          str(req.net_income),
        }

    if type in ('pending', 'edited') or type is None:
        pending_list = []
        for req in all_reqs.filter(status='pending').order_by('-date', '-time'):
            req_day = req.date.strftime('%A').lower()
            day_slots = TimeSlots.objects.filter(
                doctor=doctor, day=req_day).order_by('time')
            pending_list.append({
                **base_fields(req),
                "available_slots": [s.time.strftime("%H:%M") for s in day_slots],
            })

        edited_list = []
        for req in all_reqs.filter(status='edited').order_by('-date', '-time'):
            req_day = req.date.strftime('%A').lower()
            day_slots = TimeSlots.objects.filter(
                doctor=doctor, day=req_day).order_by('time')
            edited_list.append({
                **base_fields(req),
                "available_slots": [s.time.strftime("%H:%M") for s in day_slots],
            })

        return Response({"pending": pending_list, "edited": edited_list}, status=200)

    elif type == 'accepted':
        accepted_list = [base_fields(req)
                         for req in all_reqs.filter(status='accepted').order_by('-date', '-time')]
        return Response({"accepted": accepted_list}, status=200)

    elif type == 'completed':
        completed_list = [base_fields(req)
                          for req in all_reqs.filter(status='completed').order_by('-date', '-time')]
        return Response({"completed": completed_list}, status=200)

    return Response({"error": "Invalid request type"}, status=400)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def request_action(request, request_id):
    if request.user.role != 'doctor':
        return Response({"error": "Unauthorized"}, status=401)

    doctor = Doctor.objects.get(user=request.user)
    req = get_object_or_404(DoctorRequest, id=request_id, doctor=doctor)
    action = request.data.get('action')

    if action == 'reject':
        req.status = 'rejected'
        req.save()
        return Response({"message": "Request rejected"}, status=200)

    elif action == 'accept':
        req.status = 'accepted'
        req.save()
        return Response({"message": "Request accepted"}, status=200)

    elif action == 'reschedule':
        new_time = request.data.get('new_time')
        if not new_time:
            return Response({"error": "new_time is required for reschedule."}, status=400)
        try:
            h, m = new_time.split(':')
            new_t = time(int(h), int(m))
            if new_t == req.time:
                req.status = 'accepted'
            else:
                req.time = new_t
                req.status = 'edited'
            req.save()
            return Response({"message": f"Request {req.status}"}, status=200)
        except (ValueError, AttributeError):
            return Response({"error": "Invalid time format. Use HH:MM."}, status=400)

    return Response({"error": "Invalid action. Use 'accept', 'reject', or 'reschedule'."}, status=400)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_done_doctor(request, request_id):
    if request.user.role != 'doctor':
        return Response({"error": "Unauthorized"}, status=401)

    doctor = Doctor.objects.get(user=request.user)
    req = get_object_or_404(DoctorRequest, id=request_id,
                            doctor=doctor, status='accepted')

    req.doctor_done = True
    if req.patient_done:
        req.status = 'completed'
    req.save()

    return Response({
        "message": "Marked as done",
        "status":  req.status,
    }, status=200)

# ─────────────────────────────────────────────
# TIME SLOTS
# ─────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_time_slots(request):
    if request.user.role != 'doctor':
        return Response({"error": "Unauthorized"}, status=401)

    doctor = Doctor.objects.get(user=request.user)
    days = get_ordered_week_days()
    selected_day = request.GET.get('day') or days[0]['day']

    morning_slots = []
    evening_slots = []

    for slot in TimeSlots.objects.filter(doctor=doctor, day=selected_day).order_by('time'):
        slot_data = {
            "id":   slot.id,
            "time": slot.time.strftime("%H:%M"),
            "day":  slot.day,
        }
        if slot.time < time(12, 0):
            morning_slots.append(slot_data)
        else:
            evening_slots.append(slot_data)

    return Response({
        "days":          [{"day": d["day"], "date": str(d["date"])} for d in days],
        "selected_day":  selected_day,
        "morning_slots": morning_slots,
        "evening_slots": evening_slots,
    }, status=200)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def save_time_slots(request):
    if request.user.role != 'doctor':
        return Response({"error": "Unauthorized"}, status=401)

    doctor = Doctor.objects.get(user=request.user)
    days_data = request.data.get('days')

    if not days_data:
        day = request.data.get('day')
        times = request.data.get('times', [])
        if not day:
            return Response({"error": "Missing 'day' field."}, status=400)
        days_data = {day: times}

    saved = {}
    for day, times in days_data.items():
        TimeSlots.objects.filter(doctor=doctor, day=day).delete()
        created = []
        for t_str in times:
            try:
                h, m = t_str.split(':')
                TimeSlots.objects.get_or_create(
                    doctor=doctor, day=day, time=time(int(h), int(m)))
                created.append(t_str)
            except (ValueError, AttributeError):
                continue
        saved[day] = created

    return Response({
        "message": "Time slots saved successfully",
        "saved":   saved,
    }, status=200)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_time_slot(request, slot_id):
    if request.user.role != 'doctor':
        return Response({"error": "Unauthorized"}, status=401)

    doctor = Doctor.objects.get(user=request.user)
    slot = get_object_or_404(TimeSlots, id=slot_id, doctor=doctor)
    slot.delete()

    return Response({"message": "Time slot deleted successfully"}, status=200)

############################### patient Rooole ################################################
# ─────────────────────────────────────────────
# DASHBOARD
# ─────────────────────────────────────────────


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def patient_dashboard(request):
    if request.user.role != 'patient':
        return Response({"error": "Unauthorized"}, status=401)

    try:
        patient = Patient.objects.get(user=request.user)
    except Patient.DoesNotExist:
        return Response({"error": "Patient profile not found"}, status=404)

    name = patient.user.first_name + " " + patient.user.last_name
    profile_pic = patient.profile_pic.url if patient.profile_pic else None
    email = patient.user.email
    phone_num = patient.phone_number
    governorate = patient.get_governorate_display()
    address = patient.address

    doctor_reqs = patient.doctor_requests.all()
    doctor_total = doctor_reqs.count()
    doctor_pending = doctor_reqs.filter(
        status__in=['pending', 'edited']).count()
    doctor_accepted = doctor_reqs.filter(status='accepted').count()
    doctor_completed = doctor_reqs.filter(status='completed').count()

    nurse_reqs = patient.nurse_requests.all()
    nurse_total = nurse_reqs.count()
    nurse_pending = nurse_reqs.filter(status__in=['pending', 'edited']).count()
    nurse_accepted = nurse_reqs.filter(status='accepted').count()
    nurse_completed = nurse_reqs.filter(status='completed').count()

    return Response({
        "name":        name,
        "profile_pic": profile_pic,
        "email":       email,
        "phone_number": phone_num,
        "governorate": governorate,
        "address":     address,
        "doctor": {
            "total":     doctor_total,
            "pending":   doctor_pending,
            "accepted":  doctor_accepted,
            "completed": doctor_completed,
        },
        "nurse": {
            "total":     nurse_total,
            "pending":   nurse_pending,
            "accepted":  nurse_accepted,
            "completed": nurse_completed,
        },
        "combined": {
            "total":     doctor_total + nurse_total,
            "pending":   doctor_pending + nurse_pending,
            "accepted":  doctor_accepted + nurse_accepted,
            "completed": doctor_completed + nurse_completed,
        },
    }, status=200)


# ─────────────────────────────────────────────
# EDIT PROFILE
# ─────────────────────────────────────────────

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def edit_patient_profile(request):
    if request.user.role != 'patient':
        return Response({"error": "Unauthorized"}, status=401)

    User = get_user_model()
    try:
        patient = Patient.objects.get(user=request.user)
    except Patient.DoesNotExist:
        return Response({"error": "Patient profile not found"}, status=404)

    if request.method == 'GET':
        return Response({
            "name":         patient.user.first_name + " " + patient.user.last_name,
            "username":     patient.user.username,
            "phone_number": patient.phone_number,
            "address":      patient.address,
            "governorate":  patient.governorate,
            "profile_pic":  patient.profile_pic.url if patient.profile_pic else None,
        }, status=200)

    phone_number = request.data.get('phone_number')
    address = request.data.get('address')
    username = request.data.get('username')
    governorate = request.data.get('governorate')

    if User.objects.filter(username=username).exclude(id=request.user.id).exists():
        return Response({"error": "Username already exists"}, status=400)

    if not validations.validate_username(username):
        return Response({"error": "Username must be lowercase, allowed letters, numbers, _ or ., and cannot contain forbidden words."}, status=400)

    if not validations.validate_phone(phone_number):
        return Response({"error": "Phone number must start with 0 or 1."}, status=400)

    if not validations.validate_address(address):
        return Response({"error": "Can't use <,> or forbidden words."}, status=400)

    patient.user.username = username
    patient.phone_number = phone_number
    patient.address = address
    patient.governorate = governorate
    patient.profile_pic = request.FILES.get(
        'profile_pic') or patient.profile_pic
    patient.user.save()
    patient.save()

    return Response({"message": "Profile updated successfully"}, status=200)


# ─────────────────────────────────────────────
# REQUESTS — LIST
# ─────────────────────────────────────────────

# ── helpers ─────────────────────────────────────────────────────────────────

def _get_patient(request):
    """Returns (patient, None) or (None, error Response)."""
    try:
        return Patient.objects.get(user=request.user), None
    except Patient.DoesNotExist:
        return None, Response({"error": "Patient profile not found"}, status=404)


def _doctor_request_fields(req):
    return {
        "id":                  req.id,
        "status":              req.status,
        "date":                str(req.date),
        "time":                str(req.time),
        "disease_description": req.disease_description,
        "address":             req.address,
        "governorate":         req.governorate,
        "total_price":         str(req.total_price),
        "doctor": {
            "id":            req.doctor.id,
            "name":          f"Dr. {req.doctor.user.first_name} {req.doctor.user.last_name}",
            "specification": req.doctor.get_specification_display(),
            "profile_pic":   req.doctor.profile_pic.url if req.doctor.profile_pic else None,
        } if req.doctor else None,
    }


def _nurse_request_fields(req):
    return {
        "id":                  req.id,
        "status":              req.status,
        "date":                str(req.date),
        "time":                str(req.time),
        "disease_description": req.disease_description,
        "address":             req.address,
        "governorate":         req.governrate,
        "net_income":          str(req.net_income),
        "services": [
            {"id": s.id, "name": s.name, "price": str(s.price)}
            for s in req.service.all()
        ],
        "nurse": {
            "id":          req.nurse.id,
            "name":        f"{req.nurse.user.first_name} {req.nurse.user.last_name}",
            "profile_pic": req.nurse.profile_pic.url if req.nurse.profile_pic else None,
        } if req.nurse else None,
    }


# ── patient_requests ─────────────────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def patient_requests(request, category, type):
    if request.user.role != 'patient':
        return Response({"error": "Unauthorized"}, status=401)

    patient, err = _get_patient(request)
    if err:
        return err

    # ── DOCTOR ──────────────────────────────────────────────────────────────
    if category == 'doctor':
        all_reqs = patient.doctor_requests.all()

        if type == 'booking':
            doctors = []
            # Only doctors who actually have time slots (mirrors web view)
            for doctor in Doctor.objects.filter(slots__isnull=False).distinct():
                avg = doctor.rates.aggregate(Avg('rate'))['rate__avg'] or 0
                doctors.append({
                    "id":            doctor.id,
                    "name":          f"Dr. {doctor.user.first_name} {doctor.user.last_name}",
                    "specification": doctor.get_specification_display(),
                    "governorate":   doctor.get_governorate_display(),
                    "address":       doctor.address,
                    "price":         str(doctor.price),
                    "avg_rating":    round(avg),
                    "profile_pic":   doctor.profile_pic.url if doctor.profile_pic else None,
                    "brief":         doctor.brief,
                })
            return Response({
                "doctors":         doctors,
                "specializations": SPECIFICATIONS,
                "governorates":    GOVERNORATES,
            }, status=200)

        elif type == 'pending':
            pending_list = [_doctor_request_fields(r)
                            for r in all_reqs.filter(status='pending').order_by('-date', '-time')]
            edited_list  = [_doctor_request_fields(r)
                            for r in all_reqs.filter(status='edited').order_by('-date', '-time')]
            return Response({"pending": pending_list, "edited": edited_list}, status=200)

        elif type == 'accepted':
            accepted_list = [_doctor_request_fields(r)
                             for r in all_reqs.filter(status='accepted').order_by('-date', '-time')]
            return Response({"accepted": accepted_list}, status=200)

        elif type == 'done':
            completed_list = [_doctor_request_fields(r)
                              for r in all_reqs.filter(status='completed').order_by('-date', '-time')]
            return Response({"completed": completed_list}, status=200)

    # ── NURSE ────────────────────────────────────────────────────────────────
    elif category == 'nurse':
        all_reqs = patient.nurse_requests.all()

        if type == 'booking':
            nurses = []
            # Only nurses who have slots (mirrors web view)
            for nurse in Nurse.objects.filter(slots__isnull=False).distinct():
                avg = nurse.rates.aggregate(Avg('rate'))['rate__avg'] or 0
                min_price = nurse.nurse_services.aggregate(Min('price'))['price__min']
                nurses.append({
                    "id":          nurse.id,
                    "name":        f"{nurse.user.first_name} {nurse.user.last_name}",
                    "governorate": nurse.get_governorate_display(),
                    "address":     nurse.address,
                    "avg_rating":  round(avg),
                    "min_price":   str(min_price) if min_price is not None else None,
                    "profile_pic": nurse.profile_pic.url if nurse.profile_pic else None,
                    "brief":       nurse.brief,
                })
            return Response({
                "nurses":       nurses,
                "governorates": GOVERNORATES,
            }, status=200)

        elif type == 'pending':
            pending_list = [_nurse_request_fields(r)
                            for r in all_reqs.filter(status='pending').order_by('-date', '-time')]
            edited_list  = [_nurse_request_fields(r)
                            for r in all_reqs.filter(status='edited').order_by('-date', '-time')]
            return Response({"pending": pending_list, "edited": edited_list}, status=200)

        elif type == 'accepted':
            accepted_list = [_nurse_request_fields(r)
                             for r in all_reqs.filter(status='accepted').order_by('-date', '-time')]
            return Response({"accepted": accepted_list}, status=200)

        elif type == 'done':
            completed_list = [_nurse_request_fields(r)
                              for r in all_reqs.filter(status='completed').order_by('-date', '-time')]
            return Response({"completed": completed_list}, status=200)

    return Response({"error": "Invalid category or type."}, status=400)


# ── DOCTOR BOOKING ────────────────────────────────────────────────────────────

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def book_appointment(request, doctor_id):
    if request.user.role != 'patient':
        return Response({"error": "Unauthorized"}, status=401)

    patient, err = _get_patient(request)
    if err:
        return err

    doctor = get_object_or_404(Doctor, id=doctor_id)

    raw_days = TimeSlots.objects.filter(
        doctor=doctor).values_list('day', flat=True).distinct()
    days_with_dates = get_provider_days_with_dates(raw_days)

    days_list = []
    all_slots = {}
    for d in days_with_dates:
        slots = TimeSlots.objects.filter(
            doctor=doctor, day=d['day']).order_by('time')
        all_slots[d['day']] = {
            "morning": [s.time.strftime('%H:%M') for s in slots if s.time < time_type(12, 0)],
            "evening": [s.time.strftime('%H:%M') for s in slots if s.time >= time_type(12, 0)],
        }
        days_list.append({
            "day":       d['day'],
            "full_date": d['date'].isoformat(),
            "date_num":  d['date'].strftime('%d'),
            "month":     d['date'].strftime('%b').upper(),
        })

    if request.method == 'GET':
        avg = doctor.rates.aggregate(Avg('rate'))['rate__avg'] or 0
        return Response({
            "doctor": {
                "id":            doctor.id,
                "name":          f"Dr. {doctor.user.first_name} {doctor.user.last_name}",
                "specification": doctor.get_specification_display(),
                "governorate":   doctor.get_governorate_display(),
                "address":       doctor.address,
                "price":         str(doctor.price),
                "avg_rating":    round(avg),
                "profile_pic":   doctor.profile_pic.url if doctor.profile_pic else None,
                "brief":         doctor.brief,
            },
            "days":         days_list,
            "all_slots":    all_slots,
            "governorates": GOVERNORATES,
        }, status=200)

    # POST
    disease_description = request.data.get('disease_description', '').strip()
    governorate         = request.data.get('governorate', '').strip()
    address             = request.data.get('address', '').strip()
    selected_date       = request.data.get('date', '').strip()
    selected_time       = request.data.get('time', '').strip()

    if not selected_date:
        return Response({"error": "Please select a day."}, status=400)
    if not selected_time:
        return Response({"error": "Please select a time slot."}, status=400)
    if not disease_description:
        return Response({"error": "Please describe your symptoms."}, status=400)

    DoctorRequest.objects.create(
        patient=patient,
        doctor=doctor,
        date=dt.fromisoformat(selected_date),
        time=selected_time,
        total_price=doctor.price,
        net_income=doctor.price * 75 / 100,
        disease_description=disease_description,
        governorate=governorate,
        address=address,
        status='pending',
    )
    return Response({"message": "Appointment booked successfully"}, status=201)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def cancel_request(request, request_id):
    if request.user.role != 'patient':
        return Response({"error": "Unauthorized"}, status=401)

    patient, err = _get_patient(request)
    if err:
        return err

    req = get_object_or_404(DoctorRequest, id=request_id, patient=patient)
    req.status = 'rejected'
    req.save()
    return Response({"message": "Request cancelled"}, status=200)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def accept_reschedule(request, request_id):
    if request.user.role != 'patient':
        return Response({"error": "Unauthorized"}, status=401)

    patient, err = _get_patient(request)
    if err:
        return err

    req = get_object_or_404(DoctorRequest, id=request_id,
                            patient=patient, status='edited')
    req.status = 'accepted'
    req.save()
    return Response({"message": "Reschedule accepted"}, status=200)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_done(request, request_id):
    if request.user.role != 'patient':
        return Response({"error": "Unauthorized"}, status=401)

    patient, err = _get_patient(request)
    if err:
        return err

    req = get_object_or_404(DoctorRequest, id=request_id,
                            patient=patient, status='accepted')
    req.patient_done = True
    if req.doctor_done:
        req.status = 'completed'
    req.save()
    return Response({"message": "Marked as done", "status": req.status}, status=200)


# ── NURSE BOOKING ─────────────────────────────────────────────────────────────

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def book_nurse(request, nurse_id):
    if request.user.role != 'patient':
        return Response({"error": "Unauthorized"}, status=401)

    patient, err = _get_patient(request)
    if err:
        return err

    nurse = get_object_or_404(Nurse, id=nurse_id)

    raw_days = TimeSlots.objects.filter(
        nurse=nurse).values_list('day', flat=True).distinct()
    days_with_dates = get_provider_days_with_dates(raw_days)

    days_list = []
    all_slots = {}
    for d in days_with_dates:
        slots = TimeSlots.objects.filter(
            nurse=nurse, day=d['day']).order_by('time')
        all_slots[d['day']] = {
            "morning": [s.time.strftime('%H:%M') for s in slots if s.time < time_type(12, 0)],
            "evening": [s.time.strftime('%H:%M') for s in slots if s.time >= time_type(12, 0)],
        }
        days_list.append({
            "day":       d['day'],
            "full_date": d['date'].isoformat(),
            "date_num":  d['date'].strftime('%d'),
            "month":     d['date'].strftime('%b').upper(),
        })

    if request.method == 'GET':
        avg = nurse.rates.aggregate(Avg('rate'))['rate__avg'] or 0
        services = [
            {"id": s.id, "name": s.name, "description": s.description, "price": str(s.price)}
            for s in nurse.nurse_services.all()
        ]
        return Response({
            "nurse": {
                "id":          nurse.id,
                "name":        f"{nurse.user.first_name} {nurse.user.last_name}",
                "governorate": nurse.get_governorate_display(),
                "address":     nurse.address,
                "avg_rating":  round(avg),
                "profile_pic": nurse.profile_pic.url if nurse.profile_pic else None,
                "brief":       nurse.brief,
            },
            "services":     services,
            "days":         days_list,
            "all_slots":    all_slots,
            "governorates": GOVERNORATES,
        }, status=200)

    # POST
    service_ids         = request.data.get('services', [])
    disease_description = request.data.get('disease_description', '').strip()
    governorate         = request.data.get('governorate', '').strip()
    address             = request.data.get('address', '').strip()
    selected_date       = request.data.get('date', '').strip()
    selected_time       = request.data.get('time', '').strip()

    if not service_ids:
        return Response({"error": "Please select at least one service."}, status=400)
    if not selected_date:
        return Response({"error": "Please select a day."}, status=400)
    if not selected_time:
        return Response({"error": "Please select a time slot."}, status=400)
    if not disease_description:
        return Response({"error": "Please describe your condition."}, status=400)

    selected_services = Service.objects.filter(id__in=service_ids, nurse=nurse)
    if not selected_services.exists():
        return Response({"error": "Invalid services selected."}, status=400)

    total = sum(s.price for s in selected_services)
    req = NurseRequest.objects.create(
        patient=patient,
        nurse=nurse,
        date=dt.fromisoformat(selected_date),
        time=selected_time,
        governrate=governorate,
        address=address,
        disease_description=disease_description,
        net_income=total,
        status='pending',
    )
    req.service.set(selected_services)
    return Response({"message": "Nurse appointment booked successfully"}, status=201)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def cancel_nurse_request(request, request_id):
    if request.user.role != 'patient':
        return Response({"error": "Unauthorized"}, status=401)

    patient, err = _get_patient(request)
    if err:
        return err

    req = get_object_or_404(NurseRequest, id=request_id, patient=patient)
    req.status = 'rejected'
    req.save()
    return Response({"message": "Nurse request cancelled"}, status=200)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def accept_nurse_reschedule(request, request_id):
    if request.user.role != 'patient':
        return Response({"error": "Unauthorized"}, status=401)

    patient, err = _get_patient(request)
    if err:
        return err

    req = get_object_or_404(NurseRequest, id=request_id,
                            patient=patient, status='edited')
    req.status = 'accepted'
    req.save()
    return Response({"message": "Nurse reschedule accepted"}, status=200)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_nurse_done(request, request_id):
    if request.user.role != 'patient':
        return Response({"error": "Unauthorized"}, status=401)

    patient, err = _get_patient(request)
    if err:
        return err

    req = get_object_or_404(NurseRequest, id=request_id,
                            patient=patient, status='accepted')
    req.patient_done = True
    if req.nurse_done:
        req.status = 'completed'
    req.save()
    return Response({"message": "Marked as done", "status": req.status}, status=200)