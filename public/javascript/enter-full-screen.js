// Add event listeners to each full-screen button

let overlayTimeout; // Declare overlayTimeout variable

document.querySelectorAll('.fullscreen-button').forEach(button => {
  button.addEventListener('click', () => {
    const muxplayer = button.closest('.video_asset').querySelector('.video-stream mux-player');
    const overlay = button.closest('.video_asset').querySelector('.full-screen-overlay');
    toggleFullScreen(muxplayer);
    showOverlay(overlay);
    addMouseActivityListener(overlay);
  });
});

function showOverlay(element) {
    element.style.display = 'block'; // Show overlay
    element.style.opacity = '1';
    console.log('overlay called');
};

// Function to toggle full-screen mode
function toggleFullScreen(element) {
  console.log('toggleFullScreen function called');
  if (!element.classList.contains('video-fullscreen')) {
    element.classList.add('video-fullscreen');
  } else {
    element.classList.remove('video-fullscreen');
  }
}

document.querySelectorAll('.full-screen-overlay').forEach(button => {
  button.addEventListener('click', () => {
    const muxplayer = button.closest('.video_asset').querySelector('.video-stream mux-player');
    console.log("back button called")
    toggleFullScreen(muxplayer);
  });
});

function showOverlay(overlay) {
  overlay.style.display = 'block'; // Show overlay
  overlay.style.opacity = '1'; // Show overlay by setting opacity to 1
  console.log('Overlay shown');
  clearTimeout(overlayTimeout); // Clear any existing timeout
  overlayTimeout = setTimeout(() => {
      overlay.style.opacity = '0'; // Fade out overlay after a period of inactivity
      console.log('Overlay faded out');
  }, 1000); // Adjust the timeout duration as needed (e.g., 3000 milliseconds = 3 seconds)
}

function addMouseActivityListener(overlay) {
  document.addEventListener('mousemove', () => {
      overlay.style.opacity = '1'; // Restore full opacity when mouse moves over the overlay
      clearTimeout(overlayTimeout); // Clear any existing timeout
      overlayTimeout = setTimeout(() => {
          overlay.style.opacity = '0'; // Fade out overlay after a period of inactivity
          console.log('Overlay faded out');
      }, 3000); // Adjust the timeout duration as needed (e.g., 3000 milliseconds = 3 seconds)
  });
}