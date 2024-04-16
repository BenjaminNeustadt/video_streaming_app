let overlayTimeout;


//   const muxPlayer = document.querySelector('mux-player');

//   // Override the --controls CSS variable with a different value
//   muxPlayer.style.setProperty('--controls', 'unset');
// });


document.addEventListener('DOMContentLoaded', function () {
document.querySelectorAll('.fullscreen-button').forEach(button => {
  button.addEventListener('click', () => {
    const videoAsset = findParentByClass(button, 'video_asset');
    if (videoAsset) {
      console.log("Parent element with class 'video_asset' found");
      const muxplayer = videoAsset.querySelector('.video-stream mux-player');
      const overlay = videoAsset.querySelector('.full-screen-overlay');
      
      // if (muxplayer) {
      //   console.log("Found mux-player");
      // } else {
      //   console.log("Mux-player not found"); // Log if mux-player is not found
      // }
      muxplayer.style.setProperty('--controls', 'unset');
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
  console.log("One video entered full screen");
}

// Event listener for the back button
document.querySelectorAll('.full-screen-overlay button#back-button').forEach(button => {
  button.addEventListener('click', () => {
    const videoAsset = findParentByClass(button, 'video_asset');
    if (videoAsset) {
      const muxplayer = videoAsset.querySelector('.video-stream mux-player');
      const overlay = videoAsset.querySelector('.full-screen-overlay');
      
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

// let overlayTimeout;

// document.querySelectorAll('.fullscreen-button').forEach(button => {
//   button.addEventListener('click', () => {
//     const muxplayer = button.closest('.video_asset').querySelector('.video-stream mux-player');
//     const overlay = button.closest('.video_asset').querySelector('.full-screen-overlay');

//     AddFullScreen(muxplayer);
//     showOverlay(overlay);
//     addMouseActivityListener(overlay);
//   });
// });

// function AddFullScreen(element) {
//   console.log('AddFullScreen function called');
//     element.classList.add('video-fullscreen');
//     console.log("One video entered full screen");
// };

// // ================================

// document.querySelectorAll('.full-screen-overlay').forEach(button => {
//   button.addEventListener('click', () => {
//     const muxplayer = button.closest('.video_asset').querySelector('.video-stream mux-player');
//     // const overlay = button.closest('.video_asset').querySelector('.full-screen-overlay');
//     muxplayer.classList.remove('video-fullscreen');
//     // hideOverlay(overlay);

//     console.log("Attempted to exit full screen");
//   });
// });

// function showOverlay(overlay) {
//   overlay.style.display = 'block';
//   overlay.style.opacity = '1';
// };

// function hideOverlay(overlay) {
//   overlayrstyle.display = 'none';
//   overlay.style.opacity = '0';
// };

// function addMouseActivityListener(overlay) {
//   document.addEventListener('mousemove', () => {
//       overlay.style.opacity = '1';
//       clearTimeout(overlayTimeout);
//       overlayTimeout = setTimeout(() => {
//           overlay.style.opacity = '0';
//           console.log('Overlay faded out');
//       }, 1000);
//   });
// }
// // function showOverlay(element) {
// //     element.style.display = 'block';
// //     element.style.opacity = '1';
// //     console.log('overlay called');
// // };


// // function toggleFullScreen(element) {
// //   console.log('toggleFullScreen function called');
// //   if (!element.classList.contains('video-fullscreen')) {
// //     element.classList.add('video-fullscreen');
// //     console.log("One video entered full screen");
// //   } else {
// //     element.classList.remove('video-fullscreen');
// //   }
// // }

// // Break up this toggle fullscreen method into two methods
// // addfullscreen
// // removefullscreen

// // document.querySelectorAll('.full-screen-overlay button#back-button').forEach(button => {
// //   button.addEventListener('click', () => {
// //     const muxplayer = button.closest('.video_asset').querySelector('.video-stream mux-player');
// //     console.log("back button called")
// //     toggleFullScreen(muxplayer);
// //   });
// // });

// // I think it is something above this section //

document.querySelectorAll('.fullscreen-button').forEach(button => {
  button.addEventListener('click', () => {
    console.log("Fullscreen button clicked");
    // Rest of the code
  });
});

document.querySelectorAll('.full-screen-overlay button#back-button').forEach(button => {
  button.addEventListener('click', () => {
    console.log("Back button clicked");
    // Rest of the code
  });
});