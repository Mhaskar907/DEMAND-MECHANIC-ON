# 🔐 COMPLETE GOOGLE SIGN-IN SETUP GUIDE

## 📋 **INFORMATION I NEED FROM YOU**

Please provide these 5 values:

### **1. From Supabase Dashboard:**
- Go to: https://supabase.com/dashboard → Your Project → Settings → API
- Copy:
  ```
  SUPABASE_URL=https://xxxxx.supabase.co
  SUPABASE_ANON_KEY=eyJhbGc...
  ```

### **2. From Google Cloud Console:**
After following the setup steps below, copy:
  ```
  GOOGLE_WEB_CLIENT_ID=xxxxx.apps.googleusercontent.com
  GOOGLE_WEB_CLIENT_SECRET=GOCSPX-xxxxx
  GOOGLE_ANDROID_CLIENT_ID=xxxxx.apps.googleusercontent.com
  ```

---

## 🚀 **STEP-BY-STEP SETUP**

### **STEP 1: Google Cloud Console Setup**

#### **1.1 Create Google Cloud Project**
1. Go to: https://console.cloud.google.com/
2. Click project dropdown (top left) → **"New Project"**
3. Project name: `MechanicOnDemand`
4. Click **"Create"**
5. Select your new project

#### **1.2 Enable Google+ API**
1. Go to: **APIs & Services** → **Library**
2. Search: **"Google+ API"** (or "Google People API")
3. Click → **"Enable"**

#### **1.3 Configure OAuth Consent Screen**
1. Go to: **APIs & Services** → **OAuth consent screen**
2. User Type: **"External"**
3. Click **"Create"**

**App Information:**
- App name: `MechanicOnDemand`
- User support email: [Your email]
- App logo: (optional)
- Developer contact: [Your email]

**Scopes:**
- Click **"Add or Remove Scopes"**
- Select:
  - ✅ `email`
  - ✅ `profile`  
  - ✅ `openid`
- Click **"Update"** → **"Save and Continue"**

**Test Users (Optional):**
- Add your email for testing
- Click **"Save and Continue"**

#### **1.4 Get SHA-1 Fingerprint (For Android)**

**Windows PowerShell:**
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Mac/Linux:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Look for:**
```
SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
```
**COPY THIS SHA-1 VALUE!**

#### **1.5 Create OAuth Credentials - WEB**
1. Go to: **APIs & Services** → **Credentials**
2. Click **"Create Credentials"** → **"OAuth client ID"**
3. Application type: **"Web application"**
4. Name: `MechanicOnDemand Web`
5. **Authorized redirect URIs**: 
   - Click **"Add URI"**
   - Add: `https://YOUR_SUPABASE_PROJECT_ID.supabase.co/auth/v1/callback`
   - Replace `YOUR_SUPABASE_PROJECT_ID` with your actual Supabase project ID
6. Click **"Create"**
7. **IMPORTANT - SAVE THESE:**
   ```
   Client ID: xxxxx.apps.googleusercontent.com
   Client Secret: GOCSPX-xxxxx
   ```

#### **1.6 Create OAuth Credentials - ANDROID**
1. Click **"Create Credentials"** → **"OAuth client ID"** (again)
2. Application type: **"Android"**
3. Name: `MechanicOnDemand Android`
4. Package name: `com.example.pro_v1`
5. SHA-1 certificate fingerprint: **[Paste the SHA-1 from step 1.4]**
6. Click **"Create"**
7. **SAVE THIS:**
   ```
   Client ID: xxxxx.apps.googleusercontent.com
   ```

---

### **STEP 2: Configure Supabase**

#### **2.1 Enable Google Provider**
1. Go to: Supabase Dashboard → Your Project
2. Navigate: **Authentication** → **Providers**
3. Find **"Google"** in the list
4. Toggle to **"Enabled"**
5. Fill in:
   - **Client ID (for OAuth)**: [Paste Web Client ID from step 1.5]
   - **Client Secret (for OAuth)**: [Paste Client Secret from step 1.5]
6. **Authorized Client IDs**: (Optional, for mobile)
   - Add the Android Client ID from step 1.6
7. Click **"Save"**

#### **2.2 Get Supabase Callback URL**
- Still in Supabase → Authentication → Providers → Google
- Look for: **"Callback URL (for OAuth)"**
- Copy this URL (e.g., `https://xxxxx.supabase.co/auth/v1/callback`)
- **Verify** this URL matches what you added in Google Cloud Console (step 1.5)

---

### **STEP 3: Configure Your Flutter App**

#### **3.1 Create .env File**
In your project root, create a file named `.env`:

```env
# Supabase Configuration
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_KEY_HERE

# Google OAuth Configuration
GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com
```

**Replace with your actual values!**

#### **3.2 Update AndroidManifest.xml**
File: `android/app/src/main/AndroidManifest.xml`

The deep link is already configured, but verify it matches:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="com.example.pro_v1"
        android:host="login-callback" />
</intent-filter>
```

---

### **STEP 4: Update Auth Service**

I'll update the `auth_service.dart` to use environment variables properly.

---

## 🧪 **TESTING THE SETUP**

### **Test Checklist:**

1. **Run the app**
   ```bash
   flutter run
   ```

2. **Go to Login/Signup**
   - Click **"Continue with Google"** button

3. **Check Console Logs**
   ```
   ✅ "Google Sign-In initiated"
   ✅ "Redirecting to Google..."
   ✅ "User authenticated successfully"
   ```

4. **Verify in Supabase**
   - Go to: Authentication → Users
   - Your Google account should appear in the list

5. **Test Role Selection**
   - After Google login, you should see role selection page
   - Select User or Mechanic
   - Profile should be created

---

## 🐛 **TROUBLESHOOTING**

### **Issue 1: "OAuth Error" / "Invalid Client"**
**Solution:**
- Verify Client ID and Secret in Supabase match Google Cloud Console
- Check redirect URL matches exactly

### **Issue 2: "SHA-1 mismatch" (Android)**
**Solution:**
- Regenerate SHA-1 using the keytool command
- Update it in Google Cloud Console → Android OAuth client

### **Issue 3: "Redirect URI mismatch"**
**Solution:**
- In Google Cloud Console, verify the redirect URI is:
  `https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback`
- Must match EXACTLY (no trailing slash, correct project ID)

### **Issue 4: App crashes after Google login**
**Solution:**
- Check `.env` file exists and has correct values
- Verify `flutter pub get` was run after adding env variables
- Check console logs for specific errors

---

## ✅ **SUMMARY - What You Need to Do**

1. ✅ **Follow STEP 1**: Set up Google Cloud Console
2. ✅ **Follow STEP 2**: Configure Supabase with Google OAuth
3. ✅ **Follow STEP 3**: Create `.env` file with your credentials
4. ✅ **Give me these 5 values**:
   ```
   SUPABASE_URL=
   SUPABASE_ANON_KEY=
   GOOGLE_WEB_CLIENT_ID=
   GOOGLE_WEB_CLIENT_SECRET=
   GOOGLE_ANDROID_CLIENT_ID=
   ```

5. ✅ **I will then**:
   - Update auth_service.dart to use env variables
   - Ensure Google Sign-In works properly
   - Add proper error handling
   - Test the complete flow

---

## 📞 **NEXT STEPS**

After you complete the setup and provide the 5 values, I will:
1. Update the code to use your credentials properly
2. Ensure both web and mobile flows work
3. Add comprehensive error handling
4. Test and verify the complete Google Sign-In flow

**Ready? Let me know when you have the credentials!** 🚀
