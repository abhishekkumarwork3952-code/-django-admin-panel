from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import login, logout
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.utils import timezone
from django.contrib.auth.models import User
from .models import UserAccount

def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        
        print(f"DEBUG: Login attempt for username: {username}")
        
        try:
            # Check if user exists in UserAccount model
            user_account = UserAccount.objects.get(user_id=username)
            print(f"DEBUG: User account found: {user_account.user_id}")
            
            # Check if user is active
            if not user_account.status:
                print("DEBUG: User account is disabled")
                messages.error(request, 'Account is disabled. Please contact administrator.')
                return redirect('login')
            
            # Check if user is already logged in (single session enforcement)
            if user_account.is_logged_in and user_account.current_session:
                print("DEBUG: User already logged in from another session")
                messages.error(request, 'User is already logged in from another session. Please logout first.')
                return redirect('login')
            
            # Check password (simple comparison for demo)
            if user_account.password == password:
                print("DEBUG: Password matches")
                
                # Create or get Django User for session management
                django_user, created = User.objects.get_or_create(
                    username=username,
                    defaults={'email': f'{username}@example.com'}
                )
                print(f"DEBUG: Django user created: {created}, username: {django_user.username}")
                
                # Always set password for Django user to match UserAccount
                django_user.set_password(password)
                django_user.save()
                print("DEBUG: Django user password set")
                
                # Login the Django user for session management
                login(request, django_user)
                print(f"DEBUG: Django login called, user authenticated: {request.user.is_authenticated}")
                
                # Update UserAccount with login info and session tracking
                user_account.is_logged_in = True
                user_account.last_login = timezone.now()
                
                # Get real IP from Nginx headers
                x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
                if x_forwarded_for:
                    user_account.device_ip = x_forwarded_for.split(',')[0]
                else:
                    user_account.device_ip = request.META.get('REMOTE_ADDR')
                
                user_account.current_session = request.session.session_key
                user_account.session_key = request.session.session_key
                user_account.save()
                print(f"DEBUG: UserAccount updated, session key: {request.session.session_key}")
                
                # Debug: Check if user is authenticated after login
                if request.user.is_authenticated:
                    print("DEBUG: User is authenticated, redirecting to dashboard")
                    return redirect('dashboard')
                else:
                    print("DEBUG: User not authenticated after login")
                    messages.error(request, 'Authentication failed. Please try again.')
                    return redirect('login')
            else:
                print("DEBUG: Password does not match")
                messages.error(request, 'Invalid username or password')
                return redirect('login')
                
        except UserAccount.DoesNotExist:
            print(f"DEBUG: User account not found: {username}")
            messages.error(request, 'Invalid username or password')
            return redirect('login')
            
    return render(request, 'users/login.html')

@login_required
def dashboard(request):
    users = UserAccount.objects.all().order_by('user_id')
    msg = request.GET.get('msg')
    return render(request, 'users/dashboard.html', {'users': users, 'msg': msg})

@login_required
def logout_view(request):
    # Update UserAccount logout info
    try:
        current_user = request.user.username
        user_account = UserAccount.objects.get(user_id=current_user)
        user_account.is_logged_in = False
        user_account.current_session = None
        user_account.session_key = None
        user_account.save()
        print(f"DEBUG: Logout - cleared session for user: {current_user}")
    except Exception as e:
        print(f"DEBUG: Logout error: {e}")
    
    logout(request)
    return redirect('login')

@login_required
def create_user(request):
    if request.method == 'POST':
        uid = request.POST.get('user_id')
        pwd = request.POST.get('password')
        if uid and pwd:
            # Check if user already exists
            if UserAccount.objects.filter(user_id=uid).exists():
                return redirect('/dashboard/?msg=User+already+exists')
            
            UserAccount.objects.create(user_id=uid, password=pwd, status=True)
            return redirect('/dashboard/?msg=User+created')
    return redirect('/dashboard/?msg=Missing+fields')

@login_required
def enable_user(request, user_id):
    u = get_object_or_404(UserAccount, user_id=user_id)
    u.status = True
    u.save()
    return redirect('/dashboard/?msg=Enabled')

@login_required
def disable_user(request, user_id):
    u = get_object_or_404(UserAccount, user_id=user_id)
    u.status = False
    u.save()
    return redirect('/dashboard/?msg=Disabled')

@login_required
def delete_user(request, user_id):
    u = get_object_or_404(UserAccount, user_id=user_id)
    u.delete()
    return redirect('/dashboard/?msg=Deleted')
