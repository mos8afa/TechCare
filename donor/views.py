from django.shortcuts import redirect, render
from accounts.models import Donor
from accounts import validations
from django.contrib.auth import get_user_model
from django.contrib.auth.decorators import login_required
import json as _json
from django.db.models import Avg
from accounts.models import Doctor, Nurse, SPECIFICATIONS, GOVERNORATES, TimeSlots, get_provider_days_with_dates
from doctor.models import DoctorRequest
from datetime import time as time_type, datetime as dt
from .models import BloodDonationRequest, DonorOffer
from accounts.models import BLOOD_TYPES, GOVERNORATES as GOV_CHOICES


@login_required
def donor_dashboard(request):
    if request.user.role != 'donor':
        return redirect('login')  
    
    donor = Donor.objects.get(user=request.user)
    name = donor.user.first_name + " " + donor.user.last_name
    email = donor.user.email
    phone_number = donor.phone_number
    governorate = donor.governorate
    address = donor.address
    blood_type = donor.blood_type
    last_donation_date = donor.last_donation_date
    prfile_pic = donor.profile_pic

    donations = donor.donation_offers.all().count()

    doctor_requests = donor.doctor_requests.all().count()
    nurse_requests = donor.nurse_requests.all().count()
    donations_requests = donor.user.blood_requests.all().count()

    return render(request, 'donor/dashboard.html', {
        'name': name,
        'email': email,
        'phone_number': phone_number,
        'governorate': governorate,
        'address': address,
        'blood_type': blood_type,
        'last_donation_date': last_donation_date,
        'donations': donations,
        'doctor_requests': doctor_requests,
        'nurse_requests': nurse_requests,
        'donations_requests': donations_requests,
        'profile_pic': prfile_pic,
    })

@login_required
def edit_donor_profile(request):
    if request.user.role != 'donor':
        return redirect('login')  
    
    User = get_user_model()
    donor = Donor.objects.get(user=request.user)
    name = donor.user.first_name + " " + donor.user.last_name
    profile_pic = donor.profile_pic

    errors = {}

    if request.method == 'POST':
        username = request.POST.get('username')
        phone_number = request.POST.get('phone_number')
        governorate = request.POST.get('governorate')
        address = request.POST.get('address')
        last_donation_date = request.POST.get('last_donation_date')
        profile_pic = request.FILES.get('profile_pic')

        if User.objects.filter(username=username).exclude(id=request.user.id).exists():
            errors['exist_username']="Username already exists"
            return render(request, 'donor/edit_profile.html', 
            {'errors':errors,
            'donor': donor,
            'name': name,
            'profile_pic': profile_pic,
            })
        
        if not validations.validate_username(username):
            errors['username']="Username must be lowercase, allowed letters, numbers, _ or ., and cannot contain forbidden words."
            return render(request, 'donor/edit_profile.html', 
            {'errors':errors,
            'donor': donor,
            'name': name,
            'profile_pic': profile_pic,
            })
        
        if not validations.validate_phone(phone_number):
            errors['phone_invalid'] = "Phone number must start with 0 or 1."
            return render(request, 'donor/edit_profile.html',
            {'errors':errors,
                'donor': donor,
                'name': name,
                'profile_pic': profile_pic,
            })
        
        if not validations.validate_address(address):
            errors['address']="can't use <,> or forbidden words"
            return render(request, 'donor/edit_profile.html',
            {'errors':errors,
            'donor': donor,
            'name': name,
            'profile_pic': profile_pic,
            })

        donor.user.username = username
        donor.phone_number = phone_number
        donor.governorate = governorate
        donor.address = address
        donor.last_donation_date = last_donation_date
        donor.profile_pic = profile_pic
        donor.user.save()
        donor.save()
        return redirect('donor:donor_dashboard')

    return render(request, 'donor/edit_profile.html', {
        'donor': donor,
    })


