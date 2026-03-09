from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login
from django.contrib.auth.hashers import make_password
from django.core.cache import cache
from django.core.mail import send_mail
from project.settings import EMAIL_HOST_USER, FERNET_KEY
from django.contrib.auth import get_user_model
import random
from .models import ROLE_REDIRECTS, Patient, Doctor, Nurse, Pharmacist, Donor, PendingUser
from cryptography.fernet import Fernet
import json
from . import validations



def user_login(request):
    errors = {}
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')

        user = authenticate(request, username=username, password=password)
        
        if user is None:
            errors['login_error']='Invalid username or password'
            return render(request, 'accounts/login.html',{'errors': errors})
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
            request.session['otp_source'] = 'login'

            return redirect('verify_otp_l')

    return render(request, 'accounts/login.html')

def verify_otp_login(request):
    errors = {}
    if request.method == "POST":
        user_id = request.session.get("otp_user_id")

        if request.method == "POST":
            list_otp = [
                request.POST.get('otp1'),
                request.POST.get('otp2'),
                request.POST.get('otp3'),
                request.POST.get('otp4'),
                request.POST.get('otp5'),
                request.POST.get('otp6')
            ]
        for otp in list_otp:
            if not otp or not otp.isdigit():
                errors['otp_invalid']="All OTP fields must be digits only."
                return render(request, "accounts/verify_otp.html", {'errors': errors, "otp_type": "login"})

        otp_str = "".join(list_otp)
        otp_input = int(otp_str)
        
        if not user_id:
            return redirect('login')

        saved_otp = cache.get(f"otp_{user_id}")

        attempts = request.session.get("otp_attempts", 0)

        if attempts >= 3:
            errors['otp_invalid']="Invalid OTP"
            cache.delete(f"otp_{user_id}")
            request.session.pop("otp_user_id", None)
            request.session.pop("otp_attempts", None)
            return redirect("verify_otp_faild")
        
        if not saved_otp:
            errors['otp_invalid']="OTP Expired"
            return render(request, "accounts/verify_otp.html", {'errors': errors, "otp_type": "login"})

        if saved_otp != otp_input:
            request.session["otp_attempts"] = attempts + 1
            errors['otp_invalid']="Invalid OTP"
            return render(request, "accounts/verify_otp.html", {'errors': errors, "otp_type": "login"})

        request.session.pop("otp_attempts", None)

        User = get_user_model()
        user = get_object_or_404(User, id=user_id)
        login(request, user)
        cache.delete(f"otp_{user_id}")
        request.session.pop("otp_user_id", None)

        return redirect("user_profile")
    return render(request, "accounts/verify_otp.html", {"otp_type": "login"})

def resend_otp_login(request):
    if request.method == 'GET':
        user_id = request.session.get("otp_user_id")
        if not user_id:
            return redirect('login')
        User = get_user_model()
        user = get_object_or_404(User, id=user_id)
        otp = random.randint(100000,999999)

        cache.set(f"otp_{user.id}", otp, timeout=300)

        send_mail(
            subject = "TechCare Team",
            message = f"your verification OTP is {otp}",
            from_email = EMAIL_HOST_USER,
            recipient_list = [user.email]
        )
        
        return redirect('verify_otp_l')
    return redirect('login')


def user_register(request):
    errors = {}
    if request.method =='POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        first_name = request.POST.get('first_name')
        last_name = request.POST.get('last_name')
        email = request.POST.get('email')
        role = request.POST.get('role')

        User = get_user_model()

        if User.objects.filter(username=username).exists():
            errors['exist_username']="Username already exists"
            return render(request, 'accounts/register.html', {'errors':errors})

        if User.objects.filter(email=email).exists():
            errors['exist_email']="email already exists"
            return render(request, 'accounts/register.html', {'errors':errors})
        
        if not validations.validate_username(username):
            errors['username']="Username must be lowercase, allowed letters, numbers, _ or ., and cannot contain forbidden words."
            return render(request, 'accounts/register.html', {'errors':errors})
        
        if not validations.validate_email(email):
            errors['email']="Email must be valid (user@example.com)"
            return render(request, 'accounts/register.html', {'errors':errors})
        
        if not validations.validate_password(password):
            errors['password']="Password must be at least 8 chars and include at least one uppercase, one lowercase, one number, and one special char (!@#&?$%*.-~)."
            return render(request, 'accounts/register.html', {'errors':errors})
        
        if not validations.validate_name(first_name):
            errors['name']="Name must start with a capital letter, at least 2 letters, cannot contain forbidden words."
            return render(request, 'accounts/register.html', {'errors':errors})
        
        if not validations.validate_name(last_name):
            errors['name']="Name must start with a capital letter, at least 2 letters, cannot contain forbidden words."
            return render(request, 'accounts/register.html', {'errors':errors})
        
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

        request.session['otp_source'] = 'signup'

        return redirect('verify_otp_s', token=pending_user.id)
    return render(request, 'accounts/register.html')

