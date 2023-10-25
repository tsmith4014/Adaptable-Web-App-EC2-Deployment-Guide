#!/bin/bash

# Define working directory
WORK_DIR="/home/ec2-user/calculator-webapp"
VENV_PATH="/home/ec2-user/calculator-webapp/venv"
SYSTEMD_SERVICE_FILE="/etc/systemd/system/calculator-webapp.service"

# Update package manager
yum update -y

# Install Git
yum install git -y

# Navigate to ec2-user's home directory
cd /home/ec2-user/

# Clone the Calculator-Webapp repository
git clone https://github.com/codeplatoon-devops/calculator-webapp/

# Navigate to the cloned repository
cd $WORK_DIR

# Install Python-Pip
yum install python-pip -y

# Edit requirements.txt to include gunicorn
echo "gunicorn" >> requirements.txt

# Create a Python virtual environment
python3 -m venv venv

# Activate the virtual environment
source $VENV_PATH/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Create Gunicorn config file
echo "bind = '0.0.0.0:80'
workers = 4" > gunicorn_config.py

# Create systemd service file
echo "[Unit]
Description=Gunicorn instance to serve calculator-webapp
Wants=network.target
After=syslog.target network-online.target

[Service]
Type=simple
WorkingDirectory=$WORK_DIR
Environment=\"PATH=$VENV_PATH/bin\"
ExecStart=$VENV_PATH/bin/gunicorn calc:app -c $WORK_DIR/gunicorn_config.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target" > $SYSTEMD_SERVICE_FILE

# Reload systemd daemon
systemctl daemon-reload

# Enable the service
systemctl enable calculator-webapp.service

# Start the service
systemctl start calculator-webapp.service

# Check the service status
systemctl status calculator-webapp.service
