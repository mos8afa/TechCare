from django.shortcuts import redirect, render
from accounts import validations
from accounts.models import Doctor
from django.db.models import Avg
from django.contrib.auth import get_user_model

errors = {}

def doctor_dashboard(request, slug):
    doctor = Doctor.objects.get(user__slug=slug)
    name = "Dr. " + doctor.user.first_name + " " + doctor.user.last_name
    specification =  doctor.get_specification_display()
    price = doctor.price
    governorate = doctor.get_governorate_display()
    address = doctor.address
    brief = doctor.brief
    profile_pic = doctor.profile_pic

    doctor_requests = doctor.doctor_requests.all()
    pending = doctor_requests.filter(status='pending')
    pending = pending.count()
    completed = doctor_requests.filter(status='completed')
    completed = completed.count()

    if doctor.rates.exists():
        average_rating = doctor.rates.aggregate(Avg('rate'))['rate__avg'] or 0
        average_rating = round(average_rating) 
    else:
        average_rating = 0

    return render(request, 'doctor/doctor_profile.html', {
        'name': name,
        'specification': specification,
        'price': price,
        'governorate': governorate,
        'address': address,
        'average_rating': average_rating,
        'brief': brief,
        'profile_pic': profile_pic,
        'slug': slug,  
        'pending': pending,
        'completed': completed,
    })

def edit_doctor_profile(request, slug):
    doctor = Doctor.objects.get(user__slug=slug)
    name = "Dr. " + doctor.user.first_name + " " + doctor.user.last_name
    specification =  doctor.get_specification_display()
    profile_pic = doctor.profile_pic

    User = get_user_model()

    if request.method == 'POST':
        phone_number = request.POST.get('phone_number')
        address = request.POST.get('address')
        brief = request.POST.get('brief')
        username = request.POST.get('username')

        if User.objects.filter(username=username).exists():
            errors['exist_username']="Username already exists"
            return render(request, 'doctor/dr_edit_profile.html', 
            {'errors':errors,
            'doctor': doctor,
            'slug': slug,
            'name': name,
            'specification': specification,
            'profile_pic': profile_pic,
            })
        
        if not validations.validate_username(username):
            errors['username']="Username must be lowercase, allowed letters, numbers, _ or ., and cannot contain forbidden words."
            return render(request, 'doctor/dr_edit_profile.html', 
            {'errors':errors,
            'doctor': doctor,
            'slug': slug,
            'name': name,
            'specification': specification,
            'profile_pic': profile_pic,
            })
        
        if not validations.validate_phone(phone_number):
            errors['phone_invalid'] = "Phone number must start with 0 or 1."
            return render(request, 'doctor/dr_edit_profile.html',
            {'errors':errors,
                'doctor': doctor,
                'slug': slug,
                'name': name,
                'specification': specification,
                'profile_pic': profile_pic,
            })
        
        if not validations.validate_address(address):
            errors['address']="can't use <,> or forbidden words"
            return render(request, 'doctor/dr_edit_profile.html',
            {'errors':errors,
            'doctor': doctor,
            'slug': slug,
            'name': name,
            'specification': specification,
            'profile_pic': profile_pic,
            })

        if not validations.validate_address(brief):
            errors['brief']="Brief can't contain forbidden words."
            return render(request, 'doctor/dr_edit_profile.html',
            {'errors':errors,
            'doctor': doctor,
            'slug': slug,
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
        return redirect('doctor:doctor_dashboard', slug=slug)

    return render(request, 'doctor/dr_edit_profile.html', {
        'doctor': doctor,
        'slug': slug,
        'errors': errors,
        'name': name,
        'specification': specification,
        'profile_pic': profile_pic,
    })

def doctor_requests(request, slug, type):
    doctor = Doctor.objects.get(user__slug=slug)


    name = "Dr. " + doctor.user.first_name + " " + doctor.user.last_name
    specification =  doctor.get_specification_display()
    profile_pic = doctor.profile_pic


    doctor_requests = doctor.doctor_requests.all()

    pending = doctor_requests.filter(status='pending')
    pending = pending.order_by('-date', '-time')
    accepted = doctor_requests.filter(status='accepted')
    accepted = accepted.order_by('-date', '-time')
    completed = doctor_requests.filter(status='completed')
    completed = completed.order_by('-date', '-time')




    if type == 'pending' or type is None:
        return render(request, 'doctor/requests_pending.html', {
            'pending': pending,
            "slug": slug,
            "name": name,
            "specification": specification,
            "profile_pic": profile_pic,
        })
    elif type == 'accepted':
        return render(request, 'doctor/requests_accepted.html', {
            'accepted': accepted,
            "slug": slug,
            "name": name,
            "specification": specification,
            "profile_pic": profile_pic,
        })      
    elif type == 'completed':
        return render(request, 'doctor/requests_completed.html', {
            'completed': completed,
            "slug": slug,
            "name": name,
            "specification": specification, 
            "profile_pic": profile_pic,
        })
    
    else:
        return redirect('doctor:doctor_dashboard', slug=slug)
    
