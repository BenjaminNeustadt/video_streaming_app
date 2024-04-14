const darkModeToggle = document.getElementById('dark-mode-toggle');
darkModeToggle.addEventListener('click', function() {
    document.body.classList.toggle('dark-mode');

    const darkModeEnabled = document.body.classList.contains('dark-mode');
    document.cookie = `darkModeEnabled=${darkModeEnabled}; expires=Fri, 31 Dec 9999 23:59:59 GMT`;
});
