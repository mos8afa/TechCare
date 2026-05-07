/**
 * TechCare — Landing Page Scripts
 * Author: Senior Frontend Developer
 */

'use strict';

/* ── Animated Counter ── */
function animateCounter(el) {
  const target   = parseInt(el.dataset.target, 10) || 0;
  const suffix   = el.dataset.suffix || '';

  // If target is 0, just show it immediately
  if (target === 0) {
    el.textContent = '0' + suffix;
    return;
  }

  // Scale duration to the number — small numbers animate faster
  const duration = Math.min(1800, Math.max(600, target * 0.5));
  const step     = 16;
  const increment = target / (duration / step);
  let current    = 0;

  const timer = setInterval(() => {
    current += increment;
    if (current >= target) {
      current = target;
      clearInterval(timer);
    }
    el.textContent = Math.floor(current).toLocaleString() + suffix;
  }, step);
}

/* ── Intersection Observer for counters ── */
function initCounters() {
  const counters = document.querySelectorAll('[data-target]');
  if (!counters.length) return;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          animateCounter(entry.target);
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.5 }
  );

  counters.forEach((el) => observer.observe(el));
}

/* ── Parallax on mouse move ── */
function initParallax() {
  const shapes = document.querySelectorAll('.shape');
  const cards  = document.querySelectorAll('.glass-card');

  document.addEventListener('mousemove', (e) => {
    const cx = window.innerWidth  / 2;
    const cy = window.innerHeight / 2;
    const dx = (e.clientX - cx) / cx;   // -1 → 1
    const dy = (e.clientY - cy) / cy;   // -1 → 1

    shapes.forEach((shape, i) => {
      const depth = (i + 1) * 6;
      shape.style.transform = `translate(${dx * depth}px, ${dy * depth}px)`;
    });

    cards.forEach((card, i) => {
      const depth = (i + 1) * 4;
      card.style.transform = `translate(${dx * depth}px, ${dy * depth}px)`;
    });
  });
}

/* ── Ripple effect on CTA button ── */
function initRipple() {
  const btn = document.querySelector('.btn-cta');
  if (!btn) return;

  btn.addEventListener('click', function (e) {
    const rect   = btn.getBoundingClientRect();
    const x      = e.clientX - rect.left;
    const y      = e.clientY - rect.top;
    const ripple = document.createElement('span');

    ripple.style.cssText = `
      position: absolute;
      width: 6px; height: 6px;
      background: rgba(255,255,255,0.45);
      border-radius: 50%;
      left: ${x}px; top: ${y}px;
      transform: translate(-50%, -50%) scale(0);
      animation: rippleAnim 0.6s ease-out forwards;
      pointer-events: none;
    `;

    btn.appendChild(ripple);
    setTimeout(() => ripple.remove(), 700);
  });

  /* Inject ripple keyframe once */
  if (!document.getElementById('ripple-style')) {
    const style = document.createElement('style');
    style.id = 'ripple-style';
    style.textContent = `
      @keyframes rippleAnim {
        to { transform: translate(-50%, -50%) scale(28); opacity: 0; }
      }
    `;
    document.head.appendChild(style);
  }
}

/* ── Smooth entrance for glass cards ── */
function initCardTilt() {
  const cards = document.querySelectorAll('.glass-card');

  cards.forEach((card) => {
    card.addEventListener('mouseenter', () => {
      card.style.transform = 'translateY(-6px) scale(1.02)';
      card.style.transition = 'transform 0.3s ease, box-shadow 0.3s ease';
      card.style.boxShadow  = '0 16px 48px rgba(79, 142, 247, 0.25)';
    });

    card.addEventListener('mouseleave', () => {
      card.style.transform = '';
      card.style.boxShadow = '';
    });
  });
}

/* ── Navbar scroll effect ── */
function initNavbar() {
  const navbar = document.querySelector('.navbar');
  if (!navbar) return;

  window.addEventListener('scroll', () => {
    if (window.scrollY > 20) {
      navbar.style.background    = 'rgba(10, 15, 30, 0.85)';
      navbar.style.backdropFilter = 'blur(20px)';
      navbar.style.webkitBackdropFilter = 'blur(20px)';
      navbar.style.borderBottom  = '1px solid rgba(255,255,255,0.07)';
      navbar.style.padding       = '16px 60px';
      navbar.style.transition    = 'all 0.35s ease';
    } else {
      navbar.style.background    = '';
      navbar.style.backdropFilter = '';
      navbar.style.webkitBackdropFilter = '';
      navbar.style.borderBottom  = '';
      navbar.style.padding       = '';
    }
  });
}

/* ── Init all ── */
document.addEventListener('DOMContentLoaded', () => {
  initCounters();
  initParallax();
  initRipple();
  initCardTilt();
  initNavbar();
});
