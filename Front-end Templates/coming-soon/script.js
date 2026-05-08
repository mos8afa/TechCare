/**
 * TechCare — Coming Soon  |  script.js
 * Handles: Page Loader · Particle Canvas · Countdown Timer · Email Form · Parallax
 */

/* ============================================================
   CONFIG
   ============================================================ */
// 50 days from 2026-05-08 = 2026-06-27
const LAUNCH_DATE  = new Date('2026-06-27T00:00:00');
const PROGRESS_PCT = 78;    // development progress %
const LOADER_DELAY = 1600;  // ms before loader hides

/* ============================================================
   1. PAGE LOADER
   Uses DOMContentLoaded so we don't wait on slow CDN resources.
   A hard 3 s fallback guarantees the loader always hides.
   ============================================================ */
function hideLoader() {
    const loader = document.getElementById('loader');
    if (!loader || loader.classList.contains('hidden')) return;
    loader.classList.add('hidden');
    initProgressBar();
}

// Primary: fires as soon as HTML is parsed (doesn't wait for fonts/icons CDN)
document.addEventListener('DOMContentLoaded', function () {
    setTimeout(hideLoader, LOADER_DELAY);
});

// Hard fallback: hides loader after 3 s no matter what
setTimeout(hideLoader, 3000);

/* ============================================================
   2. PARTICLE CANVAS
   ============================================================ */
(function initParticles() {
    var canvas = document.getElementById('particleCanvas');
    if (!canvas) return;

    var ctx = canvas.getContext('2d');
    var particles = [];
    var W, H, animId;

    var PRIMARY_RGB = '29, 137, 228';

    function resize() {
        W = canvas.width  = window.innerWidth;
        H = canvas.height = window.innerHeight;
    }

    function createParticle() {
        return {
            x:     Math.random() * W,
            y:     Math.random() * H,
            r:     Math.random() * 1.8 + 0.4,
            vx:    (Math.random() - 0.5) * 0.35,
            vy:    (Math.random() - 0.5) * 0.35,
            alpha: Math.random() * 0.5 + 0.08,
            pulse: Math.random() * Math.PI * 2,
            speed: Math.random() * 0.015 + 0.006,
        };
    }

    function spawnParticles() {
        var count = Math.floor((W * H) / 9000);
        particles = [];
        for (var i = 0; i < Math.min(count, 120); i++) {
            particles.push(createParticle());
        }
    }

    function drawConnectionLine(a, b, dist, maxDist) {
        var alpha = (1 - dist / maxDist) * 0.12;
        ctx.strokeStyle = 'rgba(' + PRIMARY_RGB + ', ' + alpha + ')';
        ctx.lineWidth = 0.6;
        ctx.beginPath();
        ctx.moveTo(a.x, a.y);
        ctx.lineTo(b.x, b.y);
        ctx.stroke();
    }

    function loop() {
        ctx.clearRect(0, 0, W, H);
        var maxDist = 130;

        for (var i = 0; i < particles.length; i++) {
            var p = particles[i];
            p.x += p.vx;
            p.y += p.vy;
            p.pulse += p.speed;

            if (p.x < 0) p.x = W;
            if (p.x > W) p.x = 0;
            if (p.y < 0) p.y = H;
            if (p.y > H) p.y = 0;

            var alpha = p.alpha * (0.6 + 0.4 * Math.sin(p.pulse));

            ctx.beginPath();
            ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
            ctx.fillStyle = 'rgba(' + PRIMARY_RGB + ', ' + alpha + ')';
            ctx.fill();

            for (var j = i + 1; j < particles.length; j++) {
                var q  = particles[j];
                var dx = p.x - q.x;
                var dy = p.y - q.y;
                var dist = Math.sqrt(dx * dx + dy * dy);
                if (dist < maxDist) {
                    drawConnectionLine(p, q, dist, maxDist);
                }
            }
        }

        animId = requestAnimationFrame(loop);
    }

    function init() {
        resize();
        spawnParticles();
        cancelAnimationFrame(animId);
        loop();
    }

    window.addEventListener('resize', function () {
        resize();
        spawnParticles();
    });

    init();
})();

/* ============================================================
   3. COUNTDOWN TIMER  → 50 days from 2026-05-08 = 2026-06-27
   ============================================================ */
