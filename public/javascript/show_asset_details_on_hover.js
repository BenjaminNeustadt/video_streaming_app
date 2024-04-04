// Show asset info on hover

document.querySelectorAll('.video-stream').forEach(function(videoStream) {
  videoStream.addEventListener('mouseenter', function() {
    var assetInfo = this.closest('.video_asset').querySelector('.asset_info');
    if (assetInfo) {
      assetInfo.classList.add('show');
    }
  });

  videoStream.addEventListener('mouseleave', function() {
    var assetInfo = this.closest('.video_asset').querySelector('.asset_info');
    if (assetInfo) {
      assetInfo.classList.remove('show');
    }
  });
});