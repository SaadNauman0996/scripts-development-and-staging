#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Hello, I am running because a PR was made to the Development branch!"

# Navigate to the Vue.js project directory
echo "Navigating to the project directory..."
cd /home/saad/deploy/Haussler_frontend || { echo "Failed to navigate to the project directory"; exit 1; }

# Ensure the SSH agent is running and the key is added
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Set the correct remote URL
echo "Setting the remote URL..."
git remote set-url origin git@github.com:CoalAI/Haussler_frontend.git

# Switch to the desired branch
echo "Switching to the branch 'development'..."
git checkout development || { echo "Branch 'development' does not exist"; exit 1; }

# Pull the latest changes from the development branch
echo "Pulling the latest changes from 'development' branch..."
git pull origin development || { echo "Failed to pull from 'development' branch"; exit 1; }

# Install dependencies
echo "Installing dependencies from package.json..."
npm install || { echo "Failed to install dependencies"; exit 1; }

# Build the project
echo "Building the project..."
npm run build || { echo "Failed to build the project"; exit 1; }

# Check if the tmux session exists and restart the application
if tmux has-session -t haussler-frontend-development 2>/dev/null; then
    echo "Restarting the application in the existing tmux session..."
    tmux send-keys -t haussler-frontend-development C-c  # Send Ctrl+C to stop the application
    tmux send-keys -t haussler-frontend-development 'npm run dev -- --host 0.0.0.0 --port 8102' C-m  # Start the application on port 8102
else
    echo "Tmux session not found. Creating a new tmux session and starting the application..."
    tmux new-session -d -s haussler-frontend-development
    tmux send-keys -t haussler-frontend-development 'cd /home/saad/deploy/Haussler_frontend && npm run dev -- --host 0.0.0.0 --port 8102' C-m
fi

echo "Script executed successfully!"
