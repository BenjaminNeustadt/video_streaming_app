document.querySelectorAll('.edit-button').forEach(function(button) {
  button.addEventListener('click', function() {
    var assetActions = this.closest('.video_asset').querySelector('.asset-actions');
    if (assetActions) {
      assetActions.classList.toggle('show');
      darkenBackground();
    }
  });
});

document.querySelectorAll('.close-admin-view').forEach(function(button) {
  button.addEventListener('click', function() {
    var assetActions = this.closest('.video_asset').querySelector('.asset-actions');
    if (assetActions) {
      assetActions.classList.toggle('show');
      removeDarkOverlay();
    }
  });
});


function darkenBackground() {
  // Create and append a dark overlay element to the body
  let overlay = document.querySelector('.video-overlay');

  if (!overlay) {
    overlay = document.createElement('div');
    overlay.classList.add('video-overlay');
    document.body.appendChild(overlay);
  }

  // Ensure that the overlay is visible
  setTimeout(() => {
    overlay.classList.add('overlay-active');
  }, 0);
}

function removeDarkOverlay() {
  const overlay = document.querySelector('.video-overlay');
  if (overlay) {
    // Remove the overlay element from the body
    overlay.remove();
  }
}
