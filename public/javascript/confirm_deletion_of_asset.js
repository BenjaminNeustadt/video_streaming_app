document.querySelectorAll(".delete-button").forEach(function(button) {
  button.addEventListener("click", function(event) {
    event.preventDefault(); // Prevent the default form submission
    
    if (confirm("Are you sure you want to delete this asset?")) {
      this.closest("form").submit(); // Submit the closest form to the clicked button
    }
  });
});