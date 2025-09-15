#!/bin/bash

# Django Auto-Restart Monitor
echo "🔍 Django Auto-Restart Monitor Starting..."

# Function to start Django
start_django() {
    echo "🚀 Starting Django server..."
    cd /home/ec2-user/-django-admin-panel
    
    # Kill any existing processes
    pkill -f "python3 manage.py runserver"
    sudo fuser -k 8000/tcp 2>/dev/null
    
    # Start Django server
    nohup python3 manage.py runserver 0.0.0.0:8000 > django.log 2>&1 &
    
    # Wait and check if started successfully
    sleep 5
    if pgrep -f "python3 manage.py runserver" > /dev/null; then
        echo "✅ Django started successfully at $(date)"
        return 0
    else
        echo "❌ Django failed to start at $(date)"
        return 1
    fi
}

# Initial start
start_django

# Monitor loop
while true; do
    # Check if Django process is running
    if ! pgrep -f "python3 manage.py runserver" > /dev/null; then
        echo "⚠️ Django process not found. Restarting at $(date)..."
        start_django
    else
        # Check if Django is responding
        if ! curl -s http://localhost:8000 > /dev/null; then
            echo "⚠️ Django not responding. Restarting at $(date)..."
            start_django
        else
            echo "✅ Django is running and responding at $(date)"
        fi
    fi
    
    # Wait 30 seconds before next check
    sleep 30
done
