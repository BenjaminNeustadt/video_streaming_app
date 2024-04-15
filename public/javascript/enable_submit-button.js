function enableSubmitButton() {
  console.log("Checking upload status...");
  const statusMessage = document.querySelector("body > main > div.upload_asset_metadata > div > mux-uploader").shadowRoot.querySelector("mux-uploader-status").shadowRoot.querySelector("#status-message");

  if (statusMessage && statusMessage.innerText.trim() === 'Upload complete!') {
    console.log("Upload complete message found.");

    const submitButton = document.getElementById('submit-button');
    if (submitButton) {
      submitButton.removeAttribute('disabled');
    } else {
      console.error("Submit button not found.");
    }
    clearInterval(uploadStatusCheckInterval);
  } else {
    console.log("Upload complete message not found.");
  }
}

const uploadStatusCheckInterval = setInterval(enableSubmitButton, 1000);

// This function runs every second when on the admin page,
// when it discovers the 'Upload complete!' MessageChannel, it enables click
// functionality on the submit button.