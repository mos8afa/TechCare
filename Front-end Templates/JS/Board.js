//===============================
//Toggle Sidebar Collapse
//===============================
const sidebarToggle = document.querySelector(".sidebar-toggle");
const sidebar = document.querySelector(".sidebar");

sidebarToggle.addEventListener("click", () => {
    sidebar.classList.toggle("collapsed");
});

//===============================
//Toggle Notification Dropdown
//===============================
const notificationBtn = document.getElementById("notificationBtn");
const notificationBox = document.getElementById("notificationBox");

notificationBtn.addEventListener("click", (e) => {
    e.stopPropagation();
    notificationBox.classList.toggle("active");
});

//===============================
//Close Notification When Clicking Outside
//===============================
document.addEventListener("click", (e) => {
    if (!notificationBox.contains(e.target)) {
        notificationBox.classList.remove("active");
    }
});

// ==================================================================================

//===============================
// Tab Switching request pending
//===============================
const tabLinks = document.querySelectorAll(".tab-link");

tabLinks.forEach(link => {
    link.addEventListener("click", () => {
        // Remove active class from all links
        tabLinks.forEach(l => l.classList.remove("active"));
        // Add active class to clicked link
        link.classList.add("active");
        
        // Here you can add logic to filter cards based on status
        console.log("Switching to tab:", link.getAttribute("data-status"));
    });
});

//===============================
// Edit Request div
//===============================
const editModal = document.getElementById("editModal");
const closeModal = document.getElementById("closeModal");
const editButtons = document.querySelectorAll(".btn-action.edit");

// فتح الـ Modal عند الضغط على أي زرار Edit
editButtons.forEach(btn => {
    btn.addEventListener("click", () => {
        editModal.classList.add("active");
    });
});

// إغلاق الـ Modal عند الضغط على X
closeModal.addEventListener("click", () => {
    editModal.classList.remove("active");
});

// إغلاق الـ Modal عند الضغط في أي مكان فاضي بره الصندوق
window.addEventListener("click", (e) => {
    if (e.target === editModal) {
        editModal.classList.remove("active");
    }
});