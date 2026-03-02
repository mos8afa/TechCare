//Toggle Sidebar Collapse
const sidebarToggle = document.querySelector(".sidebar-toggle");
const sidebar = document.querySelector(".sidebar");

sidebarToggle.addEventListener("click", () => {
    sidebar.classList.toggle("collapsed");
});

//Toggle Notification Dropdown
const notificationBtn = document.getElementById("notificationBtn");
const notificationBox = document.getElementById("notificationBox");

notificationBtn.addEventListener("click", (e) => {
    e.stopPropagation();
    notificationBox.classList.toggle("active");
});

//Close Notification When Clicking Outside
document.addEventListener("click", (e) => {
    if (!notificationBox.contains(e.target)) {
        notificationBox.classList.remove("active");
    }
});

// ==================================================================================
// Edit Profile bottons
document.getElementById('profile-upload').addEventListener('change', function(e) {
    if (e.target.files && e.target.files[0]) {
        const reader = new FileReader();
        
        reader.onload = function(e) {
            document.querySelector('.edit-avatar img').src = e.target.result;
        }
        reader.readAsDataURL(e.target.files[0]);
    }
});