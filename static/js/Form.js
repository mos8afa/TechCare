// 1- =================Lang Button====================
const langBtn = document.getElementById('langBtn');
const langMenu = document.getElementById('langMenu');

if (langBtn && langMenu)
{
    langBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        langMenu.classList.toggle('show');
    });
    
    window.onclick = function() {
        langMenu.classList.remove('show');
    }
}

// 2- ================= eye toggle====================
const togglePassword = document.querySelector('#togglePassword');
const passwordInput = document.querySelector('#passwordInput');

if (togglePassword && passwordInput)
{
    togglePassword.addEventListener('click', function () {

        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);
        
        this.classList.toggle('fa-eye');
        this.classList.toggle('fa-eye-slash');
    });
}


const newtogglePassword = document.querySelector('#newtogglePassword');
const newpasswordInput = document.querySelector('#newpasswordInput');

if (newtogglePassword && newpasswordInput)
{
    newtogglePassword.addEventListener('click', function () {

        const type = newpasswordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        newpasswordInput.setAttribute('type', type);
        

        this.classList.toggle('fa-eye');
        this.classList.toggle('fa-eye-slash');
    });
}

// 3- =================OTP====================
const inputs = document.querySelectorAll(".otp-input");

inputs.forEach((input, index) => {
    // Focus
    input.addEventListener("input", function () {
        this.value = this.value.replace(/[^0-9]/g, '');
        
        if (this.value && index < inputs.length - 1) {
            inputs[index + 1].focus(); 
        }
    });

    // Backspace
    input.addEventListener("keydown", function (e) {
        if (e.key === "Backspace" && !this.value && index > 0) {
            inputs[index - 1].focus(); 
        }
    });

    // Paste
    input.addEventListener("paste", function (e) {
        e.preventDefault();
    
        // ClipboardData    
        const pastedData = (e.clipboardData || window.clipboardData).getData('text');
    
        for (let i = 0; i < inputs.length; i++) {
            if (i < pastedData.length) {
                inputs[i].value = pastedData[i]; 
            } else {
                inputs[i].value = ''; 
            }
        }
    
        // Last Focus
        if (pastedData.length > 0) {
            const nextIndex = pastedData.length - 1; 
            inputs[nextIndex].focus(); 
        }
    });
});

// 4- =================Upload & Reset====================
document.addEventListener("DOMContentLoaded", function () {

    const allFileInputs = document.querySelectorAll('input[type="file"]');

    allFileInputs.forEach(input => {

        const wrapper = input.closest('.file-wrapper');
        if (!wrapper) return;

        const icon = wrapper.querySelector('i');
        const span = wrapper.querySelector('span');

        if (icon && !icon.dataset.originalIcon) {
            icon.dataset.originalIcon = icon.className;
        }

        if (span && !span.dataset.originalText) {
            span.dataset.originalText = span.textContent;
        }

        input.addEventListener('change', function () {
            if (this.files && this.files.length > 0) {
                if (span) {span.textContent = this.files[0].name;}
                if (icon) {icon.className = "fas fa-check-circle";}

                wrapper.classList.add('uploaded');
            }
        });
    });

    // Reset
    const allForms = document.querySelectorAll("form");

    allForms.forEach(form => {

        form.addEventListener("reset", () => {
            const wrappers = form.querySelectorAll(".file-wrapper");
            wrappers.forEach(wrapper => {

                wrapper.classList.remove("uploaded");
                const icon = wrapper.querySelector("i");
                const span = wrapper.querySelector("span");

                if (icon && icon.dataset.originalIcon) {
                    icon.className = icon.dataset.originalIcon;
                }

                if (span && span.dataset.originalText) {
                    span.textContent = span.dataset.originalText;
                }

                const fileInput = wrapper.querySelector('input[type="file"]');
                if (fileInput) {
                    fileInput.value = "";
                }
            });
        });
    });
});
// ========================================================================================================