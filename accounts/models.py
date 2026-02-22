from project import settings
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils.text import slugify


# ----- static choices -----
ROLES = (
    ("patient", "Patient"),
    ("doctor", "Doctor"),
    ("nurse", "Nurse"),
    ("pharmacist", "Pharmacist"),
    ("donor", "Donor"),
)


ROLE_REDIRECTS = {
    "doctor": "doctor_registration",
    "patient": "patient_registration",
    "nurse": "nurse_registration",
    "pharmacist": "pharmacist_registration",
    "donor": "donor_registration",
}


GENDERS = (
    ("male", "Male"),
    ("female", "Female"),
)


GOVERNORATES = (
    ("alexandria", "Alexandria"),
    ("aswan", "Aswan"),
    ("asyut", "Asyut"),
    ("beheira", "Beheira"),
    ("beni_suef", "Beni Suef"),
    ("cairo", "Cairo"),
    ("damietta", "Damietta"),
    ("dakahlia", "Dakahlia"),
    ("fayoum", "Fayoum"),
    ("gharbia", "Gharbia"),
    ("giza", "Giza"),
    ("ismailia", "Ismailia"),
    ("kafr_el_sheikh", "Kafr El Sheikh"),
    ("luxor", "Luxor"),
    ("matrouh", "Matrouh"),
    ("minya", "Minya"),
    ("monufia", "Monufia"),
    ("new_valley", "New Valley"),
    ("north_sinai", "North Sinai"),
    ("port_said", "Port Said"),
    ("qalyubia", "Qalyubia"),
    ("qena", "Qena"),
    ("red_sea", "Red Sea"),
    ("sharqia", "Sharqia"),
    ("sohag", "Sohag"),
    ("south_sinai", "South Sinai"),
    ("suez", "Suez"),
)


BLOOD_TYPES = (
    ("A+", "A+"),
    ("A-", "A-"),
    ("B+", "B+"),
    ("B-", "B-"),
    ("AB+", "AB+"),
    ("AB-", "AB-"),
    ("O+", "O+"),
    ("O-", "O-"),
)


UNIVERSITIES = (
    ("cairo_university", "Cairo University"),
    ("ain_shams_university", "Ain Shams University"),
    ("alexandria_university", "Alexandria University"),
    ("mansoura_university", "Mansoura University"),
    ("future_university", "Future University in Egypt"),
    ("american_university_cairo", "The American University in Cairo"),
    ("zagazig_university", "Zagazig University"),
    ("al_azhar_university", "Al-Azhar University"),
    ("assiut_university", "Assiut University"),
    ("benha_university", "Benha University"),
    ("egypt_japan_university", "Egypt-Japan University of Science and Technology"),
    ("kafr_el_sheikh_university", "Kafrelsheikh University"),
    ("tanta_university", "Tanta University"),
    ("arab_academy", "Arab Academy for Science, Technology and Maritime Transport"),
    ("aswan_university", "Aswan University"),
    ("beni_suef_university", "Beni-Suef University"),
    ("damietta_university", "Damietta University"),
    ("delta_university", "Delta University for Science and Technology"),
    ("minia_university", "Minia University"),
    ("new_valley_university", "New Valley University"),
    ("university_sadat_city", "University of Sadat City"),
    ("south_valley_university", "South Valley University"),
    ("suez_canal_university", "Suez Canal University"),
    ("menofia_university", "Menofia University"),
    ("fayoum_university", "Fayoum University"),
    ("sohag_university", "Sohag University"),
    ("port_said_university", "Port Said University"),
    ("british_university_egypt", "The British University in Egypt"),
    ("zewail_city", "Zewail City of Science, Technology and Innovation"),
    ("damanhour_university", "Damanhour University"),
    ("helwan_university", "Helwan University"),
    ("misr_university_science", "Misr University for Science and Technology"),
    ("nile_university", "Nile University"),
    ("msa_university", "October University for Modern Sciences and Arts"),
    ("german_university_cairo", "German University in Cairo"),
    ("galala_university", "Galala University"),
    ("badr_university", "Badr University in Cairo"),
    ("new_giza_university", "New Giza University"),
    ("pharos_university", "Pharos University in Alexandria"),
    ("sinai_university", "Sinai University"),
    ("egyptian_russian_university", "Egyptian Russian University"),
    ("misr_international_university", "Misr International University"),
    ("october_6_university", "October 6 University"),
    ("ahrarm_canadian_university", "Ahram Canadian University"),
    ("canadian_international_college", "Canadian International College"),
    ("mti_university", "MTI University"),
    ("nahda_university", "Nahda University in Beni Suef"),
    ("heliopolis_university", "Heliopolis University"),
    ("egyptian_chinese_university", "Egyptian Chinese University"),
    ("egyptian_elearning_university", "Egyptian E-Learning University"),
    ("el_shorouk_academy", "El Shorouk Academy"),
    ("french_university_egypt", "French University of Egypt"),
    ("hertfordshire_egypt", "Hertfordshire University in Egypt"),
    ("king_salman_university", "King Salman International University"),
    ("new_mansoura_university", "New Mansoura University"),
    ("toronto_metropolitan_cairo", "Toronto Metropolitan University Cairo"),
    ("university_prince_edward", "University of Prince Edward Island"),
    ("egypt_university_informatics", "Egypt University of Informatics"),
    ("luxor_university", "Luxor University"),
    ("suez_university", "Suez University"),
)


