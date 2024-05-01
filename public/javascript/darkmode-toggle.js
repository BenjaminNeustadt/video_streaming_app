const darkModeToggle = document.getElementById('dark-mode-toggle');
darkModeToggle.addEventListener('click', function() {
    const darkModeEnabled = document.body.classList.toggle('dark-mode');
    // document.body.classList.toggle('dark-mode');
    document.querySelector('nav').classList.toggle('dark-mode-nav'); // Add or remove 'dark-mode-nav' class to <nav>
    document.querySelector('h1').classList.toggle('dark-mode-h1'); // Add or remove 'dark-mode-nav' class to <nav>

    darkModeToggle.textContent = darkModeEnabled ? 'Light Mode' : 'Dark Mode';

    // const darkModeEnabled = document.body.classList.contains('dark-mode');
    document.cookie = `darkModeEnabled=${darkModeEnabled}; expires=Fri, 31 Dec 9999 23:59:59 GMT`;
});
