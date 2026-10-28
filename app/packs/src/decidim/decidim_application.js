// This file is compiled inside Decidim core pack. Code can be added here and will be executed
// as part of that pack

// Load images
require.context("../../images", true)

// Never show Decidim's "install app" prompt
try {
  localStorage.setItem("pwaInstallPromptSeen", "true");
} catch (error) {
  // Storage blocked (private mode); the prompt may still appear once
}

// Open the process phases dialog when the URL ends with #szakaszok
window.addEventListener("load", () => {
  if (window.location.hash !== "#szakaszok") {
    return;
  }
  const opener = document.querySelector('[data-dialog-open="process-steps-modal"]');
  if (opener) {
    opener.click();
  }
});
