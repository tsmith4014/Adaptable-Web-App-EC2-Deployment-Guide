---

# Calculator-Webapp Deployment Guide

A comprehensive guide to deploying the Calculator-Webapp, a cloud-based service that provides a simple yet powerful calculator application. The web application is built using Python and Flask, and is deployable via AWS EC2 instances for maximum scalability and accessibility.

**Additional Optional reference resources in Repository:**

- `user_data.sh`: Automated shell script for EC2 deployment.
- `calc_app.service`: systemd service file for running the app as a service.

## Table of Contents

- [Introduction](#calculator-webapp-deployment-guide)
- [Additional Resources in Repository](#additional-resources-in-repository)
- [Step-By-Step Instruction Guide](#step-by-step-instruction-guide-to-deploy-calculator-webapp-on-an-ec2-instance)
- [Full Deployment Shell Script](#full-deployment-shell-script)
- [Attribution](#attribution)

## Step-By-Step Instruction Guide to Deploy Calculator-Webapp on an EC2 instance

1. **SSH into EC2 instance**
   ```bash
   ssh ec2-user@<Your_EC2_IP>
   ```
2. **Update package manager**

   ```bash
   sudo yum update -y
   ```

3. **Install Git**

   ```bash
   sudo yum install git -y
   ```

4. **Clone the Calculator-Webapp repository**

   ```bash
   git clone https://github.com/codeplatoon-devops/calculator-webapp/
   ```

5. **Navigate to the cloned repository**

   ```bash
   cd calculator-webapp/
   ```

6. **Install Python-Pip**

   ```bash
   sudo yum install python-pip -y
   ```

7. **Edit requirements.txt to include gunicorn**

   ```bash
   vi requirements.txt
   ```

   In Vim, add `gunicorn` under the flask entry.

8. **Create a Python virtual environment**

   ```bash
   python3 -m venv venv
   ```

9. **Activate the virtual environment**

   ```bash
   source venv/bin/activate
   ```

10. **Install Python dependencies**

    ```bash
    pip install -r requirements.txt
    ```

11. **Create a Gunicorn config file**

    ```bash
    vim gunicorn_config.py
    ```

    Inside Vim, add the following lines:

    ```python
    bind = "0.0.0.0:80"
    workers = 4
    ```

12. **Create a systemd service file**
    Create a file called `calculator-webapp.service` and paste the following content:

    ```
    [Unit]
    Description=Gunicorn instance to serve calculator-webapp
    Wants=network.target
    After=syslog.target network-online.target

    [Service]
    Type=simple
    WorkingDirectory=/home/ec2-user/calculator-webapp
    Environment="PATH=/home/ec2-user/calculator-webapp/venv/bin"
    ExecStart=/home/ec2-user/calculator-webapp/venv/bin/gunicorn calc:app -c /home/ec2-user/calculator-webapp/gunicorn_config.py
    Restart=always
    RestartSec=10

    [Install]
    WantedBy=multi-user.target
    ```

13. **Move the service file to the systemd directory**

    ```bash
    sudo cp calculator-webapp.service /etc/systemd/system
    ```

14. **Reload systemd daemon**

    ```bash
    sudo systemctl daemon-reload
    ```

15. **Enable the service**

    ```bash
    sudo systemctl enable calculator-webapp.service
    ```

16. **Start the service**

    ```bash
    sudo systemctl start calculator-webapp.service
    ```

17. **Check the service status**
    ```bash
    sudo systemctl status calculator-webapp.service
    ```

## Full Deployment Shell Script

For those who prefer an automated approach, you can use the following shell script. Just copy and paste the entire block into your EC2 User Data field or save it as an .sh file and execute it or add it to your EC2 User Data.

```#!/bin/bash

# Update package manager
yum update -y

# Install Git
yum install git -y

# Navigate to ec2-user's home directory
cd /home/ec2-user/

# Clone the Calculator-Webapp repository
git clone https://github.com/codeplatoon-devops/calculator-webapp.git

# Navigate to the cloned repository
cd calculator-webapp

# Install Python-Pip
yum install python-pip -y

# Append gunicorn to requirements.txt
echo "gunicorn" >> requirements.txt

# Create Python virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

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
WorkingDirectory=/home/ec2-user/calculator-webapp
Environment=\"PATH=/home/ec2-user/calculator-webapp/venv/bin\"
ExecStart=/home/ec2-user/calculator-webapp/venv/bin/gunicorn calc:app -c /home/ec2-user/calculator-webapp/gunicorn_config.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/calculator-webapp.service > /dev/null

# Reload systemd daemon
systemctl daemon-reload

# Enable the service
systemctl enable calculator-webapp.service

# Start the service
systemctl start calculator-webapp.service

# Check the service status
systemctl status calculator-webapp.service


```

### Attribution

Special thanks to Chandradeo Arya https://github.com/chandradeoarya for creating an awesome calculator Web-app and providing DevOps deployment guidance, as well as Edwin Quito https://github.com/epquito for providing a step-by-step guide that helped organize this README.
