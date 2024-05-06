document.addEventListener('DOMContentLoaded', function() {
  var startTime = new Date();
  // var loadingIndicator = document.getElementById('loading-indicator');
  // alert('loading');

  // loadingIndicator.style.display = 'none';
  
    window.addEventListener('beforeunload', function() {
      var currentTime = new Date();
      var timeOnSite = Math.floor((currentTime - startTime) / 1000); // in seconds
      var sessionID = document.querySelector('.client-data').dataset.sessionId;
  
      // loadingIndicator.style.display = 'block';
      $.ajax({
        url: '/log_time_on_site',
        type: 'POST',
        data: {
          timeOnSite: timeOnSite,
          sessionID: sessionID
          }
      }).done(function(response) {
        console.log('Time on site logged successfully:', timeOnSite);
      }).fail(function(jqXHR, textStatus, errorThrown) {
        console.error('Error logging time on site:', errorThrown);
      });
    });
  });