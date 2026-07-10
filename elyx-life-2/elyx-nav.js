(function () {
  function initMobileMenu() {
    const burger = document.getElementById('elyx-burger');
    const menu = document.getElementById('elyx-mobile-menu');
    const closeBtn = document.getElementById('elyx-menu-close');
    if (!menu) return;

    if (burger) {
      burger.setAttribute('aria-controls', 'elyx-mobile-menu');
      burger.setAttribute('aria-expanded', 'false');
    }
    menu.setAttribute('aria-hidden', 'true');
    menu.setAttribute('inert', '');

    window.__elyxToggleMenu = function (open) {
      menu.style.opacity = open ? '1' : '0';
      menu.style.pointerEvents = open ? 'auto' : 'none';
      menu.style.transform = open ? 'none' : 'translateY(-6px)';
      menu.setAttribute('aria-hidden', open ? 'false' : 'true');
      if (open) menu.removeAttribute('inert');
      else menu.setAttribute('inert', '');
      if (burger) burger.setAttribute('aria-expanded', open ? 'true' : 'false');
      document.body.classList.toggle('elyx-menu-open', open);
      if (open) (closeBtn || menu.querySelector('a,button')).focus();
      else if (burger) burger.focus();
    };

    menu.querySelectorAll('a').forEach(function (a) {
      a.addEventListener('click', function () { window.__elyxToggleMenu(false); });
    });
    window.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') window.__elyxToggleMenu(false);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initMobileMenu);
  } else {
    initMobileMenu();
  }
})();