def _build_slots_json(provider, provider_type, days_with_dates):
    all_slots = {}
    for d in days_with_dates:
        if provider_type == 'doctor':
            slots = TimeSlots.objects.filter(doctor=provider, day=d['day']).order_by('time')
        else:
            slots = TimeSlots.objects.filter(nurse=provider, day=d['day']).order_by('time')
        all_slots[d['day']] = {
            'morning': [s.time.strftime('%H:%M') for s in slots if s.time < time_type(12, 0)],
            'evening': [s.time.strftime('%H:%M') for s in slots if s.time >= time_type(12, 0)],
        }
    return all_slots

def _enrich_days(days_with_dates):
    for d in days_with_dates:
        d['day_name']   = d['day']
        d['short_name'] = d['day'][:3].upper()
        d['date_num']   = d['date'].strftime('%d')
        d['month_name'] = d['date'].strftime('%b').upper()
        d['full_date']  = d['date'].isoformat()
    return days_with_dates


@login_required
def donor_requests(request, category, type):
    if request.user.role != 'donor':
        return redirect('login')

    donor = Donor.objects.get(user=request.user)
    name = donor.user.first_name + ' ' + donor.user.last_name
    profile_pic = donor.profile_pic

    context_base = {
        'name': name,
        'profile_pic': profile_pic,
        'category': category,
        'type': type,
    }

    if category == 'doctor':
        all_reqs = donor.doctor_requests.all()

        if type == 'booking':
            doctors = Doctor.objects.filter(slots__isnull=False).distinct()
            for doc in doctors:
                avg = doc.rates.aggregate(Avg('rate'))['rate__avg'] or 0
                doc.avg_rating = round(avg)
            return render(request, 'donor/doctor_booking.html', {
                **context_base,
                'doctors': doctors,
                'specializations': SPECIFICATIONS,
                'governorates': GOVERNORATES,
                'book_url_name': 'donor:book_doctor',
            })

        elif type == 'pending':
            pending = all_reqs.filter(status='pending').order_by('-date', '-time')
            edited  = all_reqs.filter(status='edited').order_by('-date', '-time')
            return render(request, 'donor/doctor_pending.html', {
                **context_base,
                'pending': pending,
                'edited': edited,
            })

        elif type == 'accepted':
            accepted = all_reqs.filter(status='accepted').order_by('-date', '-time')
            return render(request, 'donor/doctor_accepted.html', {
                **context_base,
                'accepted': accepted,
            })

        elif type == 'done':
            completed = all_reqs.filter(status='completed').order_by('-date', '-time')
            return render(request, 'donor/doctor_done.html', {
                **context_base,
                'completed': completed,
            })

    if category == 'nurse':
        all_reqs = donor.nurse_requests.all()

        if type == 'booking':
            nurses = Nurse.objects.filter(slots__isnull=False).distinct()
            for nurse in nurses:
                avg = nurse.rates.aggregate(Avg('rate'))['rate__avg'] or 0
                nurse.avg_rating = round(avg)
            return render(request, 'donor/nurse_booking.html', {
                **context_base,
                'nurses': nurses,
                'governorates': GOVERNORATES,
            })

        elif type == 'pending':
            pending = all_reqs.filter(status='pending').order_by('-date', '-time')
            edited  = all_reqs.filter(status='edited').order_by('-date', '-time')
            return render(request, 'donor/nurse_pending.html', {
                **context_base,
                'pending': pending,
                'edited': edited,
            })

        elif type == 'accepted':
            accepted = all_reqs.filter(status='accepted').order_by('-date', '-time')
            return render(request, 'donor/nurse_accepted.html', {
                **context_base,
                'accepted': accepted,
            })

        elif type == 'done':
            completed = all_reqs.filter(status='completed').order_by('-date', '-time')
            return render(request, 'donor/nurse_done.html', {
                **context_base,
                'completed': completed,
            })

    return redirect('donor:donor_dashboard')


