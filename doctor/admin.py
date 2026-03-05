from django.contrib import admin
from .models import DoctorRequest

@admin.register(DoctorRequest)
class DoctorRequestAdmin(admin.ModelAdmin):
    list_display = (
        'id', 
        'patient', 
        'doctor', 
        'date', 
        'time', 
        'total_price', 
        'net_income', 
        'status'
    )  
    list_filter = ('status', 'doctor', 'date') 
    search_fields = ('patient__user__username', 'doctor__user__username', 'disease_description', 'address')
    ordering = ('-date',) 
