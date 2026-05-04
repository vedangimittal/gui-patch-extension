// Sidebar script for handling user interactions
document.addEventListener('DOMContentLoaded', function() {
  const deployBtn = document.getElementById('deployBtn');
  const projectPathInput = document.getElementById('projectPath');
  const remoteIpInput = document.getElementById('remoteIp');
  const passwordInput = document.getElementById('password');
  const statusDiv = document.getElementById('status');
  const outputContainer = document.getElementById('outputContainer');
  const outputDiv = document.getElementById('output');

  // Load saved values if they exist
  browser.storage.local.get(['lastRemoteIp', 'lastProjectPath']).then(result => {
    if (result.lastRemoteIp) {
      remoteIpInput.value = result.lastRemoteIp;
    }
    if (result.lastProjectPath) {
      projectPathInput.value = result.lastProjectPath;
    }
  });

  deployBtn.addEventListener('click', function() {
    const projectPath = projectPathInput.value.trim();
    const remoteIp = remoteIpInput.value.trim();
    const password = passwordInput.value.trim();

    if (!projectPath || !remoteIp || !password) {
      showStatus('⚠️ Please fill in all fields', 'error');
      return;
    }

    // Save the values for next time
    browser.storage.local.set({
      lastRemoteIp: remoteIp,
      lastProjectPath: projectPath
    });

    // Disable button and show processing status
    deployBtn.disabled = true;
    deployBtn.innerHTML = '<span class="spinner"></span><span>Deploying...</span>';
    showStatus('🚀 Starting deployment...', 'info');
    
    // Clear and show output container
    outputDiv.textContent = '';
    outputContainer.classList.add('visible');

    // Send message to background script
    browser.runtime.sendMessage({
      action: 'deploy',
      projectPath: projectPath,
      remoteIp: remoteIp,
      password: password
    }).then(response => {
      deployBtn.disabled = false;
      deployBtn.innerHTML = '<span>Deploy Build</span>';
      
      if (response.success) {
        showStatus('✅ Deployment completed successfully!', 'success');
        // Clear password for security
        passwordInput.value = '';
        
        // Add to output
        appendOutput('\n✅ Deployment completed successfully!');
      } else {
        showStatus('❌ Deployment failed: ' + response.error, 'error');
        appendOutput('\n❌ Error: ' + response.error);
      }
    }).catch(error => {
      deployBtn.disabled = false;
      deployBtn.innerHTML = '<span>Deploy Build</span>';
      showStatus('❌ Error: ' + error.message, 'error');
      appendOutput('\n❌ Error: ' + error.message);
    });
  });

  // Listen for output messages from background script
  browser.runtime.onMessage.addListener((message) => {
    if (message.type === 'deployment-output') {
      appendOutput(message.data);
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
    // Auto-scroll to bottom
    outputDiv.scrollTop = outputDiv.scrollHeight;
  }

  // Allow Enter key to submit and navigate between fields
  projectPathInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
      remoteIpInput.focus();
    }
  });

  remoteIpInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
      passwordInput.focus();
    }
  });

  passwordInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
      deployBtn.click();
    }
  });
});