@login_required
def book_doctor(request, doctor_id):
    if request.user.role != 'donor':
        return redirect('login')

    donor  = Donor.objects.get(user=request.user)
    doctor = Doctor.objects.get(id=doctor_id)

    raw_days = TimeSlots.objects.filter(doctor=doctor).values_list('day', flat=True).distinct()
    days     = _enrich_days(get_provider_days_with_dates(raw_days))

    selected_day  = days[0]['day'] if days else None
    selected_date = days[0]['full_date'] if days else ''

    all_slots = _build_slots_json(doctor, 'doctor', days)

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
                donor=donor,
                patient=None,
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
            return redirect('donor:donor_requests', category='doctor', type='pending')

    return render(request, 'donor/book_appointment.html', {
        'doctor': doctor,
        'patient': donor,          
        'days': days,
        'selected_day': selected_day,
        'selected_date': selected_date,
        'all_slots_json': _json.dumps(all_slots),
        'governorates': GOVERNORATES,
        'errors': errors,
        'name': donor.user.first_name + ' ' + donor.user.last_name,
        'profile_pic': donor.profile_pic,
    })

@login_required
def cancel_doctor_request(request, request_id):
    if request.user.role != 'donor':
        return redirect('login')
    donor = Donor.objects.get(user=request.user)
    try:
        req = DoctorRequest.objects.get(id=request_id, donor=donor)
        req.status = 'rejected'
        req.save()
    except DoctorRequest.DoesNotExist:
        pass
    return redirect('donor:donor_requests', category='doctor', type='pending')

@login_required
def accept_doctor_reschedule(request, request_id):
    if request.user.role != 'donor':
        return redirect('login')
    donor = Donor.objects.get(user=request.user)
    try:
        req = DoctorRequest.objects.get(id=request_id, donor=donor, status='edited')
        req.status = 'accepted'
        req.save()
    except DoctorRequest.DoesNotExist:
        pass
    return redirect('donor:donor_requests', category='doctor', type='pending')

@login_required
def mark_doctor_done(request, request_id):
    if request.user.role != 'donor':
        return redirect('login')
    donor = Donor.objects.get(user=request.user)
    try:
        req = DoctorRequest.objects.get(id=request_id, donor=donor, status='accepted')
        req.patient_done = True
        if req.doctor_done:
            req.status = 'completed'
        req.save()
    except DoctorRequest.DoesNotExist:
        return redirect('donor:donor_requests', category='doctor', type='accepted')

    doctor = req.doctor
    name = donor.user.first_name + ' ' + donor.user.last_name
    return render(request, 'donor/rate_doctor.html', {
        'req': req,
        'doctor_name': doctor.user.first_name + ' ' + doctor.user.last_name,
        'doctor_specialization': doctor.get_specification_display(),
        'doctor_profile_pic': doctor.profile_pic,
        'name': name,
        'profile_pic': donor.profile_pic,
    })


@login_required
def rate_doctor(request, request_id):
    if request.user.role != 'donor':
        return redirect('login')
    from accounts.models import Rate
    donor = Donor.objects.get(user=request.user)
    try:
        req = DoctorRequest.objects.get(id=request_id, donor=donor)
    except DoctorRequest.DoesNotExist:
        return redirect('donor:donor_requests', category='doctor', type='accepted')

    if request.method == 'POST':
        rate_value = request.POST.get('rate')
        feedback = request.POST.get('feedback', '').strip()
        if rate_value:
            Rate.objects.create(rate=rate_value, feedback=feedback, doctor=req.doctor)
        if req.doctor_done:
            return redirect('donor:donor_requests', category='doctor', type='done')
        return redirect('donor:donor_requests', category='doctor', type='accepted')

    return redirect('donor:donor_requests', category='doctor', type='accepted')


