from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.shortcuts import render
from accounts.models import Doctor, Nurse, Donor, Patient


def home_view(request):
    context = {
        'doctors_count': Doctor.objects.count(),
        'donors_count':  Donor.objects.count(),
        'nurses_count':  Nurse.objects.count(),
        'patients_count': Patient.objects.count(),
    }
    return render(request, 'index.html', context)


urlpatterns = [
    path('', home_view, name='home'),
    path('admin/', admin.site.urls),
    path('api/',include('api.urls')),
    path('auth/',include("accounts.urls")),
    path('doctor/', include('doctor.urls', namespace='doctor')),
    path('nurse/', include('nurse.urls', namespace = 'nurse')),
    path('patient/', include('patient.urls', namespace='patient')),
    path('donor/', include('donor.urls', namespace='donor')),
    path('donation/', include('donor.donation_urls', namespace='donation')),
    path('wallet/', include('wallet.urls', namespace='wallet')),
]

urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
