// Toggle Sidebar Collapse
const sidebarToggle = document.querySelector(".sidebar-toggle");
const sidebar = document.querySelector(".sidebar");

if (sidebarToggle && sidebar) {
    sidebarToggle.addEventListener("click", () => {
        sidebar.classList.toggle("collapsed");
    });
}

// Toggle Notification Dropdown
const notificationBtn = document.getElementById("notificationBtn");
const notificationBox = document.getElementById("notificationBox");

if (notificationBtn && notificationBox) {
    notificationBtn.addEventListener("click", (e) => {
        e.stopPropagation();
        notificationBox.classList.toggle("active");
    });

    // Close Notification When Clicking Outside
    document.addEventListener("click", (e) => {
        if (!notificationBox.contains(e.target)) {
            notificationBox.classList.remove("active");
        }
    });
}
// ==================================================================================
// Edit Profile buttons
const profileUpload = document.getElementById('profile-upload');
const avatarImage = document.querySelector('.edit-avatar img');

if (profileUpload && avatarImage) {
    profileUpload.addEventListener('change', function(e) {

        if (e.target.files && e.target.files[0]) {
            const reader = new FileReader();
            reader.onload = function(event) {
                avatarImage.src = event.target.result;
            };
            reader.readAsDataURL(e.target.files[0]);
        }
    });
}
// ==================================================================================
// Nurse Section ---------->

// Add Service Modal
document.addEventListener('DOMContentLoaded', function() {
    const addServiceBtn = document.getElementById('addServiceBtn');
    const addServiceModal = document.getElementById('addServiceModal');
    const closeAddService = document.getElementById('closeAddService');

    if (addServiceBtn && addServiceModal) {
        addServiceBtn.addEventListener('click', function() {
            addServiceModal.classList.add('active');
        });
    }

    // Close Add Service When Clicking On (X)
    if (closeAddService && addServiceModal) {
        closeAddService.addEventListener('click', function() {
            addServiceModal.classList.remove('active');
        });
    }

    // Close Add Service When Clicking Outside
    if (addServiceModal) {
        window.addEventListener('click', function(event) {
            if (event.target === addServiceModal) {
                addServiceModal.classList.remove('active');
            }
        });
    }

});
// ==================================================================================