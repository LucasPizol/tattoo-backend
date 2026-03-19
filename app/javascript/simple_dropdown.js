// Simple dropdown test
console.log('Simple dropdown loaded');

document.addEventListener('DOMContentLoaded', function() {
  console.log('DOM loaded');
  setupDropdowns();
});

document.addEventListener('turbo:load', function() {
  console.log('Turbo loaded');
  setupDropdowns();
});

function setupDropdowns() {
  const locationButton = document.getElementById('location-dropdown-button');
  const locationMenu = document.getElementById('location-dropdown-menu');

  if (locationButton && locationMenu) {
    console.log('Found location dropdown elements');

    locationButton.addEventListener('click', function(e) {
      e.preventDefault();
      console.log('Location button clicked');

      if (locationMenu.hasAttribute('hidden')) {
        locationMenu.removeAttribute('hidden');
        locationButton.setAttribute('aria-expanded', 'true');
        console.log('Dropdown opened');
      } else {
        locationMenu.setAttribute('hidden', '');
        locationButton.setAttribute('aria-expanded', 'false');
        console.log('Dropdown closed');
      }
    });
  } else {
    console.log('Dropdown elements not found', { locationButton, locationMenu });
  }

  const materialButton = document.getElementById('material-dropdown-button');
  const materialMenu = document.getElementById('material-dropdown-menu');

  if (materialButton && materialMenu) {
    console.log('Found material dropdown elements');

    materialButton.addEventListener('click', function(e) {
      e.preventDefault();
      console.log('Material button clicked');

      if (materialMenu.hasAttribute('hidden')) {
        materialMenu.removeAttribute('hidden');
        materialButton.setAttribute('aria-expanded', 'true');
        console.log('Material dropdown opened');
      } else {
        materialMenu.setAttribute('hidden', '');
        materialButton.setAttribute('aria-expanded', 'false');
        console.log('Material dropdown closed');
      }
    });
  } else {
    console.log('Material dropdown elements not found', { materialButton, materialMenu });
  }
}
