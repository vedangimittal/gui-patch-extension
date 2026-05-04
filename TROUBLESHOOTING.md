# Troubleshooting Guide

## Error: "No such native application remote_deployment"

This error means Firefox cannot find the native messaging host. Follow these steps:

### Solution 1: Run the Setup Script (Recommended)

```bash
cd /Users/vedangimittal/Documents/extension-new
chmod +x setup-native-host.sh
./setup-native-host.sh
```

This script will:
- Make native-host.py executable
- Create the native messaging directory
- Install the manifest with the correct path
- Verify Python and sshpass are installed

### Solution 2: Manual Setup

1. **Verify the native messaging manifest exists:**
   ```bash
   ls -la ~/Library/Application\ Support/Mozilla/NativeMessagingHosts/remote_deployment.json
   ```

2. **Check the manifest contents:**
   ```bash
   cat ~/Library/Application\ Support/Mozilla/NativeMessagingHosts/remote_deployment.json
   ```
   
   It should look like:
   ```json
   {
     "name": "remote_deployment",
     "description": "Native messaging host for remote deployment",
     "path": "/Users/vedangimittal/Documents/extension-new/native-host.py",
     "type": "stdio",
     "allowed_extensions": ["remote-deployment@example.com"]
   }
   ```

3. **Verify native-host.py is executable:**
   ```bash
   ls -la native-host.py
   # Should show: -rwxr-xr-x
   ```
   
   If not, make it executable:
   ```bash
   chmod +x native-host.py
   ```

4. **Test the native host manually:**
   ```bash
   echo '{"command":"test"}' | python3 native-host.py
   ```

### Solution 3: Reload the Extension

After setting up the native messaging host:

1. Go to `about:debugging#/runtime/this-firefox` in Firefox
2. Find "Remote Deployment Tool"
3. Click "Reload"
4. Try using the extension again

## Error: "sshpass not found"

Install sshpass:
```bash
brew install sshpass
```

## Error: "Project directory not found"

Make sure you enter the full absolute path to your project:
- ✅ Correct: `/Users/vedangimittal/my-project`
- ❌ Wrong: `~/my-project`
- ❌ Wrong: `my-project`

## Error: "Build failed"

1. **Check if npm is installed:**
   ```bash
   npm --version
   ```

2. **Verify your project has a build script:**
   ```bash
   cd /path/to/your/project
   cat package.json | grep "build"
   ```

3. **Try building manually:**
   ```bash
   cd /path/to/your/project
   npm run build
   ```

## Error: "SCP failed" or "SSH failed"

1. **Test SSH connection manually:**
   ```bash
   ssh service@<system url>
   ```

2. **Test with sshpass:**
   ```bash
   sshpass -p "your_password" ssh service@<system url> "echo 'Connection successful'"
   ```

3. **Check network connectivity:**
   - Make sure you're on the correct network
   - Verify the remote machine is accessible
   - Check if VPN is required

## Checking Logs

### Firefox Browser Console
1. Press `Ctrl+Shift+J` (or `Cmd+Shift+J` on Mac)
2. Look for errors related to "remote_deployment" or "native messaging"

### Extension Console
1. Go to `about:debugging#/runtime/this-firefox`
2. Find "Remote Deployment Tool"
3. Click "Inspect"
4. Check the Console tab for errors

## Common Issues

### Extension doesn't appear in sidebar menu

1. Reload the extension in `about:debugging`
2. Restart Firefox
3. Check if the extension is enabled

### Sidebar shows but deployment doesn't start

1. Check Browser Console for errors
2. Verify all three fields are filled in
3. Make sure the project path exists
4. Verify native messaging host is set up correctly

### Deployment starts but fails immediately

1. Check if the project has a `package.json` with a build script
2. Verify `npm` is installed and in PATH
3. Check if the project directory has proper permissions
4. Try running the deployment script manually:
   ```bash
   cd /path/to/your/project
   /Users/vedangimittal/Documents/extension-new/load-build.sh remote_ip password
   ```

## Still Having Issues?

1. Run the setup script again:
   ```bash
   ./setup-native-host.sh
   ```

2. Check all prerequisites:
   - Python 3 installed
   - sshpass installed
   - npm installed
   - Project has build script
   - SSH access to remote machine

3. Test each component individually:
   - Test native host: `echo '{"command":"test"}' | python3 native-host.py`
   - Test SSH: `ssh service@remote_ip`
   - Test build: `cd project && npm run build`
   - Test deployment script: `./load-build.sh remote_ip password`

4. Check file permissions:
   ```bash
   ls -la native-host.py load-build.sh setup-native-host.sh
   # All should be executable (-rwxr-xr-x)