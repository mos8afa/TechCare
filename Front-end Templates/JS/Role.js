// قائمة اللغات
const langBtn = document.getElementById('langBtn');
const langMenu = document.getElementById('langMenu');

langBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    langMenu.classList.toggle('show');
});

window.onclick = () => langMenu.classList.remove('show');

// التحقق من الملف المرفوع وتغيير النص
const fileInput = document.getElementById('Profile');
const fileSpan = document.querySelector('.file-wrapper span');

fileInput.addEventListener('change', function() {
    if (this.files && this.files.length > 0) {
        fileSpan.textContent = "File selected: " + this.files[0].name;
        fileSpan.style.color = "#1D89E4";
    }
});