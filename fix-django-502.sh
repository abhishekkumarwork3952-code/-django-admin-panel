#!/bin/bash

# Quick Fix for Django 502 Error
echo "🔧 Fixing Django 502 Error..."

# Kill all existing Django processes
echo "🔄 Killing existing Django processes..."
pkill -f "python3 manage.py runserver"
sleep 2

# Check if port 8000 is free
if netstat -tlnp | grep :8000 > /dev/null; then
    echo "⚠️ Port 8000 still in use. Force killing..."
    sudo fuser -k 8000/tcp
    sleep 2
fi

# Navigate to Django directory
cd /home/ec2-user/-django-admin-panel

# Start Django server in background
echo "🚀 Starting Django server..."
nohup python3 manage.py runserver 0.0.0.0:8000 > django.log 2>&1 &

# Wait a moment
sleep 3

# Check if Django is running
if pgrep -f "python3 manage.py runserver" > /dev/null; then
    echo "✅ Django server started successfully!"
    echo "📊 Process ID: $(pgrep -f 'python3 manage.py runserver')"
    echo "📋 Logs: tail -f django.log"
else
    echo "❌ Failed to start Django server"
    echo "📋 Check logs: cat django.log"
fi

# Test the server
echo "🧪 Testing server..."
if curl -s http://localhost:8000 > /dev/null; then
    echo "✅ Server is responding!"
else
    echo "❌ Server is not responding"
fi
