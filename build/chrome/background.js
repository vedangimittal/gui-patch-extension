// Background script to handle native messaging
// Cross-browser compatibility: Use browser API (works in Firefox, Chrome, Edge)
// For Chrome/Edge, use chrome API; for Firefox, use browser API
const browserAPI = (typeof chrome !== 'undefined' && chrome.runtime) ? chrome : browser;

console.log('[Background] Script loaded successfully');

let port = null;

// Listen for messages from popup/sidebar
browserAPI.runtime.onMessage.addListener((message, sender, sendResponse) => {
  console.log('[Background] Received message:', message);
  
  if (message.action === 'deploy') {
    console.log('[Background] Starting deployment...');
    deployToRemote(message.projectPath, message.remoteIp, message.password)
      .then(result => {
        console.log('[Background] Deployment result:', result);
        sendResponse(result);
      })
      .catch(error => {
        console.error('[Background] Deployment error:', error);
        sendResponse({ success: false, error: error.message });
      });
    return true; // Keep the message channel open for async response
  }
  
  // Return false for other message types
  return false;
});

console.log('[Background] Message listener registered');

// Function to send output to sidebar
function sendOutputToSidebar(data) {
  browserAPI.runtime.sendMessage({
    type: 'deployment-output',
    data: data
  }).catch(() => {
    // Ignore errors if sidebar is not open
  });
}

async function deployToRemote(projectPath, remoteIp, password) {
  try {
    // Connect to native messaging host
    port = browserAPI.runtime.connectNative("remote_deployment");
    
    return new Promise((resolve, reject) => {
      let output = '';
      let settled = false;

      port.onMessage.addListener((response) => {
        if (response.type === 'output') {
          output += response.data + '\n';
          console.log('Deployment output:', response.data);
          sendOutputToSidebar(response.data);
        } else if (response.type === 'success') {
          settled = true;
          sendOutputToSidebar('\n✅ Deployment completed successfully!');
          browserAPI.runtime.sendMessage({ type: 'deployment-complete', success: true }).catch(() => {});
          resolve({ success: true, output: output });
        } else if (response.type === 'error') {
          settled = true;
          const errMsg = response.message || 'Deployment failed';
          browserAPI.runtime.sendMessage({ type: 'deployment-complete', success: false, error: errMsg }).catch(() => {});
          reject(new Error(errMsg));
        }
      });

      port.onDisconnect.addListener(() => {
        // Ignore disconnect if success/error was already received
        if (settled) return;
        const errMsg = browserAPI.runtime.lastError
          ? 'Native messaging host disconnected: ' + browserAPI.runtime.lastError.message
          : 'Native messaging host disconnected unexpectedly';
        browserAPI.runtime.sendMessage({ type: 'deployment-complete', success: false, error: errMsg }).catch(() => {});
        reject(new Error(errMsg));
      });
      
      // Send deployment request
      port.postMessage({
        command: 'deploy',
        projectPath: projectPath,
        remoteIp: remoteIp,
        password: password
      });
      
      // Set timeout for deployment (15 minutes for large transfers)
      setTimeout(() => {
        reject(new Error('Deployment timeout after 15 minutes'));
      }, 900000);
    });
  } catch (error) {
    throw new Error('Failed to connect to native messaging host: ' + error.message);
  }
}
