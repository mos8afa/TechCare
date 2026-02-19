// 1. وظيفة العين (إظهار/إخفاء الباسورد)
const togglePassword = document.querySelector('#togglePassword');
const passwordInput = document.querySelector('#passwordInput');

togglePassword.addEventListener('click', function () {
    // تبديل نوع الـ input بين text و password
    const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
    passwordInput.setAttribute('type', type);
    
    // تبديل شكل العين (إضافة أو إزالة الـ slash)
    this.classList.toggle('fa-eye');
    this.classList.toggle('fa-eye-slash');
});

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