#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Native messaging host for Firefox extension to execute deployment script.
This script communicates with the Firefox extension using native messaging protocol.
"""

import sys
import json
import struct
import subprocess
import os

def get_message():
    """Read a message from stdin and decode it."""
    raw_length = sys.stdin.buffer.read(4)
    if not raw_length:
        sys.exit(0)
    message_length = struct.unpack('=I', raw_length)[0]
    message = sys.stdin.buffer.read(message_length).decode('utf-8')
    return json.loads(message)

def encode_message(message_content):
    """Encode a message for transmission, given its content."""
    encoded_content = json.dumps(message_content).encode('utf-8')
    encoded_length = struct.pack('=I', len(encoded_content))
    return {'length': encoded_length, 'content': encoded_content}

def send_message(message):
    """Send an encoded message to stdout."""
    encoded_message = encode_message(message)
    sys.stdout.buffer.write(encoded_message['length'])
    sys.stdout.buffer.write(encoded_message['content'])
    sys.stdout.buffer.flush()

def run_deployment(project_path, remote_ip, password):
    """Execute the deployment script."""
    try:
        # Get the directory where this script is located
        script_dir = os.path.dirname(os.path.abspath(__file__))
        deploy_script = os.path.join(script_dir, 'load-build.sh')
        
        # Check if script exists
        if not os.path.exists(deploy_script):
            send_message({
                'type': 'error',
                'message': f'Deployment script not found at {deploy_script}'
            })
            return
        
        # Check if project path exists
        if not os.path.exists(project_path):
            send_message({
                'type': 'error',
                'message': f'Project directory not found at {project_path}'
            })
            return
        
        # Make sure script is executable
        os.chmod(deploy_script, 0o755)
        
        send_message({
            'type': 'output',
            'data': f'Project path: {project_path}'
        })
        
        send_message({
            'type': 'output',
            'data': f'Starting deployment to {remote_ip}...'
        })
        
        # Run the deployment script with project_path as working directory
        process = subprocess.Popen(
            [deploy_script, remote_ip, password],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            universal_newlines=True,
            cwd=project_path
        )
        
        # Stream output
        if process.stdout:
            for line in process.stdout:
                send_message({
                    'type': 'output',
                    'data': line.strip()
                })
        
        # Wait for completion
        return_code = process.wait()
        
        if return_code == 0:
            send_message({
                'type': 'success',
                'message': 'Deployment completed successfully'
            })
        else:
            send_message({
                'type': 'error',
                'message': f'Deployment failed with exit code {return_code}'
            })
            
    except Exception as e:
        send_message({
            'type': 'error',
            'message': f'Error during deployment: {str(e)}'
        })

def main():
    """Main function to handle native messaging."""
    try:
        message = get_message()
        
        if message.get('command') == 'deploy':
            project_path = message.get('projectPath')
            remote_ip = message.get('remoteIp')
            password = message.get('password')
            
            if not project_path or not remote_ip or not password:
                send_message({
                    'type': 'error',
                    'message': 'Missing project path, remote IP, or password'
                })
                return
            
            run_deployment(project_path, remote_ip, password)
        else:
            send_message({
                'type': 'error',
                'message': 'Unknown command'
            })
            
    except Exception as e:
        send_message({
            'type': 'error',
            'message': f'Native host error: {str(e)}'
        })

if __name__ == '__main__':
    main()

