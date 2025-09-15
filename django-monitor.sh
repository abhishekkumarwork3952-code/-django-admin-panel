#!/bin/bash

# Django Process Monitor Script
# This will automatically restart Django if it crashes

echo "🔍 Django Process Monitor Starting..."

while true; do
    # Check if Django process is running
    if ! pgrep -f "python3 manage.py runserver" > /dev/null; then
        echo "⚠️ Django process not found. Restarting..."
        
        # Kill any existing processes
        pkill -f "python3 manage.py runserver"
        
        # Start Django server
        cd /home/ec2-user/-django-admin-panel
        nohup python3 manage.py runserver 0.0.0.0:8000 > django.log 2>&1 &
        
        echo "✅ Django restarted at $(date)"
    else
        echo "✅ Django is running at $(date)"
    fi
    
    # Wait 30 seconds before next check
    sleep 30
done
