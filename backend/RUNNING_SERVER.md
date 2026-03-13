# 🖥️ Running the Backend Server

## Quick Start

### Option 1: Using the Startup Script (Recommended)
```bash
cd backend
./start_server.sh
```

### Option 2: Manual Start
```bash
cd backend
npm install        # Install dependencies (first time only)
node server.js     # Start the server
```

## Expected Output

When the server starts successfully, you should see:
```
⚙️  Starting server on port 5001...
🟢 MongoDB Connected: mongodb+srv://moodify_db:...
✅ Server running on port 5001
📊 Environment: development
```

## Testing the Backend

Once the server is running, test it with:

**Using curl:**
```bash
curl http://localhost:5001/api/health
```

**Expected response:**
```json
{
  "success": true,
  "message": "Moodify API is running",
  "timestamp": "2024-..."
}
```

## Troubleshooting

### ❌ Error: Cannot find module 'express'
**Solution:** Run `npm install` in the backend directory

### ❌ Error: Connection refused to MongoDB
**Solution:** Check your MongoDB Atlas connection string in `.env` file

### ❌ Error: Port 5001 already in use
**Solution:** 
1. Kill the process using port 5001: `lsof -ti:5001 | xargs kill -9`
2. Or change the port in `.env` file

### ❌ Flutter app shows "Connection refused"
**Solutions:**
1. Make sure the backend server is running
2. Verify the port matches (default: 5001)
3. For Android emulator, use `http://10.0.2.2:5001`
4. For iOS simulator, use `http://localhost:5001`

## API Endpoints

### User Routes (`/api/users`)
- `POST /register` - Register new user
- `POST /login` - Login user
- `GET /:userId` - Get user profile
- `PUT /:userId` - Update user profile
- `DELETE /:userId` - Delete user
- `PUT /:userId/suspend` - Suspend user
- `PUT /:userId/unsuspend` - Unsuspend user

### Mood Routes (`/api/moods`)
- `GET /user/:userId` - Get user's moods
- `POST /` - Create mood
- `GET /:id` - Get specific mood
- `PUT /:id` - Update mood
- `DELETE /:id` - Delete mood
- `GET /stats/:userId` - Get mood statistics

### Wellness Routes (`/api/wellness`)
- `GET /` - Get all wellness activities
- `GET /:id` - Get specific activity
- `POST /` - Create activity (admin)
- `PUT /:id` - Update activity (admin)
- `DELETE /:id` - Delete activity (admin)
- `GET /admin/:adminId` - Get admin's activities

## Keeping the Server Running

The backend server needs to stay running while you develop and test the Flutter app. Keep the terminal window open with the server running in the background.

### Pro Tip: Use a separate terminal
Open a dedicated terminal for the backend:
```bash
cd /Users/bishnukumaryadav/FlutterDev/Flutter\ Projects/Moodify/backend
node server.js
```

Then use another terminal for Flutter:
```bash
flutter run
```
