# Google OAuth Configuration Template

This file contains template configuration for Google OAuth integration.

## Setup Instructions

### 1. Create Google OAuth Credentials
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable Google+ API
4. Create OAuth 2.0 credentials:
   - Application type: Android/iOS
   - Package name: com.bear.quietspace
   - SHA-1 fingerprint: [Your SHA-1 fingerprint]

### 2. Android Setup
1. Add your SHA-1 fingerprint to the Google Cloud Console
2. Download the `google-services.json` file
3. Place it in `android/app/`

### 3. iOS Setup
1. Add your iOS bundle ID to the Google Cloud Console
2. Download the `GoogleService-Info.plist` file
3. Place it in `ios/Runner/`

### 4. Web Setup (if needed)
1. Add authorized JavaScript origins
2. Add authorized redirect URIs

## Security Notes
- Never commit actual API keys or credential files to version control
- Use environment variables for sensitive configuration
- Rotate keys regularly
- Monitor usage in Google Cloud Console

## Files to Add to .gitignore
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/config/api_keys.dart`
- Any files containing actual API keys