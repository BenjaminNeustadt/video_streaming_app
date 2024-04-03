document.querySelectorAll('.edit-button').forEach(function(button) {
  button.addEventListener('click', function() {
    // Get the corresponding asset actions container
    var assetActions = this.parentElement.querySelector('.asset-actions');

    // Toggle visibility of asset actions container and its children
    if (assetActions) {
      var displayValue = (assetActions.style.display === 'none') ? 'block' : 'none';
      assetActions.style.display = displayValue;
      assetActions.querySelectorAll('*').forEach(function(element) {
        element.style.display = displayValue;
      });
    }
  });
});