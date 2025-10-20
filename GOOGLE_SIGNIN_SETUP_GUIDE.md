# 🔐 GOOGLE SIGN-IN SETUP GUIDE

## 📋 **What I Need From You**

### **1. From Supabase Dashboard:**

#### **Step 1: Get Supabase OAuth Settings**
1. Go to your Supabase project: https://supabase.com/dashboard
2. Navigate to: **Authentication** → **Providers** → **Google**
3. You'll see:
   - ✅ **Callback URL (Redirect URL)** - Copy this (looks like: `https://your-project.supabase.co/auth/v1/callback`)
   - ✅ Note if Google provider is **enabled** or not

#### **Step 2: Get Your Supabase Project Details**
1. Go to: **Settings** → **API**
2. Copy these values:
   - ✅ **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - ✅ **Anon/Public Key** (the public anon key)

### **2. From Google Cloud Console:**

We need to create OAuth 2.0 credentials. I'll guide you step-by-step:

---

## 🔧 **Step-by-Step Setup**

### **PART 1: Google Cloud Console Setup**

#### **Step 1: Create/Select Google Cloud Project**
1. Go to: https://console.cloud.google.com/
2. Click on the project dropdown (top left)
3. Click **"New Project"** or select existing project
4. Name it: `MechanicOnDemand`
5. Click **"Create"**

#### **Step 2: Enable Google+ API**
1. Go to: **APIs & Services** → **Library**
2. Search for: **"Google+ API"**
3. Click on it
4. Click **"Enable"**

#### **Step 3: Configure OAuth Consent Screen**
1. Go to: **APIs & Services** → **OAuth consent screen**
2. Select **"External"** (unless you have Google Workspace)
3. Click **"Create"**
4. Fill in:
   - **App name**: `MechanicOnDemand`
   - **User support email**: Your email
   - **Developer contact**: Your email
5. Click **"Save and Continue"**
6. **Scopes**: Click **"Add or Remove Scopes"**
   - Add: `email`
   - Add: `profile`
   - Add: `openid`
7. Click **"Save and Continue"**
8. **Test users** (optional): Add your email for testing
9. Click **"Save and Continue"**

#### **Step 4: Create OAuth 2.0 Credentials**

##### **For Web (Supabase):**
1. Go to: **APIs & Services** → **Credentials**
2. Click **"Create Credentials"** → **"OAuth client ID"**
3. Select: **"Web application"**
4. Name it: `MechanicOnDemand Web`
5. **Authorized JavaScript origins**: Leave empty
6. **Authorized redirect URIs**: 
   - Add your Supabase callback URL (from Step 1 above)
   - Example: `https://xxxxx.supabase.co/auth/v1/callback`
7. Click **"Create"**
8. **COPY THESE** (You'll need them!):
   - ✅ **Client ID** (looks like: `xxxxx.apps.googleusercontent.com`)
   - ✅ **Client Secret** (looks like: `GOCSPX-xxxxx`)

##### **For Android (Flutter App):**
1. Click **"Create Credentials"** → **"OAuth client ID"** again
2. Select: **"Android"**
3. Name it: `MechanicOnDemand Android`
4. **Package name**: `com.example.pro_v1`
5. **SHA-1 certificate fingerprint**: 
   - Run this in terminal: 
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
   - Copy the **SHA-1** value
   - For Windows, use:
   ```cmd
   keytool -list -v -keystore "C:\Users\YOUR_USERNAME\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
6. Click **"Create"**
7. **COPY THIS**:
   - ✅ **Client ID** (Android OAuth Client ID)

---

### **PART 2: Configure Supabase**

#### **Step 1: Add Google Provider to Supabase**
1. Go to Supabase Dashboard
2. Navigate to: **Authentication** → **Providers** → **Google**
3. Toggle **"Enable"** to ON
4. Fill in:
   - **Client ID (for OAuth)**: Paste the **Web Client ID** from Google Cloud
   - **Client Secret (for OAuth)**: Paste the **Client Secret** from Google Cloud
5. Click **"Save"**

---

### **PART 3: What You Need to Give Me**

Please provide these values (you can redact sensitive parts if needed):

```
1. SUPABASE_URL=https://xxxxx.supabase.co
2. SUPABASE_ANON_KEY=eyJhbGc...
3. GOOGLE_WEB_CLIENT_ID=xxxxx.apps.googleusercontent.com
4. GOOGLE_WEB_CLIENT_SECRET=GOCSPX-xxxxx
5. GOOGLE_ANDROID_CLIENT_ID=xxxxx.apps.googleusercontent.com
```

---

## 📱 **Testing SHA-1 Fingerprint**

### **For Windows (PowerShell):**
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### **For Mac/Linux:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Look for this line:**
```
SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
```

---

## 🔍 **Current Status Check**

Let me check what's already configured in your app:


