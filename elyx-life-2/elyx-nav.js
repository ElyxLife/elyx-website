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

  // Collapse all mobile accordion groups (so the menu reopens in a clean state).
  function resetAccordions(menu) {
    if (!menu) return;
    menu.querySelectorAll('.elyx-m-group.is-open').forEach(function (g) {
      g.classList.remove('is-open');
      var t = g.querySelector('.elyx-m-toggle');
      if (t) { t.textContent = '+'; t.setAttribute('aria-expanded', 'false'); }
    });
  }

  window.__elyxToggleMenu = function (open) {
    const nodes = els();
    if (!nodes.menu) return;

    if (open) lastFocus = document.activeElement;
    isOpen = !!open;
    applyState();

    if (!open) resetAccordions(nodes.menu);

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
    // Mobile accordion toggle: expand/collapse a group's section links.
    var acc = e.target.closest('[data-elyx-acc]');
    if (acc) {
      e.preventDefault();
      var group = acc.closest('.elyx-m-group');
      if (group) {
        var open = group.classList.toggle('is-open');
        acc.textContent = open ? '–' : '+';
        acc.setAttribute('aria-expanded', open ? 'true' : 'false');
      }
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

  // Scroll to a #section target, accounting for the fixed header.
  // Used for cross-page links like /the-team#s-medical: the DC runtime
  // renders content after the browser's initial anchor jump, so the target
  // element doesn't exist yet at load — poll briefly until it appears.
  var HEADER_OFFSET = 96;
  function hashTargetId() {
    if (!location.hash || location.hash === '#') return '';
    try { return decodeURIComponent(location.hash.slice(1)); }
    catch (e) { return location.hash.slice(1); }
  }
  function scrollToHash(smooth) {
    var id = hashTargetId();
    if (!id) return false;
    var el = document.getElementById(id);
    if (!el) return false;
    var y = el.getBoundingClientRect().top + window.pageYOffset - HEADER_OFFSET;
    if (smooth) {
      window.scrollTo({ top: y, behavior: 'smooth' });
    } else {
      // Force instant on cross-page load (the page sets scroll-behavior:smooth,
      // which would otherwise animate from the top — jarring on arrival).
      var de = document.documentElement;
      var prev = de.style.scrollBehavior;
      de.style.scrollBehavior = 'auto';
      window.scrollTo(0, y);
      de.style.scrollBehavior = prev;
    }
    return true;
  }
  function scrollToHashWhenReady() {
    if (!hashTargetId()) return;
    // The DC runtime renders/rehydrates after load and can reset scroll to
    // the top, so keep re-asserting the target until it holds (or we time out).
    var tries = 0, stable = 0;
    var iv = setInterval(function () {
      tries++;
      var id = hashTargetId();
      var el = id && document.getElementById(id);
      if (el) {
        var y = el.getBoundingClientRect().top + window.pageYOffset - HEADER_OFFSET;
        if (Math.abs(window.pageYOffset - y) <= 6) {
          if (++stable >= 2) { clearInterval(iv); return; }
        } else {
          stable = 0;
          scrollToHash(false);
        }
      }
      if (tries > 50) clearInterval(iv);
    }, 80);
  }

  // Submenu clicks: for a section link on the CURRENT page, always scroll to
  // it — even on a repeat click where the hash is unchanged (no navigation or
  // hashchange fires, so native anchor scrolling would do nothing). Cross-page
  // links fall through to default navigation; the on-load handler scrolls there.
  document.addEventListener('click', function (e) {
    var a = e.target && e.target.closest && e.target.closest('.elyx-submenu a[href], .elyx-m-sub a[href]');
    if (!a) return;
    // Desktop: close the dropdown as soon as an item is clicked, even if the
    // pointer is still over the nav item. Force it shut (overrides :hover) and
    // clear the state when the pointer leaves so the next hover reopens it.
    var navItem = a.closest('.elyx-nav-item');
    if (navItem && e.detail > 0) {
      navItem.classList.add('elyx-collapsed');
      navItem.addEventListener('mouseleave', function off() {
        navItem.classList.remove('elyx-collapsed');
        navItem.removeEventListener('mouseleave', off);
      });
    }
    var url;
    try { url = new URL(a.getAttribute('href'), location.href); } catch (_) { return; }
    if (url.pathname !== location.pathname || !url.hash) return;
    var el = document.getElementById(decodeURIComponent(url.hash.slice(1)));
    if (!el) return;
    e.preventDefault();
    try { history.replaceState(null, '', url.hash); } catch (_) {}
    scrollToHash(true);
    // On a mouse click we preventDefault (no navigation), so the link keeps
    // focus and :focus-within would hold the desktop dropdown open even after
    // the pointer leaves. Blur it so hovering away closes the menu. (Keyboard
    // activation has e.detail === 0 — leave focus put for accessibility.)
    if (e.detail > 0 && typeof a.blur === 'function') a.blur();
  });

  function bootAria() {
    applyState();
    scrollToHashWhenReady();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bootAria);
  } else {
    bootAria();
  }
})();