@login_required
def book_nurse(request, nurse_id):
    if request.user.role != 'donor':
        return redirect('login')

    from nurse.models import NurseRequest, Service

    donor = Donor.objects.get(user=request.user)
    nurse = Nurse.objects.get(id=nurse_id)

    avg = nurse.rates.aggregate(Avg('rate'))['rate__avg'] or 0
    nurse.avg_rating = round(avg)

    services = nurse.nurse_services.all()

    raw_days = TimeSlots.objects.filter(nurse=nurse).values_list('day', flat=True).distinct()
    days     = _enrich_days(get_provider_days_with_dates(raw_days))

    selected_day  = days[0]['day'] if days else None
    selected_date = days[0]['full_date'] if days else ''

    all_slots = _build_slots_json(nurse, 'nurse', days)

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
                donor=donor,
                patient=None,
                nurse=nurse,
                date=dt.fromisoformat(selected_date_post),
                time=selected_time_post,
                governrate=governorate,
                address=address,
                disease_description=disease_description,
                net_income=total * 80 / 100,
                status='pending',
            )
            req.service.set(selected_services)
            return redirect('donor:donor_requests', category='nurse', type='pending')

    return render(request, 'donor/book_nurse_services.html', {
        'nurse': nurse,
        'patient': donor,          
        'services': services,
        'days': days,
        'selected_day': selected_day,
        'selected_date': selected_date,
        'all_slots_json': _json.dumps(all_slots),
        'governorates': GOVERNORATES,
        'errors': errors,
        'name': donor.user.first_name + ' ' + donor.user.last_name,
        'profile_pic': donor.profile_pic,
    })

@login_required
def cancel_nurse_request(request, request_id):
    if request.user.role != 'donor':
        return redirect('login')
    from nurse.models import NurseRequest
    donor = Donor.objects.get(user=request.user)
    try:
        req = NurseRequest.objects.get(id=request_id, donor=donor)
        req.status = 'rejected'
        req.save()
    except NurseRequest.DoesNotExist:
        pass
    return redirect('donor:donor_requests', category='nurse', type='pending')

@login_required
def accept_nurse_reschedule(request, request_id):
    if request.user.role != 'donor':
        return redirect('login')
    from nurse.models import NurseRequest
    donor = Donor.objects.get(user=request.user)
    try:
        req = NurseRequest.objects.get(id=request_id, donor=donor, status='edited')
        req.status = 'accepted'
        req.save()
    except NurseRequest.DoesNotExist:
        pass
    return redirect('donor:donor_requests', category='nurse', type='pending')

@login_required
def mark_nurse_done(request, request_id):
    if request.user.role != 'donor':
        return redirect('login')
    from nurse.models import NurseRequest
    donor = Donor.objects.get(user=request.user)
    try:
        req = NurseRequest.objects.get(id=request_id, donor=donor, status='accepted')
        req.patient_done = True
        if req.nurse_done:
            req.status = 'completed'
        req.save()
    except NurseRequest.DoesNotExist:
        return redirect('donor:donor_requests', category='nurse', type='accepted')

    nurse = req.nurse
    name = donor.user.first_name + ' ' + donor.user.last_name
    return render(request, 'donor/rate_nurse.html', {
        'req': req,
        'nurse_name': nurse.user.first_name + ' ' + nurse.user.last_name,
        'nurse_profile_pic': nurse.profile_pic,
        'name': name,
        'profile_pic': donor.profile_pic,
    })


@login_required
def rate_nurse(request, request_id):
    if request.user.role != 'donor':
        return redirect('login')
    from nurse.models import NurseRequest
    from accounts.models import Rate
    donor = Donor.objects.get(user=request.user)
    try:
        req = NurseRequest.objects.get(id=request_id, donor=donor)
    except NurseRequest.DoesNotExist:
        return redirect('donor:donor_requests', category='nurse', type='accepted')

    if request.method == 'POST':
        rate_value = request.POST.get('rate')
        feedback = request.POST.get('feedback', '').strip()
        if rate_value:
            Rate.objects.create(rate=rate_value, feedback=feedback, nurse=req.nurse)
        if req.nurse_done:
            return redirect('donor:donor_requests', category='nurse', type='done')
        return redirect('donor:donor_requests', category='nurse', type='accepted')

    return redirect('donor:donor_requests', category='nurse', type='accepted')


