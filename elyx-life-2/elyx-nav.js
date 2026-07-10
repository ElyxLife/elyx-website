(function () {
  function initMobileMenu() {
    const burger = document.getElementById('elyx-burger');
    const menu = document.getElementById('elyx-mobile-menu');
    const closeBtn = document.getElementById('elyx-menu-close');
    if (!menu) return;

    let lastFocus = null;
    let inerted = [];

    function menuOpen() {
      return menu.getAttribute('aria-hidden') === 'false';
    }

    function focusables() {
      return Array.from(menu.querySelectorAll(
        'a[href], button:not([disabled]), input:not([disabled]), textarea:not([disabled]), select:not([disabled]), [tabindex]:not([tabindex="-1"])'
      )).filter(function (el) {
        return el.offsetParent !== null || el === closeBtn;
      });
    }

    function setBackgroundInert(open) {
      inerted.forEach(function (el) { el.removeAttribute('inert'); });
      inerted = [];
      if (!open) return;
      const parent = menu.parentElement;
      if (!parent) return;
      Array.from(parent.children).forEach(function (child) {
        if (child === menu) return;
        child.setAttribute('inert', '');
        inerted.push(child);
      });
    }

    if (burger) {
      burger.setAttribute('aria-controls', 'elyx-mobile-menu');
      burger.setAttribute('aria-expanded', 'false');
    }
    menu.setAttribute('aria-hidden', 'true');
    menu.setAttribute('inert', '');

    window.__elyxToggleMenu = function (open) {
      if (open) lastFocus = document.activeElement;
      menu.style.opacity = open ? '1' : '0';
      menu.style.pointerEvents = open ? 'auto' : 'none';
      menu.style.transform = open ? 'none' : 'translateY(-6px)';
      menu.setAttribute('aria-hidden', open ? 'false' : 'true');
      if (open) menu.removeAttribute('inert');
      else menu.setAttribute('inert', '');
      if (burger) burger.setAttribute('aria-expanded', open ? 'true' : 'false');
      document.body.classList.toggle('elyx-menu-open', open);
      setBackgroundInert(open);
      if (open) (closeBtn || focusables()[0] || menu).focus();
      else if (lastFocus && typeof lastFocus.focus === 'function') lastFocus.focus();
      else if (burger) burger.focus();
    };

    menu.querySelectorAll('a').forEach(function (a) {
      a.addEventListener('click', function () { window.__elyxToggleMenu(false); });
    });

    menu.addEventListener('keydown', function (e) {
      if (e.key !== 'Tab' || !menuOpen()) return;
      const items = focusables();
      if (!items.length) return;
      const first = items[0];
      const last = items[items.length - 1];
      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    });

    window.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && menuOpen()) window.__elyxToggleMenu(false);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initMobileMenu);
  } else {
    initMobileMenu();
  }
})();
