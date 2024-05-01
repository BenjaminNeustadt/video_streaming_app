// const darkModeToggle = document.getElementById('dark-mode-toggle');
// darkModeToggle.addEventListener('click', function() {
//     const darkModeEnabled = document.body.classList.toggle('dark-mode');
//     // document.body.classList.toggle('dark-mode');
//     document.querySelector('nav').classList.toggle('dark-mode-nav'); // Add or remove 'dark-mode-nav' class to <nav>
//     document.querySelector('h1').classList.toggle('dark-mode-h1'); // Add or remove 'dark-mode-nav' class to <nav>

//     darkModeToggle.textContent = darkModeEnabled ? 'Light Mode' : 'Dark Mode';

//     // const darkModeEnabled = document.body.classList.contains('dark-mode');
//     document.cookie = `darkModeEnabled=${darkModeEnabled}; expires=Fri, 31 Dec 9999 23:59:59 GMT`;
// });

const darkModeToggle = document.getElementById('dark-mode-toggle');

// Function to check if it's a mobile screen
function isMobileScreen() {
    return window.matchMedia("(max-width: 600px)").matches;
}

// Function to update button content based on screen size and dark mode status
function updateButtonContent() {
    const darkModeToggle = document.getElementById('dark-mode-toggle');
    if (darkModeToggle) {
        const darkModeEnabled = document.body.classList.contains('dark-mode');
        if (isMobileScreen()) {
            darkModeToggle.textContent = darkModeEnabled ? 'Light' : 'Dark';
        } else {
            darkModeToggle.textContent = darkModeEnabled ? 'Light Mode' : 'Dark Mode';
        }
    }
}

// Initial update when the page loads
updateButtonContent();

// Event listener for toggling dark mode
darkModeToggle.addEventListener('click', function() {
    const darkModeEnabled = document.body.classList.toggle('dark-mode');
    document.querySelector('nav').classList.toggle('dark-mode-nav');
    document.querySelector('h1').classList.toggle('dark-mode-h1');

    // Update button content after toggling dark mode
    updateButtonContent();

    // Store dark mode status in a cookie
    document.cookie = `darkModeEnabled=${darkModeEnabled}; expires=Fri, 31 Dec 9999 23:59:59 GMT`;
});

// Event listener for window resize to update button content
window.addEventListener('resize', updateButtonContent);
