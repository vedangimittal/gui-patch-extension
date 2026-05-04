# Quick Installation Guide

Follow these steps to install and configure the Remote Deployment Firefox Extension (Sidebar Version).

## Step 1: Install Prerequisites

```bash
# Install sshpass (required for SSH automation)
brew install sshpass
```

## Step 2: Run the Setup Script (Recommended)

The easiest way to set everything up:

```bash
# Navigate to the extension directory
cd /Users/vedangimittal/Documents/extension-new

# Run the setup script
chmod +x setup-native-host.sh
./setup-native-host.sh
```

This script will:
- Make all scripts executable
- Create the native messaging directory
- Install the native messaging manifest with correct paths
- Verify Python and sshpass are installed

**If you prefer manual setup, see the Manual Setup section below.**

## Step 3: Create Extension Icons (Optional)

You can either:

**Option A: Use the icon creation script (requires ImageMagick)**
```bash
cd icons
chmod +x create-icons.sh
./create-icons.sh
```

**Option B: Create icons manually**
- Create two PNG files: `icon-48.png` (48x48) and `icon-96.png` (96x96)
- Place them in the `icons/` directory
- Use any icon that represents deployment/rocket/upload

**Option C: Use placeholder icons**
- The extension will work without icons, but won't look as nice

## Step 4: Install the Extension in Firefox

1. Open Firefox
2. Navigate to `about:debugging#/runtime/this-firefox`
3. Click "Load Temporary Add-on..."
4. Navigate to `/Users/vedangimittal/Documents/extension-new`
5. Select the `manifest.json` file
6. Click "Open"

The extension sidebar should now be available!

## Step 5: Open and Test the Sidebar

1. **Prepare your project:**
   ```bash
   # Navigate to your project and checkout the branch you want to deploy
   cd /path/to/your/project
   git checkout your-branch-name
   ```

2. **Open the sidebar:**
   - Click View > Sidebar > Remote Deployment
   - Or use the keyboard shortcut (usually Ctrl+B, then select Remote Deployment)

3. **Fill in the deployment details:**
   - Project Directory Path: `/path/to/your/project` (the full path to your project)
   - Remote IP: or system url
   - Password: Your lab password

4. **Deploy:**
   - Click "Deploy Build" or press Enter
   - Watch the deployment progress in real-time in the terminal-style output

**Note:** The extension will build and deploy whatever branch is currently checked out in your project directory. Make sure you've checked out the correct branch before deploying!

---

## Manual Setup (Alternative to Step 2)

If you prefer to set up manually instead of using the setup script:

### Make scripts executable
```bash
chmod 755 load-build.sh
chmod 755 native-host.py
```

### Install the native messaging host

**For macOS:**
```bash
mkdir -p ~/Library/Application\ Support/Mozilla/NativeMessagingHosts/

cat > ~/Library/Application\ Support/Mozilla/NativeMessagingHosts/remote_deployment.json << EOF
{
  "name": "remote_deployment",
  "description": "Native messaging host for remote deployment",
  "path": "/Users/vedangimittal/Documents/extension-new/native-host.py",
  "type": "stdio",
  "allowed_extensions": ["remote-deployment@example.com"]
}
EOF
```

**For Linux:**
```bash
mkdir -p ~/.mozilla/native-messaging-hosts/

cat > ~/.mozilla/native-messaging-hosts/remote_deployment.json << EOF
{
  "name": "remote_deployment",
  "description": "Native messaging host for remote deployment",
  "path": "/Users/vedangimittal/Documents/extension-new/native-host.py",
  "type": "stdio",
  "allowed_extensions": ["remote-deployment@example.com"]
}
EOF
```

---

## Troubleshooting

If you encounter any issues, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions.

Common issues:
- **"No such native application"** - Run `./setup-native-host.sh` again
- **"sshpass not found"** - Run `brew install sshpass`
- **Deployment fails** - Check project path and ensure branch is checked out

## Making the Extension Permanent

Temporary add-ons are removed when Firefox restarts. To make it permanent:

1. Package the extension as an XPI file
2. Sign it with Mozilla (for distribution)
3. Or keep loading it as a temporary add-on each time

For development purposes, loading as a temporary add-on is sufficient.

## Next Steps

- Customize the extension icon
- Modify the deployment script for your specific needs
- Add error handling for specific deployment scenarios
- Consider adding a deployment history feature

## Support

If you encounter issues:
1. Check the Browser Console (Ctrl+Shift+J) for errors
2. Verify all file permissions are correct
3. Test the deployment script manually first
4. Ensure you have network access to the remote machine