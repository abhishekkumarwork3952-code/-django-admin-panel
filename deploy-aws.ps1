# AWS Deployment Script for Windows PowerShell
# Deploy your Django Admin Panel to AWS

Write-Host "🚀 Starting AWS Deployment for Django Admin Panel..." -ForegroundColor Green

# Check if Python is installed
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Python not found. Please install Python first." -ForegroundColor Red
    exit 1
}

# Check if pip is installed
if (!(Get-Command pip -ErrorAction SilentlyContinue)) {
    Write-Host "❌ pip not found. Please install pip first." -ForegroundColor Red
    exit 1
}

# Install required packages
Write-Host "📦 Installing required packages..." -ForegroundColor Yellow
pip install -r requirements.txt

# Collect static files
Write-Host "📁 Collecting static files..." -ForegroundColor Yellow
python manage.py collectstatic --noinput

# Check if AWS CLI is installed
if (!(Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "❌ AWS CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "   Download from: https://awscli.amazonaws.com/AWSCLIV2.msi" -ForegroundColor Yellow
    Write-Host "   After installation, run: aws configure" -ForegroundColor Yellow
    exit 1
}

# Check if EB CLI is installed
if (!(Get-Command eb -ErrorAction SilentlyContinue)) {
    Write-Host "📥 Installing EB CLI..." -ForegroundColor Yellow
    pip install awsebcli
}

Write-Host "✅ Prerequisites check passed!" -ForegroundColor Green

# Initialize Elastic Beanstalk (if not already done)
if (!(Test-Path ".ebextensions")) {
    Write-Host "🌱 Initializing Elastic Beanstalk..." -ForegroundColor Yellow
    eb init
}

# Deploy to Elastic Beanstalk
Write-Host "🚀 Deploying to Elastic Beanstalk..." -ForegroundColor Yellow
eb deploy

Write-Host "✅ Deployment completed!" -ForegroundColor Green
Write-Host "🌐 Your admin panel should be available at the EB URL" -ForegroundColor Cyan
Write-Host "🔐 Default superuser: admin / admin123" -ForegroundColor Cyan
Write-Host "⚠️  Remember to change the default password!" -ForegroundColor Red

# Pause to see the output
Read-Host "Press Enter to continue..."
