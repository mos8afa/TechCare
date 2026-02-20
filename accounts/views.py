from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login
from django.contrib import messages
from django.core.cache import cache
from django.core.mail import send_mail
from project.settings import EMAIL_HOST_USER 
from django.contrib.auth import get_user_model
import random
from .forms import RegisterForm, DonorForm, DoctorStep2Form, DoctorStep1Form, PatientForm, PharmacistStep1Form, NurseStep1Form, NurseStep2Form,PharmacistStep2Form
from .models import ROLE_REDIRECTS
 

def user_login(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')

        user = authenticate(request, username=username, password=password)

        if user is None:
            messages.error(request,'Invalid username or password')
            return render(request, 'login.html')
        else:
            otp = random.randint(10000,99999)

            cache.set(f"otp_{user.id}", otp, timeout=300)

            send_mail(
                subject = "TechCare Team",
                message = f"your verification OTP is {otp}",
                from_email = EMAIL_HOST_USER,
                recipient_list = [user.email]
            )
            request.session['otp_user_id'] = user.id

            return redirect('verify_otp_l')

    return render(request, 'login.html')


def verify_otp_login(request):
    if request.method == "POST":
        user_id = request.session.get("otp_user_id")
        otp = request.POST.get("otp")

        if not user_id:
            messages.error(request, "User not found")
            return redirect("login")

        saved_otp = cache.get(f"otp_{user_id}")

        attempts = request.session.get("otp_attempts", 0)

        if attempts >= 5:
            messages.error(request, "Too many attempts")
            cache.delete(f"otp_{user_id}")
            request.session.pop("otp_user_id", None)
            request.session.pop("otp_attempts", None)
            return redirect("login")
        
        if not saved_otp:
            messages.error(request, "OTP expired")
            return redirect("login")

        if str(saved_otp) != str(otp):
            request.session["otp_attempts"] = attempts + 1
            messages.error(request, "Invalid OTP")
            return render(request, "verify_otp.html")

        request.session.pop("otp_attempts", None)

        User = get_user_model()
        user = get_object_or_404(User, id=user_id)
        login(request, user)
        cache.delete(f"otp_{user_id}")
        request.session.pop("otp_user_id", None)

        return redirect("home")

    return render(request, "verify_otp.html")


def verify_otp_signup(request):
    if request.method == "POST":
        user_id = request.session.get("otp_user_id")
        otp = request.POST.get("otp")

        if not user_id:
            messages.error(request, "User not found")
            return redirect("register")

        saved_otp = cache.get(f"otp_{user_id}")

        attempts = request.session.get("otp_attempts", 0)

        if attempts >= 5:
            cache.delete(f"otp_{user_id}")
            request.session.pop("otp_user_id", None)
            request.session.pop("otp_attempts", None)
            messages.error(request, "Too many attempts")
            return redirect("register")
        
        if not saved_otp:
            messages.error(request, "OTP expired")
            return redirect("register")

        if str(saved_otp) != str(otp):
            request.session["otp_attempts"] = attempts + 1
            messages.error(request, "Invalid OTP")
            return render(request, "verify_otp.html")

        request.session.pop("otp_attempts", None)

        User = get_user_model()
        user = get_object_or_404(User, id=user_id)
        user.is_active = True
        user.save()
        cache.delete(f"otp_{user_id}")

        request.session.pop("otp_user_id", None)

        return redirect(ROLE_REDIRECTS[user.role])

    return render(request, "verify_otp.html")


def user_register(request):
    if request.method =='POST':
        register_form = RegisterForm(request.POST)
        if register_form.is_valid():
            user = register_form.save(commit=False)
            user.is_active = False
            user.save()

            otp = random.randint(10000,99999)

            cache.set(f"otp_{user.id}", otp, timeout=300)

            send_mail(
                subject = "TechCare Team",
                message = f"your verification OTP is {otp}",
                from_email = EMAIL_HOST_USER,
                recipient_list = [user.email]
            )
            request.session['otp_user_id'] = user.id

            return redirect('verify_otp_s')
    else:
        register_form = RegisterForm()
    return render(request, 'register.html',{'register_form':register_form})


def patient_registration(request):
    if request.method == 'POST':
        form = PatientForm(request.POST, request.FILES)
        if form.is_valid():
            patient = form.save(commit=False)
            patient.user = request.user
            patient.save()

            login(request, request.user)
            return redirect('home')
    else:
        form = PatientForm()
    return render(request, 'patient_registration.html',{'form':form})


def doctor_registration(request):
    if request.method == 'POST':
        form = DoctorStep1Form(request.POST, request.FILES)
        if form.is_valid():
            doctor = form.save(commit=False)
            doctor.user = request.user
            doctor.save()

            return redirect('doctor_registration_s2')
        else:
            form = DoctorStep1Form()
    return render(request, 'doctor.html', {'form':form})

def doctor_registration_s2(request):
    if request.method == 'POST':
        doctor = request.user.doctor
        form = DoctorStep2Form(request.POST, request.FILES, instance=doctor)
        if form.is_valid():
            doctor = form.save(commit=False)
            doctor.user = request.user
            doctor.save()
            
            login(request, request.user)
            return redirect('home')
        else:
            form = DoctorStep2Form()
            form.fields=['excellence_certificate', 'price', 'syndicate_card', 'practice_permit', 'graduation_certificate', 'university', 'specification']
    return render(request, 'doctor.html', {'form':form})


def nurse_registration(request):
    if request.method == 'POST':
        form = NurseStep1Form(request.POST, request.FILES)
        if form.is_valid():
            nurse = form.save(commit=False)
            nurse.user = request.user
            nurse.save()

            return redirect('nurse_registration_s2')
        else:
            form = NurseStep1Form()
            form.fields = ['gender', 'phone_number', 'date_of_birth', 'governorate','national_id_pic_front', 'national_id_pic_back', 'profile_pic']

    return render(request, 'nurse.html', {'form':form})

def nurse_registration_s2(request):
    if request.method == 'POST':
        nurse = request.user.nurse
        form = NurseStep2Form(request.POST,request.FILES, instance=nurse)
        if form.is_valid():
            nurse = form.save(commit=False)
            nurse.user = request.user
            nurse.save()
            login(request, request.user)
            return redirect('home')
        else:
            form = NurseStep2Form()
    return render(request, 'nurse.html', {'form':form})


def pharmacist_registration(request):
    if request.method == 'POST':
        form = PharmacistStep1Form(request.POST, request.FILES)
        if form.is_valid():
            pharmacist = form.save(commit=False)
            pharmacist.user = request.user
            pharmacist.save()

            return redirect('pharmacist_registration_s2')
        else:
            form = PharmacistStep1Form()
    return render(request, 'pharmacist.html', {'form':form})

def pharmacist_registration_s2(request):
    if request.method == 'POST':
        pharmacist = request.user.pharmacist
        form = PharmacistStep2Form(request.POST, request.FILES, instance=pharmacist)
        if form.is_valid():
            pharmacist = form.save(commit=False)
            pharmacist.user = request.user
            pharmacist.save()

            login(request, request.user)
            return redirect('home')
        else:
            form = PharmacistStep2Form()
    return render(request, 'pharmacist.html', {'form':form})


def donor_registration(request):
        if request.method == 'POST':
            form = DonorForm(request.POST,request.FILES)
            if form.is_valid():
                donor = form.save(commit=False)
                donor.user = request.user
                donor.save()

                login(request, request.user)
                return redirect('home')
        else:
            form = DonorForm()
        return render(request, 'donor_registration.html',{'form':form})      