import json
from django.shortcuts import redirect, render
from django.http import JsonResponse
from django.views.decorators.http import require_POST
from accounts import validations
from accounts.models import Doctor, get_provider_days_with_dates, TimeSlots
from django.db.models import Avg
from django.contrib.auth import get_user_model
from django.contrib.auth.decorators import login_required
from datetime import date, time, timedelta
from doctor.models import DoctorRequest
from datetime import time as time_type
from donor import views as donation_views


@login_required
def doctor_dashboard(request):    
    if request.user.role != "doctor":
        return redirect("login")
    
    doctor = Doctor.objects.get(user = request.user)
    name = "Dr. " + doctor.user.first_name + " " + doctor.user.last_name
    specification =  doctor.get_specification_display()
    price = doctor.price
    governorate = doctor.get_governorate_display()
    address = doctor.address
    brief = doctor.brief
    profile_pic = doctor.profile_pic
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
    selected_day = days[0]['day'] if days else None

    all_slots = {}
    for d in days:
        slots = TimeSlots.objects.filter(doctor=doctor, day=d['day']).order_by('time')
        all_slots[d['day']] = {
            'morning': [s.time.strftime('%H:%M') for s in slots if s.time < time(12, 0)],
            'evening': [s.time.strftime('%H:%M') for s in slots if s.time >= time(12, 0)],
        }

    morning_slots = []
    evening_slots = []
    if selected_day:
        for slot in TimeSlots.objects.filter(doctor=doctor, day=selected_day).order_by('time'):
            if slot.time < time(12, 0):
                morning_slots.append(slot)
            else:
                evening_slots.append(slot)

    return render(request, 'doctor/doctor_profile.html', {
        'name': name,
        'specification': specification,
        'price': price,
        'governorate': governorate,
        'address': address,
        'average_rating': average_rating,
        'brief': brief,
        'profile_pic': profile_pic,
        'pending': pending,
        'completed': completed,
        'phone_number':phone_num,
        'email':email,
        'days':days,
        'selected_day': selected_day,
        'morning_slots':morning_slots,
        'evening_slots':evening_slots,
        'all_slots_json': json.dumps(all_slots),
    })

@login_required
def edit_doctor_profile(request):
    errors = {}

    doctor = Doctor.objects.get(user = request.user)
    name = "Dr. " + doctor.user.first_name + " " + doctor.user.last_name
    specification =  doctor.get_specification_display()
    profile_pic = doctor.profile_pic

    User = get_user_model()

    if request.method == 'POST':
        phone_number = request.POST.get('phone_number')
        address = request.POST.get('address')
        brief = request.POST.get('brief')
        username = request.POST.get('username')

        if User.objects.filter(username=username).exclude(id=request.user.id).exists():
            errors['exist_username']="Username already exists"
            return render(request, 'doctor/dr_edit_profile.html', 
            {'errors':errors,
            'doctor': doctor,
            'name': name,
            'specification': specification,
            'profile_pic': profile_pic,
            })
        
        if not validations.validate_username(username):
            errors['username']="Username must be lowercase, allowed letters, numbers, _ or ., and cannot contain forbidden words."
            return render(request, 'doctor/dr_edit_profile.html', 
            {'errors':errors,
            'doctor': doctor,
            'name': name,
            'specification': specification,
            'profile_pic': profile_pic,
            })
        
        if not validations.validate_phone(phone_number):
            errors['phone_invalid'] = "Phone number must start with 0 or 1."
            return render(request, 'doctor/dr_edit_profile.html',
            {'errors':errors,
                'doctor': doctor,
                'name': name,
                'specification': specification,
                'profile_pic': profile_pic,
            })
        
        if not validations.validate_address(address):
            errors['address']="can't use <,> or forbidden words"
            return render(request, 'doctor/dr_edit_profile.html',
            {'errors':errors,
            'doctor': doctor,
            'name': name,
            'specification': specification,
            'profile_pic': profile_pic,
            })

        if not validations.validate_address(brief):
            errors['brief']="Brief can't contain forbidden words."
            return render(request, 'doctor/dr_edit_profile.html',
            {'errors':errors,
            'doctor': doctor,
            'name': name,
            'specification': specification,
            'profile_pic': profile_pic,
            })
        
        doctor.user.username = username
        doctor.phone_number = phone_number
        doctor.address = address
        doctor.brief = brief
        doctor.price = request.POST.get('price')
        doctor.governorate = request.POST.get('governorate')
        doctor.profile_pic = request.FILES.get('profile_pic') or doctor.profile_pic
        doctor.user.save()
        doctor.save()
        return redirect('doctor:doctor_dashboard')

    return render(request, 'doctor/dr_edit_profile.html', {
        'doctor': doctor,
        'errors': errors,
        'name': name,
        'specification': specification,
        'profile_pic': profile_pic,
    })


