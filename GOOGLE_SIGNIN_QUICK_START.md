# 🎯 QUICK START: Google Sign-In Setup

## 🚀 **TL;DR - What You Need to Do**

### **1. Get Google OAuth Credentials** (15 minutes)
```
Google Cloud Console → Create Project → Enable APIs → Create OAuth Clients
```

### **2. Configure Supabase** (5 minutes)
```
Supabase Dashboard → Authentication → Providers → Enable Google → Add Credentials
```

### **3. Provide Me With These 5 Values:**
```
1. SUPABASE_URL=https://xxxxx.supabase.co
2. SUPABASE_ANON_KEY=eyJhbGc...
3. GOOGLE_WEB_CLIENT_ID=xxxxx.apps.googleusercontent.com
4. GOOGLE_WEB_CLIENT_SECRET=GOCSPX-xxxxx
5. GOOGLE_ANDROID_CLIENT_ID=xxxxx.apps.googleusercontent.com
```

### **4. I'll Update the Code** (I'll do this)
```
✅ Update auth_service.dart to use your credentials
✅ Configure proper OAuth flows
✅ Add error handling
✅ Test everything
```

---

## 📍 **Where to Find Each Value**

### **1 & 2: Supabase Values**
```
Supabase Dashboard → Your Project → Settings → API
├─ Project URL → Copy this
└─ Anon/Public Key → Copy this
```

### **3 & 4: Google Web Client (for Supabase)**
```
Google Cloud Console → APIs & Services → Credentials
└─ Create OAuth Client ID → Web Application
   ├─ Client ID → Copy this
   └─ Client Secret → Copy this
```

### **5: Google Android Client (for Flutter App)**
```
Google Cloud Console → APIs & Services → Credentials
└─ Create OAuth Client ID → Android
   └─ Client ID → Copy this
```

---

## 🔧 **Step-by-Step Commands**

### **Get SHA-1 (for Android OAuth)**

**Windows:**
```cmd
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Mac/Linux:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Copy the SHA-1 line:**
```
SHA1: AB:CD:EF:12:34:56:78:90...
```

---

## 📋 **Quick Checklist**

- [ ] Created Google Cloud project
- [ ] Enabled Google+ API
- [ ] Configured OAuth consent screen
- [ ] Created Web OAuth client
- [ ] Created Android OAuth client (with SHA-1)
- [ ] Enabled Google provider in Supabase
- [ ] Added Client ID & Secret to Supabase
- [ ] Copied all 5 values
- [ ] Provided values to developer

---

## 🎯 **What Happens After You Provide Values**

1. **I'll create your `.env` file** with your credentials
2. **I'll update auth_service.dart** to use environment variables
3. **I'll test the Google Sign-In flow**:
   ```
   User clicks "Sign in with Google"
        ↓
   Opens Google login popup
        ↓
   User selects Google account
        ↓
   Redirects back to app
        ↓
   Role selection page (if first time)
        ↓
   Home page
   ```

---

## ⚡ **Expected Flow**

```
┌────────────────────────────────────────┐
│  Login Page                            │
│  [Continue with Google] ← Click        │
└────────────────────────────────────────┘
              ↓
┌────────────────────────────────────────┐
│  Google Login Popup                    │
│  [Select your Google account]          │
└────────────────────────────────────────┘
              ↓
┌────────────────────────────────────────┐
│  Role Selection (First Time)           │
│  [User] or [Mechanic]                  │
└────────────────────────────────────────┘
              ↓
┌────────────────────────────────────────┐
│  Home Page                             │
│  Welcome! You're logged in with Google │
└────────────────────────────────────────┘
```

---

## 📞 **Ready to Proceed?**

Once you complete the setup and provide the 5 values, I'll:
- ✅ Configure everything automatically
- ✅ Test the complete flow
- ✅ Fix any issues
- ✅ Make Google Sign-In work perfectly!

**Just give me the 5 values and I'll handle the rest!** 🚀

