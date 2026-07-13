(function () {
  // DC runtime (support.js) replaces <x-dc> with a React tree after boot.
  // Keep open state + always query live nodes so hamburger still works after re-render.
  let isOpen = false;
  let lastFocus = null;
  let inerted = [];

  const style = document.createElement('style');
  style.textContent =
    '#elyx-mobile-menu.is-open{opacity:1!important;pointer-events:auto!important;transform:none!important;}';
  document.head.appendChild(style);

  function els() {
    return {
      menu: document.getElementById('elyx-mobile-menu'),
      burger: document.getElementById('elyx-burger'),
      closeBtn: document.getElementById('elyx-menu-close'),
    };
  }

  function focusables(menu, closeBtn) {
    return Array.from(menu.querySelectorAll(
      'a[href], button:not([disabled]), input:not([disabled]), textarea:not([disabled]), select:not([disabled]), [tabindex]:not([tabindex="-1"])'
    )).filter(function (el) {
      return el.offsetParent !== null || el === closeBtn;
    });
  }

  function setBackgroundInert(menu, open) {
    inerted.forEach(function (el) { el.removeAttribute('inert'); });
    inerted = [];
    if (!open || !menu) return;
    const parent = menu.parentElement;
    if (!parent) return;
    Array.from(parent.children).forEach(function (child) {
      if (child === menu) return;
      child.setAttribute('inert', '');
      inerted.push(child);
    });
  }

  function applyState() {
    const nodes = els();
    const menu = nodes.menu;
    const burger = nodes.burger;
    if (!menu) return;

    menu.classList.toggle('is-open', isOpen);
    menu.setAttribute('aria-hidden', isOpen ? 'false' : 'true');
    if (isOpen) menu.removeAttribute('inert');
    else menu.setAttribute('inert', '');

    if (burger) {
      burger.setAttribute('aria-controls', 'elyx-mobile-menu');
      burger.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    }

    document.body.classList.toggle('elyx-menu-open', isOpen);
    setBackgroundInert(menu, isOpen);
  }

  window.__elyxToggleMenu = function (open) {
    const nodes = els();
    if (!nodes.menu) return;

    if (open) lastFocus = document.activeElement;
    isOpen = !!open;
    applyState();

    if (open) {
      const focusTarget = nodes.closeBtn || focusables(nodes.menu, nodes.closeBtn)[0] || nodes.menu;
      if (focusTarget && typeof focusTarget.focus === 'function') focusTarget.focus();
    } else if (lastFocus && typeof lastFocus.focus === 'function') {
      lastFocus.focus();
    } else if (nodes.burger) {
      nodes.burger.focus();
    }
  };

  // Re-apply after React/DC re-renders wipe inline styles / classes
  const mo = new MutationObserver(function () {
    const nodes = els();
    if (!nodes.menu) return;
    if (isOpen && !nodes.menu.classList.contains('is-open')) applyState();
    else if (nodes.burger && !nodes.burger.getAttribute('aria-controls')) applyState();
  });
  mo.observe(document.documentElement, { childList: true, subtree: true });

  // Event delegation — do NOT use inline onclick in templates.
  // DC/React treats onclick="..." as onClick string and throws React #231.
  document.addEventListener('click', function (e) {
    if (!e.target || !e.target.closest) return;
    if (e.target.closest('#elyx-burger')) {
      e.preventDefault();
      window.__elyxToggleMenu(true);
      return;
    }
    if (e.target.closest('#elyx-menu-close')) {
      e.preventDefault();
      window.__elyxToggleMenu(false);
      return;
    }
    if (isOpen && e.target.closest('#elyx-mobile-menu a')) {
      window.__elyxToggleMenu(false);
    }
  });

  document.addEventListener('keydown', function (e) {
    const nodes = els();
    if (!nodes.menu || !isOpen) return;

    if (e.key === 'Escape') {
      window.__elyxToggleMenu(false);
      return;
    }

    if (e.key !== 'Tab') return;
    const items = focusables(nodes.menu, nodes.closeBtn);
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

  function bootAria() {
    applyState();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bootAria);
  } else {
    bootAria();
  }
})();