# ═══════════════════════════════════════════════════════════════════════════════
#  BLOOD DONATION FLOW
# ═══════════════════════════════════════════════════════════════════════════════
@login_required
def create_blood_request(request):
    from donor.blood_request_utils import can_create_blood_request
    errors = {}

    role = request.user.role
    profile_pic = None
    name = request.user.first_name + ' ' + request.user.last_name

    if role == 'donor':
        try:
            _profile = Donor.objects.get(user=request.user)
            profile_pic = _profile.profile_pic
        except Donor.DoesNotExist:
            pass
    elif role == 'patient':
        from accounts.models import Patient
        try:
            _profile = Patient.objects.get(user=request.user)
            profile_pic = _profile.profile_pic
        except Exception:
            pass
    elif role == 'doctor':
        try:
            from accounts.models import Doctor as DoctorModel
            _profile = DoctorModel.objects.get(user=request.user)
            profile_pic = _profile.profile_pic
        except Exception:
            pass
    elif role == 'nurse':
        try:
            _profile = Nurse.objects.get(user=request.user)
            profile_pic = _profile.profile_pic
        except Exception:
            pass

    allowed, blocking = can_create_blood_request(request.user)
    latest_request = blocking or BloodDonationRequest.objects.filter(
        requester=request.user).exclude(status='cancelled').order_by('-created_at').first()

    if not allowed:
        errors['blocked'] = 'You already have an active blood request. You can create a new one once it expires or is completed.'

    if request.method == 'POST' and allowed:
        blood_type        = request.POST.get('blood_type', '').strip()
        governorate       = request.POST.get('governorate', '').strip()
        address           = request.POST.get('address', '').strip()
        medical_condition = request.POST.get('medical_condition', '').strip()
        condition         = request.POST.get('urgency', 'normal').strip()

        if not blood_type:
            errors['blood_type'] = 'Please select a blood type.'
        if not governorate:
            errors['governorate'] = 'Please select a governorate.'
        if not address:
            errors['address'] = 'Please enter your address.'
        if not medical_condition:
            errors['medical_condition'] = 'Please describe the medical condition.'

        if not errors:
            blood_req = BloodDonationRequest.objects.create(
                requester=request.user,
                blood_type=blood_type,
                governorate=governorate,
                address=address,
                medical_condition=medical_condition,
                condition=condition,
            )
            return redirect('donation:request_offers', request_id=blood_req.id)

    return render(request, 'donor/blood_request.html', {
        'blood_types': BLOOD_TYPES,
        'governorates': GOV_CHOICES,
        'errors': errors,
        'name': name,
        'profile_pic': profile_pic,
        'latest_request': latest_request,
        'blocked': not allowed,
    })

@login_required
def my_blood_requests_pending(request):
    """Blood requests the user created that have no offers yet."""
    from django.db.models import Count
    user = request.user

    pending_requests = BloodDonationRequest.objects.filter(
        requester=user,
        status='open',
    ).annotate(offer_count=Count('offers')).filter(offer_count=0).order_by('-created_at')

    profile_pic = None
    name = user.first_name + ' ' + user.last_name
    if user.role == 'donor':
        try:
            _d = Donor.objects.get(user=user)
            profile_pic = _d.profile_pic
        except Donor.DoesNotExist:
            pass

    latest_request = BloodDonationRequest.objects.filter(
        requester=user).exclude(status='cancelled').order_by('-created_at').first()

    return render(request, 'donor/my_blood_requests_pending.html', {
        'pending_requests': pending_requests,
        'name': name,
        'profile_pic': profile_pic,
        'latest_request': latest_request,
    })


