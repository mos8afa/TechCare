/* ============================================================
   TECHCARE WALLET JS
   ============================================================ */

(function () {
  'use strict';

  /* ── Sidebar toggle ── */
  const sidebar = document.getElementById('walletSidebar');
  const toggleBtn = document.getElementById('sidebarToggle');

  if (sidebar && toggleBtn) {
    toggleBtn.addEventListener('click', function () {
      sidebar.classList.toggle('collapsed');
    });
  }

  /* ── Notification dropdown ── */
  const notifBtn = document.querySelector('.topbar-notif');
  const notifDropdown = document.getElementById('notifDropdown');

  if (notifBtn && notifDropdown) {
    notifBtn.addEventListener('click', function (e) {
      e.stopPropagation();
      notifDropdown.classList.toggle('open');
    });
    document.addEventListener('click', function (e) {
      if (!notifDropdown.contains(e.target)) {
        notifDropdown.classList.remove('open');
      }
    });
  }

  /* ── Card number formatter ── */
  const cardInput = document.getElementById('cardNumberInput');
  if (cardInput) {
    cardInput.addEventListener('input', function () {
      let val = this.value.replace(/\D/g, '').substring(0, 16);
      this.value = val.replace(/(.{4})/g, '$1 ').trim();

      // Detect card type
      const cardTypeInput = document.getElementById('cardTypeInput');
      if (cardTypeInput) {
        cardTypeInput.value = val.startsWith('4') ? 'visa' : 'mastercard';
      }
    });
  }

  /* ── Expiry date formatter ── */
  document.querySelectorAll('input[name="expiry"]').forEach(function (el) {
    el.addEventListener('input', function () {
      let val = this.value.replace(/\D/g, '').substring(0, 4);
      if (val.length >= 3) {
        val = val.substring(0, 2) + '/' + val.substring(2);
      }
      this.value = val;
    });
  });

  /* ── Auto-dismiss toast messages ── */
  document.querySelectorAll('.alert-toast').forEach(function (toast) {
    setTimeout(function () {
      toast.style.transition = 'opacity 0.5s ease';
      toast.style.opacity = '0';
      setTimeout(function () { toast.remove(); }, 500);
    }, 5000);
  });

  /* ── Mobile hamburger menu ── */
  function initMobileMenu() {
    if (!sidebar) return;

    const btn = document.createElement('button');
    btn.className = 'hamburger-btn';
    btn.setAttribute('aria-label', 'Toggle menu');
    btn.innerHTML = '<i class="ri-menu-line"></i>';
    document.body.appendChild(btn);

    const overlay = document.createElement('div');
    overlay.className = 'sidebar-overlay';
    document.body.appendChild(overlay);

    function openSidebar() {
      sidebar.classList.add('mobile-open');
      overlay.classList.add('active');
      btn.innerHTML = '<i class="ri-close-line"></i>';
      document.body.style.overflow = 'hidden';
    }

    function closeSidebar() {
      sidebar.classList.remove('mobile-open');
      overlay.classList.remove('active');
      btn.innerHTML = '<i class="ri-menu-line"></i>';
      document.body.style.overflow = '';
    }

    btn.addEventListener('click', function () {
      sidebar.classList.contains('mobile-open') ? closeSidebar() : openSidebar();
    });
    overlay.addEventListener('click', closeSidebar);

    sidebar.querySelectorAll('.nav-item').forEach(function (link) {
      link.addEventListener('click', function () {
        if (window.innerWidth <= 768) closeSidebar();
      });
    });

    window.addEventListener('resize', function () {
      if (window.innerWidth > 768) {
        sidebar.classList.remove('mobile-open');
        overlay.classList.remove('active');
        btn.innerHTML = '<i class="ri-menu-line"></i>';
        document.body.style.overflow = '';
      }
    });
  }

  /* ── Init ── */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initMobileMenu);
  } else {
    initMobileMenu();
  }

})();
