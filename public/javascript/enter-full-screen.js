let overlayTimeout;


document.addEventListener('DOMContentLoaded', function () {

  document.querySelectorAll('.fullscreen-button').forEach(button => {

    button.addEventListener('click', () => {
      const videoAsset = findParentByClass(button, 'video_asset');
      if (videoAsset) {
        console.log("Parent element with class 'video_asset' found");
        const muxplayer = videoAsset.querySelector('.video-stream mux-player');
        const overlay = videoAsset.querySelector('.full-screen-overlay');
        const formspree =document.getElementById("formbutton-container");
        
        AddFullScreen(muxplayer);
        showOverlay(overlay);
        addMouseActivityListener(overlay);

        formspree.setAttribute("hidden", true);
      }
    });
  });
});


function AddFullScreen(element) {
  console.log('AddFullScreen function called');
  element.classList.add('video-fullscreen');

// =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
// Adding play button when full screen
// =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

  const muxPlayer = document.querySelector("body > main > div > div:nth-child(2) > div.video-stream > mux-player");
  const mediaTheme = muxPlayer.shadowRoot.querySelector("media-theme");
  const mediaController = mediaTheme.shadowRoot.querySelector("media-controller");
  const playButton = mediaController.querySelector("div > media-play-button");
              // Check if the media-play-button element is found
  if (playButton) {
    const cssRule = `mux-player::part(center play button) { display: block; }`;
    const styleElement = document.createElement('style');
    styleElement.innerHTML = cssRule;
    document.head.appendChild(styleElement);
  }

  console.log("One video entered full screen");
}

// =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
// Event listener for the back button
// =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

document.querySelectorAll('.full-screen-overlay button#back-button').forEach(button => {
  button.addEventListener('click', () => {
    const videoAsset = findParentByClass(button, 'video_asset');
    if (videoAsset) {
      const muxplayer = videoAsset.querySelector('.video-stream mux-player');
      const overlay = videoAsset.querySelector('.full-screen-overlay');
      const formspree =document.getElementById("formbutton-container");
      
      if (!muxplayer.paused) {
        muxplayer.pause();
        console.log('Video paused');
      }

      const cssRule = `mux-player::part(center play button) { display: none; }`;
      const styleElement = document.createElement('style');
      styleElement.innerHTML = cssRule;

      // Append the <style> element to the document's <head>
      document.head.appendChild(styleElement);

       // Add back the --controls property to the mux-player style
      muxplayer.style.setProperty('--controls', 'none');

      // Remove fullscreen class from the video player
      muxplayer.classList.remove('video-fullscreen');
      
      // Hide overlay
      hideOverlay(overlay);
      formspree.removeAttribute("hidden", false);
      
      console.log("Attempted to exit full screen");
    }
  });
});

// =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
// Oberlay stuff
// =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

function showOverlay(overlay) {
  overlay.style.display = 'block';
  overlay.style.opacity = '1';
}

function hideOverlay(overlay) {
  overlay.style.display = 'none';
  overlay.style.opacity = '0';
}

// =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
// Mouse movement
// =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

function addMouseActivityListener(overlay) {
  document.addEventListener('mousemove', () => {
    overlay.style.opacity = '1';
    clearTimeout(overlayTimeout);
    overlayTimeout = setTimeout(() => {
      overlay.style.opacity = '0';
      console.log('Overlay faded out');
    }, 1000);
  });
}

// Helper function to find the parent element by class name
function findParentByClass(element, className) {
  let parent = element.parentNode;
  while (parent) {
    if (parent.classList && parent.classList.contains(className)) {
      return parent;
    }
    parent = parent.parentNode;
  }
  return null;
}

// =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
// Logging
// =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

document.querySelectorAll('.fullscreen-button').forEach(button => {
  button.addEventListener('click', () => {
    console.log("Fullscreen button clicked");
  });
});

document.querySelectorAll('.full-screen-overlay button#back-button').forEach(button => {
  button.addEventListener('click', () => {
    console.log("Back button clicked");
  });
});