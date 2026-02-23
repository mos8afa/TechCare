import re

forbiden = ['admin','test','user','abc','qwerty','doctor','nurse','donor','pharmacist','patient','script','python']

def validate_username(username):
    if username.lower() in forbiden:
        return False
    
    lower_username = username.lower()
    for word in forbiden:
        if lower_username.startswith(word) or lower_username.endswith(word):
            return False
        
    pattern = r'^(?!.*(?:admin|test|user|doctor|nurse|donor|pharmacist|patient|script|python))[a-z][a-z0-9_.]{2,19}$'
    return re.match(pattern, username, re.IGNORECASE) is not None


def validate_password(password):
    pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[\d])(?=.*[!@#&?$%*\.~])[A-Za-z\d!@#&?$%*\.~]{8,}$'
    return re.match(pattern, password)is not None


def validate_name(name):
    if name.lower() in forbiden:
        return False
    
    lower_name = name.lower()
    for word in forbiden:
        if lower_name.startswith(word) or lower_name.lower().endswith(word):
            return False
        
    pattern = r'^(?!.*--)(?!.*(?:admin|test|user|doctor|nurse|donor|pharmacist|patient|script|python|ADMIN|TEST|USER|ABC|QWERTY|DOCTOR|NURSE|DONOR|PHARMACIST|PATIENT|SCRIPT|PYTHON))[A-Z][A-Za-z-]{0,48}[A-Za-z]$'
    return re.match(pattern,name) is not None

def validate_email(email):
    pattern = r'^[a-zA-Z0-9]+([._-][a-zA-Z0-9]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+$'
    return re.match(pattern,email) is not None