# Quick Installation Guide

## Automatic Setup (Recommended)

Run the automatic setup script:

```bash
chmod +x auto-setup.sh
./auto-setup.sh
```

Then proceed to install the extension in Firefox.

---

## Manual Setup (Alternative)

If you prefer manual setup:

```bash
brew install sshpass
chmod +x setup-native-host.sh
./setup-native-host.sh
```

For complete manual control, see the Advanced Manual Setup section at the bottom.

---

## Install the Extension in Firefox

1. Open Firefox and navigate to `about:debugging#/runtime/this-firefox`
2. Click "Load Temporary Add-on..."
3. Select the `manifest.json` file from the extension directory
4. Open the sidebar: View > Sidebar > Remote Deployment
5. Enter your project path, remote IP, and password
6. Click "Deploy Build"

---

## Advanced Manual Setup

If you prefer complete manual control instead of using any setup scripts:

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