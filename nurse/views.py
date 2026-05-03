import json
from django.shortcuts import redirect, render, get_object_or_404
from django.http import JsonResponse
from django.views.decorators.http import require_POST
from accounts import validations
from accounts.models import Nurse, TimeSlots, get_provider_days_with_dates
from django.db.models import Avg
from django.contrib.auth import get_user_model
from django.contrib.auth.decorators import login_required
from .models import Service, NurseRequest
from decimal import Decimal
from datetime import time
from doctor.views import get_ordered_week_days
from donor import views as donation_views
from donor.models import BloodDonationRequest, DonorOffer
from accounts.models import BLOOD_TYPES, GOVERNORATES as GOV_CHOICES


def _nurse_name(nurse):
    prefix = "Mr. " if nurse.gender == 'male' else "Mrs. "
    return prefix + nurse.user.first_name + " " + nurse.user.last_name


@login_required
def nurse_dashboard(request):
    if request.user.role != "nurse":
        return redirect("login")

    nurse = Nurse.objects.get(user=request.user)
    name = _nurse_name(nurse)

    nurse_reqs = nurse.nurse_requests.all()
    pending   = nurse_reqs.filter(status__in=['pending', 'edited']).count()
    completed = nurse_reqs.filter(status='completed').count()
    services  = nurse.nurse_services.all()

    average_rating = round(nurse.rates.aggregate(Avg('rate'))['rate__avg'] or 0) if nurse.rates.exists() else 0

    days = list(get_provider_days_with_dates(
        TimeSlots.objects.filter(nurse=nurse).values_list('day', flat=True).distinct()
    ))

    selected_day = days[0]['day'] if days else None

    import json as _json
    all_slots = {}
    for d in days:
        slots = TimeSlots.objects.filter(nurse=nurse, day=d['day']).order_by('time')
        all_slots[d['day']] = [s.time.strftime('%H:%M') for s in slots]

    time_slots = list(TimeSlots.objects.filter(nurse=nurse, day=selected_day).order_by('time')) if selected_day else []

    return render(request, 'nurse/nurse_profile.html', {
        'name': name,
        'governorate': nurse.get_governorate_display(),
        'address': nurse.address,
        'phone_number': nurse.phone_number,
        'email': nurse.user.email,
        'average_rating': average_rating,
        'brief': nurse.brief,
        'profile_pic': nurse.profile_pic,
        'pending': pending,
        'completed': completed,
        'services': services,
        'days': days,
        'time_slots': time_slots,
        'selected_day': selected_day,
        'all_slots_json': _json.dumps(all_slots),
    })


@login_required
def edit_nurse_profile(request):
    errors = {}
    if request.user.role != "nurse":
        return redirect("login")

    nurse = Nurse.objects.get(user=request.user)
    name = _nurse_name(nurse)
    profile_pic = nurse.profile_pic
    User = get_user_model()

    if request.method == 'POST':
        phone_number = request.POST.get('phone_number')
        address      = request.POST.get('address')
        brief        = request.POST.get('brief')
        username     = request.POST.get('username')

        if User.objects.filter(username=username).exclude(id=request.user.id).exists():
            errors['exist_username'] = "Username already exists"
        elif not validations.validate_username(username):
            errors['username'] = "Username must be lowercase, allowed letters, numbers, _ or ., and cannot contain forbidden words."
        elif not validations.validate_phone(phone_number):
            errors['phone_invalid'] = "Phone number must start with 0 or 1."
        elif not validations.validate_address(address):
            errors['address'] = "Can't use <,> or forbidden words"
        elif not validations.validate_address(brief):
            errors['brief'] = "Brief can't contain forbidden words."
        else:
            nurse.user.username = username
            nurse.phone_number  = phone_number
            nurse.address       = address
            nurse.brief         = brief
            nurse.governorate   = request.POST.get('governorate')
            nurse.profile_pic   = request.FILES.get('profile_pic') or nurse.profile_pic
            nurse.user.save()
            nurse.save()
            return redirect('nurse:nurse_dashboard')

    return render(request, 'nurse/nurse_edit_profile.html', {
        'nurse': nurse, 'errors': errors, 'name': name, 'profile_pic': profile_pic,
    })


