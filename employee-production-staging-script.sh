#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Hello, I am running because a PR was made to the Staging branch!"

# Navigate to the Vue.js project directory
echo "Navigating to the project directory..."
cd /home/saad/employee-production-staging/Haussler_frontend || { echo "Failed to navigate to the project directory"; exit 1; }

# Switch to the desired branch
echo "Switching to the branch 'employee-production-staging'..."
git checkout employee-production-staging || { echo "Branch 'employee-production-staging' does not exist"; exit 1; }

# Ensure the SSH agent is running and the key is added
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Set the correct remote URL
echo "Setting the remote URL..."
git remote set-url origin git@github.com:CoalAI/Haussler_frontend.git

# Pull the latest changes from the staging branch
echo "Pulling the latest changes from 'employee-production-staging' branch..."
git pull origin employee-production-staging || { echo "Failed to pull from 'employee-production-staging' branch"; exit 1; }

# Install dependencies
echo "Installing dependencies from package.json..."
npm install || { echo "Failed to install dependencies"; exit 1; }

# Build the project
echo "Building the project..."
npm run build || { echo "Failed to build the project"; exit 1; }

# Check if the tmux session exists and restart the application
if tmux has-session -t haussler-frontend-employee-production-staging 2>/dev/null; then
    echo "Restarting the application in the existing tmux session..."
    tmux send-keys -t haussler-frontend-employee-production-staging C-c  # Send Ctrl+C to stop the application
    tmux send-keys -t haussler-frontend-employee-production-staging 'npm run dev -- --host 0.0.0.0 --port 8105' C-m  # Start the application on port 8103
else
    echo "Tmux session not found. Creating a new tmux session and starting the application..."
    tmux new-session -d -s haussler-frontend-employee-production-staging
    tmux send-keys -t haussler-frontend-employee-production-staging 'cd /home/saad/employee-production-staging/Haussler_frontend && npm run dev -- --host 0.0.0.0 --port 8105' C-m
fi

echo "Script executed successfully!"
