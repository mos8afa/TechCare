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

const nextStepBtn2 = document.getElementById('nextStepBtn2');
if (nextStepBtn2) {
    nextStepBtn2.addEventListener('click', (e) => {
        // إذا كان الزر داخل Form، نمنع الـ Submit الافتراضي لو عايز تحكم كامل في الانتقال
        window.location.href = 'nurse2.html';
    });
}

// --- 4. إعادة التعيين (Reset) ---
// بيتعرف على أي Form موجود (سواء بتاع الصفحة 1 أو 2) وبيرجع الأشكال لأصلها
document.addEventListener("DOMContentLoaded", function () {

    // ================================
    // 1. Navigation Buttons
    // ================================
    const navButtons = {
        doctorBtn: "doctor.html",
        hospitalBtn: "hospital.html",
        pharmacyBtn: "pharmacy.html",
        labBtn: "lab.html",
        radiologyBtn: "radiology.html"
    };

    Object.keys(navButtons).forEach(id => {
        const btn = document.getElementById(id);
        if (btn) {
            btn.addEventListener("click", () => {
                window.location.href = navButtons[id];
            });
        }
    });


    // ================================
    // 2. File Upload System
    // ================================
    const allFileInputs = document.querySelectorAll('input[type="file"]');

    allFileInputs.forEach(input => {

        const wrapper = input.closest('.file-wrapper');
        if (!wrapper) return;

        const icon = wrapper.querySelector('i');
        const span = wrapper.querySelector('span');

        // حفظ الأيقونة الأصلية
        if (icon && !icon.dataset.originalIcon) {
            icon.dataset.originalIcon = icon.className;
        }

        // حفظ النص الأصلي
        if (span && !span.dataset.originalText) {
            span.dataset.originalText = span.textContent;
        }

        input.addEventListener('change', function () {

            if (this.files && this.files.length > 0) {

                // تغيير النص لاسم الملف
                if (span) {
                    span.textContent = this.files[0].name;
                }

                // تغيير الأيقونة لصح
                if (icon) {
                    icon.className = "fas fa-check-circle";
                }

                wrapper.classList.add('uploaded');
            }
        });
    });


    // ================================
    // 3. Reset Forms System
    // ================================
    const allForms = document.querySelectorAll("form");

    allForms.forEach(form => {

        form.addEventListener("reset", () => {

            const wrappers = form.querySelectorAll(".file-wrapper");

            wrappers.forEach(wrapper => {

                wrapper.classList.remove("uploaded");

                const icon = wrapper.querySelector("i");
                const span = wrapper.querySelector("span");

                // رجوع الأيقونة الأصلية
                if (icon && icon.dataset.originalIcon) {
                    icon.className = icon.dataset.originalIcon;
                }

                // رجوع النص الأصلي
                if (span && span.dataset.originalText) {
                    span.textContent = span.dataset.originalText;
                }

                // تفريغ input file يدويًا (أحيانًا المتصفح لا يمسحه)
                const fileInput = wrapper.querySelector('input[type="file"]');
                if (fileInput) {
                    fileInput.value = "";
                }

            });

        });

    });

});

// ========================================================================================================