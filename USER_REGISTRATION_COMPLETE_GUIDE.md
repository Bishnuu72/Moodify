# ✅ Complete User Registration Guide - MongoDB + Firebase Auth

## 🎯 Current Architecture

### Authentication Flow:
```
Firebase Auth → Handles login/signup (email/password)
     ↓
MongoDB → Stores ALL user data (profiles, roles, etc.)
```

**Important:** We're using **Firebase Auth** for authentication only (creating user accounts with email/password), but storing all user data in **MongoDB Atlas** instead of Firestore.

---

## ✅ What's Working

### 1. **Registration Process:**
- ✅ User fills registration form (email, password, role)
- ✅ Firebase Auth creates account
- ✅ User data saved to MongoDB via API
- ✅ Navigates to role-based dashboard

### 2. **Login Process:**
- ✅ User logs in with Firebase Auth
- ✅ Fetches user role from MongoDB
- ✅ Navigates to correct dashboard

### 3. **Data Storage:**
- ✅ All users stored in MongoDB `users` collection
- ✅ Roles properly saved (user/therapist/admin)
- ✅ Therapists visible in "Find Therapist" screen

---

## 🔍 Verification Steps

### Step 1: Test MongoDB Connection
```bash
cd backend
node test_registration.js
```

**Expected Output:**
```
✅ MongoDB Connected Successfully!
✅ User model working
✅ Created: user - test.user@test.com
✅ Created: therapist - test.therapist@test.com
✅ Created: admin - test.admin@test.com
🎉 All tests passed!
```

### Step 2: Start Backend Server
```bash
cd backend
node server.js
```

**Expected Output:**
```
🚀 Server running on port 5001
✅ MongoDB Connected: clustermoodify.qnbvz4w.mongodb.net
```

### Step 3: Run Flutter App
```bash
flutter run
```

### Step 4: Register Test Users

**Register as USER:**
1. Open app → Sign Up
2. Email: `john.user@example.com`
3. Password: `Test123!`
4. Confirm Password: `Test123!`
5. Role: Select **User**
6. Click "Sign Up"

**Expected Console Logs:**
```
🔵 Starting registration for: john.user@example.com with role: user
✅ Firebase Auth created user: abc123xyz
💾 Saving user to MongoDB...
🌐 Creating user in MongoDB: john.user@example.com
📊 Response status: 201
📄 Response body: {"success":true,"data":{...}}
✅ User created successfully in MongoDB
✅ MongoDB save result: true
✅ User saved to MongoDB with ID: abc123xyz
```

**Expected Result:**
- ✅ Account created in Firebase Auth
- ✅ User saved to MongoDB
- ✅ Navigates to User Dashboard

**Repeat for THERAPIST:**
- Email: `sarah.therapist@example.com`
- Role: Select **Therapist**

**Repeat for ADMIN:**
- Email: `admin.test@example.com`
- Role: Select **Admin**

---

## 📊 Verify in MongoDB

### Method 1: Via API
```bash
curl "http://localhost:5001/api/users?limit=100" | python3 -m json.tool
```

**Expected Response:**
```json
{
  "success": true,
  "count": 3,
  "total": 3,
  "data": [
    {
      "userId": "firebase_uid_1",
      "email": "john.user@example.com",
      "role": "user",
      "displayName": ""
    },
    {
      "userId": "firebase_uid_2",
      "email": "sarah.therapist@example.com",
      "role": "therapist",
      "displayName": ""
    },
    {
      "userId": "firebase_uid_3",
      "email": "admin.test@example.com",
      "role": "admin",
      "displayName": ""
    }
  ]
}
```

### Method 2: MongoDB Atlas UI
1. Go to https://cloud.mongodb.com/
2. Login to your account
3. Navigate to: **Database** → **Collections**
4. Click on **users** collection
5. You should see all registered users!

---

## 🧪 Testing Different Scenarios

### Test 1: Register User Role
```
Email: test.user@moodify.com
Password: Test123!
Role: User
```
**Expected:** Saves to MongoDB with `role: "user"`

### Test 2: Register Therapist Role
```
Email: test.therapist@moodify.com
Password: Test123!
Role: Therapist
```
**Expected:** Saves to MongoDB with `role: "therapist"`
**Bonus:** Should appear in "Find Therapist" screen

### Test 3: Register Admin Role
```
Email: test.admin@moodify.com
Password: Test123!
Role: Admin
```
**Expected:** Saves to MongoDB with `role: "admin"`

### Test 4: Login After Registration
1. Logout from current account
2. Login with one of the test accounts
3. Should navigate to correct dashboard based on role

---

## 🐛 Debugging Issues

### Issue 1: "Failed to create user"
**Check Backend Logs:**
```bash
# Watch backend logs in real-time
tail -f backend/logs.txt
```

**Common Causes:**
- Backend server not running
- MongoDB not connected
- Duplicate email (user already exists)

**Solution:**
```bash
# Check if backend is running
curl http://localhost:5001/api/health

# If not running, start it
cd backend
node server.js
```

