#!/bin/bash

echo "🚀 Starting Moodify Development Environment..."

# Start backend server
echo "📦 Starting backend server..."
cd "/Users/bishnukumaryadav/FlutterDev/Flutter Projects/Moodify/backend"
node server.js &
BACKEND_PID=$!

echo "✅ Backend started (PID: $BACKEND_PID)"
echo "⏳ Waiting for backend to initialize..."
sleep 3

# Start Flutter app
echo "📱 Starting Flutter app..."
cd "/Users/bishnukumaryadav/FlutterDev/Flutter Projects/Moodify"
flutter run

# Cleanup when done
kill $BACKEND_PID 2>/dev/null
echo "👋 Stopped all services"
