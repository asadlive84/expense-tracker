# HTTPS Setup Guide

> **Why this is needed:** Android 9+ (including Samsung A56) blocks plain HTTP on
> real mobile networks. The emulator works because it runs on your Mac's localhost.
> The fix is a free domain + free SSL certificate.
>
> **Cost: $0.** DuckDNS (free subdomain) + Let's Encrypt (free SSL).

---

## Step 1 — Get a Free Domain (DuckDNS)

1. Go to **https://www.duckdns.org**
2. Log in with Google or GitHub
3. Under "Add a domain", type a name — e.g. `expensetracker` → click **Add Domain**
4. You get: `expensetracker.duckdns.org`
5. In the **current ip** field, enter your EC2 IP: `18.139.46.170`
6. Click **Update IP**

Test it — run this on your Mac:
```bash
curl http://hisabkhata.duckdns.org/v1/healthz
# should return: {"status":"ok"}
```

---

## Step 2 — Open Port 443 on AWS

1. Go to **AWS Console → EC2 → Security Groups**
2. Click on your instance's security group
3. **Inbound rules → Edit inbound rules → Add rule**
4. Type: **HTTPS**, Port: **443**, Source: **Anywhere (0.0.0.0/0)**
5. Click **Save rules**

---

## Step 3 — Install nginx + Certbot on the Server

SSH into your EC2 server:
```bash
ssh -i your-key.pem ubuntu@18.139.46.170
```

Then run:
```bash
# Install nginx
sudo apt update
sudo apt install -y nginx

# Install certbot (Let's Encrypt SSL tool)
sudo apt install -y certbot python3-certbot-nginx

# Start nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

## Step 4 — Configure nginx

Create the nginx config for your domain:
```bash
sudo nano /etc/nginx/sites-available/expensetracker
```

Paste this (replace `expensetracker.duckdns.org` with your DuckDNS domain):
```nginx
server {
    listen 80;
    server_name expensetracker.duckdns.org;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable it:
```bash
sudo ln -s /etc/nginx/sites-available/expensetracker /etc/nginx/sites-enabled/
sudo nginx -t          # should say: syntax is ok
sudo systemctl reload nginx
```

Test HTTP still works:
```bash
curl http://expensetracker.duckdns.org/v1/healthz
# {"status":"ok"}
```

---

## Step 5 — Get the Free SSL Certificate

```bash
sudo certbot --nginx -d expensetracker.duckdns.org
```

Certbot will ask:
- Enter your email (for renewal reminders)
- Agree to terms: **Y**
- Share email with EFF: your choice
- Redirect HTTP to HTTPS: **2** (Yes, redirect)

Certbot automatically:
- Gets the certificate from Let's Encrypt
- Updates your nginx config to serve HTTPS on port 443
- Sets up auto-renewal (cert lasts 90 days, auto-renewed)

Test HTTPS:
```bash
curl https://expensetracker.duckdns.org/v1/healthz
# {"status":"ok"}
```

---

## Step 6 — Update the Flutter App

Change the default server URL in the app:

```bash
# File: mobile_app/lib/core/storage/server_url_storage.dart
```

Change line:
```dart
// BEFORE
const _defaultUrl = 'http://18.139.46.170/v1';

// AFTER
const _defaultUrl = 'https://expensetracker.duckdns.org/v1';
```

Also update `api_client.dart` compiled default:
```dart
// BEFORE
defaultValue: 'http://18.139.46.170/v1',

// AFTER  
defaultValue: 'https://expensetracker.duckdns.org/v1',
```

Then rebuild the APK:
```bash
cd ~/go/src/expense-tracker/mobile_app && \
flutter build apk --release && \
cp build/app/outputs/flutter-apk/app-release.apk ../expenseTracker.apk
```

---

## Step 7 — Verify Everything Works

On your Samsung A56:
1. Open the browser
2. Go to `https://expensetracker.duckdns.org/v1/healthz`
3. Should show: `{"status":"ok"}` with a padlock icon 🔒
4. Install the new APK → login should work

---

## Troubleshooting

**Certbot fails with "Could not connect to domain":**
- Make sure port 80 is open in AWS Security Group
- Make sure the DuckDNS IP is set correctly
- Wait 1-2 minutes for DNS to propagate

**After getting the certificate, curl works but app still fails:**
- Make sure you rebuilt the APK with the new HTTPS URL
- Or change the URL in **Settings → Advanced → Server URL** to `https://expensetracker.duckdns.org/v1`

**Certificate renewal (automatic — nothing to do):**
```bash
# Certbot adds this automatically, but you can verify:
sudo certbot renew --dry-run
```

**Check nginx is running:**
```bash
sudo systemctl status nginx
sudo nginx -t
```

---

## Summary

| Before | After |
|---|---|
| `http://18.139.46.170/v1` | `https://expensetracker.duckdns.org/v1` |
| Blocked on real Android devices | Works on all Android + iOS |
| No encryption | TLS encrypted |
| IP can change | Domain stays the same |

The entire setup takes about **15 minutes** and costs **$0**.
