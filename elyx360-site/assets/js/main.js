// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    const href = this.getAttribute('href');

    // Skip if it's just "#"
    if (href === '#') return;

    e.preventDefault();
    const target = document.querySelector(href);

    if (target) {
      const headerOffset = 100;
      const elementPosition = target.getBoundingClientRect().top;
      const offsetPosition = elementPosition + window.pageYOffset - headerOffset;

      window.scrollTo({
        top: offsetPosition,
        behavior: 'smooth'
      });
    }
  });
});

// Add active state to navigation on scroll
const sections = document.querySelectorAll('section[id]');
const navLinks = document.querySelectorAll('.nav-links a');

function highlightNavigation() {
  const scrollY = window.pageYOffset;

  sections.forEach(section => {
    const sectionHeight = section.offsetHeight;
    const sectionTop = section.offsetTop - 150;
    const sectionId = section.getAttribute('id');

    if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
      navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === `#${sectionId}`) {
          link.classList.add('active');
        }
      });
    }
  });
}

window.addEventListener('scroll', highlightNavigation);

// Simple fade-in animation for cards on scroll
const observerOptions = {
  threshold: 0.1,
  rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.style.opacity = '1';
      entry.target.style.transform = 'translateY(0)';
    }
  });
}, observerOptions);

// Observe all cards
document.addEventListener('DOMContentLoaded', () => {
  const cards = document.querySelectorAll('.card, .job-card');

  cards.forEach(card => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';
    card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(card);
  });
});

// Newsletter form handling (placeholder)
const newsletterForm = document.querySelector('.section input[type="email"]');
if (newsletterForm) {
  const submitButton = newsletterForm.nextElementSibling;

  if (submitButton) {
    submitButton.addEventListener('click', (e) => {
      e.preventDefault();
      const email = newsletterForm.value;

      if (email && email.includes('@')) {
        alert('Newsletter functionality coming soon! We\'ll save your interest.');
        newsletterForm.value = '';
      } else {
        alert('Please enter a valid email address.');
      }
    });
  }
}

// Mobile navigation toggle (for future mobile menu implementation)
const createMobileMenu = () => {
  const nav = document.querySelector('.nav');
  const navLinks = document.querySelector('.nav-links');

  // Check if we're on mobile
  if (window.innerWidth <= 768) {
    // Add mobile menu button if it doesn't exist
    if (!nav.querySelector('.mobile-menu-toggle')) {
      const toggleButton = document.createElement('button');
      toggleButton.className = 'mobile-menu-toggle';
      toggleButton.innerHTML = '☰';
      toggleButton.style.cssText = `
        display: block;
        background: none;
        border: none;
        color: #C9A961;
        font-size: 24px;
        cursor: pointer;
        padding: 8px;
      `;

      nav.querySelector('.nav-container').appendChild(toggleButton);

      toggleButton.addEventListener('click', () => {
        navLinks.classList.toggle('mobile-open');
      });
    }
  }
};

// Initialize mobile menu on load and resize
window.addEventListener('load', createMobileMenu);
window.addEventListener('resize', createMobileMenu);

console.log('Elyx 360 - Building the future of healthcare 🚀');
