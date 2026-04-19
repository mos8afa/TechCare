from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/',include('api.urls')),
    path('auth/',include("accounts.urls")),
    path('doctor/', include('doctor.urls', namespace='doctor')),
    path('nurse/', include('nurse.urls', namespace = 'nurse')),
    path('patient/', include('patient.urls', namespace='patient')),
    path('donor/', include('donor.urls', namespace='donor')),
    path('donation/', include('donor.donation_urls', namespace='donation')),
]

urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
