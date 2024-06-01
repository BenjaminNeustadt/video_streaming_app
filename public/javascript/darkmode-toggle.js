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

function logLocalStorage() {
    console.log(localStorage.getItem("dark-mode"));
}

// Function to enable dark mode
const enableDarkMode = () => {
    document.body.classList.add('dark-mode');
    document.querySelector('nav').classList.add('dark-mode-nav');
    document.querySelector('h1').classList.add('dark-mode-h1');
    localStorage.setItem("dark-mode", "enabled");
};

// Function to disable dark mode
const disableDarkMode = () => {
    document.body.classList.remove('dark-mode');
    document.querySelector('nav').classList.remove('dark-mode-nav');
    document.querySelector('h1').classList.remove('dark-mode-h1');
    localStorage.setItem("dark-mode", "disabled");
};

// Check the initial dark mode status from localStorage
let darkMode = localStorage.getItem("dark-mode");
if (darkMode === "enabled") {
    enableDarkMode(); // set state of darkMode on page load
} else {
    disableDarkMode(); // ensure dark mode is disabled if not enabled
}

// Update button content based on initial dark mode status
updateButtonContent();

// Event listener for toggling dark mode
darkModeToggle.addEventListener('click', function() {
    darkMode = localStorage.getItem("dark-mode");
    if (darkMode === "disabled" || darkMode === null) {
        enableDarkMode();
    } else {
        disableDarkMode();
    }

    // Update button content after toggling dark mode
    updateButtonContent();
    logLocalStorage();
});
// Event listener for toggling dark mode
// darkModeToggle.addEventListener('click', function() {
//     const darkModeEnabled = document.body.classList.toggle('dark-mode');
//     document.querySelector('nav').classList.toggle('dark-mode-nav');
//     document.querySelector('h1').classList.toggle('dark-mode-h1');

    // Update button content after toggling dark mode
    // updateButtonContent();

    // Store dark mode status in a cookie
    // document.cookie = `darkModeEnabled=${darkModeEnabled}; expires=Fri, 31 Dec 9999 23:59:59 GMT`;
    // document.cookie = `darkModeEnabled=${darkModeEnabled}; SameSite=Strict`;
    // logCookie();
// });

// Event listener for window resize to update button content
window.addEventListener('resize', updateButtonContent);
