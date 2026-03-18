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

// Service Carousel Navigation
document.addEventListener('DOMContentLoaded', function() {
    const servicesGrid = document.querySelector('.services-grid');
    const prevBtn = document.getElementById('prev-service');
    const nextBtn = document.getElementById('next-service');

    if (servicesGrid && prevBtn && nextBtn) {
        // دالة لحساب مسافة التمرير (عرض البطاقة + الفجوة)
        function getScrollAmount() {
            const card = servicesGrid.querySelector('.service-card');
            if (!card) return 300; // قيمة افتراضية في حال عدم وجود بطاقات

            // عرض البطاقة الفعلي (يشمل padding, border)
            const cardWidth = card.offsetWidth;
            
            // الحصول على قيمة الفجوة من CSS (تحويلها من px إلى رقم)
            const gap = parseFloat(window.getComputedStyle(servicesGrid).gap) || 20;
            
            return cardWidth + gap;
        }

        prevBtn.addEventListener('click', function() {
            const amount = getScrollAmount();
            servicesGrid.scrollBy({
                left: -amount,
                behavior: 'smooth'
            });
        });

        nextBtn.addEventListener('click', function() {
            const amount = getScrollAmount();
            servicesGrid.scrollBy({
                left: amount,
                behavior: 'smooth'
            });
        });
    }
});

// ==================== Services Management ====================
// Data store
let services = [
    {
        title: 'Home Visit Consultation',
        price: 45,
        description: 'Basic health assessment and vital check-up.'
    },
    {
        title: 'Wound Dressing',
        price: 30,
        description: 'Cleaning and dressing of surgical or chronic wounds.'
    },
    {
        title: 'IV Medication Admin',
        price: 60,
        description: 'Professional administration of intravenous medications.'
    }
];

// DOM elements
const servicesGrid = document.getElementById('servicesGrid');
const serviceCountSpan = document.getElementById('serviceCount');
const addServiceBtn = document.getElementById('addServiceBtn');
const addServiceModal = document.getElementById('addServiceModal');
const closeAddService = document.getElementById('closeAddService');
const serviceForm = document.getElementById('serviceForm');
const modalTitle = document.getElementById('modalTitle');
const saveServiceBtn = document.getElementById('saveServiceBtn');
const titleInput = document.getElementById('serviceTitle');
const priceInput = document.getElementById('servicePrice');
const descriptionInput = document.getElementById('serviceDescription');

let editingIndex = null; // لتحديد إذا كنا في وضع التعديل

// Render services
function renderServices() {
    // Clear grid
    servicesGrid.innerHTML = '';

    // Create cards
    services.forEach((service, index) => {
        const card = document.createElement('div');
        card.className = 'service-card';
        card.innerHTML = `
            <h4>${service.title} <span class="money">$${service.price}</span></h4>
            <p>${service.description}</p>
            <div class="service-actions">
                <a href="#" class="edit-service" data-index="${index}"><i class="fas fa-edit"></i> Edit</a>
                <a href="#" class="remove-service" data-index="${index}"><i class="fas fa-trash"></i> Remove</a>
            </div>
        `;
        servicesGrid.appendChild(card);
    });

    // Update service count
    serviceCountSpan.textContent = `(${services.length})`;

    // Re-attach event listeners to edit/remove buttons
    document.querySelectorAll('.edit-service').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            const index = this.dataset.index;
            openEditModal(index);
        });
    });

    document.querySelectorAll('.remove-service').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            const index = this.dataset.index;
            deleteService(index);
        });
    });
}

// Open modal for editing
function openEditModal(index) {
    const service = services[index];
    titleInput.value = service.title;
    priceInput.value = service.price;
    descriptionInput.value = service.description;
    editingIndex = index;
    modalTitle.textContent = 'Edit Service';
    saveServiceBtn.textContent = 'Update Service';
    addServiceModal.classList.add('active');
}

// Open modal for adding
function openAddModal() {
    titleInput.value = '';
    priceInput.value = '';
    descriptionInput.value = '';
    editingIndex = null;
    modalTitle.textContent = 'Add New Service';
    saveServiceBtn.textContent = 'Add Service';
    addServiceModal.classList.add('active');
}

// Delete service
function deleteService(index) {
    services.splice(index, 1);
    renderServices();
}

// Handle form submit (add or edit)
serviceForm.addEventListener('submit', function(e) {
    e.preventDefault();

    const newService = {
        title: titleInput.value.trim(),
        price: parseFloat(priceInput.value),
        description: descriptionInput.value.trim()
    };

    if (editingIndex !== null) {
        // Edit existing
        services[editingIndex] = newService;
    } else {
        // Add new
        services.push(newService);
    }

    // Close modal and re-render
    addServiceModal.classList.remove('active');
    renderServices();
});

// Event listeners for modal open/close
addServiceBtn.addEventListener('click', openAddModal);

closeAddService.addEventListener('click', () => {
    addServiceModal.classList.remove('active');
});

window.addEventListener('click', (event) => {
    if (event.target === addServiceModal) {
        addServiceModal.classList.remove('active');
    }
});

// Initial render
renderServices();