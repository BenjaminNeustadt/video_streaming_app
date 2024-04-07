// Add event listeners to each full-screen button
document.querySelectorAll('.fullscreen-button').forEach(button => {
  button.addEventListener('click', () => {
    const muxplayer = button.closest('.video_asset').querySelector('.video-stream mux-player');
    toggleFullScreen(muxplayer);
    removeHover();
  });
});

// Function to toggle full-screen mode
function toggleFullScreen(element) {
  console.log('toggleFullScreen function called');
  if (!element.classList.contains('video-fullscreen')) {
    element.classList.add('video-fullscreen');
    // document.body.classList.add('fullscreen-mode'); // Add class to body
  } else {
    // element.classList.remove('video-fullscreen');
    // document.body.classList.remove('fullscreen-mode'); // Remove class from body
  }
}

  function removeHover() {
    console.log('Hover functionality removed');
    const elements = document.querySelectorAll('*');
    elements.forEach(element => {
      // Remove any existing hover-related styles
      element.style.removeProperty('hover');
      element.style.removeProperty('pointer-events');
    });
  }