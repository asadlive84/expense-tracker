# Zero-Cost AWS Deployment Guide 🚀

This guide will help you deploy your Expense Tracker to AWS for $0 using the Free Tier.

## 🧠 Learning the Concepts

### 1. What is CI/CD?
*   **CI (Continuous Integration):** Automatically building and testing your code every time you "push" to GitHub.
*   **CD (Continuous Deployment):** Automatically updating your live server with the new code.
*   **Benefits:** You never have to manually upload files or restart servers again.

### 2. Why Docker on EC2?
By running Docker on a single EC2 instance, you bypass the cost of expensive managed services. It's like having your own private computer in the cloud that you control completely.

---

## 🛠️ Step 1: Prepare the AWS Foundation

Follow these steps in the [AWS Console](https://console.aws.app/):

### A. Create the ECR Repositories (Storage for your code)
1.  Go to **Amazon ECR** -> **Repositories**.
2.  Click **Create repository**.
3.  Name it: `expense-tracker-api`.
4.  Create another one named: `expense-tracker-frontend`.
5.  *Note:* Keep them **Private**.

### B. Launch the EC2 Server (Your compute)
1.  Go to **EC2** -> **Launch Instance**.
2.  **Name:** `ExpenseTracker-Prod`.
3.  **OS:** `Ubuntu 24.04`.
4.  **Instance Type:** `t3.micro` (This is the **Free Tier** one).
5.  **Key Pair:** Create a new one, download the `.pem` file. **Keep this safe!**
6.  **Network:** Allow **SSH**, **HTTP**, and **HTTPS** traffic from the checkboxes.
7.  Click **Launch**.

### C. Get a Static IP (Elastic IP)
1.  In EC2 sidebar, go to **Network & Security** -> **Elastic IPs**.
2.  Click **Allocate Elastic IP address** -> **Allocate**.
3.  Select the new IP -> **Actions** -> **Associate Elastic IP address**.
4.  Choose your `ExpenseTracker-Prod` instance and click **Associate**.
5.  **Copy this IP!** This is your app's permanent home.

---

## 🔐 Step 2: Configure GitHub Secrets

Go to your GitHub Repository -> **Settings** -> **Secrets and variables** -> **Actions** -> **New repository secret**.

Add these one by one:

| Secret Name | What to put in it |
| :--- | :--- |
| `AWS_ACCESS_KEY_ID` | Your AWS IAM Access Key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS IAM Secret Key |
| `AWS_REGION` | e.g., `us-east-1` |
| `AWS_ACCOUNT_ID` | Your 12-digit AWS Account Number |
| `SERVER_IP` | The **Elastic IP** you just copied |
| `EC2_SSH_KEY` | Paste the **ENTIRE** content of your `.pem` file |
| `DB_PASSWORD` | A strong password for your database |
| `JWT_SECRET` | A long random string for security |

---

## 🚀 Step 3: The One-Time Server Setup

Log in to your server once to install Docker. Open your terminal:

```bash
# 1. Login to your server (replace IP and key path)
ssh -i your-key.pem ubuntu@YOUR_SERVER_IP

# 2. Install Docker
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2 awscli

# 3. Allow your user to run docker without sudo
sudo usermod -aG docker ubuntu
newgrp docker

# 4. Clone your repo (so the config files are there)
git clone https://github.com/YOUR_USERNAME/expense-tracker.git ~/expense-tracker
```

---

## ✅ Step 4: Just Push!

From now on, whenever you run:
```bash
git add .
git commit -m "update app"
git push origin main
```
GitHub will automatically build the images, push them to AWS, and update your server.

### How to see your app:
Open your browser and go to: `http://YOUR_SERVER_IP`
