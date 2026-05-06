# Remote Deployment Firefox Extension

A Firefox extension to deploy builds to remote machines directly from your browser.

## Features

- 🚀 One-click deployment to remote machines
- 📂 Specify project directory path (deploys from any branch)
- 📊 Sidebar interface with real-time output
- 🔒 Secure password handling (not stored)
- 📝 Real-time deployment output in terminal-style view
- 💾 Remembers last used IP address and project path
- 🔄 Automatic build and deployment process
- ⌨️ Keyboard shortcuts (Enter to navigate/submit)
- 🌿 Works with any Git branch (uses currently checked out branch)

## Installation

Run the automatic setup script:

```bash
./auto-setup.sh
```

Then load the extension in Firefox (about:debugging).

For manual setup options, see [INSTALLATION.md](INSTALLATION.md).


## Usage

1. Open the sidebar by clicking View > Sidebar > Remote Deployment (or press Ctrl+B and select it)
2. Enter your project directory path (e.g., `/Users/username/my-project`)
   - The extension will use whatever branch is currently checked out in that directory
   - Make sure you've checked out the branch you want to deploy before running
3. Enter the remote machine IP or hostname
4. Enter the lab password
5. Click "Deploy Build" or press Enter
6. Monitor the deployment progress in real-time in the output terminal

### Example Workflow:

```bash
# In your terminal, navigate to your project and checkout the branch you want
cd /Users/username/my-project
git checkout feature-branch

# Then use the extension to deploy
# Enter path: /Users/username/my-project
# Enter IP: <system url>
# Enter password: your_password
# Click Deploy
```


## Project Structure

```
extension-new/
├── manifest.json              # Extension manifest (sidebar configuration)
├── sidebar.html               # Sidebar UI
├── sidebar.js                 # Sidebar logic
├── popup.html                 # Legacy popup UI (not used)
├── popup.js                   # Legacy popup logic (not used)
├── background.js              # Background script for native messaging
├── load-build.sh              # Deployment script
├── native-host.py             # Native messaging host
├── remote_deployment.json     # Native messaging manifest
├── icons/                     # Extension icons
│   ├── icon-48.png
│   ├── icon-96.png
│   └── create-icons.sh        # Script to generate icons
├── README.md                  # This file
└── INSTALLATION.md            # Installation guide
```

## How It Works

1. **Extension UI**: The sidebar provides an interface to enter project path, IP, and credentials
2. **Native Messaging**: The extension communicates with a Python script via Firefox's native messaging API
3. **Working Directory**: The Python script changes to your specified project directory before running the deployment
4. **Deployment Script**: The script executes `load-build.sh` from your project directory (using the currently checked out branch)
5. **Real-time Feedback**: Output from the deployment script is streamed back to the sidebar in real-time

## Deployment Script Details

The `load-build.sh` script performs the following steps:

1. Changes to your specified project directory
2. Uses the currently checked out Git branch
3. Cleans old build artifacts (`rm -rf dist`)
4. Runs `npm run build` to create a new build
5. Copies the `dist` folder to the remote machine via SCP
6. Executes remote commands to:
   - Create overlay directories
   - Set proper permissions
   - Copy files to `/usr/share/www`
   - Restart the `bmcweb` service

**Important**: Make sure you checkout the correct branch in your project directory before deploying!

## Security Notes

- Passwords are never stored or logged
- SSH connections use `StrictHostKeyChecking=no` for convenience (consider security implications)
- The extension requires `nativeMessaging` permission to execute local scripts

## Troubleshooting

### Extension doesn't connect to native host

1. Verify the native messaging manifest is in the correct location
2. Check that the `path` in `remote_deployment.json` points to the correct location of `native-host.py`
3. Ensure `native-host.py` is executable: `chmod +x native-host.py`
4. Check Firefox's Browser Console (Ctrl+Shift+J) for error messages

### Deployment fails

1. Verify `sshpass` is installed: `which sshpass`
2. Test the deployment script manually: `./load-build.sh <ip> <password>`
3. Check that you have SSH access to the remote machine
4. Verify the remote user has sudo privileges

### Icons not showing

1. Run the icon creation script: `cd icons && chmod +x create-icons.sh && ./create-icons.sh`
2. Or create 48x48 and 96x96 PNG icons manually and place them in the `icons/` directory

## Development

To modify the extension:

1. Make your changes to the source files
2. Reload the extension in `about:debugging`
3. Test the changes

## License

This extension is provided as-is for internal use.

## Support

For issues or questions, please contact the development team.