def verify_otp_signup(request, token):
    errors = {}
    pending_user = get_object_or_404(PendingUser, id=token)
    if request.method == "POST":
        list_otp = [
            request.POST.get('otp1'),
            request.POST.get('otp2'),
            request.POST.get('otp3'),
            request.POST.get('otp4'),
            request.POST.get('otp5'),
            request.POST.get('otp6')
        ]
        for otp in list_otp:
            if not otp or not otp.isdigit():
                errors['otp_invalid']="All OTP fields must be digits only."
                return render(request, "accounts/verify_otp.html", {'errors': errors, "token": token, "otp_type": "signup", "url_back": "register"})

        otp_str = "".join(list_otp)
        otp_input = int(otp_str)

        encrypted_data = cache.get(f"pending_data_{pending_user.id}")

        if not encrypted_data:
            return redirect('login')
        
        key = Fernet(FERNET_KEY)
        data = key.decrypt(encrypted_data)

        pending_data = json.loads(data)

        attempts = pending_data['attempts']

        if attempts >= 3:
            cache.delete(f"pending_data_{pending_user.id}")
            pending_user.delete()
            return redirect("verify_otp_faild")        
        
        if str(pending_data['otp']) != str(otp_input):
            pending_data["attempts"] = attempts + 1
            updated_encrypted = key.encrypt(json.dumps(pending_data).encode())
            cache.set(f"pending_data_{pending_user.id}", updated_encrypted, timeout=300)
            errors['otp_invalid']="Invalid OTP"
            return render(request, 'accounts/verify_otp.html',{'errors': errors, "token": token, "otp_type": "signup", "url_back": "register"})

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
        login(request, user)
        cache.delete(f"pending_data_{pending_user.id}")
        pending_user.delete()

        return redirect(ROLE_REDIRECTS[user.role])

    return render(request, "accounts/verify_otp.html", {
        "token": token,
        "otp_type": "signup",
        "url_back": "register"
        })

def resend_otp_signup(request, token):
    if request.method == 'GET':
        pending_user = get_object_or_404(PendingUser, id=token)
        otp = random.randint(100000,999999)

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
            recipient_list = [pending_user.email]
        )

        return redirect('verify_otp_s', token=token)
    return redirect('user_register')


def verify_otp_faild(request):
    
    source = request.session.get('otp_source')

    if source == 'login':
        back_url = 'login'

    elif source == 'signup':
        back_url = 'register'

    elif source == 'forget':
        back_url = 'forget_password'

    else:
        back_url = 'login'

    request.session.pop('otp_source', None)
    return render(request, 'accounts/verify_otp_faild.html', {
        'back_url': back_url
    })


def patient_registration(request):
    errors = {}
    if request.method == 'POST':
        gender = request.POST.get('gender')
        address = request.POST.get('address')
        governorate = request.POST.get('governorate')
        phone_number = request.POST.get('phone_number')
        profile_pic = request.FILES.get('profile_pic')
        national_id_pic_back = request.FILES.get('national_id_pic_back')
        national_id_pic_front = request.FILES.get('national_id_pic_front')

        if not validations.validate_phone(phone_number):
            errors['phone_invalid'] = "Phone number must start with 0 or 1."
            return render(request, 'accounts/patient_registration.html', {'errors':errors})
        
        if not validations.validate_address(address):
            errors['address']="can't use <,> or forbidden words"
            return render(request, 'accounts/patient_registration.html', {'errors':errors})

        patient = Patient.objects.create(
            user=request.user,
            gender=gender,
            address=address,
            governorate=governorate,
            phone_number=phone_number,
            profile_pic=profile_pic,
            national_id_pic_back=national_id_pic_back,
            national_id_pic_front=national_id_pic_front,
        )

        patient.save()

        return redirect("user_profile")
    return render(request, 'accounts/patient_registration.html')


