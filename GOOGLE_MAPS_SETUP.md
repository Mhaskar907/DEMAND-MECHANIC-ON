# GOOGLE MAPS API SETUP GUIDE

## Step 1: Get Google Maps API Key

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/

2. **Create a New Project (or select existing)**
   - Click "Select a project" → "New Project"
   - Enter project name: "MechanicOnDemand"
   - Click "Create"

3. **Enable Required APIs**
   - Go to "APIs & Services" → "Library"
   - Search and enable these APIs:
     - **Maps SDK for Android**
     - **Maps SDK for iOS** 
     - **Geocoding API**
     - **Places API** (optional, for better address search)

4. **Create API Key**
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "API Key"
   - Copy the generated API key

5. **Restrict API Key (Recommended)**
   - Click on your API key
   - Under "Application restrictions":
     - Select "Android apps" for Android
     - Add your package name: `com.example.pro_v1`
     - Add SHA-1 fingerprint (get from: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`)
   - Under "API restrictions":
     - Select "Restrict key"
     - Choose the APIs you enabled above

## Step 2: Configure Android

1. **Add API Key to Android Manifest**
   ```xml
   <!-- Add this inside <application> tag -->
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE"/>
   ```

2. **Update android/app/src/main/AndroidManifest.xml**
   - Add the meta-data tag with your API key

## Step 3: Configure iOS (if needed)

1. **Add API Key to iOS Info.plist**
   ```xml
   <key>GMSApiKey</key>
   <string>YOUR_API_KEY_HERE</string>
   ```

## Step 4: Test the Setup

1. **Run the app**
2. **Go to Live Map page**
3. **Check if map loads properly**

## Troubleshooting

### Common Issues:

1. **"API key not found"**
   - Check if API key is correctly added to AndroidManifest.xml
   - Verify API key is not restricted incorrectly

2. **"This app is not authorized to use this API"**
   - Check API restrictions in Google Cloud Console
   - Ensure package name matches exactly

3. **Map shows gray/blank**
   - Check if Maps SDK for Android is enabled
   - Verify API key has correct permissions

4. **Location not working**
   - Check location permissions in AndroidManifest.xml
   - Verify location services are enabled on device

## Cost Information

- **Maps SDK**: $7 per 1,000 requests (first 28,000 requests free per month)
- **Geocoding API**: $5 per 1,000 requests (first 40,000 requests free per month)
- **Places API**: $17 per 1,000 requests (first 1,000 requests free per month)

## Security Best Practices

1. **Restrict API Key** by package name and SHA-1 fingerprint
2. **Use different keys** for development and production
3. **Monitor usage** in Google Cloud Console
4. **Set up billing alerts** to avoid unexpected charges

## Alternative APIs (if Google Maps is too expensive)

1. **Mapbox** - More affordable, good for custom styling
2. **OpenStreetMap** - Free but requires more setup
3. **HERE Maps** - Good alternative with reasonable pricing
