#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Hello, I am running because a PR was made to the Development branch!"

# Navigate to the Django project directory
echo "Navigating to the Django project directory..."
cd /home/saad/deploy/Haussler-backend || { echo "Failed to navigate to the project directory"; exit 1; }

# Activate virtual environment if you have one
echo "Activating the virtual environment..."
source /home/saad/deploy/Haussler-backend/venv/bin/activate || { echo "Failed to activate"; exit 1;}

# # Remove all existing cron jobs
# echo "Removing all existing cron jobs..."
# python manage.py crontab remove || { echo "Failed to remove existing cron jobs"; exit 1; }
#Remove all existing cron jobs
echo "Removing all existing cron jobs..."
while ! python manage.py crontab remove; do
    echo "Failed to remove existing cron jobs, retrying..."
    sleep 5  # Wait for 5 seconds before retrying
done
echo "Successfully removed existing cron jobs."

# Switch to the desired branch
echo "Switching to the branch 'development'..."
git checkout development || { echo "Branch 'development' does not exist"; exit 1; }

# Pull the latest changes from the ci-cd-testing-v1 branch
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

# # Remove all existing cron jobs
# echo "Removing all existing cron jobs..."
# python manage.py crontab remove || { echo "Failed to remove existing cron jobs"; exit 1; }

#Remove all existing cron jobs
echo "Removing all existing cron jobs..."
while ! python manage.py crontab remove; do
    echo "Failed to remove existing cron jobs, retrying..."
    sleep 5  # Wait for 5 seconds before retrying
done
echo "Successfully removed existing cron jobs."

# Add new cron jobs
# echo "Adding new cron jobs..."
# python manage.py crontab add || { echo "Failed to add new cron jobs"; exit 1; }

echo "Adding all existing cron jobs..."
while ! python manage.py crontab add; do
    echo "Failed to add new cron jobs"
    sleep 5  # Wait for 5 seconds before retrying
done
echo "Successfully add existing cron jobs."

# Restart the application in the tmux session
# echo "Restarting the application in the tmux session..."
# tmux send-keys -t haussler-backend-development C-c  # Send Ctrl+C to stop the application
# tmux send-keys -t haussler-backend-development 'source /home/saad/deploy/Haussler-backend/venv/bin/activate && python manage.py runserver 0.0.0.0:8100' C-m

# Add new cron jobs
# echo "Adding new cron jobs..."
# python manage.py crontab add || { echo "Failed to add new cron jobs"; exit 1; }

# Go to /home/saad directory and save current cron jobs
cd /home/saad || { echo "Failed to navigate to /home/saad"; exit 1; }
crontab -l > mycron || { echo "Failed to save current cron jobs to mycron"; exit 1; }

# Go to /home/saad/staging/Haussler-backend/ and add new cron jobs
cd /home/saad/staging/Haussler-backend/ || { echo "Failed to navigate to /home/saad/staging/Haussler-backend"; exit 1; }
echo "Adding all existing cron jobs..."
while ! python manage.py crontab add; do
    echo "Failed to add new cron jobs"
    sleep 5  # Wait for 5 seconds before retrying
done
echo "Successfully add existing cron jobs."

# Return to /home/saad and merge cron jobs
cd /home/saad || { echo "Failed to navigate to /home/saad"; exit 1; }
crontab -l > newcron || { echo "Failed to save new cron jobs to newcron"; exit 1; }
cat mycron newcron > mergedcron || { echo "Failed to merge cron jobs"; exit 1; }
crontab mergedcron || { echo "Failed to install merged cron jobs"; exit 1; }
crontab -l || { echo "Failed to list current cron jobs"; exit 1; }

# Restart the application in the tmux session
echo "Restarting the application in the tmux session..."
tmux send-keys -t haussler-backend-development C-c  # Send Ctrl+C to stop the application
tmux send-keys -t haussler-backend-development 'source /home/saad/deploy/Haussler-backend/venv/bin/activate && python manage.py runserver 0.0.0.0:8100' C-m



echo "Script executed successfully!"



#--------------Satging--------#
#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Hello, I am running because a PR was made to the Staging branch!"

# Navigate to the Django project directory
echo "Navigating to the Django project directory..."
cd /home/saad/staging/Haussler-backend || { echo "Failed to navigate to the project directory"; exit 1; }


# Activate virtual environment if you have one
echo "Activating the virtual environment..."
source /home/saad/staging/Haussler-backend/venv/bin/activate || { echo "Failed to activate"; exit 1; }


# Switch to the desired branch
echo "Switching to the branch 'staging'..."
git checkout staging || { echo "Branch 'staging' does not exist"; exit 1; }

# Remove all existing cron jobs
echo "Removing all existing cron jobs..."
python manage.py crontab remove || { echo "Failed to remove existing cron jobs"; exit 1; }

# Pull the latest changes from the ci-cd-testing-v1 branch
echo "Pulling the latest changes from 'staging' branch..."
git pull origin staging || { echo "Failed to pull from 'staging' branch"; exit 1; }

# Install requirements
echo "Installing requirements from requirements.txt..."
pip install -r requirements.txt || { echo "Failed to install requirements"; exit 1; }


echo "Applying makemigrations..."
python manage.py makemigrations || { echo "Failed to apply migrations"; exit 1; }

echo "Applying migrations..."
python manage.py migrate || { echo "Failed to apply migrations"; exit 1; }

# Remove all existing cron jobs
echo "Removing all existing cron jobs..."
python manage.py crontab remove || { echo "Failed to remove existing cron jobs"; exit 1; }

# Add new cron jobs
echo "Adding new cron jobs..."
python manage.py crontab add || { echo "Failed to add new cron jobs"; exit 1; }

# Restart the application in the tmux session
echo "Restarting the application in the tmux session..."
tmux send-keys -t haussler-backend-staging C-c  # Send Ctrl+C to stop the application
tmux send-keys -t haussler-backend-staging 'source /home/saad/staging/Haussler-backend/venv/bin/activate && python manage.py runserver 0.0.0.0:8101' C-m

echo "Script executed successfully!"