def doctor_registration(request):
    errors = {}
    if request.method == 'POST':
        gender = request.POST.get('gender')
        address = request.POST.get('address')
        governorate = request.POST.get('governorate')
        phone_number = request.POST.get('phone_number')
        profile_pic = request.FILES.get('profile_pic')
        date_of_birth = request.POST.get('date_of_birth')

        if not validations.validate_phone(phone_number):
            errors['phone_invalid'] = "Phone number must start with 0 or 1."
            return render(request, 'accounts/doctor_registration.html', {'errors':errors})
        
        if not validations.validate_dop(date_of_birth,22):
            errors['dob_invalid'] = "You must be at least 22 years old."
            return render(request, 'accounts/doctor_registration.html', {'errors':errors})
        
        if not validations.validate_address(address):
            errors['address']="can't use <,> or forbidden words"
            return render(request, 'accounts/doctor_registration.html', {'errors':errors})

        doctor = Doctor.objects.create(
            user=request.user,
            gender=gender,
            address=address,
            governorate=governorate,
            phone_number=phone_number,
            profile_pic=profile_pic,
            date_of_birth = date_of_birth
        )

        doctor.save()
        
        return redirect('doctor_registration_s2')
    
    return render(request, 'accounts/doctor_registration.html')

def doctor_registration_s2(request):
    doctor = Doctor.objects.get(user=request.user)

    if request.method == 'POST':
        doctor.excellence_certificate = request.FILES.get('excellence_certificate')
        doctor.price = float(request.POST.get('price'))
        doctor.syndicate_card = request.FILES.get('syndicate_card')
        doctor.practice_permit = request.FILES.get('practice_permit')
        doctor.graduation_certificate = request.FILES.get('graduation_certificate')
        doctor.university = request.POST.get('university')
        doctor.specification = request.POST.get('specification')
        doctor.national_id_pic_back = request.FILES.get('national_id_pic_back')
        doctor.national_id_pic_front = request.FILES.get('national_id_pic_front')
        doctor.save()

        return redirect("user_profile")
    return render(request, 'accounts/doctor_registration_s2.html')


def nurse_registration_step1(request):
    errors = {}
    if request.method == 'POST':
        gender = request.POST.get('gender')
        phone_number = request.POST.get('phone_number')
        date_of_birth = request.POST.get('date_of_birth')
        governorate = request.POST.get('governorate')
        profile_pic = request.FILES.get('profile_pic')
        address = request.POST.get('address')

        if not validations.validate_phone(phone_number):
            errors['phone_invalid'] = "Phone number must start with 0 or 1."
            return render(request, 'accounts/nurse_registration.html', {'errors':errors})

        
        if not validations.validate_dop(date_of_birth,20):
            errors['dob_invalid'] = "You must be at least 20 years old."
            return render(request, 'accounts/nurse_registration.html', {'errors':errors})
        
        if not validations.validate_address(address):
            errors['address']="can't use <,> or forbidden words"
            return render(request, 'accounts/nurse_registration.html', {'errors':errors})

        nurse = Nurse.objects.create(
            user=request.user,
            gender=gender,
            phone_number=phone_number,
            date_of_birth=date_of_birth,
            governorate=governorate,
            profile_pic=profile_pic,
            address = address,
        )
        nurse.save()

        return redirect('nurse_registration_s2')

    return render(request, 'accounts/nurse_registration.html')

def nurse_registration_step2(request):

    nurse = Nurse.objects.get(user=request.user)

    if request.method == 'POST':
        
        nurse.excellence_certificate = request.FILES.get('excellence_certificate')
        nurse.syndicate_card = request.FILES.get('syndicate_card')
        nurse.practice_permit = request.FILES.get('practice_permit')
        nurse.graduation_certificate = request.FILES.get('graduation_certificate')
        nurse.national_id_pic_front = request.FILES.get('national_id_pic_front')
        nurse.national_id_pic_back = request.FILES.get('national_id_pic_back')
        nurse.save()

        return redirect("user_profile")

    return render(request, 'accounts/nurse_registration_s2.html')