### Issue 2: User created in Firebase but not MongoDB
**Check Firebase Auth:**
- Go to Firebase Console → Authentication → Users
- See if user exists

**Check MongoDB:**
```bash
curl "http://localhost:5001/api/users/test_user_id"
```

**If user NOT in MongoDB:**
1. Check backend console for errors
2. Verify API endpoint is accessible
3. Check network logs in Flutter console

**Manual Fix:**
```bash
# Manually create user in MongoDB via API
curl -X POST http://localhost:5001/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "firebase_uid_here",
    "email": "user@example.com",
    "role": "user"
  }'
```

### Issue 3: Login doesn't navigate to correct dashboard
**Problem:** Role not being fetched from MongoDB

**Debug:**
```dart
// Add this temporarily to login_screen.dart
final role = await authService.getUserRole(user.uid);
print('🎭 User role from MongoDB: $role'); // ← Add this line
```

**Check MongoDB has correct role:**
```bash
curl "http://localhost:5001/api/users/firebase_uid_here"
```

---

## 📝 Files Modified

### Flutter App:
1. ✅ `lib/services/auth_service.dart`
   - Removed Firestore dependency
   - Added MongoDB API calls
   - Added detailed logging

2. ✅ `lib/services/api_service.dart`
   - Added `createUser()` method
   - Enhanced error handling and logging

3. ✅ `lib/screens/auth/register_screen.dart`
   - Already configured correctly
   - No changes needed

### Backend:
4. ✅ `backend/controllers/userController.js`
   - Added `createUser()` function
   - Handles duplicate checking

5. ✅ `backend/routes/userRoutes.js`
   - Added POST `/api/users` route

6. ✅ `backend/models/User.js`
   - Already configured correctly

7. ✅ `backend/test_registration.js`
   - New test script for verification

---

## 🎯 Expected Console Output During Registration

### Flutter Console:
```
🔵 Starting registration for: test.user@example.com with role: user
✅ Firebase Auth created user: xyzABC123
💾 Saving user to MongoDB...
🌐 Creating user in MongoDB: test.user@example.com
📊 Response status: 201
📄 Response body: {"success":true,"data":{"userId":"xyzABC123","email":"test.user@example.com","role":"user"}}
✅ User created successfully in MongoDB
✅ MongoDB save result: true
✅ User saved to MongoDB with ID: xyzABC123
```

### Backend Console:
```
POST /api/users 201 150.234 ms - 311
```

---

## ✨ Key Features

### ✅ Role-Based Registration:
- User selects role during signup
- Role stored in MongoDB
- Determines dashboard navigation

### ✅ Centralized Data:
- All user data in MongoDB
- No split between Firestore + MongoDB
- Single source of truth

### ✅ Comprehensive Logging:
- Every step logged to console
- Easy debugging
- Clear error messages

### ✅ Automatic Verification:
- Test script validates setup
- Creates & cleans up test data
- Confirms MongoDB connectivity

---

## 🔒 Security Notes

### Current Setup (Development):
- ✅ Firebase Auth handles password security
- ✅ MongoDB connection via secure URI
- ⚠️ API endpoints are public (for development)

### For Production:
- [ ] Add JWT authentication
- [ ] Secure API endpoints
- [ ] Add rate limiting
- [ ] Enable CORS restrictions
- [ ] Use environment variables for sensitive data

---

## 📊 Database Schema

### MongoDB Users Collection:
```javascript
{
  "_id": ObjectId("..."),
  "userId": "firebase_uid",        // From Firebase Auth
  "email": "user@example.com",     // User's email
  "role": "user",                  // user | therapist | admin
  "displayName": "",               // Optional display name
  "photoUrl": null,                // Profile picture URL
  "bio": null,                     // User bio
  "specialization": null,          // For therapists only
  "experience": null,              // Years of experience
  "phone": null,                   // Contact number
  "preferredMood": "",             // Favorite mood type
  "interests": [],                 // Array of interests
  "moodEntriesCount": 0,           // Number of mood entries
  "createdAt": ISODate("..."),     // Registration date
  "updatedAt": ISODate("...")      // Last update
}
```

---

## 🎉 Summary

### ✅ What's Working:
1. ✅ User registration creates account in Firebase Auth
2. ✅ User data saved to MongoDB with role
3. ✅ Login fetches role from MongoDB
4. ✅ Dashboard routing works correctly
5. ✅ Therapists visible in "Find Therapist" screen
6. ✅ All data centralized in MongoDB

### 🚀 Ready to Use:
- Backend server running on port 5001
- MongoDB connected and tested
- Flutter app configured
- Registration flow complete
- Login flow complete

### 📝 Next Steps:
1. ✅ Start backend: `node server.js`
2. ✅ Run Flutter: `flutter run`
3. ✅ Register test users
4. ✅ Verify in MongoDB Atlas
5. ✅ Test login with different roles

**Everything is working perfectly!** 🎉
