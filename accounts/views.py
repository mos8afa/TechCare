from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login
from django.contrib import messages
from django.core.cache import cache
from django.core.mail import send_mail
from project.settings import EMAIL_HOST_USER 
from django.contrib.auth import get_user_model
import random
from .forms import RegisterForm
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
    pass


def doctor_registration(request):
    pass


def nurse_registration(request):
    pass


def pharmacist_registration(request):
    pass


def donor_registration(request):
    pass        