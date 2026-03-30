from django.contrib import admin
from .models import DoctorRequest
from accounts.models import TimeSlots

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

@admin.register(TimeSlots)
class TimeSlotsAdmin(admin.ModelAdmin):
    list_display = ('doctor', 'day', 'time')
    list_filter = ('day', 'doctor')
    search_fields = ('doctor__user__first_name', 'doctor__user__last_name')
    ordering = ('day', 'time')