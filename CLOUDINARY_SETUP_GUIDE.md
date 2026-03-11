# 🌥️ Cloudinary Setup Guide for Moodify

## Step-by-Step Configuration

### 1️⃣ Create Cloudinary Account

1. **Sign Up**: Go to [https://cloudinary.com](https://cloudinary.com)
2. Click **"Sign Up Free"**
3. Fill in your details (email, password, name)
4. Choose **"Free"** plan (generous limits!)
5. Verify your email

### 2️⃣ Get Your Cloud Name

1. Log in to [Cloudinary Dashboard](https://console.cloudinary.com)
2. Look at the top of the dashboard
3. You'll see your **Cloud Name** (e.g., `dxxxxx`)
4. Copy this cloud name

### 3️⃣ Create Unsigned Upload Preset

1. In Dashboard, go to **Settings** ⚙️ → **Upload**
2. Scroll down to **"Upload presets"** section
3. Click **"Add upload preset"**
4. Configure the preset:
   - **Preset name**: `moodify_profile_photos` (or any name you like)
   - **Signing Mode**: Select **"Unsigned"** ✅ (IMPORTANT!)
   - **Asset type**: `image`
   - **Folder**: `profile_photos` (optional, keeps things organized)
   
5. **Optional Settings** (recommended):
   - Under "Image upload", set:
     - ✅ **Overwrite**: true (replaces old photos with same name)
     - ✅ **Unique filename**: false
   
6. Click **"Save"**

### 4️⃣ Update Flutter App Configuration

Open `/lib/services/cloudinary_service.dart` and update:

```dart
class CloudinaryService {
  // Replace with your actual Cloudinary cloud name
  static const String cloudName = 'YOUR_CLOUD_NAME'; // ← Paste your cloud name here
  
  // Replace with your actual upload preset
  static const String uploadPreset = 'YOUR_UPLOAD_PRESET'; // ← Paste your preset name here
}
```

**Example:**
```dart
class CloudinaryService {
  static const String cloudName = 'dxxxxx';
  static const String uploadPreset = 'moodify_profile_photos';
}
```

### 5️⃣ Test the Upload

1. Run your Flutter app
2. Go to Profile page
3. Tap profile picture
4. Select "Choose from Gallery"
5. Pick a photo
6. Save changes

**Check console output:**
```
🌥️ Starting Cloudinary upload...
📦 File size: 234567 bytes
☁️ Uploading to Cloudinary...
📊 Response status: 200
✅ Upload successful!
🔗 URL: https://res.cloudinary.com/YOUR_CLOUD/image/upload/v1234567890/profile_photos/xyz.jpg
🆔 Public ID: profile_photos/xyz123
```

## 🎁 Cloudinary Free Tier Limits

- ✅ **Storage**: 25 GB
- ✅ **Bandwidth**: 25 GB/month
- ✅ **Transformations**: 25k transformations/month
- ✅ **Uploads**: Unlimited (within bandwidth limits)
- ✅ **Images stored permanently**

This is MORE than enough for profile photos!

## 🔒 Security Notes

### Unsigned Upload Presets

**What are they?**
- Unsigned presets allow uploads without authentication
- Anyone with your cloud name + preset can upload images
- This is OK for profile photos because:
  - Images are publicly viewable anyway
  - Cloudinary has built-in malware scanning
  - You can delete unwanted images later

**Best Practices:**
1. Use unsigned presets ONLY for public content (like profile photos)
2. Set folder restrictions in preset settings
3. Enable image validation in Cloudinary settings
4. Monitor usage in dashboard

### For Private Content (Future)

If you need private uploads later:
1. Use **signed uploads** (requires server-side signing)
2. Add authentication middleware
3. Implement access controls

See: [Cloudinary Signed Uploads](https://cloudinary.com/documentation/upload_images#signed_uploads)

## 🛠️ Troubleshooting

### Error: "Cloudinary not configured!"

**Cause**: Credentials not updated in code

**Fix**: 
```dart
// In lib/services/cloudinary_service.dart
static const String cloudName = 'your_actual_cloud_name';
static const String uploadPreset = 'your_actual_preset_name';
```

### Error: "Upload preset not found"

**Cause**: Wrong preset name or not created

**Fix**:
1. Check spelling in cloudinary_service.dart
2. Verify preset exists in Settings → Upload → Upload presets
3. Make sure preset is **unsigned**

### Error: "Invalid cloud name"

**Cause**: Typo in cloud name

**Fix**: Copy-paste directly from Cloudinary dashboard

### Upload succeeds but image doesn't show

**Possible causes**:
1. Image URL not saved to MongoDB
2. Network issue loading image
3. Cache showing old data

**Fix**:
```bash
# Clear app cache/restart
flutter clean
flutter pub get
flutter run
```

## 📊 Monitoring Usage

Track your Cloudinary usage:
1. Go to [Dashboard](https://console.cloudinary.com)
2. View current month stats:
   - Storage used
   - Bandwidth consumed
   - Transformations count
   - Upload count

## 🎨 Advanced Features (Optional)

### Image Transformations

Cloudinary allows on-the-fly transformations:

```dart
// Original URL:
https://res.cloudinary.com/dxxxxx/image/upload/v1234/profile.jpg

// Resize to 200x200:
https://res.cloudinary.com/dxxxxx/image/upload/w_200,h_200,c_fill/v1234/profile.jpg

// Apply filters:
https://res.cloudinary.com/dxxxxx/image/upload/e_grayscale/v1234/profile.jpg
```

Learn more: [Cloudinary Transformations](https://cloudinary.com/documentation/image_transformations)

### Auto-Optimization

Add these parameters to URLs for automatic optimization:
- `f_auto` - Auto format (WebP, AVIF, etc.)
- `q_auto` - Auto quality
- `dpr_auto` - Auto device pixel ratio

Example:
```
https://res.cloudinary.com/dxxxxx/image/upload/f_auto,q_auto/v1234/profile.jpg
```

## 📝 Summary Checklist

- [ ] Sign up at cloudinary.com
- [ ] Copy cloud name from dashboard
- [ ] Create unsigned upload preset
- [ ] Update cloudinary_service.dart with credentials
- [ ] Test upload with real photo
- [ ] Verify image appears in profile
- [ ] Check Cloudinary dashboard shows uploaded image

## 🎉 Success Indicators

When everything works correctly:

✅ Console shows: `✅ Upload successful!`
✅ Photo displays in profile immediately
✅ Image accessible via URL in browser
✅ Cloudinary dashboard shows 1 image uploaded
✅ MongoDB document contains Cloudinary URL

---

**Need Help?**
- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [Community Support](https://community.cloudinary.com/)
- [API Reference](https://cloudinary.com/documentation/image_upload_api_reference)
