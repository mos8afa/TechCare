from django import forms
from django.contrib.auth import get_user_model
from . import models

User = get_user_model()
            
            
class PatientForm(forms.ModelForm):
    class Meta:
        model = models.Patient
        exclude = ["user"]


class DoctorStep1Form(forms.ModelForm):
    class Meta:
        model = models.Doctor
        fields = [
            'gender', 'phone_number', 'date_of_birth', 'governorate',
            'profile_pic', 'address'
        ]

class DoctorStep2Form(forms.ModelForm):
    class Meta:
        model = models.Doctor
        fields = [
            'excellence_certificate', 'price', 'syndicate_card',
            'national_id_pic_front', 'national_id_pic_back',
            'practice_permit', 'graduation_certificate', 'university',
            'specification'
        ]


class NurseStep1Form(forms.ModelForm):
    class Meta:
        model = models.Nurse
        fields = ['gender', 'phone_number', 'date_of_birth', 'governorate',
                'profile_pic']

class NurseStep2Form(forms.ModelForm):
    class Meta:
        model = models.Nurse
        fields = ['excellence_certificate', 'syndicate_card', 'practice_permit', 'graduation_certificate','national_id_pic_front', 'national_id_pic_back']


class PharmacistStep1Form(forms.ModelForm):
    class Meta:
        model = models.Pharmacist
        fields = ['gender', 'phone_number', 'date_of_birth',
                  'national_id_pic_front','national_id_pic_back','profile_pic']

class PharmacistStep2Form(forms.ModelForm):
    class Meta:
        model = models.Pharmacist
        fields = ['pharmacy_name','pharmacy_address','university', 'governorate',
                  'syndicate_card', 'practice_permit', 'graduation_certificate']


class DonorForm(forms.ModelForm):
    class Meta:
        model = models.Donor
        exclude = ["user"]

