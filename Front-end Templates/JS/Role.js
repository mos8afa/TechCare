// --- 1. نظام قائمة اللغات (شغال في الصفحتين) ---
const langBtn = document.getElementById('langBtn');
const langMenu = document.getElementById('langMenu');

if (langBtn && langMenu) {
    langBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        langMenu.classList.toggle('show');
    });
}

// إغلاق القائمة عند الضغط في أي مكان خارجها
window.addEventListener('click', () => {
    if (langMenu) langMenu.classList.remove('show');
});

// --- 2. ميكانزم رفع الملفات (تغيير الأيقونة والـ Style) ---
// الكود ده بيتعامل مع أي Input ملفات في الصفحتين سواء ملف واحد أو أكتر
const allFileInputs = document.querySelectorAll('input[type="file"]');

allFileInputs.forEach(input => {
    input.addEventListener('change', function() {
        const wrapper = this.parentElement; // الـ file-wrapper
        const icon = wrapper.querySelector('i');
        const span = wrapper.querySelector('span') || document.getElementById('fileStatusText');

        if (this.files && this.files.length > 0) {
            // 1. تغيير النص لاسم الملف
            span.textContent = (this.id === 'Profile') ? "File selected: " + this.files[0].name : this.files[0].name;
            if (this.id === 'Profile') span.style.color = "#1D89E4";
            
            // 2. تغيير الأيقونة لعلامة صح
            if (icon) icon.className = "fas fa-check-circle"; 
            
            // 3. إضافة كلاس لإيقاف الـ Hover
            wrapper.classList.add('uploaded');
        }
    });
});

// --- 3. التنقل بين الصفحات (خاص بالصفحة الأولى فقط) ---
const nextStepBtn = document.getElementById('nextStepBtn');
if (nextStepBtn) {
    nextStepBtn.addEventListener('click', (e) => {
        // إذا كان الزر داخل Form، نمنع الـ Submit الافتراضي لو عايز تحكم كامل في الانتقال
        window.location.href = 'doctor2.html';
    });
}

// --- 4. إعادة التعيين (Reset) ---
// بيتعرف على أي Form موجود (سواء بتاع الصفحة 1 أو 2) وبيرجع الأشكال لأصلها
const forms = [document.getElementById('doctorForm'), document.getElementById('doctorProfessionalForm')];

forms.forEach(form => {
    if (form) {
        form.addEventListener('reset', () => {
            const wrappers = form.querySelectorAll('.file-wrapper');
            wrappers.forEach(w => {
                w.classList.remove('uploaded');
                const icon = w.querySelector('i');
                const span = w.querySelector('span') || document.getElementById('fileStatusText');
                
                // إرجاع الأيقونة الأصلية (السحابة)
                if (icon) icon.className = "fas fa-cloud-upload-alt";
                
                // إرجاع النص الأصلي
                if (span) {
                    span.textContent = (span.id === 'fileStatusText') ? "Click to upload file" : "Upload File";
                    span.style.color = "";
                }
            });
        });
    }
});

// ========================================================================================================