@login_required
def nurse_requests(request, type):
    if request.user.role != "nurse":
        return redirect("login")

    nurse = Nurse.objects.get(user=request.user)
    name = _nurse_name(nurse)
    profile_pic = nurse.profile_pic
    context_base = {'name': name, 'profile_pic': profile_pic}

    all_reqs = nurse.nurse_requests.all()

    if type in ('pending', 'edited') or type is None:
        pending_qs = []
        for req in all_reqs.filter(status='pending').order_by('-date', '-time'):
            req_day = req.date.strftime('%A').lower()
            req.nurse_slots = TimeSlots.objects.filter(nurse=nurse, day=req_day).order_by('time')
            req.day_slots = req.nurse_slots
            pending_qs.append(req)

        edited_qs = []
        for req in all_reqs.filter(status='edited').order_by('-date', '-time'):
            req_day = req.date.strftime('%A').lower()
            req.nurse_slots = TimeSlots.objects.filter(nurse=nurse, day=req_day).order_by('time')
            req.day_slots = req.nurse_slots
            edited_qs.append(req)

        return render(request, 'nurse/requests_pending.html', {**context_base, 'pending': pending_qs, 'edited': edited_qs})

    elif type == 'accepted':
        accepted = all_reqs.filter(status='accepted').order_by('-date', '-time')
        return render(request, 'nurse/requests_accepted.html', {**context_base, 'accepted': accepted})

    elif type == 'completed':
        completed = all_reqs.filter(status='completed').order_by('-date', '-time')
        return render(request, 'nurse/requests_completed.html', {**context_base, 'completed': completed})

    return redirect('nurse:nurse_dashboard')


@login_required
@require_POST
def request_action(request, request_id):
    if request.user.role != 'nurse':
        return redirect('login')

    nurse = Nurse.objects.get(user=request.user)
    req = get_object_or_404(NurseRequest, id=request_id, nurse=nurse)
    action = request.POST.get('action')

    if action == 'reject':
        req.status = 'rejected'
        req.save()
    elif action == 'accept':
        selected_time = request.POST.get('selected_time')
        if selected_time:
            try:
                h, m = selected_time.split(':')
                new_t = time(int(h), int(m))
                if new_t != req.time:
                    req.time = new_t
                    req.status = 'edited'
                else:
                    req.status = 'accepted'
                req.save()
            except (ValueError, AttributeError):
                req.status = 'accepted'
                req.save()
        else:
            req.status = 'accepted'
            req.save()

    return redirect('nurse:nurse_requests', type='pending')


@login_required
@require_POST
def mark_done(request, request_id):
    if request.user.role != 'nurse':
        return redirect('login')

    nurse = Nurse.objects.get(user=request.user)
    req = get_object_or_404(NurseRequest, id=request_id, nurse=nurse, status='accepted')
    req.nurse_done = True
    if req.patient_done:
        req.status = 'completed'
    req.save()
    return redirect('nurse:nurse_requests', type='accepted')




@login_required
def add_services(request):
    if request.method == 'POST':
        nurse = Nurse.objects.get(user=request.user)
        service_name = request.POST.get('name')
        description  = request.POST.get('description')
        price        = request.POST.get('price')
        try:
            price = Decimal(price)
            nurse.nurse_services.create(name=service_name, description=description, price=price)
        except Exception:
            pass
    return redirect('nurse:nurse_dashboard')


@login_required
def edit_service(request, service_id):
    nurse   = Nurse.objects.get(user=request.user)
    service = get_object_or_404(Service, id=service_id, nurse=nurse)
    if request.method == 'POST':
        service.name        = request.POST.get('name')
        service.description = request.POST.get('description')
        service.price       = Decimal(request.POST.get('price', 0))
        service.save()
    return redirect('nurse:nurse_dashboard')


