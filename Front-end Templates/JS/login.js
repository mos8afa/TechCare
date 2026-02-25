// 1. وظيفة العين (إظهار/إخفاء الباسورد) — يدعم معرفات مختلفة عبر الصفحات
const togglePassword = document.getElementById('togglePassword');
const toggleConfirmPassword = document.getElementById('toggleConfirmPassword');

// حاول العثور على الحقول بأسماء معرفات ممكنة في القوالب المختلفة
const passwordInput = document.getElementById('password') || document.getElementById('passwordInput') || document.getElementById('pwd');
const confirmPasswordInput = document.getElementById('confirmPassword') || document.getElementById('confirmPasswordInput') || document.getElementById('confirm_password');

function setupToggle(toggleBtn, input) {
    if (!toggleBtn || !input) return;
    toggleBtn.addEventListener('click', function () {
        const type = input.type === 'password' ? 'text' : 'password';
        input.type = type;
        this.classList.toggle('fa-eye');
        this.classList.toggle('fa-eye-slash');
    });
}

setupToggle(togglePassword, passwordInput);
setupToggle(toggleConfirmPassword, confirmPasswordInput);

// 2. وظيفة قائمة اللغات
const langBtn = document.getElementById('langBtn');
const langMenu = document.getElementById('langMenu');

// فتح/قفل القائمة عند الضغط على الزر
langBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    langMenu.classList.toggle('show');
});

// إغلاق القائمة تلقائياً لو تم الضغط في أي مكان خارجها
window.onclick = function() {
    langMenu.classList.remove('show');
}

// 3. OTP inputs handling (for passwd_rest.html)
const otpInputs = document.querySelectorAll('.otp-form .otp');
const continueBtn = document.getElementById('continueBtn');
const backBtn = document.getElementById('backBtn');
const resendBtn = document.getElementById('resendBtn');
const resendInfo = document.getElementById('resendInfo');

if (otpInputs.length) {
    otpInputs.forEach((input, idx) => {
        input.addEventListener('input', (e) => {
            const val = e.target.value.replace(/[^0-9]/g, '');
            e.target.value = val;
            if (val && idx < otpInputs.length - 1) otpInputs[idx + 1].focus();
            updateContinueState();
        });

        input.addEventListener('keydown', (e) => {
            if (e.key === 'Backspace' && !e.target.value && idx > 0) {
                otpInputs[idx - 1].focus();
            }
        });
    });

    // handle paste of full code
    const first = otpInputs[0];
    first && first.addEventListener('paste', (e) => {
        e.preventDefault();
        const paste = (e.clipboardData || window.clipboardData).getData('text').trim();
        const digits = paste.replace(/\D/g, '').slice(0, otpInputs.length).split('');
        digits.forEach((d, i) => { otpInputs[i].value = d; });
        const next = Math.min(digits.length, otpInputs.length) - 1;
        if (next >= 0) otpInputs[next].focus();
        updateContinueState();
    });
}

function updateContinueState(){
    const allFilled = Array.from(otpInputs).every(i => i.value && i.value.length === 1);
    if (continueBtn) continueBtn.disabled = !allFilled;
}

if (backBtn) {
    backBtn.addEventListener('click', (e) => {
        e.preventDefault();
        window.location.href = 'forget_password.html';
    });
}

if (resendBtn) {
    let timer = 0;
    resendBtn.addEventListener('click', (e) => {
        e.preventDefault();
        if (timer > 0) return;
        // simulate resend
        startResendTimer(30);
        // TODO: call backend resend endpoint
    });

    function startResendTimer(seconds){
        timer = seconds;
        resendBtn.disabled = true;
        resendInfo.textContent = ` (${timer}s)`;
        const iv = setInterval(() => {
            timer--;
            resendInfo.textContent = timer > 0 ? ` (${timer}s)` : '';
            if (timer <= 0) {
                clearInterval(iv);
                resendBtn.disabled = false;
            }
        }, 1000);
    }
}