SPECIFICATIONS = (
    ("neurosurgery", "Neurosurgery"),
    ("orthopedic_surgery", "Orthopedic Surgery"),
    ("plastic_surgery", "Plastic Surgery"),
    ("cardiothoracic_surgery", "Cardiothoracic Surgery"),
    ("ent", "Otolaryngology (ENT)"),
    ("vascular_surgery", "Vascular Surgery"),
    ("urology", "Urology"),
    ("ophthalmology", "Ophthalmology"),
    ("general_surgery", "General Surgery"),
    ("pediatric_surgery", "Pediatric Surgery"),
    ("dermatology", "Dermatology"),
    ("cardiology", "Cardiology"),
    ("gastroenterology", "Gastroenterology"),
    ("oncology", "Medical Oncology"),
    ("hematology", "Hematology"),
    ("endocrinology", "Endocrinology"),
    ("nephrology", "Nephrology"),
    ("rheumatology", "Rheumatology"),
    ("pulmonology", "Pulmonology"),
    ("neurology", "Neurology"),
    ("psychiatry", "Psychiatry"),
    ("emergency_medicine", "Emergency Medicine"),
    ("anesthesiology", "Anesthesiology"),
    ("radiology", "Diagnostic Radiology"),
    ("pathology", "Pathology"),
    ("internal_medicine", "Internal Medicine"),
    ("pediatrics", "Pediatrics"),
    ("obgyn", "Obstetrics and Gynecology"),
    ("family_medicine", "Family Medicine"),
    ("critical_care", "Critical Care Medicine"),
    ("sports_medicine", "Sports Medicine"),
    ("geriatrics", "Geriatrics"),
    ("pain_medicine", "Pain Medicine"),
    ("public_health", "Public Health"),
    ("nuclear_medicine", "Nuclear Medicine"),
    ("physical_medicine_rehab", "Physical Medicine and Rehabilitation"),
    ("addiction_medicine", "Addiction Medicine"),
    ("forensic_psychiatry", "Forensic Psychiatry"),
    ("child_psychiatry", "Child and Adolescent Psychiatry"),
    ("primary_care", "Primary Care"),
    ("general_practice", "General Practice"),
)

#----- user -----
class CustomUser(AbstractUser):
    role = models.CharField(max_length=10, choices=ROLES)
    slug = models.SlugField()
    is_verified = models.BooleanField(default=False)
    
    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.username)
        super().save(*args, **kwargs)

class PendingUser(models.Model):
    username = models.CharField(max_length=150)
    email = models.EmailField()
    password = models.CharField(max_length=128)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    role = models.CharField(max_length=10, choices=ROLES)
    created_at = models.DateTimeField(auto_now_add=True)

