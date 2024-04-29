  document.addEventListener("DOMContentLoaded", function() {
    const showAllButton = document.getElementById("show-all-user-metrics");
    const showLessButton = document.getElementById("show-less-user-metrics");

    const firstTenUsers = document.getElementById("first-10-user-metrics");
    const allUsers = document.getElementById("all-user-metrics");

    showAllButton.addEventListener("click", function() {
      console.log("Show all button clicked");
        firstTenUsers.hidden = true;
        allUsers.hidden = false;
      });

    showLessButton.addEventListener("click", function() {
      console.log("Show less button clicked");
        allUsers.hidden = true;
        firstTenUsers.hidden = false;
    });
  });

