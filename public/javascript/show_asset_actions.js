document.querySelectorAll('.edit-button').forEach(function(button) {
  button.addEventListener('click', function() {
    var assetActions = this.closest('.video_asset').querySelector('.asset-actions');
    if (assetActions) {
      assetActions.classList.toggle('show');
    }
  });
});

document.querySelectorAll('.close-admin-view').forEach(function(button) {
  button.addEventListener('click', function() {
    var assetActions = this.closest('.video_asset').querySelector('.asset-actions');
    if (assetActions) {
      assetActions.classList.toggle('show');
    }
  });
});
