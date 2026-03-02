// ===============================================
// عناصر المودال والإضافات
// ===============================================
const addServiceBtn = document.getElementById("addServiceBtn");
const addServiceModal = document.getElementById("addServiceModal");
const closeAddService = document.getElementById("closeAddService");
const addServiceForm = document.getElementById("addServiceForm");
const servicesGrid = document.querySelector(".services-grid");
const serviceCount = document.getElementById("serviceCount");

// فتح المودال
addServiceBtn.addEventListener("click", () => {
    addServiceModal.style.display = "flex";
});

// غلق المودال بزرار ×
closeAddService.addEventListener("click", () => {
    addServiceModal.style.display = "none";
});

// غلق عند الضغط خارج المودال
window.addEventListener("click", (e) => {
    if (e.target === addServiceModal) {
        addServiceModal.style.display = "none";
    }
});

// إضافة خدمة جديدة
addServiceForm.addEventListener("submit", function (e) {
    e.preventDefault();

    const title = document.getElementById("serviceTitle").value;
    const price = document.getElementById("servicePrice").value;
    const description = document.getElementById("serviceDescription").value;

    const serviceCard = document.createElement("div");
    serviceCard.classList.add("card", "service-card");
    serviceCard.innerHTML = `
        <h4>${title} <span class="money">$${price}</span></h4>
        <p>${description}</p>
        <div class="service-actions">
            <a href="#" class="edit-service"><i class="fas fa-edit"></i> Edit</a>
            <a href="#" class="delete-service"><i class="fas fa-trash"></i> Remove</a>
        </div>
    `;

    servicesGrid.appendChild(serviceCard);

    // تحديث عدد الخدمات
    const totalServices = servicesGrid.querySelectorAll(".service-card").length;
    serviceCount.textContent = `(${totalServices})`;

    addServiceForm.reset();
    addServiceModal.style.display = "none";
});

// حذف الخدمة
servicesGrid.addEventListener("click", function (e) {
    // حذف
    if (e.target.closest(".delete-service")) {
        e.target.closest(".service-card").remove();
        const totalServices = servicesGrid.querySelectorAll(".service-card").length;
        serviceCount.textContent = `(${totalServices})`;
    }

    // فتح مودال تعديل
    if (e.target.closest(".edit-service")) {
        editModal.classList.add("active");

        // يمكن هنا ملء المودال بالبيانات الحالية إذا أردت
    }
});

// ===============================================
// Sidebar Toggle
// ===============================================
const sidebarToggle = document.querySelector(".sidebar-toggle");
const sidebar = document.querySelector(".sidebar");

sidebarToggle.addEventListener("click", () => {
    sidebar.classList.toggle("collapsed");
});

// ===============================================
// Notification Dropdown
// ===============================================
const notificationBtn = document.getElementById("notificationBtn");
const notificationBox = document.getElementById("notificationBox");

notificationBtn.addEventListener("click", (e) => {
    e.stopPropagation();
    notificationBox.classList.toggle("active");
});

document.addEventListener("click", (e) => {
    if (!notificationBox.contains(e.target)) {
        notificationBox.classList.remove("active");
    }
});

// ===============================================
// Tabs
// ===============================================
const tabLinks = document.querySelectorAll(".tab-link");
tabLinks.forEach(link => {
    link.addEventListener("click", () => {
        tabLinks.forEach(l => l.classList.remove("active"));
        link.classList.add("active");
        console.log("Switching to tab:", link.getAttribute("data-status"));
    });
});

// ===============================================
// Edit Modal
// ===============================================
const editModal = document.getElementById("editModal");
const closeModal = document.getElementById("closeModal");

closeModal.addEventListener("click", () => {
    editModal.classList.remove("active");
});

window.addEventListener("click", (e) => {
    if (e.target === editModal) {
        editModal.classList.remove("active");
    }
});