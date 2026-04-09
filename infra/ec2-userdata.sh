#!/bin/bash
# EC2 User Data - Bootstrap script
# Paste this in EC2 > Advanced Details > User Data when launching instance

yum update -y

# SSM Agent (pre-installed on Amazon Linux 2, ensure it's running)
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Nginx
amazon-linux-extras install nginx1 -y
systemctl enable nginx
systemctl start nginx

# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && ./aws/install

# App directory with proper permissions
mkdir -p /var/www/html
chown -R nginx:nginx /var/www/html

# Copy deploy script
cp /home/ec2-user/deploy.sh /home/ec2-user/deploy.sh
chmod +x /home/ec2-user/deploy.sh
