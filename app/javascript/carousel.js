// Carousel functionality for the e-commerce homepage
document.addEventListener('DOMContentLoaded', function() {
  const carousel = document.getElementById('featured-carousel');
  const wrapper = document.getElementById('carousel-wrapper');
  const prevBtn = document.getElementById('prev-btn');
  const nextBtn = document.getElementById('next-btn');

  if (!carousel || !wrapper || !prevBtn || !nextBtn) return;

  const slides = wrapper.children;
  const totalSlides = slides.length;
  let currentIndex = 0;

  // Get number of visible slides based on screen size
  function getVisibleSlides() {
    const width = window.innerWidth;
    if (width >= 1024) return 4; // lg screens
    if (width >= 768) return 3;  // md screens
    return 1; // mobile
  }

  let visibleSlides = getVisibleSlides();
  const maxIndex = Math.max(0, totalSlides - visibleSlides);

  // Update carousel position
  function updateCarousel() {
    const slideWidth = 100 / visibleSlides;
    const translateX = -(currentIndex * slideWidth);
    wrapper.style.transform = `translateX(${translateX}%)`;

    // Update button states
    prevBtn.disabled = currentIndex === 0;
    nextBtn.disabled = currentIndex >= maxIndex;

    prevBtn.style.opacity = currentIndex === 0 ? '0.5' : '1';
    nextBtn.style.opacity = currentIndex >= maxIndex ? '0.5' : '1';
  }

  // Previous slide
  prevBtn.addEventListener('click', function() {
    if (currentIndex > 0) {
      currentIndex--;
      updateCarousel();
    }
  });

  // Next slide
  nextBtn.addEventListener('click', function() {
    if (currentIndex < maxIndex) {
      currentIndex++;
      updateCarousel();
    }
  });

  // Handle window resize
  window.addEventListener('resize', function() {
    const newVisibleSlides = getVisibleSlides();
    if (newVisibleSlides !== visibleSlides) {
      visibleSlides = newVisibleSlides;
      const newMaxIndex = Math.max(0, totalSlides - visibleSlides);

      // Adjust current index if needed
      if (currentIndex > newMaxIndex) {
        currentIndex = newMaxIndex;
      }

      updateCarousel();
    }
  });

  // Auto-advance carousel (optional)
  let autoAdvanceInterval;

  function startAutoAdvance() {
    autoAdvanceInterval = setInterval(function() {
      if (currentIndex < maxIndex) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
      updateCarousel();
    }, 5000); // Change slide every 5 seconds
  }

  function stopAutoAdvance() {
    if (autoAdvanceInterval) {
      clearInterval(autoAdvanceInterval);
      autoAdvanceInterval = null;
    }
  }

  // Start auto-advance
  startAutoAdvance();

  // Pause auto-advance on hover
  carousel.addEventListener('mouseenter', stopAutoAdvance);
  carousel.addEventListener('mouseleave', startAutoAdvance);

  // Initial setup
  updateCarousel();

  // Touch/swipe support for mobile
  let startX = 0;
  let currentX = 0;
  let isDragging = false;

  carousel.addEventListener('touchstart', function(e) {
    startX = e.touches[0].clientX;
    isDragging = true;
    stopAutoAdvance();
  });

  carousel.addEventListener('touchmove', function(e) {
    if (!isDragging) return;
    currentX = e.touches[0].clientX;
    const deltaX = startX - currentX;

    // Prevent default scrolling
    if (Math.abs(deltaX) > 10) {
      e.preventDefault();
    }
  });

  carousel.addEventListener('touchend', function(e) {
    if (!isDragging) return;
    isDragging = false;

    const deltaX = startX - currentX;
    const threshold = 50; // Minimum swipe distance

    if (Math.abs(deltaX) > threshold) {
      if (deltaX > 0 && currentIndex < maxIndex) {
        // Swipe left - next slide
        currentIndex++;
      } else if (deltaX < 0 && currentIndex > 0) {
        // Swipe right - previous slide
        currentIndex--;
      }
      updateCarousel();
    }

    startAutoAdvance();
  });
});
