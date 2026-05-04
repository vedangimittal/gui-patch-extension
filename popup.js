// Popup script for handling user interactions
document.addEventListener('DOMContentLoaded', function() {
  const deployBtn = document.getElementById('deployBtn');
  const remoteIpInput = document.getElementById('remoteIp');
  const passwordInput = document.getElementById('password');
  const statusDiv = document.getElementById('status');

  // Load saved IP if exists
  browser.storage.local.get('lastRemoteIp').then(result => {
    if (result.lastRemoteIp) {
      remoteIpInput.value = result.lastRemoteIp;
    }
  });

  deployBtn.addEventListener('click', function() {
    const remoteIp = remoteIpInput.value.trim();
    const password = passwordInput.value.trim();

    if (!remoteIp || !password) {
      showStatus('Please fill in all fields', 'error');
      return;
    }

    // Save the IP for next time
    browser.storage.local.set({ lastRemoteIp: remoteIp });

    // Disable button and show processing status
    deployBtn.disabled = true;
    deployBtn.textContent = 'Deploying...';
    showStatus('Starting deployment...', 'info');

    // Send message to background script
    browser.runtime.sendMessage({
      action: 'deploy',
      remoteIp: remoteIp,
      password: password
    }).then(response => {
      deployBtn.disabled = false;
      deployBtn.textContent = 'Deploy Build';
      
      if (response.success) {
        showStatus('✓ Deployment completed successfully!', 'success');
        // Clear password for security
        passwordInput.value = '';
      } else {
        showStatus('✗ Deployment failed: ' + response.error, 'error');
      }
    }).catch(error => {
      deployBtn.disabled = false;
      deployBtn.textContent = 'Deploy Build';
      showStatus('✗ Error: ' + error.message, 'error');
    });
  });

  function showStatus(message, type) {
    statusDiv.textContent = message;
    statusDiv.className = type;
    statusDiv.style.display = 'block';
  }
});

