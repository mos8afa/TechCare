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
            req.day_slots = req.nurse_slots  # alias for template compatibility
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