def pharmacist_registration_step1(request):
    errors = {}
    if request.method == 'POST':
        gender = request.POST.get('gender')
        phone_number = request.POST.get('phone_number')
        date_of_birth = request.POST.get('date_of_birth')
        national_id_pic_front = request.FILES.get('national_id_pic_front')
        national_id_pic_back = request.FILES.get('national_id_pic_back')
        profile_pic = request.FILES.get('profile_pic')

        if not validations.validate_phone(phone_number):
            errors['phone_invalid'] = "Phone number must start with 0 or 1."
            return render(request, 'accounts/pharmacist_registration.html', {'errors':errors})

        
        if not validations.validate_dop(date_of_birth,18):
            errors['dob_invalid'] = "You must be at least 18 years old."
            return render(request, 'accounts/pharmacist_registration.html', {'errors':errors})

        pharmacist = Pharmacist.objects.create(
            user=request.user,
            gender=gender,
            phone_number=phone_number,
            date_of_birth=date_of_birth,
            national_id_pic_front=national_id_pic_front,
            national_id_pic_back=national_id_pic_back,
            profile_pic=profile_pic
        )

        pharmacist.save()

        return redirect('pharmacist_registration_s2')

    return render(request, 'accounts/pharmacist_registration.html')

def pharmacist_registration_step2(request):
    errors = {}

    pharmacist = Pharmacist.objects.get(user = request.user)

    if request.method == 'POST':
        pharmacy_name = request.POST.get('pharmacy_name')
        pharmacy_address = request.POST.get('pharmacy_address')

        if not validations.validate_pharmacy_name(pharmacy_name):
            errors['name']="Name must be at most 60 letter."
            return render(request, 'accounts/pharmacist_registration_s2.html')
        
        if not validations.validate_address(pharmacy_address):
            errors['address']="can't use <,> or forbidden words"
            return render(request, 'accounts/pharmacist_registration_s2.html')

        pharmacist.pharmacy_name = pharmacy_name
        pharmacist.pharmacy_address = pharmacy_address
        pharmacist.university = request.POST.get('university')
        pharmacist.governorate = request.POST.get('governorate')
        pharmacist.syndicate_card = request.FILES.get('syndicate_card')
        pharmacist.practice_permit = request.FILES.get('practice_permit')
        pharmacist.graduation_certificate = request.FILES.get('graduation_certificate')
        pharmacist.save()

        return redirect("user_profile")

    return render(request, 'accounts/pharmacist_registration_s2.html')


def donor_registration(request):
    errors = {}
    if request.method == 'POST':
        address = request.POST.get('address')
        governorate = request.POST.get('governorate')
        phone_number = request.POST.get('phone_number')
        profile_pic = request.FILES.get('profile_pic')
        national_id_pic_back = request.FILES.get('national_id_pic_back')
        national_id_pic_front = request.FILES.get('national_id_pic_front')
        blood_type = request.POST.get('blood_type')
        last_donation_date =request.POST.get('last_donation_date')
        date_of_birth = request.POST.get('date_of_birth')

        if not validations.validate_phone(phone_number):
            errors['phone_invalid'] = "Phone number must start with 0 or 1."
            return render(request, 'accounts/Donor_registration.html', {'errors':errors})

        if not validations.validate_dop(date_of_birth,18):
            errors['dob_invalid'] = "You must be at least 18 years old."
            return render(request, 'accounts/Donor_registration.html', {'errors':errors})
        
        if not validations.validate_donation_date(last_donation_date, date_of_birth):
            errors['last_donation_invalid'] = "Last blood donation must be after you turned 16."
            return render(request, 'accounts/Donor_registration.html', {'errors':errors})
        
        if not validations.validate_address(address):
            errors['address']="can't use <,> or forbidden words"
            return render(request, 'accounts/Donor_registration.html', {'errors':errors})

        donor = Donor.objects.create(
            user=request.user,
            address=address,
            governorate=governorate,
            phone_number=phone_number,
            profile_pic=profile_pic,
            national_id_pic_back=national_id_pic_back,
            national_id_pic_front=national_id_pic_front,
            blood_type = blood_type,
            last_donation_date = last_donation_date,
            date_of_birth = date_of_birth
        )
        donor.save()

        return redirect("user_profile")
    return render(request, 'accounts/Donor_registration.html')


def forget_password(request):
    errors = {}
    if request.method == 'POST':
        email = request.POST.get('email')
        User = get_user_model()

        if User.objects.filter(email=email).exists():
            user = get_object_or_404(User, email=email)
        else:
            errors['exist_email']="email don't exists"
            return render(request, 'accounts/forget_password.html', {'errors':errors})

        otp = random.randint(100000,999999)

        cache.set(f"otp_{user.id}", otp, timeout=300)

        send_mail(
            subject = "TechCare Team",
            message = f"your verification OTP is {otp}",
            from_email = EMAIL_HOST_USER,
            recipient_list = [user.email]
        )
        request.session['otp_user_id'] = user.id
        request.session['otp_source'] = 'forget'

        return redirect('verify_otp_forget_password')

    return render(request, 'accounts/forget_password.html')

