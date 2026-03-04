from django.shortcuts import redirect, render
from accounts.models import Doctor
from django.db.models import Avg


def doctor_dashboard(request, slug):
    doctor = Doctor.objects.get(user__slug=slug)
    name = "Dr. " + doctor.user.first_name + " " + doctor.user.last_name
    specification =  doctor.get_specification_display()
    price = doctor.price
    governorate = doctor.get_governorate_display()
    address = doctor.address
    brief = doctor.brief
    profile_pic = doctor.profile_pic

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
    })


def edit_doctor_profile(request, slug):
    doctor = Doctor.objects.get(user__slug=slug)
    

    return render(request, 'doctor/dr_edit_profile.html', {
        'doctor': doctor,
    })

def doctor_requests(request, slug, type):
    doctor = Doctor.objects.get(user__slug=slug)
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
        })
    elif type == 'accepted':
        return render(request, 'doctor/requests_accepted.html', {
            'accepted': accepted,
            "slug": slug,
        })      
    elif type == 'completed':
        return render(request, 'doctor/requests_completed.html', {
            'completed': completed,
            "slug": slug,
        })
    
    else:
        return redirect('doctor:doctor_dashboard', slug=slug)