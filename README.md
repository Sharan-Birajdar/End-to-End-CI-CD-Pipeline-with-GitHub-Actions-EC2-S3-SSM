# 🚀 CI/CD Website Deployment using GitHub Actions + AWS EC2, SSM, S3 and OIDC 

This project demonstrates an **end-to-end CI/CD pipeline** that automatically deploys a website to an EC2 instance using:

* GitHub Actions
* AWS OIDC
* Amazon S3
* AWS Systems Manager (SSM)
* Amazon EC2
* IAM

---

## 📌 Project Overview

Automatically deploy a website when code is pushed to GitHub.

### 🔄 Pipeline Flow

```
Developer → GitHub Repo → GitHub Actions
            ↓
        Build Website
            ↓
        Upload Artifact → S3
            ↓
        Deploy using SSM
            ↓
        EC2 Server (Nginx)
            ↓
        Website Live
```

---

## 📁 Project Structure

```
simple-cicd-project
│
├── index.html
└── .github
    └── workflows
        └── deploy.yml
```

---

## 🌐 Sample Website (index.html)

```html
<!DOCTYPE html>
<html>
<head>
    <title>DevOps CI/CD Project</title>
    <style>
        body{
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg,#0f2027,#203a43,#2c5364);
            color:white;
            text-align:center;
            padding-top:100px;
        }

        .card{
            background: rgba(255,255,255,0.1);
            padding:40px;
            width:500px;
            margin:auto;
            border-radius:10px;
            box-shadow:0 10px 25px rgba(0,0,0,0.5);
        }

        h1{ font-size:40px; }
        p{ font-size:20px; }

        .footer{
            margin-top:40px;
            font-size:14px;
            opacity:0.7;
        }
    </style>
</head>

<body>
<div class="card">
<h1>🚀 CI/CD Deployment Successful</h1>
<p>This website is automatically deployed using:</p>
<p>GitHub Actions + OIDC + S3 + SSM + EC2</p>
<p>Congratulations! Your DevOps pipeline is working.</p>

<div class="footer">
<p>Project by DevOps Learner</p>
</div>
</div>
</body>
</html>
```

---

## 🪣 Step 1 — Create S3 Bucket

Create a bucket:

```
devops-artifact-bucket-storage
```

This stores build artifacts.

---

## 🖥️ Step 2 — Launch EC2 Instance

* OS: Ubuntu 22.04
* Type: t2.micro

### Install Nginx:

```bash
sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
```

### Attach IAM Role:

```
AmazonSSMManagedInstanceCore
```

---

## 🔐 Step 3 — Configure OIDC

Go to:

```
IAM → Identity Providers → Add Provider
```

* Provider Type: OpenID Connect
* URL: https://token.actions.githubusercontent.com
* Audience: sts.amazonaws.com

---

## 🧑‍💻 Step 4 — Create IAM Role

* Trusted Entity: Web Identity
* Provider: token.actions.githubusercontent.com
* Audience: sts.amazonaws.com

### Attach Permissions:

* AmazonS3FullAccess
* AmazonEC2FullAccess
* AmazonSSMFullAccess

### Role Name:

```
github-actions-role
```

---

## 🔥 Trust Policy (IMPORTANT)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::654485376127:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:Sharan-Birajdar/End-to-End-CI-CD-Pipeline-with-GitHub-Actions-EC2-S3-SSM:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

---

## ⚙️ Step 5 — GitHub Actions Workflow

Create file:

```
.github/workflows/deploy.yml
```

```yaml
name: Deploy Website

on:
  push:
    branches:
      - main

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::654485376127:role/github-actions-role
          aws-region: ap-south-1

      - name: Upload artifact to S3
        run: |
          aws s3 cp index.html s3://devops-artifact-bucket-storage/index.html

      - name: Deploy using SSM
        run: |
          aws ssm send-command \
            --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
            --document-name "AWS-RunShellScript" \
            --parameters commands='[
              "aws s3 cp s3://devops-artifact-bucket-storage/index.html /var/www/html/index.html"
            ]' \
            --region ap-south-1
```

---

## 🔑 Step 6 — Add GitHub Secret

Go to:

```
Repo → Settings → Secrets → Actions
```

Add:

```
EC2_INSTANCE_ID = i-xxxxxxxxxxxx
```

---

## 🚀 Step 7 — Push Code

```bash
git add .
git commit -m "deploy website"
git push origin main
```

---

## 🌍 Step 8 — Test Website

Open in browser:

```
http://<EC2_PUBLIC_IP>
```

---

## 🎉 Output

You should see:

```
🚀 CI/CD Deployment Successful
```

---

## 💡 Conclusion

This project demonstrates a complete **DevOps CI/CD pipeline** using modern AWS and GitHub integration without storing credentials using **OIDC authentication**.

