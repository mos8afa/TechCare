from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login
from django.contrib.auth.hashers import make_password
from django.contrib import messages
from django.core.cache import cache
from django.core.mail import send_mail
from project.settings import EMAIL_HOST_USER, FERNET_KEY
from django.contrib.auth import get_user_model
import random
from .models import ROLE_REDIRECTS, Patient, Doctor, Nurse, Pharmacist, Donor, PendingUser
from cryptography.fernet import Fernet
import json
from django.views.decorators.csrf import csrf_protect

def user_login(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')

        user = authenticate(request, username=username, password=password)
        
        if user is None:
            messages.error(request,'Invalid username or password', extra_tags='login_error')
            return render(request, 'accounts/login.html')
        else:
            otp = random.randint(100000,999999)

            cache.set(f"otp_{user.id}", otp, timeout=300)

            send_mail(
                subject = "TechCare Team",
                message = f"your verification OTP is {otp}",
                from_email = EMAIL_HOST_USER,
                recipient_list = [user.email]
            )
            request.session['otp_user_id'] = user.id

            return redirect('verify_otp_l')

    return render(request, 'accounts/login.html')

def verify_otp_login(request):
    if request.method == "POST":
        user_id = request.session.get("otp_user_id")
        otp1 = request.POST.get("otp1")
        otp2 = request.POST.get("otp2")
        otp3 = request.POST.get("otp3")
        otp4 = request.POST.get("otp4")
        otp5 = request.POST.get("otp5")
        otp6 = request.POST.get("otp6")
        
        otp_str = str(otp1)+str(otp2)+str(otp3)+str(otp4)+str(otp5)+str(otp6)
        otp = int(otp_str)
        
        if not user_id:
            messages.error(request, "User not found", extra_tags='login_user_error')
            return redirect("login")

        saved_otp = cache.get(f"otp_{user_id}")

        attempts = request.session.get("otp_attempts", 0)

        if attempts >= 5:
            messages.error(request, "Too many attempts",extra_tags='otp_attempts_error')
            cache.delete(f"otp_{user_id}")
            request.session.pop("otp_user_id", None)
            request.session.pop("otp_attempts", None)
            return redirect("verify_otp_faild")
        
        if not saved_otp:
            messages.error(request, "OTP expired", extra_tags='otp_expired_error')
            return redirect("verify_otp_faild")

        if str(saved_otp) != str(otp):
            request.session["otp_attempts"] = attempts + 1
            messages.error(request, "Invalid OTP", extra_tags='otp_error')
            return render(request, "accounts/verify_otp.html")

        request.session.pop("otp_attempts", None)

        User = get_user_model()
        user = get_object_or_404(User, id=user_id)
        login(request, user)
        cache.delete(f"otp_{user_id}")
        request.session.pop("otp_user_id", None)

        return redirect("home")

    return render(request, "accounts/verify_otp.html")


def user_register(request):
    if request.method =='POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        first_name = request.POST.get('first_name')
        last_name = request.POST.get('last_name')
        email = request.POST.get('email')
        role = request.POST.get('role')

        User = get_user_model()
        if User.objects.filter(username=username).exists():
            messages.error(request, "Username already exists", extra_tags='username_error')
            return redirect('register')
        
        if User.objects.filter(email=email).exists():
            messages.error(request, "email already exists", extra_tags='emai_error')
            return redirect('register')
        
        otp = random.randint(100000,999999)

        pending_user = PendingUser.objects.create(
            username=username,
            email=email,
            password=make_password(password),
            first_name=first_name,
            last_name=last_name,
            role=role,
        )

        pending_data = {
        "otp": otp,
        "attempts":0,
        }

        key = Fernet(FERNET_KEY)

        data = json.dumps(pending_data).encode()
        encrypted = key.encrypt(data)

        cache.set(f"pending_data_{pending_user.id}", encrypted, timeout=300)

        send_mail(
            subject = "TechCare Team",
            message = f"your verification OTP is {otp}",
            from_email = EMAIL_HOST_USER,
            recipient_list = [email]
        )

        return redirect('verify_otp_s', token=pending_user.id)
    
    return render(request, 'accounts/register.html')

def verify_otp_signup(request, token):
    pending_user = get_object_or_404(PendingUser, id=token)
    if request.method == "POST":

        otp_str = "".join([request.POST.get(f"otp{i}") or "" for i in range(1,7)])
        otp_input = int(otp_str)

        encrypted_data = cache.get(f"pending_data_{pending_user.id}")

        if not encrypted_data:
            messages.error(request, "OTP expired", extra_tags='otp_expired_error')
            return redirect("verify_otp_faild")
        
        key = Fernet(FERNET_KEY)
        data = key.decrypt(encrypted_data)

        pending_data = json.loads(data)

        attempts = pending_data['attempts']

        if attempts >= 5:
            cache.delete(f"pending_data_{pending_user.id}")
            pending_user.delete()
            messages.error(request, "Too many attempts",extra_tags='otp_attempts_error' )
            return redirect("verify_otp_faild")        
        
        if str(pending_data['otp']) != str(otp_input):
            pending_data["attempts"] = attempts + 1
            updated_encrypted = key.encrypt(json.dumps(pending_data).encode())
            cache.set(f"pending_data_{pending_user.id}", updated_encrypted, timeout=300)
            messages.error(request, "Invalid OTP", extra_tags='otp_error')
            return render(request, "accounts/verify_otp.html")

        User = get_user_model()
        user = User.objects.create(
            username=pending_user.username,
            email=pending_user.email,
            password=pending_user.password,  
            first_name=pending_user.first_name,
            last_name=pending_user.last_name,
            role=pending_user.role,
            is_active=True
        )
        user.save()
        
        cache.delete(f"pending_data_{pending_user.id}")
        pending_user.delete()

        return redirect(ROLE_REDIRECTS[user.role])

    return render(request, "accounts/verify_otp.html", {"token": token})


def verify_otp_faild(request):
    return render (request, 'accounts/verify_otp_faild.html')


def patient_registration(request):
    if request.method == 'POST':
        gender = request.POST.get('gender')
        address = request.POST.get('address')
        governorate = request.POST.get('governorate')
        phone_number = request.POST.get('phone_number')
        profile_pic = request.FILES.get('profile_pic')
        national_id_pic_back = request.FILES.get('national_id_pic_back')
        national_id_pic_front = request.FILES.get('national_id_pic_front')

        Patient.objects.create(
            user=request.user,
            gender=gender,
            address=address,
            governorate=governorate,
            phone_number=phone_number,
            profile_pic=profile_pic,
            national_id_pic_back=national_id_pic_back,
            national_id_pic_front=national_id_pic_front,
        )

        login(request, request.user)
        return redirect('home')
    return render(request, 'accounts/patient_registration.html')


def doctor_registration(request):
    if request.method == 'POST':
        gender = request.POST.get('gender')
        address = request.POST.get('address')
        governorate = request.POST.get('governorate')
        phone_number = request.POST.get('phone_number')
        profile_pic = request.FILES.get('profile_pic')
        date_of_birth = request.POST.get('date_of_birth')

        Doctor.objects.create(
            user=request.user,
            gender=gender,
            address=address,
            governorate=governorate,
            phone_number=phone_number,
            profile_pic=profile_pic,
            date_of_birth = date_of_birth
        )

        request.session['doctor_id'] = request.user.id

        return redirect('doctor_registration_s2')
    
    return render(request, 'accounts/doctor.html')

def doctor_registration_s2(request):
    doctor_id = request.session.get('doctor_id')
    if not doctor_id:
        return redirect('doctor_registration')

    doctor = Doctor.objects.get(id=doctor_id)

    if request.method == 'POST':
        doctor.excellence_certificate = request.FILES.get('excellence_certificate')
        doctor.price = request.POST.get('price')
        doctor.syndicate_card = request.FILES.get('syndicate_card')
        doctor.practice_permit = request.FILES.get('practice_permit')
        doctor.graduation_certificate = request.FILES.get('graduation_certificate')
        doctor.university = request.POST.get('university')
        doctor.specification = request.FILES.get('national_id_pic_front')
        doctor.national_id_pic_back = request.FILES.get('national_id_pic_back')
        doctor.national_id_pic_front = request.FILES.get('national_id_pic_front')
        doctor.save()

        login(request, request.user)

        del request.session['doctor_id']

        return redirect('home')
    return render(request, 'accounts/doctor_registeration_s2.html')


def nurse_registration_step1(request):
    if request.method == 'POST':
        gender = request.POST.get('gender')
        phone_number = request.POST.get('phone_number')
        date_of_birth = request.POST.get('date_of_birth')
        governorate = request.POST.get('governorate')
        profile_pic = request.FILES.get('profile_pic')

        nurse = Nurse.objects.create(
            user=request.user,
            gender=gender,
            phone_number=phone_number,
            date_of_birth=date_of_birth,
            governorate=governorate,
            profile_pic=profile_pic
        )

        request.session['nurse_id'] = nurse.id

        return redirect('nurse_registration_s2')

    return render(request, 'accounts/nurse_registration.html')

def nurse_registration_step2(request):
    nurse_id = request.session.get('nurse_id')
    if not nurse_id:
        return redirect('nurse_registration')

    nurse = Nurse.objects.get(id=nurse_id)

    if request.method == 'POST':
        
        excellence_certificate = request.FILES.get('excellence_certificate')
        syndicate_card = request.FILES.get('syndicate_card')
        practice_permit = request.FILES.get('practice_permit')
        graduation_certificate = request.FILES.get('graduation_certificate')
        national_id_pic_front = request.FILES.get('national_id_pic_front')
        national_id_pic_back = request.FILES.get('national_id_pic_back')

        nurse.excellence_certificate = excellence_certificate
        nurse.syndicate_card = syndicate_card
        nurse.practice_permit = practice_permit
        nurse.graduation_certificate = graduation_certificate
        nurse.national_id_pic_front = national_id_pic_front
        nurse.national_id_pic_back = national_id_pic_back
        nurse.save()

        login(request, request.user)

        del request.session['nurse_id']

        return redirect('home')

    return render(request, 'accounts/nurse_registration_s2.html')


def pharmacist_registration_step1(request):
    if request.method == 'POST':
        gender = request.POST.get('gender')
        phone_number = request.POST.get('phone_number')
        date_of_birth = request.POST.get('date_of_birth')
        national_id_pic_front = request.FILES.get('national_id_pic_front')
        national_id_pic_back = request.FILES.get('national_id_pic_back')
        profile_pic = request.FILES.get('profile_pic')

        pharmacist = Pharmacist.objects.create(
            user=request.user,
            gender=gender,
            phone_number=phone_number,
            date_of_birth=date_of_birth,
            national_id_pic_front=national_id_pic_front,
            national_id_pic_back=national_id_pic_back,
            profile_pic=profile_pic
        )

        request.session['pharmacist_id'] = pharmacist.id

        return redirect('pharmacist_registration_s2')

    return render(request, 'accounts/pharmacist_registration_s1.html')

def pharmacist_registration_step2(request):
    pharmacist_id = request.session.get('pharmacist_id')
    if not pharmacist_id:
        return redirect('pharmacist_registration')

    pharmacist = Pharmacist.objects.get(id=pharmacist_id)

    if request.method == 'POST':
        pharmacy_name = request.POST.get('pharmacy_name')
        pharmacy_address = request.POST.get('pharmacy_address')
        university = request.POST.get('university')
        governorate = request.POST.get('governorate')
        syndicate_card = request.FILES.get('syndicate_card')
        practice_permit = request.FILES.get('practice_permit')
        graduation_certificate = request.FILES.get('graduation_certificate')

        pharmacist.pharmacy_name = pharmacy_name
        pharmacist.pharmacy_address = pharmacy_address
        pharmacist.university = university
        pharmacist.governorate = governorate
        pharmacist.syndicate_card = syndicate_card
        pharmacist.practice_permit = practice_permit
        pharmacist.graduation_certificate = graduation_certificate
        pharmacist.save()

        login(request, request.user)

        del request.session['pharmacist_id']

        return redirect('home')

    return render(request, 'accounts/pharmacist_registration_s2.html')


def donor_registration(request):
    if request.method == 'POST':
        gender = request.POST.get('gender')
        address = request.POST.get('address')
        governorate = request.POST.get('governrate')
        phone_number = request.POST.get('phone_number')
        profile_pic = request.FILES.get('profile_pic')
        national_id_pic_back = request.FILES.get('national_id_pic_back')
        national_id_pic_front = request.FILES.get('national_id_pic_front')
        blood_type = request.POST.get('blood_type')
        last_donation_date =request.POST.get('last_donation_date')


        Donor.objects.create(
            user=request.user,
            gender=gender,
            address=address,
            governorate=governorate,
            phone_number=phone_number,
            profile_pic=profile_pic,
            national_id_pic_back=national_id_pic_back,
            national_id_pic_front=national_id_pic_front,
            blood_type = blood_type,
            last_donation_date = last_donation_date
        )

        login(request, request.user)
        return redirect('home')
    return render(request, 'accounts/Donor_registration.html')


def forget_password(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        User = get_user_model()
        user = get_object_or_404(User, email=email)


        otp = random.randint(100000,999999)

        cache.set(f"otp_{user.id}", otp, timeout=300)

        send_mail(
            subject = "TechCare Team",
            message = f"your verification OTP is {otp}",
            from_email = EMAIL_HOST_USER,
            recipient_list = [user.email]
        )
        request.session['otp_user_id'] = user.id
        return redirect('verify_otp_forget_password')

    return render(request, 'accounts/forget_password.html')

def verify_otp_forget_password(request):
    if request.method == "POST":
        user_id = request.session.get("otp_user_id")
        otp1 = request.POST.get("otp1")
        otp2 = request.POST.get("otp2")
        otp3 = request.POST.get("otp3")
        otp4 = request.POST.get("otp4")
        otp5 = request.POST.get("otp5")
        otp6 = request.POST.get("otp6")
        
        otp_str = str(otp1)+str(otp2)+str(otp3)+str(otp4)+str(otp5)+str(otp6)
        otp = int(otp_str)
        if not user_id:
            messages.error(request, "User not found", extra_tags='login_user_error')
            return redirect("login")

        saved_otp = cache.get(f"otp_{user_id}")

        attempts = request.session.get("otp_attempts", 0)

        if attempts >= 5:
            messages.error(request, "Too many attempts", extra_tags='otp_attempts_error')
            cache.delete(f"otp_{user_id}")
            request.session.pop("otp_user_id", None)
            request.session.pop("otp_attempts", None)
            return redirect("login")
        
        if not saved_otp:
            messages.error(request, "OTP expired", extra_tags='otp_expired_error')
            return redirect("login")

        if str(saved_otp) != str(otp):
            request.session["otp_attempts"] = attempts + 1
            messages.error(request, "Invalid OTP", extra_tags='otp_error')
            return render(request, "accounts/verify_otp.html")
        
        cache.delete(f"otp_{user_id}")

        return redirect('reset_password')
    return render(request, 'accounts/verify_otp.html')  

def reset_password(request):
    user_id = request.session.get("otp_user_id")
    if not user_id:
        messages.error(request, "Session expired",extra_tags='session_error')
        return redirect("login")
    
    if request.method == 'POST':
        password = request.POST.get('password')
        confirm = request.POST.get('confirm')

        if password != confirm :
            messages.error(request,"passwords not match",extra_tags='password_error')
            return redirect('reset_password')

        User = get_user_model()
        user = get_object_or_404(User, id=user_id)

        user.set_password(password)
        user.save()

        request.session.pop("otp_user_id", None)
        request.session.pop("otp_attempts", None)
        return redirect('login')
    return render(request, 'accounts/reset_password.html')