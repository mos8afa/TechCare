from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, Patient, Doctor, Nurse, Pharmacist, Donor, Transaction, Wallet

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ('username', 'email', 'first_name', 'last_name', 'role', 'is_staff', 'is_active')
    list_filter = ('role', 'is_staff', 'is_active')
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Personal info', {'fields': ('first_name', 'last_name', 'email')}),
        ('Role info', {'fields': ('role', 'slug')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'role', 'password1', 'password2', 'is_staff', 'is_active')}
        ),
    )
    search_fields = ('username', 'email', 'role')
    ordering = ('username',)

@admin.register(Patient)
class PatientAdmin(admin.ModelAdmin):
    list_display = ('user', 'gender', 'phone_number', 'governorate')

@admin.register(Doctor)
class DoctorAdmin(admin.ModelAdmin):
    list_display = ('user', 'gender', 'phone_number', 'price', 'governorate')

@admin.register(Nurse)
class NurseAdmin(admin.ModelAdmin):
    list_display = ('user', 'gender', 'phone_number', 'governorate')

@admin.register(Pharmacist)
class PharmacistAdmin(admin.ModelAdmin):
    list_display = ('user', 'gender', 'phone_number', 'pharmacy_name', 'governorate')

@admin.register(Donor)
class DonorAdmin(admin.ModelAdmin):
    list_display = ('user', 'phone_number', 'blood_type', 'governorate')

#---------------------------
@admin.register(Wallet)
class WalletAdmin(admin.ModelAdmin):
    list_display = ('user', 'balance', 'updated_at')

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('wallet', 'transaction_type', 'amount', 'description', 'created_at')
