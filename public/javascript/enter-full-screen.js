let overlayTimeout;

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
    element.style.display = 'block';
    element.style.opacity = '1';
    console.log('overlay called');
};

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
  overlay.style.display = 'block';
  overlay.style.opacity = '1';
  console.log('Overlay shown');
  clearTimeout(overlayTimeout);
  overlayTimeout = setTimeout(() => {
      overlay.style.opacity = '0';
      console.log('Overlay faded out');
  }, 1000);
}

function addMouseActivityListener(overlay) {
  document.addEventListener('mousemove', () => {
      overlay.style.opacity = '1';
      clearTimeout(overlayTimeout);
      overlayTimeout = setTimeout(() => {
          overlay.style.opacity = '0';
          console.log('Overlay faded out');
      }, 3000);
  });
}