@login_required
def my_blood_requests_accepted(request):
    user = request.user
    accepted_offers = DonorOffer.objects.filter(
        request__requester=user,
        status='accepted',
    ).select_related('donor__user', 'donor', 'request').order_by('-created_at')

    name = user.first_name + ' ' + user.last_name
    profile_pic = None
    # Resolve profile pic for any role
    try:
        if user.role == 'donor':
            profile_pic = Donor.objects.get(user=user).profile_pic
        elif user.role == 'patient':
            from accounts.models import Patient
            profile_pic = Patient.objects.get(user=user).profile_pic
        elif user.role == 'doctor':
            profile_pic = Doctor.objects.get(user=user).profile_pic
        elif user.role == 'nurse':
            profile_pic = Nurse.objects.get(user=user).profile_pic
    except Exception:
        pass

    latest_request = BloodDonationRequest.objects.filter(
        requester=user).exclude(status='cancelled').order_by('-created_at').first()
    return render(request, 'donor/my_blood_requests_accepted.html', {
        'accepted_offers': accepted_offers,
        'name': name,
        'profile_pic': profile_pic,
        'latest_request': latest_request,
    })

@login_required
def my_blood_requests_done(request):
    user = request.user
    completed_offers = DonorOffer.objects.filter(
        request__requester=user,
        status='completed',
    ).select_related('donor__user', 'request').order_by('-created_at')

    name = user.first_name + ' ' + user.last_name
    profile_pic = None
    try:
        if user.role == 'donor':
            profile_pic = Donor.objects.get(user=user).profile_pic
        elif user.role == 'patient':
            from accounts.models import Patient
            profile_pic = Patient.objects.get(user=user).profile_pic
        elif user.role == 'doctor':
            profile_pic = Doctor.objects.get(user=user).profile_pic
        elif user.role == 'nurse':
            profile_pic = Nurse.objects.get(user=user).profile_pic
    except Exception:
        pass

    latest_request = BloodDonationRequest.objects.filter(
        requester=user).exclude(status='cancelled').order_by('-created_at').first()

    return render(request, 'donor/my_blood_requests_done.html', {
        'completed_offers': completed_offers,
        'name': name,
        'profile_pic': profile_pic,
        'latest_request': latest_request,
    })

@login_required
def request_offers(request, request_id):
    blood_req = BloodDonationRequest.objects.get(id=request_id, requester=request.user)
    offers    = blood_req.offers.filter(status='offered').select_related('donor__user')

    profile_pic = None
    name = request.user.first_name + ' ' + request.user.last_name
    if request.user.role == 'donor':
        try:
            _d = Donor.objects.get(user=request.user)
            profile_pic = _d.profile_pic
        except Donor.DoesNotExist:
            pass

    return render(request, 'donor/blood_request_offers.html', {
        'blood_request': blood_req,
        'offers': offers,
        'name': name,
        'profile_pic': profile_pic,
    })

@login_required
def accept_offer(request, offer_id):
    """Requester accepts one donor offer → redirect to accepted page."""
    offer     = DonorOffer.objects.get(id=offer_id, request__requester=request.user)
    blood_req = offer.request
    donor     = offer.donor

    # ── Rule 1a: reject all other offers on THIS request ──
    blood_req.offers.filter(status='offered').exclude(id=offer_id).update(status='rejected')

    # ── Rule 1b: reject all OTHER pending offers this donor made on OTHER requests ──
    # (a donor can only fulfill one donation at a time)
    DonorOffer.objects.filter(
        donor=donor,
        status='offered',
    ).exclude(id=offer_id).update(status='rejected')

    offer.status = 'accepted'
    offer.save()

    blood_req.status = 'matched'
    blood_req.save()

    return redirect('donation:my_requests_accepted')

