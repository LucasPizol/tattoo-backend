// Support both DOMContentLoaded and Turbo
document.addEventListener('DOMContentLoaded', initDropdowns);
document.addEventListener('turbo:load', initDropdowns);

function initDropdowns() {
  console.log('Filters dropdown script loaded');

  // Limpar event listeners existentes
  clearExistingListeners();

  // Inicializar dropdowns
  initDropdown('location-dropdown-button', 'location-dropdown-menu', 'location-search', 'location-options');
  initDropdown('material-dropdown-button', 'material-dropdown-menu', 'material-search', 'material-options');
}

function clearExistingListeners() {
  // Remove listeners antigos para evitar duplicação
  const existingButtons = document.querySelectorAll('.dropdown-button');
  existingButtons.forEach(button => {
    button.replaceWith(button.cloneNode(true));
  });
}

function initDropdown(buttonId, menuId, searchId, optionsId) {
    const button = document.getElementById(buttonId);
    const menu = document.getElementById(menuId);
    const search = document.getElementById(searchId);
    const options = document.getElementById(optionsId);

    console.log(`Initializing dropdown ${buttonId}:`, { button, menu, search, options });

    if (!button || !menu || !search || !options) {
      console.log(`Missing elements for ${buttonId}`);
      return;
    }

    // Toggle dropdown
    button.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();

      // Fechar outros dropdowns
      closeAllDropdowns();

      const isHidden = menu.hasAttribute('hidden');
      if (isHidden) {
        menu.removeAttribute('hidden');
        button.setAttribute('aria-expanded', 'true');
        search.focus();
      }
    });

    // Search functionality
    search.addEventListener('input', (e) => {
      const query = e.target.value.toLowerCase();
      const allOptions = options.querySelectorAll('.dropdown-option');

      allOptions.forEach(option => {
        const text = option.textContent.toLowerCase();
        if (text.includes(query)) {
          option.style.display = 'flex';
        } else {
          option.style.display = 'none';
        }
      });
    });

    // Handle checkbox changes
    const checkboxes = options.querySelectorAll('.dropdown-checkbox');
    checkboxes.forEach(checkbox => {
      checkbox.addEventListener('change', () => {
        updateDropdownLabel(buttonId, optionsId);
      });
    });

    // Handle "Todos" option
    const allCheckbox = options.querySelector('input[value=""]');
    if (allCheckbox) {
      allCheckbox.addEventListener('change', (e) => {
        if (e.target.checked) {
          // Desmarcar todos os outros
          checkboxes.forEach(cb => {
            if (cb !== allCheckbox) {
              cb.checked = false;
            }
          });
        }
        updateDropdownLabel(buttonId, optionsId);
      });
    }

    // Handle other checkboxes
    checkboxes.forEach(checkbox => {
      if (checkbox.value !== '') {
        checkbox.addEventListener('change', (e) => {
          if (e.target.checked && allCheckbox) {
            allCheckbox.checked = false;
          }
          updateDropdownLabel(buttonId, optionsId);
        });
      }
    });
}

function updateDropdownLabel(buttonId, optionsId) {
    const button = document.getElementById(buttonId);
    const options = document.getElementById(optionsId);
    const labelSpan = button.querySelector('.dropdown-label');

    const checkedBoxes = options.querySelectorAll('.dropdown-checkbox:checked');
    const allCheckbox = options.querySelector('input[value=""]:checked');

    let baseLabel = buttonId.includes('location') ? 'Locais de Perfuração' : 'Material';

    if (allCheckbox || checkedBoxes.length === 0) {
      labelSpan.textContent = baseLabel;
    } else if (checkedBoxes.length === 1) {
      const selectedText = checkedBoxes[0].parentElement.textContent.trim();
      labelSpan.textContent = selectedText;
    } else {
      labelSpan.textContent = `${baseLabel} (${checkedBoxes.length})`;
    }
}

function closeAllDropdowns() {
    const allMenus = document.querySelectorAll('.dropdown-menu');
    const allButtons = document.querySelectorAll('.dropdown-button');

    allMenus.forEach(menu => menu.setAttribute('hidden', ''));
    allButtons.forEach(button => button.setAttribute('aria-expanded', 'false'));
}

// Global event listeners (only add once)
let globalListenersAdded = false;

function addGlobalListeners() {
  if (globalListenersAdded) return;

  // Close dropdowns when clicking outside
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.dropdown-container')) {
      closeAllDropdowns();
    }
  });

  // Close dropdowns on escape key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      closeAllDropdowns();
    }
  });

  globalListenersAdded = true;
}

// Add global listeners on first load
addGlobalListeners();