def verify_otp_forget_password(request):
    errors = {}
    if request.method == "POST":
        if request.method == "POST":
            list_otp = [
                request.POST.get('otp1'),
                request.POST.get('otp2'),
                request.POST.get('otp3'),
                request.POST.get('otp4'),
                request.POST.get('otp5'),
                request.POST.get('otp6')
            ]
        for otp in list_otp:
            if not otp or not otp.isdigit():
                errors['otp_invalid']="All OTP fields must be digits only."
                return render(request, "accounts/verify_otp.html", {
                'errors': errors,
                'otp_type': 'forget',
                'url_back': 'forget_password'
                })

        otp_str = "".join(list_otp)
        otp_input = int(otp_str)

        user_id = request.session.get("otp_user_id")
        if not user_id:
            return redirect('login')

        saved_otp = cache.get(f"otp_{user_id}")

        attempts = request.session.get("otp_attempts", 0)

        if attempts >= 3:
            errors['otp_invalid']="Invalid OTP"
            cache.delete(f"otp_{user_id}")
            request.session.pop("otp_user_id", None)
            request.session.pop("otp_attempts", None)
            return redirect("verify_otp_faild")
        
        if not saved_otp:
            errors['otp_invalid']="OTP Expired"
            return render(request, "accounts/verify_otp.html", {
            'errors': errors,
            'otp_type': 'forget',
            'url_back': 'forget_password'
            })
        if saved_otp != otp_input:
            request.session["otp_attempts"] = attempts + 1
            errors['otp_invalid']="Invalid OTP"
            return render(request, "accounts/verify_otp.html", {
            'errors': errors,
            'otp_type': 'forget',
            'url_back': 'forget_password'
            })
        
        cache.delete(f"otp_{user_id}")

        return redirect('reset_password')
    return render(  request, "accounts/verify_otp.html", {"otp_type": 'forget', "url_back": 'forget_password'})  

def reset_password(request):
    errors = {}
    user_id = request.session.get("otp_user_id")
    if not user_id:
        return redirect('forget_password')
    
    if request.method == 'POST':
        password = request.POST.get('password')
        confirm = request.POST.get('confirm')

        if not validations.validate_password(password):
            errors['password']="Password must be at least 8 chars and include at least one uppercase, one lowercase, one number, and one special char (!@#&?$%*.-~)."
            return render(request, 'accounts/reset_password.html', {'errors':errors})
        
        if password != confirm :
            errors['password']="Password Not Match."
            return render(request, 'accounts/reset_password.html', {'errors':errors})

        User = get_user_model()
        user = get_object_or_404(User, id=user_id)

        user.set_password(password)
        user.save()

        request.session.pop("otp_user_id", None)
        request.session.pop("otp_attempts", None)
        return redirect('login')
    return render(request, 'accounts/reset_password.html')

def resend_otp_forget_password(request):
    if request.method == 'GET':
        user_id = request.session.get("otp_user_id")
        if not user_id:
            return redirect('forget_password')
        User = get_user_model()
        user = get_object_or_404(User, id=user_id)
        otp = random.randint(100000,999999)

        cache.set(f"otp_{user.id}", otp, timeout=300)

        send_mail(
            subject = "TechCare Team",
            message = f"your verification OTP is {otp}",
            from_email = EMAIL_HOST_USER,
            recipient_list = [user.email]
        )
            
        return redirect('verify_otp_forget_password')
    return redirect('forget_password')

def user_profile(request):
    User = get_user_model()
    user = get_object_or_404(User, id=request.user.id)

    if user.role == 'doctor':
        return redirect("doctor:doctor_dashboard")
    
    elif user.role == 'patient':
        return redirect("doctor:doctor_dashboard")
    
    elif user.role == 'nurse':
        return redirect("doctor:doctor_dashboard")
    
    elif user.role == 'pharmacist':
        return redirect("doctor:doctor_dashboard")
    
    elif user.role == 'donor':
        return redirect("doctor:doctor_dashboard")
        
    else:
        return redirect('home')
    
def terms(request):
    return render(request, 'accounts/terms.html')