(function initCountdown() {
    function pad(n) { return String(n).padStart(2, '0'); }

    var elDays    = document.getElementById('days');
    var elHours   = document.getElementById('hours');
    var elMinutes = document.getElementById('minutes');
    var elSeconds = document.getElementById('seconds');

    // Safety: don't run if elements are missing
    if (!elDays || !elHours || !elMinutes || !elSeconds) return;

    function animateFlip(el, newVal) {
        if (el.textContent === newVal) return;
        el.classList.remove('flip');
        void el.offsetWidth; // reflow to restart animation
        el.classList.add('flip');
        el.textContent = newVal;
    }

    function tick() {
        var diff = LAUNCH_DATE - Date.now();

        if (diff <= 0) {
            elDays.textContent    = '00';
            elHours.textContent   = '00';
            elMinutes.textContent = '00';
            elSeconds.textContent = '00';
            return;
        }

        var totalSec = Math.floor(diff / 1000);
        var d = Math.floor(totalSec / 86400);
        var h = Math.floor((totalSec % 86400) / 3600);
        var m = Math.floor((totalSec % 3600) / 60);
        var s = totalSec % 60;

        animateFlip(elDays,    pad(d));
        animateFlip(elHours,   pad(h));
        animateFlip(elMinutes, pad(m));
        animateFlip(elSeconds, pad(s));
    }

    tick();
    setInterval(tick, 1000);
})();

/* ============================================================
   4. PROGRESS BAR ANIMATION
   Called after loader hides so animation is visible
   ============================================================ */
function initProgressBar() {
    var fill = document.getElementById('progressFill');
    if (!fill) return;
    requestAnimationFrame(function () {
        fill.style.width = PROGRESS_PCT + '%';
    });
}

/* ============================================================
   5. EMAIL NOTIFY FORM
   ============================================================ */
(function initForm() {
    var form   = document.getElementById('notifyForm');
    var input  = document.getElementById('emailInput');
    var errEl  = document.getElementById('formError');
    var succEl = document.getElementById('formSuccess');
    var btn    = document.getElementById('notifyBtn');

    // Safety: exit if any element is missing
    if (!form || !input || !errEl || !succEl || !btn) return;

    var EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    function setError(msg) {
        errEl.textContent = msg;
        succEl.classList.remove('visible');
    }

    function clearError() {
        errEl.textContent = '';
    }

    function showSuccess(email) {
        succEl.textContent = '\u2713 Got it! We\'ll notify ' + email + ' on launch day.';
        succEl.classList.add('visible');
        errEl.textContent  = '';
        input.value        = '';
        btn.textContent    = '\u2713 Subscribed';
        btn.disabled       = true;
        btn.style.background = 'var(--success)';
        btn.style.boxShadow  = '0 4px 20px rgba(16,185,129,0.45)';
    }

    function setLoading(on) {
        if (on) {
            btn.innerHTML = '<span class="btn-text">Sending\u2026</span>';
            btn.disabled  = true;
        } else {
            btn.innerHTML = '<span class="btn-text">Notify Me</span><i class="bi bi-arrow-right btn-icon"></i>';
            btn.disabled  = false;
        }
    }

    input.addEventListener('input', clearError);

    form.addEventListener('submit', function (e) {
        e.preventDefault();
        var email = input.value.trim();

        if (!email) {
            setError('Please enter your email address.');
            shakeInput();
            return;
        }
        if (!EMAIL_RE.test(email)) {
            setError('Please enter a valid email address.');
            shakeInput();
            return;
        }

        clearError();
        setLoading(true);

        // Simulate async submission — replace with real API call
        setTimeout(function () {
            setLoading(false);
            showSuccess(email);
        }, 1200);
    });

    // Inject shake keyframe once
    var style = document.createElement('style');
    style.textContent =
        '.shake-anim { animation: csShake 0.4s ease; }' +
        '@keyframes csShake {' +
        '  0%   { transform: translateX(0); }' +
        '  20%  { transform: translateX(-6px); }' +
        '  40%  { transform: translateX(6px); }' +
        '  60%  { transform: translateX(-4px); }' +
        '  80%  { transform: translateX(4px); }' +
        '  100% { transform: translateX(0); }' +
        '}';
    document.head.appendChild(style);

    function shakeInput() {
        var wrapper = document.querySelector('.input-wrapper');
        if (!wrapper) return;
        wrapper.classList.remove('shake-anim');
        void wrapper.offsetWidth;
        wrapper.classList.add('shake-anim');
        wrapper.addEventListener('animationend', function () {
            wrapper.classList.remove('shake-anim');
        }, { once: true });
    }
})();

/* ============================================================
   6. MOUSE PARALLAX on Orbs (desktop only)
   ============================================================ */
(function initParallax() {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

    var orbs    = document.querySelectorAll('.orb');
    var ticking = false;

    window.addEventListener('mousemove', function (e) {
        if (ticking) return;
        ticking = true;
        requestAnimationFrame(function () {
            var cx = window.innerWidth  / 2;
            var cy = window.innerHeight / 2;
            var dx = (e.clientX - cx) / cx;
            var dy = (e.clientY - cy) / cy;

            orbs.forEach(function (orb, i) {
                var factor = (i + 1) * 12;
                orb.style.transform = 'translate(' + (dx * factor) + 'px, ' + (dy * factor) + 'px)';
            });

            ticking = false;
        });
    });
})();
