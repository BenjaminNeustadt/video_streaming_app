let overlayTimeout;


document.addEventListener('DOMContentLoaded', function () {
document.querySelectorAll('.fullscreen-button').forEach(button => {
  button.addEventListener('click', () => {
    const videoAsset = findParentByClass(button, 'video_asset');
    if (videoAsset) {
      console.log("Parent element with class 'video_asset' found");
      const muxplayer = videoAsset.querySelector('.video-stream mux-player');
      const overlay = videoAsset.querySelector('.full-screen-overlay');
      
      // muxplayer.style.setProperty('--controls', 'unset');
      AddFullScreen(muxplayer);
      showOverlay(overlay);
      addMouseActivityListener(overlay);
    }
  });
});
});

function AddFullScreen(element) {
  console.log('AddFullScreen function called');
  element.classList.add('video-fullscreen');
  

  // Get the mux-player element
const muxPlayer = document.querySelector("body > main > div > div:nth-child(2) > div.video-stream > mux-player");

// Check if the mux-player element is found
if (muxPlayer) {
    // Get the media-theme element within the mux-player shadow DOM
    const mediaTheme = muxPlayer.shadowRoot.querySelector("media-theme");

    // Check if the media-theme element is found
    if (mediaTheme) {
        // Get the media-controller element within the media-theme shadow DOM
        const mediaController = mediaTheme.shadowRoot.querySelector("media-controller");

        // Check if the media-controller element is found
        if (mediaController) {
            // Get the media-play-button element within the media-controller shadow DOM
            const playButton = mediaController.querySelector("div > media-play-button");

            // Check if the media-play-button element is found
            if (playButton) {
                // Generate the CSS rule
                const cssRule = `mux-player::part(center play button) { display: block; }`;

                // Create a <style> element
                const styleElement = document.createElement('style');
                styleElement.innerHTML = cssRule;

                // Append the <style> element to the document's <head>
                document.head.appendChild(styleElement);
            }
        }
    }
}

  console.log("One video entered full screen");
}

// Event listener for the back button
document.querySelectorAll('.full-screen-overlay button#back-button').forEach(button => {
  button.addEventListener('click', () => {
    const videoAsset = findParentByClass(button, 'video_asset');
    if (videoAsset) {
      const muxplayer = videoAsset.querySelector('.video-stream mux-player');
      const overlay = videoAsset.querySelector('.full-screen-overlay');
      
      if (!muxplayer.paused) {
        muxplayer.pause();
        console.log('Video paused');
      }

       // Add back the --controls property to the mux-player style
      muxplayer.style.setProperty('--controls', 'none');

      // Remove fullscreen class from the video player
      muxplayer.classList.remove('video-fullscreen');
      
      // Hide overlay
      hideOverlay(overlay);
      
      console.log("Attempted to exit full screen");
    }
  });
});

function showOverlay(overlay) {
  overlay.style.display = 'block';
  overlay.style.opacity = '1';
}

function hideOverlay(overlay) {
  overlay.style.display = 'none';
  overlay.style.opacity = '0';
}

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