@login_required
def doctor_requests(request, type):
    if request.user.role != 'doctor':
        return redirect('login')
    
    doctor = Doctor.objects.get(user = request.user)

    name = "Dr. " + doctor.user.first_name + " " + doctor.user.last_name
    specification =  doctor.get_specification_display()
    profile_pic = doctor.profile_pic

    doctor_requests = doctor.doctor_requests.all()

    pending = doctor_requests.filter(status='pending').order_by('-date', '-time')
    edited = doctor_requests.filter(status='edited').order_by('-date', '-time')
    accepted = doctor_requests.filter(status='accepted').order_by('-date', '-time')
    completed = doctor_requests.filter(status='completed').order_by('-date', '-time')


    context_base = {
        'name': name,
        'profile_pic': profile_pic,
        "specification": specification,
    }

    if type in ('pending', 'edited') or type is None:
        pending_list = []
        for req in pending.order_by('-date', '-time'):
            req_day = req.date.strftime('%A').lower()
            req.day_slots = TimeSlots.objects.filter(doctor=doctor, day=req_day).order_by('time')
            pending_list.append(req)

        edited_list = []
        for req in edited.order_by('-date', '-time'):
            req_day = req.date.strftime('%A').lower()
            req.day_slots = TimeSlots.objects.filter(doctor=doctor, day=req_day).order_by('time')
            edited_list.append(req)

        return render(request, 'doctor/requests_pending.html', {
            **context_base,
            "pending": pending_list,
            "edited": edited_list,
        })
    elif type == 'accepted':
        return render(request, 'doctor/requests_accepted.html', {
            **context_base,
            "accepted": accepted,
        })      
    elif type == 'completed':
        return render(request, 'doctor/requests_completed.html', {
            **context_base,            
            'completed': completed,
        })

    else:
        return redirect('doctor:doctor_dashboard')

@login_required
@require_POST
def request_action(request, request_id):
    if request.user.role != 'doctor':
        return redirect('login')

    doctor = Doctor.objects.get(user=request.user)

    try:
        req = DoctorRequest.objects.get(id=request_id, doctor=doctor)
    except DoctorRequest.DoesNotExist:
        return redirect('doctor:doctor_requests', type='pending')

    action = request.POST.get('action')

    if action == 'reject':
        req.status = 'rejected'
        req.save()

    elif action == 'accept':
        req.status = 'accepted'
        req.save()

    elif action == 'reschedule':
        new_time = request.POST.get('new_time')
        if new_time:
            try:
                h, m = new_time.split(':')
                new_t = time_type(int(h), int(m))
                if new_t == req.time:
                    req.status = 'accepted'
                else:
                    req.time = new_t
                    req.status = 'edited'
                req.save()
            except (ValueError, AttributeError):
                pass

    return redirect('doctor:doctor_requests', type='pending')

@login_required
@require_POST
def mark_done_doctor(request, request_id):
    if request.user.role != 'doctor':
        return redirect('login')

    doctor = Doctor.objects.get(user=request.user)
    try:
        req = DoctorRequest.objects.get(id=request_id, doctor=doctor, status='accepted')
        req.doctor_done = True
        if req.patient_done:
            req.status = 'completed'
        req.save()
    except DoctorRequest.DoesNotExist:
        pass

    return redirect('doctor:doctor_requests', type='accepted')


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

@login_required
def edit_time_slots(request):
    if request.user.role != 'doctor':
        return redirect('login')

    doctor = Doctor.objects.get(user=request.user)
    days = get_ordered_week_days()
    selected_day = request.GET.get('day') or days[0]['day']

    # All days' slots as JSON for client-side switching
    all_slots = {}
    for d in days:
        s = TimeSlots.objects.filter(doctor=doctor, day=d['day']).order_by('time')
        all_slots[d['day']] = [slot.time.strftime('%H:%M') for slot in s]

    slots = TimeSlots.objects.filter(doctor=doctor, day=selected_day).order_by('time')
    morning_slots = [s for s in slots if s.time < time(12, 0)]
    evening_slots = [s for s in slots if s.time >= time(12, 0)]

    return render(request, 'doctor/time_slots.html', {
        'days': days,
        'selected_day': selected_day,
        'morning_slots': morning_slots,
        'evening_slots': evening_slots,
        'all_slots_json': json.dumps(all_slots),
    })

@login_required
@require_POST
def save_time_slots(request):
    if request.user.role != 'doctor':
        return JsonResponse({'error': 'Forbidden'}, status=403)

    doctor = Doctor.objects.get(user=request.user)

    try:
        data = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)

    # Accept multi-day: { days: { "monday": [...], ... } } or legacy single-day
    days_data = data.get('days')
    if not days_data:
        day   = data.get('day')
        times = data.get('times', [])
        if not day:
            return JsonResponse({'error': 'Missing day'}, status=400)
        days_data = {day: times}

    for day, times in days_data.items():
        TimeSlots.objects.filter(doctor=doctor, day=day).delete()
        for t_str in times:
            try:
                h, m = t_str.split(':')
                t_val = time(int(h), int(m))
            except (ValueError, AttributeError):
                continue
            TimeSlots.objects.get_or_create(doctor=doctor, day=day, time=t_val)

    return JsonResponse({'success': True})



@login_required
def create_blood_request(request):
    return donation_views.create_blood_request(request)


@login_required
def my_blood_requests(request):
    return donation_views.my_blood_requests(request)


@login_required
def request_offers(request, request_id):
    return donation_views.request_offers(request, request_id)


@login_required
def accept_offer(request, offer_id):
    return donation_views.accept_offer(request, offer_id)


@login_required
def requester_mark_done(request, offer_id):
    return donation_views.requester_mark_done(request, offer_id)


@login_required
def cancel_blood_request(request, request_id):
    return donation_views.cancel_blood_request(request, request_id)