#----- patient ------
class Patient(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    gender = models.CharField(max_length=6, choices=GENDERS)
    profile_pic = models.ImageField(upload_to='patients/profile/')
    national_id_pic_back= models.ImageField(upload_to='patients/national_id/ ')
    national_id_pic_front = models.ImageField(upload_to='patients/national_id/')
    phone_number = models.CharField(max_length=14)
    governorate = models.CharField(max_length=50, choices=GOVERNORATES)
    address = models.TextField()
    

#------- Doctor -----
class Doctor(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    national_id_pic_front = models.ImageField(upload_to='doctors/national_id/')
    national_id_pic_back= models.ImageField(upload_to='doctors/national_id/')
    gender = models.CharField(max_length=6, choices=GENDERS)
    profile_pic = models.ImageField(upload_to='doctors/profile/')
    phone_number = models.CharField(max_length=14)
    excellence_certificate = models.FileField(upload_to='doctors/certificates/')
    price = models.DecimalField(max_digits=10, decimal_places=2)
    date_of_birth = models.DateField()
    syndicate_card = models.FileField(upload_to='doctors/syndicate/')
    practice_permit = models.FileField(upload_to='doctors/practice/')
    graduation_certificate = models.FileField(upload_to='doctors/graduation/')
    university = models.CharField(max_length=100, choices=UNIVERSITIES)
    address = models.TextField()
    governorate = models.CharField(max_length=50, choices=GOVERNORATES)
    specification = models.CharField(max_length=50, choices=SPECIFICATIONS)


#------------- Nurse -------
class Nurse(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    national_id_pic_front = models.ImageField(upload_to='nurses/national_id/')
    national_id_pic_back= models.ImageField(upload_to='doctors/national_id/')
    gender = models.CharField(max_length=6, choices=GENDERS)
    profile_pic = models.ImageField(upload_to='nurses/profile/')
    phone_number = models.CharField(max_length=14)
    excellence_certificate = models.FileField(upload_to='nurses/certificates/')
    date_of_birth = models.DateField()
    syndicate_card = models.FileField(upload_to='nurses/syndicate/')
    practice_permit = models.FileField(upload_to='nurses/practice/')
    graduation_certificate = models.FileField(upload_to='nurses/graduation/')
    address = models.TextField()
    governorate = models.CharField(max_length=50, choices=GOVERNORATES)


#------- Pharmacist --------
class Pharmacist(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    national_id_pic_front = models.ImageField(upload_to='pharmacists/national_id/')
    national_id_pic_back= models.ImageField(upload_to='doctors/national_id/')
    gender = models.CharField(max_length=6, choices=GENDERS)
    profile_pic = models.ImageField(upload_to='pharmacists/profile/')
    phone_number = models.CharField(max_length=14)
    pharmacy_name = models.CharField(max_length=255)
    pharmacy_address = models.TextField()
    date_of_birth = models.DateField()
    syndicate_card = models.FileField(upload_to='pharmacists/syndicate/')
    practice_permit = models.FileField(upload_to='pharmacists/practice/')
    graduation_certificate = models.FileField(upload_to='pharmacists/graduation/')
    university = models.CharField(max_length=100, choices=UNIVERSITIES)
    governorate = models.CharField(max_length=50, choices=GOVERNORATES)


# -------- Donor -------
class Donor(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    national_id_pic_front = models.ImageField(upload_to='donors/national_id/')
    national_id_pic_back= models.ImageField(upload_to='doctors/national_id/')
    gender = models.CharField(max_length=6, choices=GENDERS)
    profile_pic = models.ImageField(upload_to='donors/profile/')
    phone_number = models.CharField(max_length=14)
    date_of_birth = models.DateField()
    last_donation_date = models.DateField()
    blood_type = models.CharField(max_length=3, choices=BLOOD_TYPES)
    address = models.TextField()
    governorate = models.CharField(max_length=50, choices=GOVERNORATES)
