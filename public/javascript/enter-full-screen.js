// Add event listeners to each full-screen button


document.querySelectorAll('.fullscreen-button').forEach(button => {
  button.addEventListener('click', () => {
    const muxplayer = button.closest('.video_asset').querySelector('.video-stream mux-player');
    const overlay = button.closest('.video_asset').querySelector('.full-screen-overlay');
    toggleFullScreen(muxplayer);
    showOverlay(overlay);
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