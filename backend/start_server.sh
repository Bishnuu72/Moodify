#!/bin/bash

# Moodify Backend Startup Script

echo "🚀 Starting Moodify Backend Server..."
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found!"
    echo "Please create a .env file with the required configuration."
    exit 1
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Start the server
echo "⚙️  Starting server on port 5001..."
node server.js
