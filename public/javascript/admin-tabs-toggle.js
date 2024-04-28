function toggleTab(tabName) {
  console.log("We are in the toggleTab script");
  const monitoring  = document.querySelector('.monitoring');
  const upload      = document.querySelector('.upload_asset_metadata');
  const userMetrics = document.querySelector('.user_monitoring');

  document.querySelectorAll('.tab-button').forEach(button => {
    button.classList.remove('active');
  });

  if (tabName === 'monitoring') {
    monitoring.style.display  = 'block';
    upload.style.display      = 'none';
    userMetrics.style.display = 'none';
    document.querySelector('[onclick="toggleTab(\'monitoring\')"]').classList.add('active');
  } else if (tabName === 'upload_asset_metadata') {
    monitoring.style.display  = 'none';
    upload.style.display      = 'block';
    userMetrics.style.display = 'none';
    document.querySelector('[onclick="toggleTab(\'upload_asset_metadata\')"]').classList.add('active');
  } else if (tabName === 'user_monitoring') {
    monitoring.style.display  = 'none';
    upload.style.display      = 'none';
    userMetrics.style.display = 'block';
    document.querySelector('[onclick="toggleTab(\'user_monitoring\')"]').classList.add('active');
  }
}