#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Hello, I am running because a PR was made to the Development branch!"

# Navigate to the Django project directory
echo "Navigating to the Django project directory..."
cd /home/saad/deploy/Haussler-backend || { echo "Failed to navigate to the project directory"; exit 1; }

# Activate virtual environment if you have one
echo "Activating the virtual environment..."
source /home/saad/deploy/Haussler-backend/venv/bin/activate || { echo "Failed to activate"; exit 1;}

# Remove all existing cron jobs
echo "Removing all existing cron jobs..."
while ! python manage.py crontab remove; do
    echo "Failed to remove existing cron jobs, retrying..."
    sleep 5  # Wait for 5 seconds before retrying
done
echo "Successfully removed existing cron jobs."

# Switch to the desired branch
echo "Switching to the branch 'development'..."
git checkout development || { echo "Branch 'development' does not exist"; exit 1; }

# Pull the latest changes from the development branch
echo "Pulling the latest changes from 'development' branch..."
git pull origin development || { echo "Failed to pull from 'development' branch"; exit 1; }

# Install requirements
echo "Installing requirements from requirements.txt..."
pip install -r requirements.txt || { echo "Failed to install requirements"; exit 1; }

# Apply Migrations
echo "Applying makemigrations..."
python manage.py makemigrations || { echo "Failed to apply migrations"; exit 1; }

echo "Applying migrations..."
python manage.py migrate || { echo "Failed to apply migrations"; exit 1; }

# Add new cron jobs
echo "Adding new cron jobs..."
while ! python manage.py crontab add; do
    echo "Failed to add new cron jobs, retrying..."
    sleep 5  # Wait for 5 seconds before retrying
done
echo "Successfully added new cron jobs."

# Go to /home/saad directory and save current cron jobs
cd /home/saad || { echo "Failed to navigate to /home/saad"; exit 1; }
crontab -l > mycron || { echo "Failed to save current cron jobs to mycron"; exit 1; }

# Go to /home/saad/staging directory
cd /home/saad/staging/Haussler-backend/ || { echo "Failed to navigate to /home/saad/staging/Haussler-backend"; exit 1; }

# Add new cron jobs for staging
echo "Adding new cron jobs for staging..."
while ! python manage.py crontab add; do
    echo "Failed to add new cron jobs, retrying..."
    sleep 5  # Wait for 5 seconds before retrying
done
echo "Successfully added new cron jobs for staging."

# Navigate to /home/saad directory
cd /home/saad || { echo "Failed to navigate to /home/saad"; exit 1; }

# List current cron jobs and save them to newcron
crontab -l > newcron || { echo "Failed to save new cron jobs to newcron"; exit 1; }

# Merge mycron with newcron and save the result to mergedcron
cat mycron newcron > mergedcron || { echo "Failed to merge cron jobs"; exit 1; }

# Install the merged cron jobs from mergedcron
crontab mergedcron || { echo "Failed to install merged cron jobs"; exit 1; }

# List the current cron jobs to verify the merge
crontab -l || { echo "Failed to list current cron jobs"; exit 1; }

# Check if the tmux session exists and restart the application
if tmux has-session -t haussler-backend-development 2>/dev/null; then
    echo "Restarting the application in the existing tmux session..."
    tmux send-keys -t haussler-backend-development C-c  # Send Ctrl+C to stop the application
    tmux send-keys -t haussler-backend-development 'source /home/saad/deploy/Haussler-backend/venv/bin/activate && python manage.py runserver 0.0.0.0:8100' C-m
else
    echo "Tmux session not found. Creating a new tmux session and starting the application..."
    tmux new-session -d -s haussler-backend-development
    tmux send-keys -t haussler-backend-development 'cd /home/saad/deploy/Haussler-backend && source venv/bin/activate && python manage.py runserver 0.0.0.0:8100' C-m
fi

echo "Script executed successfully!"
