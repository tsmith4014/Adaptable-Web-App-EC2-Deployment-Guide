### Step-By-Step Instruction Guide to Deploy Calculator-Webapp on an EC2 instance

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
