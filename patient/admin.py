from django.contrib import admin
from doctor.models import DoctorRequest

@admin.register(DoctorRequest)
class PatientDoctorRequestAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'patient',
        'doctor',
        'date',
        'time',
        'total_price',
        'status',
    )
    list_filter = ('status', 'patient', 'date')
    search_fields = ('patient__user__username', 'doctor__user__username', 'disease_description', 'address')
    ordering = ('-date',)