@login_required
def delete_service(request, service_id):
    nurse   = Nurse.objects.get(user=request.user)
    service = get_object_or_404(Service, id=service_id, nurse=nurse)
    if request.method == 'POST':
        service.delete()
    return redirect('nurse:nurse_dashboard')


@login_required
def edit_time_slots(request):
    if request.user.role != 'nurse':
        return redirect('login')

    import json as json_mod
    nurse = Nurse.objects.get(user=request.user)
    days = get_ordered_week_days()
    selected_day = request.GET.get('day') or days[0]['day']

    # Pass ALL days' slots as JSON so JS can switch days without reloading
    all_slots = {}
    for d in days:
        s = TimeSlots.objects.filter(nurse=nurse, day=d['day']).order_by('time')
        all_slots[d['day']] = [slot.time.strftime('%H:%M') for slot in s]

    slots = TimeSlots.objects.filter(nurse=nurse, day=selected_day).order_by('time')
    morning_slots = [s for s in slots if s.time < time(12, 0)]
    evening_slots = [s for s in slots if s.time >= time(12, 0)]

    return render(request, 'nurse/edit_slots.html', {
        'days': days,
        'selected_day': selected_day,
        'morning_slots': morning_slots,
        'evening_slots': evening_slots,
        'all_slots_json': json_mod.dumps(all_slots),
        'name': _nurse_name(nurse),
        'profile_pic': nurse.profile_pic,
    })


@login_required
@require_POST
def save_time_slots(request):
    if request.user.role != 'nurse':
        return JsonResponse({'error': 'Forbidden'}, status=403)

    nurse = Nurse.objects.get(user=request.user)

    try:
        data = json.loads(request.body)
    except (json.JSONDecodeError, AttributeError):
        return JsonResponse({'error': 'Invalid JSON'}, status=400)

    # Accept either single day or multiple days
    # Format: { days: { "monday": ["HH:MM", ...], "tuesday": [...] } }
    # or legacy: { day: "monday", times: [...] }
    days_data = data.get('days')
    if not days_data:
        # legacy single-day format
        day   = data.get('day')
        times = data.get('times', [])
        if not day:
            return JsonResponse({'error': 'Missing day'}, status=400)
        days_data = {day: times}

    for day, times in days_data.items():
        TimeSlots.objects.filter(nurse=nurse, day=day).delete()
        for t_str in times:
            try:
                h, m = t_str.split(':')
                TimeSlots.objects.create(nurse=nurse, day=day, time=time(int(h), int(m)))
            except (ValueError, AttributeError):
                continue

    return JsonResponse({'success': True})


@login_required
def create_blood_request(request):
    from donor.blood_request_utils import can_create_blood_request
    errors = {}
    nurse = Nurse.objects.get(user=request.user)
    profile_pic = nurse.profile_pic
    name = _nurse_name(nurse)

    allowed, blocking = can_create_blood_request(request.user)
    latest_request = blocking or BloodDonationRequest.objects.filter(
        requester=request.user).exclude(status='cancelled').order_by('-created_at').first()

    if not allowed:
        errors['blocked'] = 'You already have an active blood request. You can create a new one once it expires or is completed.'

    if request.method == 'POST' and allowed:
        blood_type = request.POST.get('blood_type', '').strip()
        governorate = request.POST.get('governorate', '').strip()
        address = request.POST.get('address', '').strip()
        medical_condition = request.POST.get('medical_condition', '').strip()
        condition = request.POST.get('urgency', 'normal').strip()
        if not blood_type: errors['blood_type'] = 'Please select a blood type.'
        if not governorate: errors['governorate'] = 'Please select a governorate.'
        if not address: errors['address'] = 'Please enter your address.'
        if not medical_condition: errors['medical_condition'] = 'Please describe the medical condition.'
        if not errors:
            blood_req = BloodDonationRequest.objects.create(
                requester=request.user, blood_type=blood_type,
                governorate=governorate, address=address,
                medical_condition=medical_condition, condition=condition,
            )
            return redirect('nurse:request_offers', request_id=blood_req.id)
    return render(request, 'nurse/blood_request.html', {
        'blood_types': BLOOD_TYPES, 'governorates': GOV_CHOICES,
        'errors': errors, 'name': name, 'profile_pic': profile_pic,
        'latest_request': latest_request,
        'blocked': not allowed,
    })


