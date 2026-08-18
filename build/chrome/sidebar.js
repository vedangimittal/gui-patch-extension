// Sidebar script for handling user interactions
// Cross-browser compatibility: Use browser API (works in Firefox, Chrome, Edge)
const browserAPI = (typeof chrome !== 'undefined' && chrome.runtime) ? chrome : browser;

document.addEventListener('DOMContentLoaded', function() {
  const deployBtn = document.getElementById('deployBtn');
  const projectPathInput = document.getElementById('projectPath');
  const remoteIpInput = document.getElementById('remoteIp');
  const passwordInput = document.getElementById('password');
  const statusDiv = document.getElementById('status');
  const outputContainer = document.getElementById('outputContainer');
  const outputDiv = document.getElementById('output');

  // Load saved values
  browserAPI.storage.local.get(['lastRemoteIp', 'lastProjectPath']).then(result => {
    if (result.lastRemoteIp) remoteIpInput.value = result.lastRemoteIp;
    if (result.lastProjectPath) projectPathInput.value = result.lastProjectPath;
  }).catch(error => {
    console.error('Error loading saved values:', error);
  });

  deployBtn.addEventListener('click', function() {
    const projectPath = projectPathInput.value.trim();
    const remoteIp = remoteIpInput.value.trim();
    const password = passwordInput.value.trim();

    if (!projectPath || !remoteIp || !password) {
      showStatus('⚠️ Please fill in all fields', 'error');
      return;
    }

    // Save values for next time
    browserAPI.storage.local.set({ lastRemoteIp: remoteIp, lastProjectPath: projectPath });

    // Disable button and show processing status
    deployBtn.disabled = true;
    deployBtn.innerHTML = '<span class="spinner"></span><span>Deploying...</span>';
    showStatus('🚀 Starting deployment...', 'info');

    // Clear and show output container
    outputDiv.textContent = '';
    outputContainer.classList.add('visible');

    // Send message to background script
    try {
      browserAPI.runtime.sendMessage({
        action: 'deploy',
        projectPath: projectPath,
        remoteIp: remoteIp,
        password: password
      }).catch(() => {
        // Firefox does not resolve this Promise when background uses return true
        // Final result is delivered via deployment-complete message instead
      });
    } catch (error) {
      deployBtn.disabled = false;
      deployBtn.innerHTML = '<span>Deploy Build</span>';
      showStatus('❌ Error: ' + error.message, 'error');
      appendOutput('\n❌ Error: ' + error.message);
    }
  });

  // Listen for output and completion messages from background script
  browserAPI.runtime.onMessage.addListener((message) => {
    if (message.type === 'deployment-output') {
      appendOutput(message.data);
    } else if (message.type === 'deployment-complete') {
      deployBtn.disabled = false;
      deployBtn.innerHTML = '<span>Deploy Build</span>';
      if (message.success) {
        showStatus('✅ Deployment completed successfully!', 'success');
        passwordInput.value = '';
      } else {
        const errorMsg = message.error || 'Unknown error';
        showStatus('❌ Deployment failed: ' + errorMsg, 'error');
        appendOutput('\n❌ Error: ' + errorMsg);
      }
    }
  });

  function showStatus(message, type) {
    statusDiv.textContent = message;
    statusDiv.className = type;
    statusDiv.style.display = 'block';

    // Auto-hide info messages after 5 seconds
    if (type === 'info') {
      setTimeout(() => {
        statusDiv.style.display = 'none';
      }, 5000);
    }
  }

  function appendOutput(text) {
    outputDiv.textContent += text + '\n';
    outputDiv.scrollTop = outputDiv.scrollHeight;
  }

  // Enter key navigation
  projectPathInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') remoteIpInput.focus();
  });

  remoteIpInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') passwordInput.focus();
  });

  passwordInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') deployBtn.click();
  });
});
