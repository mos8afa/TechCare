from django.shortcuts import redirect, render
from accounts import validations
from accounts.models import Patient, Doctor, Nurse, SPECIFICATIONS, GOVERNORATES
from doctor.models import DoctorRequest
from django.contrib.auth import get_user_model
from django.contrib.auth.decorators import login_required
from django.db.models import Avg
from accounts.models import TimeSlots, get_provider_days_with_dates
from datetime import time as time_type
from datetime import datetime as dt



@login_required
def patient_dashboard(request):
    if request.user.role != "patient":
        return redirect("login")

    patient = Patient.objects.get(user=request.user)
    name        = patient.user.first_name + " " + patient.user.last_name
    profile_pic = patient.profile_pic
    email       = patient.user.email
    phone_num   = patient.phone_number
    governorate = patient.get_governorate_display()
    address     = patient.address

    # Doctor requests
    doctor_reqs       = patient.doctor_requests.all()
    doctor_total      = doctor_reqs.count()
    doctor_pending    = doctor_reqs.filter(status__in=['pending', 'edited']).count()
    doctor_accepted   = doctor_reqs.filter(status='accepted').count()
    doctor_completed  = doctor_reqs.filter(status='completed').count()

    # Nurse requests
    from nurse.models import NurseRequest
    nurse_reqs      = patient.nurse_requests.all()
    nurse_total     = nurse_reqs.count()
    nurse_pending   = nurse_reqs.filter(status__in=['pending', 'edited']).count()
    nurse_accepted  = nurse_reqs.filter(status='accepted').count()
    nurse_completed = nurse_reqs.filter(status='completed').count()

    # All combined
    total_requests    = doctor_total + nurse_total
    total_pending     = doctor_pending + nurse_pending
    total_accepted    = doctor_accepted + nurse_accepted
    total_completed   = doctor_completed + nurse_completed

    return render(request, 'patient/profile.html', {
        'name': name,
        'profile_pic': profile_pic,
        'email': email,
        'phone_number': phone_num,
        'governorate': governorate,
        'address': address,
        # doctor
        'doctor_total': doctor_total,
        'doctor_pending': doctor_pending,
        'doctor_accepted': doctor_accepted,
        'doctor_completed': doctor_completed,
        # nurse
        'nurse_total': nurse_total,
        'nurse_pending': nurse_pending,
        'nurse_accepted': nurse_accepted,
        'nurse_completed': nurse_completed,
        # combined
        'total_requests': total_requests,
        'total_pending': total_pending,
        'total_accepted': total_accepted,
        'total_completed': total_completed,
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

    if category == 'nurse':
        from nurse.models import NurseRequest
        all_nurse = patient.nurse_requests.all()

        if type == 'booking':
            nurses = Nurse.objects.all()
            for nurse in nurses:
                avg = nurse.rates.aggregate(Avg('rate'))['rate__avg'] or 0
                nurse.avg_rating = round(avg)
            return render(request, 'patient/nurse_booking.html', {
                **context_base,
                'nurses': nurses,
                'governorates': GOVERNORATES,
            })

        elif type == 'pending':
            pending = all_nurse.filter(status='pending').order_by('-date', '-time')
            edited  = all_nurse.filter(status='edited').order_by('-date', '-time')
            return render(request, 'patient/nurse_pending.html', {
                **context_base,
                'pending': pending,
                'edited': edited,
            })

        elif type == 'accepted':
            accepted = all_nurse.filter(status='accepted').order_by('-date', '-time')
            return render(request, 'patient/nurse_accepted.html', {
                **context_base,
                'accepted': accepted,
            })

        elif type == 'done':
            completed = all_nurse.filter(status='completed').order_by('-date', '-time')
            return render(request, 'patient/nurse_done.html', {
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

    raw_days = TimeSlots.objects.filter(doctor=doctor).values_list('day', flat=True).distinct()
    days_with_dates = get_provider_days_with_dates(raw_days)

    for d in days_with_dates:
        d['day_name']   = d['day']
        d['short_name'] = d['day'][:3].upper()
        d['date_num']   = d['date'].strftime('%d')
        d['month_name'] = d['date'].strftime('%b').upper()
        d['full_date']  = d['date'].isoformat()

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

    avg = doctor.rates.aggregate(Avg('rate'))['rate__avg'] or 0
    doctor.avg_rating = round(avg)

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
            DoctorRequest.objects.create(
                patient=patient,
                doctor=doctor,
                date=dt.fromisoformat(selected_date_post),
                time=selected_time_post,
                total_price=doctor.price,
                net_income=doctor.price * 75 / 100,
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
        'governorates': GOVERNORATES,
        'errors': errors,
        'name': patient.user.first_name + ' ' + patient.user.last_name,
        'profile_pic': patient.profile_pic,
    })

@login_required
def cancel_request(request, request_id):
    if request.user.role != 'patient':
        return redirect('login')

    patient = Patient.objects.get(user=request.user)
    try:
        req = DoctorRequest.objects.get(id=request_id, patient=patient)
        req.status = 'rejected'
        req.save()
    except DoctorRequest.DoesNotExist:
        pass

    return redirect('patient:patient_requests', category='doctor', type='pending')

@login_required
def accept_reschedule(request, request_id):
    if request.user.role != 'patient':
        return redirect('login')

    patient = Patient.objects.get(user=request.user)
    try:
        req = DoctorRequest.objects.get(id=request_id, patient=patient, status='edited')
        req.status = 'accepted'
        req.save()
    except DoctorRequest.DoesNotExist:
        pass

    return redirect('patient:patient_requests', category='doctor', type='pending')

@login_required
def mark_done(request, request_id):
    if request.user.role != 'patient':
        return redirect('login')

    patient = Patient.objects.get(user=request.user)
    try:
        req = DoctorRequest.objects.get(id=request_id, patient=patient, status='accepted')
        req.patient_done = True
        if req.doctor_done:
            req.status = 'completed'
        req.save()
    except DoctorRequest.DoesNotExist:
        pass

    return redirect('patient:patient_requests', category='doctor', type='accepted')


@login_required
def book_nurse(request, nurse_id):
    if request.user.role != 'patient':
        return redirect('login')

    from nurse.models import NurseRequest, Service
    from accounts.models import TimeSlots, get_provider_days_with_dates
    from datetime import time as time_type, datetime as dt

    patient = Patient.objects.get(user=request.user)
    nurse   = Nurse.objects.get(id=nurse_id)

    avg = nurse.rates.aggregate(Avg('rate'))['rate__avg'] or 0
    nurse.avg_rating = round(avg)

    services = nurse.nurse_services.all()

    raw_days = TimeSlots.objects.filter(nurse=nurse).values_list('day', flat=True).distinct()
    days_with_dates = get_provider_days_with_dates(raw_days)
    for d in days_with_dates:
        d['day_name']   = d['day']
        d['short_name'] = d['day'][:3].upper()
        d['date_num']   = d['date'].strftime('%d')
        d['month_name'] = d['date'].strftime('%b').upper()
        d['full_date']  = d['date'].isoformat()

    selected_day  = request.GET.get('day') or (days_with_dates[0]['day'] if days_with_dates else None)
    selected_date = next((d['full_date'] for d in days_with_dates if d['day'] == selected_day), '')

    morning_slots, evening_slots = [], []
    if selected_day:
        for slot in TimeSlots.objects.filter(nurse=nurse, day=selected_day).order_by('time'):
            (morning_slots if slot.time < time_type(12, 0) else evening_slots).append(slot)

    errors = {}

    if request.method == 'POST':
        service_ids         = request.POST.getlist('services')
        disease_description = request.POST.get('disease_description', '').strip()
        governorate         = request.POST.get('governorate', '').strip()
        address             = request.POST.get('address', '').strip()
        selected_date_post  = request.POST.get('date', '').strip()
        selected_time_post  = request.POST.get('time', '').strip()

        if not service_ids:
            errors['services'] = 'Please select at least one service.'
        if not selected_date_post:
            errors['date'] = 'Please select a day.'
        if not selected_time_post:
            errors['time'] = 'Please select a time slot.'
        if not disease_description:
            errors['description'] = 'Please describe your condition.'

        if not errors:
            selected_services = Service.objects.filter(id__in=service_ids, nurse=nurse)
            total = sum(s.price for s in selected_services)

            req = NurseRequest.objects.create(
                patient=patient,
                nurse=nurse,
                date=dt.fromisoformat(selected_date_post),
                time=selected_time_post,
                governrate=governorate,
                address=address,
                disease_description=disease_description,
                net_income=total,
                status='pending',
            )
            req.service.set(selected_services)
            return redirect('patient:patient_requests', category='nurse', type='pending')

    return render(request, 'patient/book_nurse.html', {
        'nurse': nurse,
        'patient': patient,
        'services': services,
        'days': days_with_dates,
        'selected_day': selected_day,
        'selected_date': selected_date,
        'morning_slots': morning_slots,
        'evening_slots': evening_slots,
        'governorates': GOVERNORATES,
        'errors': errors,
        'name': patient.user.first_name + ' ' + patient.user.last_name,
        'profile_pic': patient.profile_pic,
    })

@login_required
def cancel_nurse_request(request, request_id):
    if request.user.role != 'patient':
        return redirect('login')
    from nurse.models import NurseRequest
    patient = Patient.objects.get(user=request.user)
    try:
        req = NurseRequest.objects.get(id=request_id, patient=patient)
        req.status = 'rejected'
        req.save()
    except NurseRequest.DoesNotExist:
        pass
    return redirect('patient:patient_requests', category='nurse', type='pending')

@login_required
def accept_nurse_reschedule(request, request_id):
    if request.user.role != 'patient':
        return redirect('login')
    from nurse.models import NurseRequest
    patient = Patient.objects.get(user=request.user)
    try:
        req = NurseRequest.objects.get(id=request_id, patient=patient, status='edited')
        req.status = 'accepted'
        req.save()
    except NurseRequest.DoesNotExist:
        pass
    return redirect('patient:patient_requests', category='nurse', type='pending')

@login_required
def mark_nurse_done(request, request_id):
    if request.user.role != 'patient':
        return redirect('login')
    from nurse.models import NurseRequest
    patient = Patient.objects.get(user=request.user)
    try:
        req = NurseRequest.objects.get(id=request_id, patient=patient, status='accepted')
        req.patient_done = True
        if req.nurse_done:
            req.status = 'completed'
        req.save()
    except NurseRequest.DoesNotExist:
        pass
    return redirect('patient:patient_requests', category='nurse', type='accepted')
