# Email Notification Setup

## Overview

The workflow now sends email notifications when errors occur during CORE sync. Emails are sent to:
1. The person who made the commit (commit author)
2. prabhu.e@polussolutions.com

## Setup Required

### Step 1: Create Gmail App Password (Recommended)

1. **Enable 2-Factor Authentication** on your Gmail account
2. **Go to Google Account Settings**: https://myaccount.google.com/
3. **Security** → **2-Step Verification** → **App passwords**
4. **Generate App Password**:
   - Select "Mail" as app
   - Select "Other" as device
   - Name it: "GitHub Actions CORE Sync"
   - Copy the 16-character password

### Step 2: Add Secrets to GitHub

1. **Go to Repository Secrets**:
   - `https://github.com/eprabhu/fibi-test/settings/secrets/actions`

2. **Add Secret 1**:
   - **Name**: `EMAIL_USERNAME`
   - **Value**: Your Gmail address (e.g., `your-email@gmail.com`)
   - Click "Add secret"

3. **Add Secret 2**:
   - **Name**: `EMAIL_PASSWORD`
   - **Value**: The 16-character app password from Step 1
   - Click "Add secret"

## Alternative: Use Different Email Service

If you prefer not to use Gmail, you can modify the workflow to use:
- **SendGrid** (free tier available)
- **Mailgun** (free tier available)
- **SMTP** (any SMTP server)

### Using SendGrid (Alternative)

1. Sign up at: https://sendgrid.com/
2. Create API key
3. Update workflow secrets:
   - `EMAIL_USERNAME`: `apikey`
   - `EMAIL_PASSWORD`: Your SendGrid API key
4. Update workflow:
   - `server_address`: `smtp.sendgrid.net`
   - `server_port`: `587`

## How It Works

- **Triggers**: Only when workflow fails (`if: failure()`)
- **Recipients**: 
  - Commit author (from git commit)
  - prabhu.e@polussolutions.com
- **Content**: Includes error details, commit info, and link to workflow logs

## Testing

To test email notifications:
1. Intentionally break the workflow (e.g., wrong path)
2. Commit and push
3. Wait for workflow to fail
4. Check emails

## Troubleshooting

### Emails Not Sending

1. **Check Secrets**: Verify `EMAIL_USERNAME` and `EMAIL_PASSWORD` are set
2. **Check Gmail**: Ensure app password is correct
3. **Check Workflow Logs**: Look for email step errors
4. **Verify Recipients**: Check commit author email is valid

### Gmail App Password Issues

- Make sure 2FA is enabled
- App password must be 16 characters
- Don't use your regular Gmail password

## Security Notes

- ✅ Secrets are encrypted in GitHub
- ✅ App passwords are safer than regular passwords
- ✅ Only sent on workflow failures
- ⚠️ Don't commit email credentials to repository

---

**Once secrets are configured, email notifications will work automatically!**

