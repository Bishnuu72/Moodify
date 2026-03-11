# 🎯 Quick Reference - MongoDB Integration

## ✅ What's Been Set Up

### Backend (Node.js + MongoDB)
- ✅ Server running on port 5000
- ✅ MongoDB Atlas connected
- ✅ REST API endpoints ready
- ✅ User & Mood models created
- ✅ CRUD operations implemented

### Frontend (Flutter)
- ✅ ApiService class created
- ✅ HTTP client configured
- ✅ Example widget provided
- ✅ All dependencies added

---

## 🚀 Start Your App

### Terminal 1 - Backend
```bash
cd backend
npm run dev
```
Expected output:
```
✅ MongoDB Connected: clustermoodify.qnbvz4w.mongodb.net
🚀 Server running on port 5000
```

### Terminal 2 - Flutter
```bash
flutter run
```

---

## 📡 Key Files Created

### Backend Files
```
backend/
├── server.js                    # Main server file
├── config/database.js           # MongoDB connection
├── models/User.js               # User schema
├── models/MoodEntry.js          # Mood schema
├── controllers/moodController.js
├── controllers/userController.js
├── routes/moodRoutes.js
├── routes/userRoutes.js
└── .env                         # MongoDB credentials
```

### Flutter Files
```
lib/services/
├── auth_service.dart            # Firebase Auth (unchanged)
└── api_service.dart             # NEW - MongoDB API calls

lib/widgets/
└── mood_tracker_widget.dart     # Example integration
```

---

## 🔌 How to Use in Your Screens

### Example: Create New Mood

```dart
import '../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

void saveMood() async {
  final user = Provider.of<AuthService>(context, listen: false).currentUser;
  
  if (user != null) {
    try {
      final result = await ApiService.createMood(
        userId: user.uid,              // From Firebase Auth
        mood: 'Happy',                  // Selected mood
        emotionScore: 8,                // 0-10 score
        note: 'Feeling great!',         // User's note
        tags: ['work', 'success'],      // Optional tags
      );
      
      if (result['success'] == true) {
        print('✅ Saved to MongoDB!');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}
```

### Example: Get User Moods

```dart
final user = authService.currentUser;

if (user != null) {
  // Get last 50 moods
  final response = await ApiService.getUserMoods(user.uid);
  
  if (response['success'] == true) {
    List<dynamic> moods = response['data'];
    // Display moods in UI
  }
}
```

### Example: Get Statistics

```dart
final response = await ApiService.getMoodStats(user.uid);

if (response['success'] == true) {
  var stats = response['data'];
  int totalMoods = stats['totalMoods'];
  double avgScore = stats['avgEmotionScore'];
  // Display statistics
}
```

### Example: Update Profile

```dart
final response = await ApiService.updateUserProfile(user.uid, {
  'displayName': 'John Doe',
  'bio': 'Mood tracking enthusiast',
  'phone': '+1234567890',
});
```

---

## 📊 Database Schemas

### User Collection
```javascript
{
  userId: "firebase_uid_123",
  email: "user@example.com",
  role: "user" | "admin" | "therapist",
  displayName: "John Doe",
  photoUrl: "https://...",
  bio: "About me...",
  phone: "+1234567890",
  moodEntriesCount: 42,
  interests: ["meditation", "yoga"],
  createdAt: ISODate("..."),
  updatedAt: ISODate("...")
}
```

### MoodEntry Collection
```javascript
{
  userId: "firebase_uid_123",
  mood: "Happy",
  emotionScore: 8,
  note: "Had a great day!",
  tags: ["work", "achievement"],
  imageUrl: "https://...",
  weather: "Sunny",
  location: "New York",
  createdAt: ISODate("..."),
  updatedAt: ISODate("...")
}
```

---

## 🧪 Test API Endpoints

### Health Check
```bash
curl http://localhost:5000/api/health
```

### Create Mood
```bash
curl -X POST http://localhost:5000/api/moods \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test123",
    "mood": "Happy",
    "emotionScore": 9,
    "note": "Testing!"
  }'
```

### Get Moods
```bash
curl http://localhost:5000/api/moods/test123
```

### Get Stats
```bash
curl http://localhost:5000/api/moods/stats/test123
```

---

## 🔄 Migration Guide

### Replace Firestore with MongoDB

#### OLD (Firestore)
```dart
await FirebaseFirestore.instance
  .collection('moods')
  .add({
    'userId': user.uid,
    'mood': selectedMood,
    'createdAt': FieldValue.serverTimestamp(),
  });
```

#### NEW (MongoDB via API)
```dart
await ApiService.createMood(
  userId: user.uid,
  mood: selectedMood,
);
```

---

#### OLD (Firestore - Read)
```dart
final snapshot = await FirebaseFirestore.instance
  .collection('moods')
  .where('userId', isEqualTo: user.uid)
  .orderBy('createdAt', descending: true)
  .limit(10)
  .get();
```

#### NEW (MongoDB via API)
```dart
final response = await ApiService.getUserMoods(
  user.uid,
  limit: 10,
);
```

---

## ⚙️ Configuration

### Change Base URL

**Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

**iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

**Physical Device:**
```dart
static const String baseUrl = 'http://192.168.1.XXX:5000/api';
// Replace XXX with your computer's IP
```

**Production:**
```dart
static const String baseUrl = 'https://api.yourdomain.com/api';
```

---

## 🐛 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Backend won't start | Check port 5000 is free: `lsof -i :5000` |
| Can't connect to MongoDB | Whitelist IP in MongoDB Atlas |
| Flutter can't connect | Use correct IP (10.0.2.2 for Android) |
| CORS error | Backend already has CORS enabled |
| Data not saving | Check MongoDB connection logs |

---

## 📱 Where to Integrate

Update these screens to use MongoDB:

1. **New Mood Screen** → `ApiService.createMood()`
2. **Mood Wall Screen** → `ApiService.getUserMoods()`
3. **Home Dashboard** → `ApiService.getMoodStats()`
4. **Profile Screen** → `ApiService.getUserProfile()` / `updateUserProfile()`

---

## ✅ Checklist

- [ ] Backend server running (`npm run dev`)
- [ ] MongoDB connected (check logs)
- [ ] Health check passes
- [ ] Update base URL for your device
- [ ] Test creating a mood
- [ ] Test viewing moods
- [ ] Test statistics
- [ ] Update all screens gradually

---

## 📚 Documentation

- Full setup guide: `SETUP_GUIDE.md`
- Backend docs: `backend/README.md`
- API Service: `lib/services/api_service.dart`

---

## 🎉 You're Ready!

Your MongoDB backend is running and ready to handle data from your Flutter app!

**Next Step:** Start both services and test the integration!
