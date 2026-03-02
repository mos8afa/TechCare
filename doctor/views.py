from django.shortcuts import render
from accounts.models import Doctor


def doctor_dashboard(request):
    doctor  = Doctor.objects.get(user=request.user)
    name = "DR. " + doctor.user.first_name + " " + doctor.user.last_name
    specification = doctor.specification
    price = doctor.price
    governorate = doctor.governorate
    address = doctor.address
    rate = doctor.rate

    return render(request, 'doctor/doctor_dashboard.html', {
        'name': name,
        'specification': specification,
        'price': price,
        'governorate': governorate,
        'address': address,
        'rate': rate,
    })


