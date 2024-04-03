  document.querySelectorAll('.edit-button').forEach(function(button) {
    button.addEventListener('click', function() {
      var assetId = this.getAttribute('data-asset-id');
      var editForm = document.getElementById('editForm_' + assetId);
      editForm.style.display = 'block';
      this.style.display = 'none';
    });
  });