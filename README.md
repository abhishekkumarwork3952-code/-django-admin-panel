# 🌐 Internet Art Tools - Admin Panel

A powerful Django-based admin panel for managing user accounts and internet art tools.

## ✨ Features

- **User Management** - Complete user account administration
- **Login Tracking** - Monitor user login status and device IPs
- **Admin Interface** - Django admin panel for easy management
- **Responsive Design** - Modern, mobile-friendly interface
- **Security** - Built-in authentication and authorization

## 🚀 Quick Start

### Local Development
```bash
# Clone the repository
git clone <your-repo-url>
cd internet_art_login

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Start development server
python manage.py runserver
```

### Access Admin Panel
- **URL**: http://127.0.0.1:8000/admin/
- **Login**: Use your superuser credentials

## 🐳 Docker Development
```bash
# Start with Docker Compose
docker-compose up -d

# Access at http://localhost:8000
```

## ☁️ AWS Deployment

### Prerequisites
1. AWS Account
2. AWS CLI installed
3. EB CLI installed

### Quick Deployment (Windows)
```powershell
# Run the deployment script
.\deploy-aws.ps1
```

### Manual Deployment
```bash
# Install EB CLI
pip install awsebcli

# Initialize EB
eb init

# Create environment
eb create production

# Deploy
eb deploy
```

## 📁 Project Structure

```
internet_art_login/
├── internet_art_tools/     # Main Django project
├── users/                  # User management app
├── .ebextensions/         # AWS EB configuration
├── staticfiles/           # Collected static files
├── manage.py              # Django management script
├── requirements.txt       # Python dependencies
├── Dockerfile            # Docker configuration
├── docker-compose.yml    # Docker Compose setup
└── aws-deployment-guide.md # Complete deployment guide
```

## 🔧 Configuration

### Environment Variables
- `SECRET_KEY` - Django secret key
- `DEBUG` - Debug mode (False for production)
- `ALLOWED_HOSTS` - Allowed hostnames
- `DATABASE_URL` - Database connection string

### Database
- **Development**: SQLite3
- **Production**: PostgreSQL (RDS)

## 📊 Admin Models

### UserAccount
- `user_id` - Unique user identifier
- `password` - User password (encrypted)
- `status` - Active/inactive status
- `is_logged_in` - Current login state
- `device_ip` - Device IP address
- `last_login` - Last login timestamp

## 🛡️ Security Features

- CSRF protection
- XSS filtering
- HSTS headers
- Secure cookies
- Password validation

## 📱 API Endpoints

- `/admin/` - Django admin interface
- `/login/` - User login
- `/logout/` - User logout
- `/dashboard/` - User dashboard

## 🔍 Monitoring

- CloudWatch integration
- Application metrics
- Error logging
- Performance monitoring

## 💰 Cost Optimization

- Free tier eligible instances
- Auto-scaling policies
- S3 for static storage
- CloudFront CDN (optional)

## 🆘 Support

- **Documentation**: See `aws-deployment-guide.md`
- **Issues**: Check common problems in deployment guide
- **AWS Support**: Available with paid plans

## 📄 License

This project is licensed under the MIT License.

---

**Built with ❤️ using Django and AWS**
