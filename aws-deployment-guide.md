# 🚀 AWS Deployment Guide for Django Admin Panel

## 📋 Prerequisites

1. **AWS Account** - Create a new AWS account at [aws.amazon.com](https://aws.amazon.com)
2. **AWS CLI** - Install AWS Command Line Interface
3. **EB CLI** - Install Elastic Beanstalk CLI
4. **Domain Name** (Optional) - For custom domain

## 🛠️ Installation Steps

### 1. Install AWS CLI
```bash
# Windows (PowerShell)
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# macOS
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### 2. Install EB CLI
```bash
pip install awsebcli
```

### 3. Configure AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your default region (e.g., us-east-1)
# Enter your output format (json)
```

## 🚀 Deployment Options

### Option 1: Elastic Beanstalk (Recommended)

#### Step 1: Initialize EB Application
```bash
eb init
# Choose your region
# Choose Python platform
# Choose Python version (3.11)
# Set up SSH (optional)
```

#### Step 2: Create Environment
```bash
eb create production
# Choose environment type (LoadBalanced)
# Choose instance type (t3.micro for free tier)
# Wait for environment creation
```

#### Step 3: Deploy
```bash
eb deploy
```

### Option 2: EC2 with Docker

#### Step 1: Launch EC2 Instance
- Choose Amazon Linux 2 AMI
- Instance type: t3.micro (free tier)
- Configure Security Group (open ports 22, 80, 443)
- Launch and connect via SSH

#### Step 2: Install Docker
```bash
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### Step 3: Deploy Application
```bash
git clone <your-repo>
cd internet_art_login
docker-compose up -d
```

## 🗄️ Database Setup

### Option 1: RDS PostgreSQL
1. Create RDS instance in AWS Console
2. Choose PostgreSQL engine
3. Configure security groups
4. Update DATABASE_URL in environment variables

### Option 2: Use SQLite (Development Only)
- Keep current SQLite setup for development
- Switch to PostgreSQL for production

## 🔐 Environment Variables

Set these in your EB environment or .env file:

```bash
SECRET_KEY=your-super-secret-key
DEBUG=False
ALLOWED_HOSTS=your-eb-url.elasticbeanstalk.com
DATABASE_URL=postgresql://username:password@host:port/database
```

## 🌐 Custom Domain (Optional)

1. **Route 53 Setup**
   - Create hosted zone
   - Add A record pointing to your EB environment

2. **SSL Certificate**
   - Request certificate in AWS Certificate Manager
   - Attach to your EB environment

## 📊 Monitoring & Scaling

1. **CloudWatch** - Monitor application metrics
2. **Auto Scaling** - Configure scaling policies
3. **Load Balancer** - Distribute traffic

## 🔍 Troubleshooting

### Common Issues:
1. **Static Files Not Loading**
   - Run `python manage.py collectstatic`
   - Check STATIC_ROOT configuration

2. **Database Connection Issues**
   - Verify DATABASE_URL format
   - Check security group rules

3. **Permission Errors**
   - Ensure proper IAM roles
   - Check file permissions

## 📱 Access Your Admin Panel

After deployment:
- **Admin URL**: `https://your-eb-url.elasticbeanstalk.com/admin/`
- **Default Superuser**: `admin` / `admin123`
- **Change password immediately after first login!**

## 💰 Cost Optimization

- Use t3.micro instances (free tier eligible)
- Enable auto-scaling based on demand
- Use S3 for static file storage
- Monitor CloudWatch metrics

## 🆘 Support

- AWS Documentation: [docs.aws.amazon.com](https://docs.aws.amazon.com)
- Django Documentation: [docs.djangoproject.com](https://docs.djangoproject.com)
- AWS Support: Available with paid plans

---

**Happy Deploying! 🎉**
