// Background script to handle native messaging
let port = null;

// Listen for messages from popup/sidebar
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.action === 'deploy') {
    deployToRemote(message.projectPath, message.remoteIp, message.password, sender.tab ? sender.tab.id : null)
      .then(result => sendResponse(result))
      .catch(error => sendResponse({ success: false, error: error.message }));
    return true; // Keep the message channel open for async response
  }
});

// Function to send output to sidebar
function sendOutputToSidebar(data) {
  // Send to all sidebar instances
  browser.runtime.sendMessage({
    type: 'deployment-output',
    data: data
  }).catch(() => {
    // Ignore errors if sidebar is not open
  });
}

async function deployToRemote(projectPath, remoteIp, password, tabId) {
  try {
    // Connect to native messaging host
    port = browser.runtime.connectNative("remote_deployment");
    
    return new Promise((resolve, reject) => {
      let output = '';
      
      port.onMessage.addListener((response) => {
        if (response.type === 'output') {
          output += response.data + '\n';
          console.log('Deployment output:', response.data);
          
          // Send output to sidebar in real-time
          sendOutputToSidebar(response.data);
        } else if (response.type === 'success') {
          resolve({ success: true, output: output });
        } else if (response.type === 'error') {
          reject(new Error(response.message || 'Deployment failed'));
        }
      });
      
      port.onDisconnect.addListener(() => {
        if (browser.runtime.lastError) {
          reject(new Error('Native messaging host disconnected: ' + browser.runtime.lastError.message));
        }
      });
      
      // Send deployment request
      port.postMessage({
        command: 'deploy',
        projectPath: projectPath,
        remoteIp: remoteIp,
        password: password
      });
      
      // Set timeout for deployment (5 minutes)
      setTimeout(() => {
        reject(new Error('Deployment timeout after 5 minutes'));
      }, 300000);
    });
  } catch (error) {
    throw new Error('Failed to connect to native messaging host: ' + error.message);
  }
}
