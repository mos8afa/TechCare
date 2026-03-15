from django.shortcuts import redirect, render, get_object_or_404
from accounts import validations
from accounts.models import Nurse
from django.db.models import Avg
from django.contrib.auth import get_user_model
from django.contrib.auth.decorators import login_required
from.models import Service
from decimal import Decimal


@login_required
def nurse_dashboard(request):
    if request.user.role != "nurse":
        return redirect("login")

    nurse = Nurse.objects.get(user=request.user)
    if nurse.gender == 'male':
        name = "Mr. " + nurse.user.first_name + " " + nurse.user.last_name
    else:
        name = "Mrs. " + nurse.user.first_name + " " + nurse.user.last_name
    governorate = nurse.get_governorate_display()
    address = nurse.address
    brief = nurse.brief
    profile_pic = nurse.profile_pic
    phone_num = nurse.phone_number
    email = nurse.user.email 

    nurse_requests = nurse.nurse_requests.all()
    pending = nurse_requests.filter(status='pending').count()
    completed = nurse_requests.filter(status='completed').count()

    services = nurse.nurse_services.all()

    if nurse.rates.exists():
        average_rating = nurse.rates.aggregate(Avg('rate'))['rate__avg'] or 0
        average_rating = round(average_rating)
    else:
        average_rating = 0

    return render(request, 'nurse/nurse_profile.html', {
        'name': name,
        'governorate': governorate,
        'address': address,
        'phone_number': phone_num,
        'email':email,
        'average_rating': average_rating,
        'brief': brief,
        'profile_pic': profile_pic,
        'pending': pending,
        'completed': completed,
        'services':services
    })


@login_required
def edit_nurse_profile(request):
    errors = {}

    if request.user.role != "nurse":
        return redirect("login")

    nurse = Nurse.objects.get(user=request.user)
    if nurse.gender == 'male':
        name = "Mr. " + nurse.user.first_name + " " + nurse.user.last_name
    else:
        name = "Mrs. " + nurse.user.first_name + " " + nurse.user.last_name

    profile_pic = nurse.profile_pic

    User = get_user_model()

    if request.method == 'POST':
        phone_number = request.POST.get('phone_number')
        address = request.POST.get('address')
        brief = request.POST.get('brief')
        username = request.POST.get('username')

        if User.objects.filter(username=username).exclude(id=request.user.id).exists():
            errors['exist_username'] = "Username already exists"
            return render(request, 'nurse/nurse_edit_profile.html',
                {'errors': errors, 'nurse': nurse, 'name': name, 'profile_pic': profile_pic})

        if not validations.validate_username(username):
            errors['username'] = "Username must be lowercase, allowed letters, numbers, _ or ., and cannot contain forbidden words."
            return render(request, 'nurse/nurse_edit_profile.html',
                {'errors': errors, 'nurse': nurse, 'name': name, 'profile_pic': profile_pic})

        if not validations.validate_phone(phone_number):
            errors['phone_invalid'] = "Phone number must start with 0 or 1."
            return render(request, 'nurse/nurse_edit_profile.html',
                {'errors': errors, 'nurse': nurse, 'name': name, 'profile_pic': profile_pic})

        if not validations.validate_address(address):
            errors['address'] = "Can't use <,> or forbidden words"
            return render(request, 'nurse/nurse_edit_profile.html',
                {'errors': errors, 'nurse': nurse, 'name': name, 'profile_pic': profile_pic})

        if not validations.validate_address(brief):
            errors['brief'] = "Brief can't contain forbidden words."
            return render(request, 'nurse/nurse_edit_profile.html',
                {'errors': errors, 'nurse': nurse, 'name': name, 'profile_pic': profile_pic})

        nurse.user.username = username
        nurse.phone_number = phone_number
        nurse.address = address
        nurse.brief = brief
        nurse.governorate = request.POST.get('governorate')
        nurse.profile_pic = request.FILES.get('profile_pic') or nurse.profile_pic
        nurse.user.save()
        nurse.save()
        return redirect('nurse:nurse_dashboard')

    return render(request, 'nurse/nurse_edit_profile.html', {
        'nurse': nurse,
        'errors': errors,
        'name': name,
        'profile_pic': profile_pic,
    })


@login_required
def nurse_requests(request, type):
    if request.user.role != "nurse":
        return redirect("login")

    nurse = Nurse.objects.get(user=request.user)

    if nurse.gender == 'male':
        name = "Mr. " + nurse.user.first_name + " " + nurse.user.last_name
    else:
        name = "Mrs. " + nurse.user.first_name + " " + nurse.user.last_name

    profile_pic = nurse.profile_pic

    all_requests = nurse.nurse_requests.all()

    pending = all_requests.filter(status='pending').order_by('-date', '-time')
    accepted = all_requests.filter(status='accepted').order_by('-date', '-time')
    completed = all_requests.filter(status='completed').order_by('-date', '-time')

    context_base = {
        'name': name,
        'profile_pic': profile_pic,
    }

    if type == 'pending' or type is None:
        return render(request, 'nurse/requests_pending.html', {
            **context_base,
            'pending': pending,
        })
    elif type == 'accepted':
        return render(request, 'nurse/requests_accepted.html', {
            **context_base,
            'accepted': accepted,
        })
    elif type == 'completed':
        return render(request, 'nurse/requests_completed.html', {
            **context_base,
            'completed': completed,
        })
    else:
        return redirect('nurse:nurse_dashboard')
    

def add_services(request):
    errors={}
    nurse = Nurse.objects.get(user=request.user)

    name = request.POST.get('name')
    description = request.POST.get('description')
    price = request.POST.get('price')

    if not validations.validate_address(description):
            errors['description'] = "Description can't contain forbidden words."
            return render(request, 'nurse/nurse_dashboard.html',
                {'errors': errors})
    try:
        price = Decimal(price)
    except:
        errors['price'] = "Price must be a valid number."
        return render(request, 'nurse/nurse_dashboard.html',
                {'errors': errors})

    if request.method =='POST':
        nurse.nurse_services.create(
            name = name,
            description = description,
            price = price
        )
    
        return redirect('nurse:nurse_dashboard')
        

def edit_service(request, service_id):
    nurse = Nurse.objects.get(user=request.user)

    service = get_object_or_404(Service, id=service_id, nurse=nurse)

    if request.method == "POST":
        service.name = request.POST.get('name')
        service.description = request.POST.get('description')
        service.price = request.POST.get('price')

        service.save()

        return redirect('nurse:nurse_dashboard')

def delete_service(request, service_id):
    nurse = Nurse.objects.get(user=request.user)

    service = get_object_or_404(Service, id=service_id, nurse=nurse)

    service.delete()

    return redirect('nurse:nurse_dashboard')