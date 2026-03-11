# Moodify Backend - MongoDB + Node.js

Backend API for Moodify app using MongoDB database and Express.js framework.

## 📋 Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- MongoDB Atlas account (already configured)

## 🚀 Installation & Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Environment Variables

The `.env` file is already configured with your MongoDB credentials:
- MongoDB URI: `mongodb+srv://moodify_db:Moodify@123@clustermoodify.qnbvz4w.mongodb.net/?appName=ClusterMoodify`
- Database Name: `moodify`
- Port: `5000`

### 3. Start the Server

**Development Mode (with auto-reload):**
```bash
npm run dev
```

**Production Mode:**
```bash
npm start
```

Server will start on `http://localhost:5000`

## 📡 API Endpoints

### Health Check
```
GET /api/health
```

### Mood Endpoints

#### Get User Moods
```
GET /api/moods/:userId?limit=50&skip=0
```

#### Create New Mood
```
POST /api/moods
Body: {
  "userId": "string",
  "mood": "Happy|Neutral|Sad|Angry|Anxious|Tired",
  "emotionScore": 0-10,
  "note": "string",
  "tags": ["array"],
  "imageUrl": "string",
  "weather": "string",
  "location": "string"
}
```

#### Update Mood
```
PUT /api/moods/:id
Body: { fields to update }
```

#### Delete Mood
```
DELETE /api/moods/:id
```

#### Get Mood Statistics
```
GET /api/moods/stats/:userId
```

### User Endpoints

#### Get User Profile
```
GET /api/users/:userId
```

#### Update User Profile
```
PUT /api/users/:userId
Body: { fields to update }
```

#### Get All Users (Admin)
```
GET /api/users?role=user|admin|therapist&limit=100&skip=0
```

## 🔗 Flutter Integration

The Flutter app connects to this backend via `ApiService` class located at:
`lib/services/api_service.dart`

### Update Base URL for Different Environments:

**Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

**iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

**Physical Device (same network):**
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:5000/api';
```

**Production:**
```dart
static const String baseUrl = 'https://your-domain.com/api';
```

## 📦 Project Structure

```
backend/
├── config/
│   └── database.js          # MongoDB connection
├── controllers/
│   ├── moodController.js    # Mood logic
│   └── userController.js    # User logic
├── models/
│   ├── MoodEntry.js         # Mood schema
│   └── User.js              # User schema
├── routes/
│   ├── moodRoutes.js        # Mood routes
│   └── userRoutes.js        # User routes
├── middleware/              # Custom middleware
├── .env                     # Environment variables
├── package.json             # Dependencies
└── server.js                # Entry point
```

## 🛡️ Security Features

- Helmet.js for security headers
- CORS enabled
- Rate limiting (100 requests per 15 minutes)
- Input validation ready
- Error handling middleware

## 🧪 Testing the API

You can test the API using:
- **Postman** or **Insomnia**
- **cURL** commands
- **Flutter app** directly

Example cURL test:
```bash
# Health check
curl http://localhost:5000/api/health

# Get user moods
curl http://localhost:5000/api/moods/user123

# Create mood
curl -X POST http://localhost:5000/api/moods \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "mood": "Happy",
    "emotionScore": 8,
    "note": "Feeling great today!"
  }'
```

## 📝 Notes

- Firebase Authentication is still used for login/signup
- MongoDB handles all data storage (moods, profiles, etc.)
- The backend is stateless - each request includes necessary data
- All responses follow a consistent format: `{ success: true/false, data/error, message }`

## 🐛 Troubleshooting

**Server won't start:**
- Check if port 5000 is available
- Verify `.env` file exists
- Run `npm install` again

**MongoDB connection fails:**
- Check internet connection
- Verify MongoDB URI in `.env`
- Ensure IP address is whitelisted in MongoDB Atlas

**Flutter can't connect:**
- Ensure backend server is running
- Check base URL in `api_service.dart`
- For physical devices, use computer's IP instead of localhost
- Check firewall settings

## 📚 Additional Resources

- [Express.js Documentation](https://expressjs.com/)
- [Mongoose Documentation](https://mongoosejs.com/)
- [MongoDB Atlas](https://cloud.mongodb.com/)
- [HTTP Package](https://pub.dev/packages/http)
