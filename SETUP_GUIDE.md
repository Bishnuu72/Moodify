# 🚀 Moodify - Complete Setup Guide

## Overview
Your Moodify app now uses:
- ✅ **Firebase Authentication** (Keep as is - working perfectly)
- ✅ **MongoDB Database** (New - for all data storage)
- ✅ **Node.js/Express Backend** (New - REST API)
- ✅ **Flutter Frontend** (Already done)

---

## 📋 Quick Start Checklist

### 1. Backend Setup (MongoDB + Node.js)

```bash
# Navigate to backend folder
cd backend

# Install dependencies (already done)
npm install

# Start the server
npm run dev
```

✅ You should see:
```
✅ MongoDB Connected: clustermoodify.qnbvz4w.mongodb.net
🚀 Server running on port 5000
📝 Environment: development
🔗 API available at http://localhost:5000/api
```

### 2. Test Backend Connection

Open browser or use curl:
```bash
curl http://localhost:5000/api/health
```

Expected response:
```json
{
  "success": true,
  "message": "Moodify API is running",
  "timestamp": "..."
}
```

### 3. Flutter App Setup

The following files have been created:
- ✅ `lib/services/api_service.dart` - HTTP client for MongoDB backend
- ✅ `backend/models/User.js` - User schema
- ✅ `backend/models/MoodEntry.js` - Mood entry schema
- ✅ All controllers and routes

Update API base URL if needed:
```dart
// lib/services/api_service.dart

// For Android Emulator:
static const String baseUrl = 'http://10.0.2.2:5000/api';

// For iOS Simulator:
static const String baseUrl = 'http://localhost:5000/api';

// For Physical Device (replace with your IP):
static const String baseUrl = 'http://192.168.1.XXX:5000/api';
```

### 4. Run Both Services

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
```

**Terminal 2 - Flutter:**
```bash
flutter run
```

---

## 🗂️ Project Structure

```
Moodify/
├── backend/                    # NEW - Node.js Backend
│   ├── config/
│   │   └── database.js        # MongoDB connection
│   ├── controllers/
│   │   ├── moodController.js  # Mood CRUD operations
│   │   └── userController.js  # User operations
│   ├── models/
│   │   ├── User.js            # User model/schema
│   │   └── MoodEntry.js       # Mood entry model/schema
│   ├── routes/
│   │   ├── moodRoutes.js      # Mood API routes
│   │   └── userRoutes.js      # User API routes
│   ├── middleware/            # Custom middleware
│   ├── .env                   # Environment variables (MongoDB URI)
│   ├── .gitignore
│   ├── package.json           # Dependencies
│   ├── server.js              # Main server file
│   └── README.md              # Detailed docs
│
├── lib/
│   ├── services/
│   │   ├── auth_service.dart  # Firebase Auth (unchanged)
│   │   └── api_service.dart   # NEW - MongoDB API calls
│   ├── screens/
│   │   ├── user_dashboard/    # User dashboard screens
│   │   ├── admin/             # Admin dashboard screens
│   │   ├── therapist/         # Therapist dashboard screens
│   │   └── ...                # Other screens
│   └── ...
│
└── pubspec.yaml               # Updated with http package
```

---

## 🔌 How It Works

### Authentication Flow (Unchanged)
1. User signs up/logs in → **Firebase Authentication**
2. User role stored in Firestore → **Firebase**
3. Role-based dashboard routing → **Flutter**

### Data Flow (NEW - MongoDB)
1. User creates mood entry → **Flutter** → `ApiService.createMood()`
2. Request sent to → **Node.js Backend** (`POST /api/moods`)
3. Backend saves to → **MongoDB** (`moodify` database)
4. Response returned → **Flutter UI updates**

### Example: Creating a Mood Entry

```dart
// In your Flutter app (e.g., new_mood_screen.dart)
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

void submitMood() async {
  // Get current user from Firebase
  final authService = Provider.of<AuthService>(context, listen: false);
  final user = authService.currentUser;
  
  if (user != null) {
    try {
      // Create mood in MongoDB via API
      final result = await ApiService.createMood(
        userId: user.uid,
        mood: 'Happy',
        emotionScore: 8,
        note: 'Feeling great today!',
        tags: ['work', 'achievement'],
      );
      
      if (result['success'] == true) {
        print('✅ Mood saved to MongoDB!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mood saved successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save mood')),
      );
    }
  }
}
```

---

## 📡 API Endpoints Reference

### Mood Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/moods/:userId` | Get all moods for a user |
| POST | `/api/moods` | Create new mood entry |
| PUT | `/api/moods/:id` | Update existing mood |
| DELETE | `/api/moods/:id` | Delete mood entry |
| GET | `/api/moods/stats/:userId` | Get mood statistics |

### User Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users/:userId` | Get user profile |
| PUT | `/api/users/:userId` | Update user profile |
| GET | `/api/users` | Get all users (admin) |

