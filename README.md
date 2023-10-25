---

# Adaptable-Web-App-EC2-Deployment-Guide
Flexible framework for deploying web applications, particularly tailored for AWS EC2 environments. While the guide is anchored around a Python-Flask Calculator-Webapp(private repo), the modular design allows for easy customization and adaptability. Potential tool for DevOps professionals, system administrators, and developers aiming to deploy a wide range of web applications.

Key features of this guide include:

Customizable Repository URL: The guide allows you to replace the Calculator-Webapp's repository URL with that of your application, facilitating deployment from any GitHub or other VCS repository.

Service File Templating: It includes a template for the systemd service file, which you can easily adapt to match your application's specific directory structure and naming conventions.

Dependency Management: The requirements.txt can be modified to accommodate any library dependencies your application needs.

Scalable Gunicorn Configuration: The guide comes equipped with a Gunicorn configuration that can be customized in terms of the number of worker processes, catering to the specific demands of your application.

This guide also stands out for its inclusion of automated shell scripts and step-by-step instructions, making it as suitable for automation as it is for manual deployments. The guide, therefore, is much more than a deployment manual for a calculator webapp; it’s a versatile, one-size-fits-all solution for deploying Python-Flask applications in a scalable and efficient manner. Whether you're a seasoned DevOps engineer or a developer just venturing into deployment, this guide offers a universally applicable toolset for streamlined, automated deployments.


## Table of Contents

- [Introduction](#calculator-webapp-deployment-guide)
- [Adapting This Guide for Other Applications](#adapting-this-guide-for-other-applications)
- [Step-By-Step Instruction Guide](#step-by-step-instruction-guide-to-deploy-calculator-webapp-on-an-ec2-instance)
- [Full Deployment Shell Script](#full-deployment-shell-script)
- [Additional Resources in Repository](#additional-resources-in-repository)
- [Attribution](#attribution)

## Adapting This Guide for Other Applications

This deployment guide, while initially aimed at the Calculator-Webapp, can be easily adapted to deploy other web applications hosted on GitHub or other repositories. Here are the areas you might need to customize:

1. **Repository URL**: Replace the Calculator-Webapp GitHub URL with your application's repository URL.
2. **Service File**: Make sure to edit the `calculator-webapp.service` file to match your application's directory structure and naming conventions.
3. **Requirements**: Replace or modify the `requirements.txt` file to include dependencies specific to your application.
4. **Gunicorn Config**: You may need to adjust the number of workers based on your application's needs.

By customizing these aspects, you can reuse the core steps and the deployment shell script to automate the deployment of various web applications.

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

## Full Deployment Shell Script for Automation

For those who prefer an automated approach, you can use the following shell script. Just copy and paste the entire block into your EC2 User Data field when launching your EC2 instance or after you ssh into your EC2 instance copy and paste the entire block into your terminal and it will automate the deployment process.

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

**Additional Optional reference resources in Repository:**

- `user_data.sh`: Automated shell script for EC2 deployment.
- `calc_app.service`: systemd service file for running the app as a service.


### Attribution

Special thanks to Chandradeo Arya https://github.com/chandradeoarya for creating an awesome calculator Web-app and providing DevOps deployment guidance, as well as Edwin Quito https://github.com/epquito for providing a step-by-step guide that helped organize this README.
