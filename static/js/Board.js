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
    // Check if servicesGrid exists on the current page
    if (!servicesGrid) return;

    // Clear grid
    servicesGrid.innerHTML = '';

    const N = 3; // Fixed number of visible elements per row
    const totalSlots = Math.max(N, Math.ceil(services.length / N) * N);

    // Create cards
    for (let i = 0; i < totalSlots; i++) {
        const card = document.createElement('div');
        card.className = 'service-card';
        
        if (i < services.length) {
            const service = services[i];
            card.innerHTML = `
                <h4>${service.title} <span class="money">$${service.price}</span></h4>
                <p>${service.description}</p>
                <div class="service-actions">
                    <a href="#" class="edit-service" data-index="${i}"><i class="fas fa-edit"></i> Edit</a>
                    <a href="#" class="remove-service" data-index="${i}"><i class="fas fa-trash"></i> Remove</a>
                </div>
            `;
        } else {
            // Empty placeholder for remaining slots
            card.classList.add('empty-slot');
            card.innerHTML = `
                <div class="empty-placeholder">
                    <i class="fas fa-plus"></i>
                    <p>Add Service</p>
                </div>
            `;
            // Clicking an empty slot opens the add new service modal
            card.addEventListener('click', openAddModal);
        }
        servicesGrid.appendChild(card);
    }

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
if (serviceForm) {
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
}

// Event listeners for modal open/close
if (addServiceBtn) {
    addServiceBtn.addEventListener('click', openAddModal);
}

if (closeAddService) {
    closeAddService.addEventListener('click', () => {
        if (addServiceModal) addServiceModal.classList.remove('active');
    });
}

if (addServiceModal) {
    window.addEventListener('click', (event) => {
        if (event.target === addServiceModal) {
            addServiceModal.classList.remove('active');
        }
    });
}

// Initial render
renderServices();

// ==================== Time Slots Carousel ====================
document.addEventListener('DOMContentLoaded', function() {
    const timeslotsGrid = document.getElementById('timeslotsGrid');
    const prevSlot = document.getElementById('prevSlot');
    const nextSlot = document.getElementById('nextSlot');

    if (timeslotsGrid && prevSlot && nextSlot) {
        const isRequestPage = timeslotsGrid.querySelectorAll('.timeslot-item1').length > 0;
        const slotsSelector = isRequestPage ? '.timeslot-item1' : '.timeslot-item';
        const slots = () => Array.from(timeslotsGrid.querySelectorAll(slotsSelector));

        // دالة للتمرير إلى عنصر معين بحيث يظهر بالكامل من اليسار
        function scrollToSlot(index) {
            if (index < 0 || index >= slots().length) return;
            const targetSlot = slots()[index];
            targetSlot.scrollIntoView({
                behavior: 'smooth',
                block: 'nearest',
                inline: 'start'          // يجعل بداية العنصر تلامس الحافة اليسرى للحاوية
            });
        }

        // تحديد العنصر الأقرب للظهور حاليًا
        function getCurrentIndex() {
            const containerRect = timeslotsGrid.getBoundingClientRect();
            let closestIndex = 0;
            let minDistance = Infinity;
            slots().forEach((slot, idx) => {
                const rect = slot.getBoundingClientRect();
                // المسافة من بداية العنصر إلى بداية الحاوية
                const distance = Math.abs(rect.left - containerRect.left);
                if (distance < minDistance) {
                    minDistance = distance;
                    closestIndex = idx;
                }
            });
            return closestIndex;
        }

        if (isRequestPage) {
            // === Requests Page Logic (Translating Cursor) ===
            function getActiveIndex() {
                return slots().findIndex(s => s.classList.contains('active-slot'));
            }

            function setActiveSlot(index) {
                const allSlots = slots();
                if (index < 0 || index >= allSlots.length) return;
                
                // Remove active class from all
                allSlots.forEach(s => s.classList.remove('active-slot'));
                
                // Set active to the new one
                const targetSlot = allSlots[index];
                targetSlot.classList.add('active-slot');
                
                // Scroll securely into view
                targetSlot.scrollIntoView({
                    behavior: 'smooth',
                    block: 'nearest',
                    inline: 'center'
                });
            }

            // Click behavior for individual slots
            slots().forEach((slot, index) => {
                slot.addEventListener('click', () => {
                    setActiveSlot(index);
                });
            });

            prevSlot.addEventListener('click', () => {
                let current = getActiveIndex();
                if (current > 0) setActiveSlot(current - 1);
            });

            nextSlot.addEventListener('click', () => {
                let current = getActiveIndex();
                if (current < slots().length - 1) setActiveSlot(current + 1);
            });

        } else {
            // === Profile Page Logic (Native Scroll Only) ===
            prevSlot.addEventListener('click', () => {
                let current = getCurrentIndex();
                scrollToSlot(current - 1);
            });

            nextSlot.addEventListener('click', () => {
                let current = getCurrentIndex();
                scrollToSlot(current + 1);
            });
        }

        // Resize logically to avoid partially visible child items
        function resizeTimeslots() {
            // Reset to allow flex stretch to get max available space
            timeslotsGrid.style.maxWidth = 'none';
            timeslotsGrid.style.flex = '1';

            // Wait a tick for browser to compute flex width
            requestAnimationFrame(() => {
                const availableWidth = timeslotsGrid.clientWidth;
                const itemWidth = 120;
                
                // Use larger gap for requests page, or original 12 for profile
                const gap = isRequestPage ? 24 : 12;
                
                // Max full items that can fit
                const count = Math.floor((availableWidth + gap) / (itemWidth + gap));
                
                // Perfect width for `count` items
                if (count > 0) {
                    const perfectWidth = count * itemWidth + (count - 1) * gap;
                    timeslotsGrid.style.maxWidth = perfectWidth + 'px';
                    timeslotsGrid.style.flex = '0 1 auto'; // allow it to shrink strictly to the computed width
                }
            });
        }

        window.addEventListener('resize', resizeTimeslots);
        // Initial call
        resizeTimeslots();
    }
});

// Helper functions for selecting days and slots
function selectDay(el) {
    document.querySelectorAll('.day-btn').forEach(d => d.classList.remove('active'));
    el.classList.add('active');
}

function selectSlotPill(el) {
    el.classList.toggle('active');
}