---

## 🧪 Testing

### 1. Test with Postman/cURL

**Create a Mood:**
```bash
curl -X POST http://localhost:5000/api/moods \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "testUser123",
    "mood": "Happy",
    "emotionScore": 9,
    "note": "Testing MongoDB integration!"
  }'
```

**Get User Moods:**
```bash
curl http://localhost:5000/api/moods/testUser123
```

**Get Statistics:**
```bash
curl http://localhost:5000/api/moods/stats/testUser123
```

### 2. Test in Flutter App

Replace your existing Firestore calls with `ApiService` calls:

```dart
// OLD - Firestore (for reference only)
// await FirebaseFirestore.instance.collection('moods').add({...});

// NEW - MongoDB via API
await ApiService.createMood(
  userId: user.uid,
  mood: selectedMood,
  emotionScore: score,
  note: note,
);
```

---

## 🔐 Security Notes

✅ **What's Secure:**
- Firebase Authentication (unchanged)
- MongoDB connection string in `.env` (not committed to git)
- CORS enabled
- Rate limiting (100 req/15min)
- Helmet.js security headers

⚠️ **For Production:**
- Change `JWT_SECRET` in `.env`
- Use HTTPS instead of HTTP
- Add authentication middleware
- Validate all inputs
- Sanitize outputs
- Use environment-specific configs

---

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check if port 5000 is in use
lsof -i :5000

# Kill the process if needed
kill -9 <PID>

# Restart server
npm run dev
```

### MongoDB connection fails
1. Check internet connection
2. Verify MongoDB URI in `backend/.env`
3. Whitelist your IP in MongoDB Atlas:
   - Go to atlas.mongodb.com
   - Network Access → Add IP Address
   - Add `0.0.0.0/0` (allow from anywhere) for testing

### Flutter can't connect to backend
1. Ensure backend is running: `http://localhost:5000/api/health`
2. Check base URL in `api_service.dart`:
   - Android Emulator: `10.0.2.2`
   - iOS Simulator: `localhost`
   - Physical device: Your computer's IP
3. Disable firewall temporarily for testing

### Common Errors

**Error: "Failed to load moods"**
- Backend server not running → Start with `npm run dev`
- Wrong user ID → Check userId parameter
- Network issue → Check base URL

**Error: "MongoDB connection timeout"**
- Internet down → Check connection
- Wrong URI → Verify `.env` file
- IP not whitelisted → Add in MongoDB Atlas

---

## 📱 Next Steps

### What to Do Now:

1. **Start Backend Server**
   ```bash
   cd backend
   npm run dev
   ```

2. **Update Your Screens** to use `ApiService` instead of direct Firestore calls

3. **Test Each Feature:**
   - ✅ Create mood → Should save to MongoDB
   - ✅ View moods → Should load from MongoDB
   - ✅ Update profile → Should update MongoDB
   - ✅ View stats → Should calculate from MongoDB

4. **Monitor Backend Logs:**
   - Watch for successful connections
   - Check for errors
   - Verify database operations

### Files to Update:

Replace Firestore calls in these screens:
- `lib/screens/new_mood/new_mood_screen.dart` → Use `ApiService.createMood()`
- `lib/screens/mood_wall/mood_wall_screen.dart` → Use `ApiService.getUserMoods()`
- `lib/screens/user_dashboard/home_screen.dart` → Use `ApiService.getMoodStats()`
- Profile screens → Use `ApiService.getUserProfile()` and `updateUserProfile()`

---

## 📚 Resources

- **Backend Docs:** `backend/README.md`
- **API Service:** `lib/services/api_service.dart`
- **Models:** `backend/models/`
- **MongoDB Atlas:** https://cloud.mongodb.com/
- **Postman:** Download for API testing

---

## ✅ Success Indicators

You'll know everything is working when:
1. ✅ Backend starts without errors
2. ✅ MongoDB connects successfully
3. ✅ Health check returns `{ success: true }`
4. ✅ Flutter app can create/read/update/delete moods
5. ✅ Data persists in MongoDB (check Atlas dashboard)
6. ✅ User profiles update correctly

---

## 🎯 Architecture Summary

```
┌─────────────┐
│   Flutter   │  ← Frontend (Dart)
│     App     │
└──────┬──────┘
       │ HTTP Requests
       ↓
┌─────────────┐
│  Node.js    │  ← Backend API (Express)
│   Backend   │
└──────┬──────┘
       │ Mongoose ODM
       ↓
┌─────────────┐
│   MongoDB   │  ← Database (Atlas Cloud)
│   Atlas     │
└─────────────┘

Firebase Auth (unchanged) → Handles login/signup
```

---

**🎉 Congratulations!** Your Moodify app now has a complete MongoDB backend integrated with your Flutter frontend!
