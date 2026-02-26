import re
from datetime import datetime, timedelta


forbidden = [

    'admin','test','user','abc','qwerty','doctor','nurse','donor','pharmacist','patient',    
    'script','python','javascript','vbscript','alert','prompt','confirm','eval','document.write','innerhtml','window.location','data:','fetch','xmlhttprequest',
    'iframe','object','embed','svg','video','audio','link','body','style','form','input','button','textarea','applet','meta','frame','frameset','marquee','base',
    'onerror','onclick','onload','onmouseover','onmouseout','onfocus','onsubmit','oninput','onchange','onkeypress','onkeydown','onkeyup','onmouseenter','onmouseleave',
    '<','>'

]

def validate_username(username):
    if username.lower() in forbidden:
        return False
    lower_username = username.lower()
    for word in forbidden:
        if lower_username.startswith(word) or lower_username.endswith(word):
            return False
        
    pattern = r'^(?!.*(?:admin|test|user|doctor|nurse|donor|pharmacist|patient|script|python|<|>))[a-z][a-z0-9_.]{2,19}$'
    return re.match(pattern, username, re.IGNORECASE) is not None


def validate_password(password):
    pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[\d])(?=.*[!@#&?$%*\.~])[A-Za-z\d!@#&?$%*\.~]{8,}$'
    return re.match(pattern, password)is not None


def validate_name(name):
    if name.lower() in forbidden:
        return False
    
    lower_name = name.lower()
    for word in forbidden:
        if lower_name.startswith(word) or lower_name.lower().endswith(word): 
            return False
        
    pattern = r'^(?!.*--)(?!.*(?:admin|test|user|doctor|nurse|donor|pharmacist|patient|script|python|ADMIN|TEST|USER|ABC|QWERTY|DOCTOR|NURSE|DONOR|PHARMACIST|PATIENT|SCRIPT|PYTHON|<|>))[A-Z][A-Za-z-]{0,48}[A-Za-z]$'
    return re.match(pattern,name) is not None

def validate_email(email):
    pattern = r'^[a-zA-Z0-9]+([._-][a-zA-Z0-9]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+$'
    return re.match(pattern,email) is not None

def validate_phone(phone_number):
    if not phone_number.isdigit() or len(phone_number) > 11 or len(phone_number) < 10 or phone_number[0] not in ['0','1'] :
        return False
    else:
        return True

def validate_dop(dob_str, valid_age):
    dob = datetime.strptime(dob_str, "%Y-%m-%d").date()
    today = datetime.today().date()
    age = (today - dob).days // 365
    if age < valid_age:
        return False
    else:
        return True
    

def validate_donation_date(donation_date,dob):
    last_donation = datetime.strptime(donation_date, "%Y-%m-%d").date()
    dob = datetime.strptime(dob, "%Y-%m-%d").date()
    min_donation_date = dob + timedelta(days=16*365)
    if last_donation < min_donation_date:
        return False
    else:
        return True
    

def validate_pharmacy_name(name):
    pattern = r'^[A-Za-z0-9-& $]{1,60}'
    return re.match(pattern, name) is not None

def validate_address(address):
    if address.lower() in forbidden:
        return False
    lower_address = address.lower()
    for word in forbidden:
        if lower_address.startswith(word) or lower_address.endswith(word):
            return False
    return True
