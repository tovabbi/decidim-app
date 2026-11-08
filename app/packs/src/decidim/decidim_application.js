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

// Open comment replies by default.
// Decidim 0.32 lazy-loads the replies of a comment when its "N replies" button is
// clicked (show-replies Stimulus controller). Click those buttons automatically, and
// keep doing so for replies that are themselves loaded later (nested threads).
// A reply the user collapses by hand stays collapsed: only never-loaded buttons are clicked.
const REPLIES_BUTTON_SELECTOR =
  '[data-controller~="show-replies"][data-show-replies-loaded-value="false"] [data-show-replies-target="button"]';
const MAX_AUTO_OPEN_ATTEMPTS = 3;

const openPendingReplies = () => {
  document.querySelectorAll(REPLIES_BUTTON_SELECTOR).forEach((button) => {
    if (button.disabled || button.getAttribute("aria-expanded") === "true") {
      return;
    }
    const attempts = parseInt(button.dataset.autoOpenAttempts || "0", 10);
    if (attempts >= MAX_AUTO_OPEN_ATTEMPTS) {
      return;
    }
    button.dataset.autoOpenAttempts = String(attempts + 1);
    button.click();
  });
};

let openRepliesTimer = null;
const scheduleOpenReplies = () => {
  // Debounce, and give Stimulus a moment to connect freshly inserted controllers
  window.clearTimeout(openRepliesTimer);
  openRepliesTimer = window.setTimeout(openPendingReplies, 100);
};

document.addEventListener("DOMContentLoaded", () => {
  const observer = new MutationObserver((mutations) => {
    if (mutations.some((mutation) => mutation.addedNodes.length > 0)) {
      scheduleOpenReplies();
    }
  });
  observer.observe(document.body, { childList: true, subtree: true });
  scheduleOpenReplies();
});
