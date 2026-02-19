from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login
from django.contrib import messages
from django.core.cache import cache
from django.core.mail import send_mail
from project.settings import EMAIL_HOST_USER
from django.contrib.auth import get_user_model
import random

def Login(request):
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

            return redirect('verify-otp')

    return render(request, 'login.html')


def VerifyOTP(request):
    if request.method == "POST":
        user_id = request.session.get("otp_user_id")
        otp = request.POST.get("otp")

        if not user_id:
            messages.error(request, "User not found")
            return redirect("login")

        saved_otp = cache.get(f"otp_{user_id}")

        if not saved_otp:
            messages.error(request, "OTP expired")
            return redirect("login")

        if str(saved_otp) != str(otp):
            messages.error(request, "Invalid OTP")
            return render(request, "verify_otp.html")

        User = get_user_model()
        user = User.objects.get(id=user_id)
        login(request, user)
        cache.delete(f"otp_{user_id}")
        request.session.pop("otp_user_id", None)

        return redirect("home")

    return render(request, "verify_otp.html")