@login_required
def request_offers(request, request_id):
    blood_req = BloodDonationRequest.objects.get(id=request_id, requester=request.user)
    offers = blood_req.offers.filter(status='offered').select_related('donor__user')
    nurse = Nurse.objects.get(user=request.user)
    profile_pic = nurse.profile_pic
    name = _nurse_name(nurse)
    return render(request, 'nurse/blood_request_offers.html', {
        'blood_request': blood_req, 'offers': offers, 'name': name, 'profile_pic': profile_pic,
    })

@login_required
def accept_offer(request, offer_id):
    offer = DonorOffer.objects.get(id=offer_id, request__requester=request.user)
    blood_req = offer.request
    offer.status = 'accepted'
    offer.save()
    blood_req.status = 'matched'
    blood_req.save()
    return redirect('nurse:request_offers', request_id=blood_req.id)

@login_required
def requester_mark_done(request, offer_id):
    offer = DonorOffer.objects.get(id=offer_id, request__requester=request.user, status='accepted')
    blood_req = offer.request
    blood_req.requester_done = True
    if offer.donor_done:
        offer.status = 'completed'
        blood_req.status = 'completed'
        offer.save()
    blood_req.save()
    return redirect('nurse:request_offers', request_id=blood_req.id)

@login_required
def cancel_blood_request(request, request_id):
    blood_req = BloodDonationRequest.objects.get(id=request_id, requester=request.user)
    blood_req.status = 'cancelled'
    blood_req.save()
    return redirect('nurse:create_blood_request')

@login_required
def my_blood_requests_pending(request):
    from django.db.models import Count
    pending_requests = BloodDonationRequest.objects.filter(
        requester=request.user,
        status='open',
    ).annotate(offer_count=Count('offers')).filter(offer_count=0).order_by('-created_at')
    nurse = Nurse.objects.get(user=request.user)
    name = _nurse_name(nurse)
    latest_request = BloodDonationRequest.objects.filter(
        requester=request.user).exclude(status='cancelled').order_by('-created_at').first()
    return render(request, 'nurse/my_blood_requests_pending.html', {
        'pending_requests': pending_requests,
        'name': name,
        'profile_pic': nurse.profile_pic,
        'latest_request': latest_request,
    })


@login_required
def my_blood_requests_accepted(request):
    accepted_offers = DonorOffer.objects.filter(
        request__requester=request.user, status='accepted',
    ).select_related('donor__user', 'request').order_by('-created_at')
    nurse = Nurse.objects.get(user=request.user)
    profile_pic = nurse.profile_pic
    name = _nurse_name(nurse)
    return render(request, 'nurse/my_blood_requests_accepted.html', {
        'accepted_offers': accepted_offers, 'name': name, 'profile_pic': profile_pic,
    })

@login_required
def my_blood_requests_done(request):
    completed_offers = DonorOffer.objects.filter(
        request__requester=request.user, status='completed',
    ).select_related('donor__user', 'request').order_by('-created_at')
    nurse = Nurse.objects.get(user=request.user)
    profile_pic = nurse.profile_pic
    name = _nurse_name(nurse)
    return render(request, 'nurse/my_blood_requests_done.html', {
        'completed_offers': completed_offers, 'name': name, 'profile_pic': profile_pic,
    })