@login_required
def requester_mark_done(request, offer_id):
    """Requester marks their side done."""
    offer     = DonorOffer.objects.get(id=offer_id, request__requester=request.user, status='accepted')
    blood_req = offer.request
    blood_req.requester_done = True
    if offer.donor_done:
        offer.status     = 'completed'
        blood_req.status = 'completed'
        offer.save()
    blood_req.save()
    return redirect('donation:my_requests_accepted')

@login_required
def cancel_blood_request(request, request_id):
    blood_req = BloodDonationRequest.objects.get(id=request_id, requester=request.user)
    blood_req.status = 'cancelled'
    blood_req.save()
    return redirect('donation:my_requests')


# ── Donor: browse open requests matching their blood type & governorate ───────
@login_required
def available_requests(request):
    if request.user.role != 'donor':
        return redirect('login')
    from datetime import date
    donor = Donor.objects.get(user=request.user)

    # ── Rule 3: donor must wait 3 months since last donation ──
    eligible = True
    days_remaining = 0
    if donor.last_donation_date:
        from dateutil.relativedelta import relativedelta
        eligible_date = donor.last_donation_date + relativedelta(months=3)
        if date.today() < eligible_date:
            eligible = False
            days_remaining = (eligible_date - date.today()).days

    open_reqs = BloodDonationRequest.objects.filter(
        blood_type=donor.blood_type,
        governorate=donor.governorate,
        status='open',
    ).exclude(
        # ── Rule 4: donor cannot offer on their own request ──
        requester=request.user
    ).order_by('-created_at')

    offered_ids = DonorOffer.objects.filter(
        donor=donor
    ).values_list('request_id', flat=True)

    return render(request, 'donation/available_requests.html', {
        'donor': donor,
        'open_requests': open_reqs,
        'offered_ids': list(offered_ids),
        'eligible': eligible,
        'days_remaining': days_remaining,
    })


@login_required
def offer_to_donate(request, request_id):
    if request.user.role != 'donor':
        return redirect('login')
    from datetime import date
    donor     = Donor.objects.get(user=request.user)
    blood_req = BloodDonationRequest.objects.get(id=request_id, status='open')

    # ── Rule 4: cannot offer on own request ──
    if blood_req.requester == request.user:
        return redirect('donation:available_requests')

    # ── Rule 3: must wait 3 months since last donation ──
    if donor.last_donation_date:
        from dateutil.relativedelta import relativedelta
        eligible_date = donor.last_donation_date + relativedelta(months=3)
        if date.today() < eligible_date:
            return redirect('donation:available_requests')

    DonorOffer.objects.get_or_create(donor=donor, request=blood_req)
    return redirect('donation:available_requests')


@login_required
def my_offers(request):
    if request.user.role != 'donor':
        return redirect('login')
    donor  = Donor.objects.get(user=request.user)
    offers = DonorOffer.objects.filter(donor=donor).exclude(
        status='completed'
    ).select_related('request__requester').order_by('-created_at')
    return render(request, 'donation/my_offers.html', {
        'donor': donor,
        'offers': offers,
    })


@login_required
def donation_done(request):
    if request.user.role != 'donor':
        return redirect('login')
    donor = Donor.objects.get(user=request.user)
    completed_offers = DonorOffer.objects.filter(
        donor=donor, status='completed'
    ).select_related('request__requester').order_by('-created_at')
    return render(request, 'donation/donation_done.html', {
        'completed_offers': completed_offers,
        'donor': donor,
    })


@login_required
def donor_mark_done(request, offer_id):
    if request.user.role != 'donor':
        return redirect('login')
    from datetime import date
    donor = Donor.objects.get(user=request.user)
    offer = DonorOffer.objects.get(id=offer_id, donor=donor, status='accepted')
    offer.donor_done = True
    if offer.request.requester_done:
        offer.status         = 'completed'
        offer.request.status = 'completed'
        offer.request.save()
        # ── Rule 2: update last_donation_date when donation is fully completed ──
        donor.last_donation_date = date.today()
        donor.save()
    offer.save()
    return redirect('donation:my_offers')
