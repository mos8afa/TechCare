from django.shortcuts import redirect, render
from accounts import validations
from accounts.models import Patient, Doctor, SPECIFICATIONS, GOVERNORATES
from doctor.models import DoctorRequest
from django.contrib.auth import get_user_model
from django.contrib.auth.decorators import login_required
from django.db.models import Avg


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

        patient.user.username = username
        patient.phone_number = phone_number
        patient.address = address
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
            # annotate avg rating on each doctor
            for doctor in doctors:
                avg = doctor.rates.aggregate(Avg('rate'))['rate__avg'] or 0
                doctor.avg_rating = round(avg)
            return render(request, 'patient/doctor_booking.html', {
                **context_base,
                'doctors': doctors,
                'specializations': SPECIFICATIONS,
                'governorates': GOVERNORATES,
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
    if request.user.role != 'patient':
        return redirect('login')

    patient = Patient.objects.get(user=request.user)
    doctor = Doctor.objects.get(id=doctor_id)

    # Build available days (only days that have slots)
    from accounts.models import TimeSlots, get_provider_days_with_dates
    from datetime import date, time as time_type

    raw_days = TimeSlots.objects.filter(doctor=doctor).values_list('day', flat=True).distinct()
    days_with_dates = get_provider_days_with_dates(raw_days)

    # Enrich each day with display fields needed by the template
    for d in days_with_dates:
        d['day_name']  = d['day']
        d['short_name'] = d['day'][:3].upper()
        d['date_num']  = d['date'].strftime('%d')
        d['month_name'] = d['date'].strftime('%b').upper()
        d['full_date'] = d['date'].isoformat()

    selected_day  = request.GET.get('day') or (days_with_dates[0]['day'] if days_with_dates else None)
    selected_date = next((d['full_date'] for d in days_with_dates if d['day'] == selected_day), '')

    morning_slots = []
    evening_slots = []
    if selected_day:
        slots = TimeSlots.objects.filter(doctor=doctor, day=selected_day).order_by('time')
        for slot in slots:
            if slot.time < time_type(12, 0):
                morning_slots.append(slot)
            else:
                evening_slots.append(slot)

    errors = {}

    if request.method == 'POST':
        disease_description = request.POST.get('disease_description', '').strip()
        governorate         = request.POST.get('governorate', '').strip()
        address             = request.POST.get('address', '').strip()
        selected_date_post  = request.POST.get('date', '').strip()
        selected_time_post  = request.POST.get('time', '').strip()

        if not selected_date_post:
            errors['date'] = 'Please select a day.'
        if not selected_time_post:
            errors['time'] = 'Please select a time slot.'
        if not disease_description:
            errors['description'] = 'Please describe your symptoms.'

        if not errors:
            from datetime import datetime as dt
            DoctorRequest.objects.create(
                patient=patient,
                doctor=doctor,
                date=dt.fromisoformat(selected_date_post),
                time=selected_time_post,
                total_price=doctor.price,
                net_income=doctor.price,
                disease_description=disease_description,
                governorate=governorate,
                address=address,
                status='pending',
            )
            return redirect('patient:patient_requests', category='doctor', type='pending')

    return render(request, 'patient/book_appointment.html', {
        'doctor': doctor,
        'patient': patient,
        'days': days_with_dates,
        'selected_day': selected_day,
        'selected_date': selected_date,
        'morning_slots': morning_slots,
        'evening_slots': evening_slots,
        'errors': errors,
    })