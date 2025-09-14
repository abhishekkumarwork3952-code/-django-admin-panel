@echo off
REM 🚀 EC2 Connection Fix Upload Script
REM Uploads all fixed files to EC2 to resolve connection issues

echo 🚀 Starting EC2 Connection Fix Upload...
echo ======================================

REM Get EC2 details from user
set /p EC2IP="Enter your EC2 IP address: "
set /p KEYPATH="Enter path to your .pem key file: "
set /p USERNAME="Enter username (default: ec2-user): "

if "%USERNAME%"=="" set USERNAME=ec2-user

echo.
echo 📤 Uploading fixed files to EC2...
echo.

REM Upload main app views (fixed redirect issues)
echo Uploading main_app/views.py (fixed redirects)...
scp -i "%KEYPATH%" "main_app\views.py" "%USERNAME%@%EC2IP%:~/internet_art_login/main_app/"
if %errorlevel% neq 0 (
    echo ❌ Failed to upload main_app/views.py
    pause
    exit /b 1
)
echo ✅ main_app/views.py uploaded successfully

REM Upload new API views (for stable connection)
echo Uploading main_app/api_views.py (new API endpoints)...
scp -i "%KEYPATH%" "main_app\api_views.py" "%USERNAME%@%EC2IP%:~/internet_art_login/main_app/"
if %errorlevel% neq 0 (
    echo ❌ Failed to upload main_app/api_views.py
    pause
    exit /b 1
)
echo ✅ main_app/api_views.py uploaded successfully

REM Upload updated URLs (with API endpoints)
echo Uploading main_app/urls.py (updated with API routes)...
scp -i "%KEYPATH%" "main_app\urls.py" "%USERNAME%@%EC2IP%:~/internet_art_login/main_app/"
if %errorlevel% neq 0 (
    echo ❌ Failed to upload main_app/urls.py
    pause
    exit /b 1
)
echo ✅ main_app/urls.py uploaded successfully

REM Upload updated settings (with logging and session config)
echo Uploading internet_art_tools/settings.py (improved config)...
scp -i "%KEYPATH%" "internet_art_tools\settings.py" "%USERNAME%@%EC2IP%:~/internet_art_login/internet_art_tools/"
if %errorlevel% neq 0 (
    echo ❌ Failed to upload internet_art_tools/settings.py
    pause
    exit /b 1
)
echo ✅ internet_art_tools/settings.py uploaded successfully

REM Upload debug script
echo Uploading ec2_debug_login.py (testing script)...
scp -i "%KEYPATH%" "ec2_debug_login.py" "%USERNAME%@%EC2IP%:~/internet_art_login/"
if %errorlevel% neq 0 (
    echo ❌ Failed to upload ec2_debug_login.py
    pause
    exit /b 1
)
echo ✅ ec2_debug_login.py uploaded successfully

echo.
echo 🎉 All files uploaded successfully!
echo.
echo 📝 Next Steps on EC2:
echo 1. SSH into your EC2 instance:
echo    ssh -i "%KEYPATH%" %USERNAME%@%EC2IP%
echo.
echo 2. Navigate to project directory:
echo    cd internet_art_login
echo.
echo 3. Create logs directory:
echo    mkdir -p logs
echo.
echo 4. Collect static files:
echo    python3 manage.py collectstatic --noinput
echo.
echo 5. Restart services:
echo    sudo systemctl restart nginx
echo    sudo systemctl restart django
echo.
echo 6. Test the fixes:
echo    curl -X POST http://localhost/app/api/login/ -H "Content-Type: application/json" -d "{\"username\":\"testuser\",\"password\":\"testpass123\"}"
echo.
echo 🌐 New API Endpoints for AI Mailer Pro:
echo    POST /app/api/login/     - JSON login (no redirects)
echo    GET  /app/api/status/    - Check login status
echo    POST /app/api/logout/    - Logout
echo    GET  /app/api/health/    - Health check
echo.
echo 🔧 What Was Fixed:
echo    ✅ HTTP 302 redirect errors
echo    ✅ Connection stability issues
echo    ✅ Session management problems
echo    ✅ Added stable API endpoints
echo.
echo 🎯 For AI Mailer Pro:
echo    Use API endpoints instead of web forms
echo    This will eliminate connection issues
echo.
pause
