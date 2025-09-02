#!/bin/bash

# AWS Deployment Script for Django Admin Panel
# This script helps deploy your Django app to AWS

echo "🚀 Starting AWS Deployment for Django Admin Panel..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it first:"
    echo "   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Check if EB CLI is installed
if ! command -v eb &> /dev/null; then
    echo "❌ EB CLI not found. Please install it first:"
    echo "   pip install awsebcli"
    exit 1
fi

echo "✅ Prerequisites check passed!"

# Collect static files
echo "📦 Collecting static files..."
python manage.py collectstatic --noinput

# Create requirements.txt for production
echo "📋 Updating requirements.txt..."
pip freeze > requirements.txt

# Initialize Elastic Beanstalk (if not already done)
if [ ! -d ".ebextensions" ]; then
    echo "🌱 Initializing Elastic Beanstalk..."
    eb init
fi

# Deploy to Elastic Beanstalk
echo "🚀 Deploying to Elastic Beanstalk..."
eb deploy

echo "✅ Deployment completed!"
echo "🌐 Your admin panel should be available at the EB URL"
echo "🔐 Don't forget to create a superuser: python manage.py createsuperuser"
