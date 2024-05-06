// Function to check if the viewport is in mobile view
function isMobileView() {
  console.log("Viewport width:", window.innerWidth);
  return window.innerWidth <= 768; // Adjust this value according to your design
}

// Function to rearrange structure based on viewport size for each asset
function rearrangeStructure() {
  const assets = document.querySelectorAll('.video_asset');
  assets.forEach(asset => {
    const assetId = asset.dataset.assetId; // Corrected
    console.log("Asset ID:", assetId);

    const desktopView = asset.querySelector(`#desktopView`);
    const mobileView = asset.querySelector(`#mobileView`);

    console.log("Desktop view display style:", desktopView.style.display);
    console.log("Mobile view display style:", mobileView.style.display);

    if (isMobileView()) {
      console.log("Mobile view detected");
      desktopView.style.display = "none";
      mobileView.style.display = "block";
    } else {
      console.log("Desktop view detected");
      desktopView.style.display = "block";
      mobileView.style.display = "none";
    }

    console.log("Updated desktop view display style:", desktopView.style.display);
    console.log("Updated mobile view display style:", mobileView.style.display);
  });
}

// Call the rearrangeStructure function on page load and resize
window.onload = function() {
  console.log("Page loaded");
  rearrangeStructure();
};
window.onresize = function() {
  console.log("Window resized");
  rearrangeStructure();
};