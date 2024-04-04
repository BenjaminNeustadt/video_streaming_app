document.querySelectorAll('.asset-data-button').forEach(function(button) {
  button.addEventListener('click', function() {
    var assetData = this.closest('.video_asset').querySelector('.asset-data');
    if (assetData) {
      assetData.classList.toggle('show');
    }
  });
});