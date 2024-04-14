const submitButton = document.getElementById('submit-button');
const uploadAsset = document.querySelector('.upload_asset');
uploadAsset.addEventListener('change', () => {
  const hasContent = uploadAsset.innerText.includes('100%');
  submitButton.disabled = !hasContent;
});
      
