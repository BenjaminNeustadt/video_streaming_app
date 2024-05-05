document.addEventListener("DOMContentLoaded", function() {
  var flashes = document.querySelectorAll('.flash');

  flashes.forEach(function(flash) {
    setTimeout(function() {
      flash.classList.add('fade-out');
    }, 3000); // Adjust the timeout as needed (in milliseconds)
  });
});