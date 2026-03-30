from django.shortcuts import redirect, render
from accounts import validations
from accounts.models import Patient, Doctor
from doctor.models import DoctorRequest
from django.contrib.auth import get_user_model
from django.contrib.auth.decorators import login_required


@login_required
def patient_dashboard(request):
    if request.user.role != "patient":
        return redirect("login")

    patient = Patient.objects.get(user=request.user)
    name = patient.user.first_name + " " + patient.user.last_name
    profile_pic = patient.profile_pic
    email = patient.user.email
    phone_num = patient.phone_number
    governorate = patient.get_governorate_display()
    address = patient.address
    brief = patient.brief

    patient_requests = patient.doctor_requests.all()
    doctor_pending = patient_requests.filter(status__in=['pending', 'edited']).count()
    doctor_completed = patient_requests.filter(status='completed').count()
    doctor_accepted = patient_requests.filter(status='accepted').count()
    doctor_total = patient_requests.count()

    return render(request, 'patient/profile.html', {
        'name': name,
        'profile_pic': profile_pic,
        'email': email,
        'phone_number': phone_num,
        'governorate': governorate,
        'address': address,
        'brief': brief,
        'doctor_pending': doctor_pending,
        'doctor_completed': doctor_completed,
        'doctor_accepted': doctor_accepted,
        'doctor_total': doctor_total,
    })


@login_required
def edit_patient_profile(request):
    if request.user.role != "patient":
        return redirect("login")

    errors = {}
    patient = Patient.objects.get(user=request.user)
    name = patient.user.first_name + " " + patient.user.last_name
    profile_pic = patient.profile_pic

    User = get_user_model()

    if request.method == 'POST':
        phone_number = request.POST.get('phone_number')
        address = request.POST.get('address')
        brief = request.POST.get('brief')
        username = request.POST.get('username')

        if User.objects.filter(username=username).exclude(id=request.user.id).exists():
            errors['exist_username'] = "Username already exists"
            return render(request, 'patient/edit_profile.html', {
                'errors': errors,
                'patient': patient,
                'name': name,
                'profile_pic': profile_pic,
            })

        if not validations.validate_username(username):
            errors['username'] = "Username must be lowercase, allowed letters, numbers, _ or ., and cannot contain forbidden words."
            return render(request, 'patient/edit_profile.html', {
                'errors': errors,
                'patient': patient,
                'name': name,
                'profile_pic': profile_pic,
            })

        if not validations.validate_phone(phone_number):
            errors['phone_invalid'] = "Phone number must start with 0 or 1."
            return render(request, 'patient/edit_profile.html', {
                'errors': errors,
                'patient': patient,
                'name': name,
                'profile_pic': profile_pic,
            })

        if not validations.validate_address(address):
            errors['address'] = "Can't use <,> or forbidden words"
            return render(request, 'patient/edit_profile.html', {
                'errors': errors,
                'patient': patient,
                'name': name,
                'profile_pic': profile_pic,
            })

        if not validations.validate_address(brief):
            errors['brief'] = "Brief can't contain forbidden words."
            return render(request, 'patient/edit_profile.html', {
                'errors': errors,
                'patient': patient,
                'name': name,
                'profile_pic': profile_pic,
            })

        patient.user.username = username
        patient.phone_number = phone_number
        patient.address = address
        patient.brief = brief
        patient.governorate = request.POST.get('governorate')
        patient.profile_pic = request.FILES.get('profile_pic') or patient.profile_pic
        patient.user.save()
        patient.save()
        return redirect('patient:patient_dashboard')

    return render(request, 'patient/edit_profile.html', {
        'patient': patient,
        'errors': errors,
        'name': name,
        'profile_pic': profile_pic,
    })


@login_required
def patient_requests(request, category, type):
    if request.user.role != "patient":
        return redirect("login")

    patient = Patient.objects.get(user=request.user)
    name = patient.user.first_name + " " + patient.user.last_name
    profile_pic = patient.profile_pic

    context_base = {
        'name': name,
        'profile_pic': profile_pic,
        'category': category,
        'type': type,
    }

    if category == 'doctor':
        all_requests = patient.doctor_requests.all()

        if type == 'booking':
            doctors = Doctor.objects.all()
            return render(request, 'patient/doctor_booking.html', {
                **context_base,
                'doctors': doctors,
            })

        elif type == 'pending':
            pending = all_requests.filter(status='pending').order_by('-date', '-time')
            edited = all_requests.filter(status='edited').order_by('-date', '-time')
            return render(request, 'patient/doctor_pending.html', {
                **context_base,
                'pending': pending,
                'edited': edited,
            })

        elif type == 'accepted':
            accepted = all_requests.filter(status='accepted').order_by('-date', '-time')
            return render(request, 'patient/doctor_accepted.html', {
                **context_base,
                'accepted': accepted,
            })

        elif type == 'done':
            completed = all_requests.filter(status='completed').order_by('-date', '-time')
            return render(request, 'patient/doctor_done.html', {
                **context_base,
                'completed': completed,
            })

    return redirect('patient:patient_dashboard')


@login_required
def book_appointment(request, doctor_id):
    if request.user.role != "patient":
        return redirect("login")

    patient = Patient.objects.get(user=request.user)
    name = patient.user.first_name + " " + patient.user.last_name
    profile_pic = patient.profile_pic

    try:
        doctor = Doctor.objects.get(id=doctor_id)
    except Doctor.DoesNotExist:
        return redirect('patient:patient_requests', category='doctor', type='booking')

    errors = {}

    if request.method == 'POST':
        date = request.POST.get('date')
        time = request.POST.get('time')
        disease_description = request.POST.get('disease_description', '')
        governorate = request.POST.get('governorate', patient.governorate)
        address = request.POST.get('address', patient.address)

        if not date or not time:
            errors['datetime'] = "Please select a date and time."
        elif not disease_description:
            errors['description'] = "Please describe your symptoms."
        else:
            DoctorRequest.objects.create(
                patient=patient,
                doctor=doctor,
                date=date,
                time=time,
                disease_description=disease_description,
                governrate=governorate,
                address=address,
                total_price=doctor.price,
                status='pending',
            )
            return redirect('patient:patient_requests', category='doctor', type='pending')

    from accounts.models import TimeSlots, get_provider_days_with_dates
    from datetime import time as time_obj

    days = TimeSlots.objects.filter(doctor=doctor).values_list('day', flat=True).distinct()
    days = get_provider_days_with_dates(days)

    morning_slots = []
    evening_slots = []

    if request.method == 'POST' and request.POST.get('day'):
        input_day = request.POST.get('day')
        slots = TimeSlots.objects.filter(doctor=doctor, day=input_day).order_by('time')
        for slot in slots:
            if slot.time < time_obj(12, 0):
                morning_slots.append(slot)
            else:
                evening_slots.append(slot)

    return render(request, 'patient/book_appointment.html', {
        'name': name,
        'profile_pic': profile_pic,
        'doctor': doctor,
        'days': days,
        'morning_slots': morning_slots,
        'evening_slots': evening_slots,
        'errors': errors,
        'patient': patient,
    })