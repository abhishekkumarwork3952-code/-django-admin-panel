from django.shortcuts import render, redirect
from django.contrib import messages
from django.utils import timezone
from users.models import UserAccount
from .models import UserSession

def main_login(request):
    """Main app login view - uses same UserAccount model"""
    # Check if user is already logged in
    if request.session.get('user_id'):
        return redirect('main_app:main_dashboard')
    
    if request.method == 'POST':
        username = request.POST.get('username', '').strip()
        password = request.POST.get('password', '').strip()
        
        # Debug: Print received credentials
        print(f"🔍 Main App Login Attempt: username={username}, password={'*' * len(password)}")
        
        if not username or not password:
            messages.error(request, 'Please enter both username and password')
            return render(request, 'main_app/login.html')
        
        try:
            # Check if user exists in UserAccount model (same as admin panel)
            user_account = UserAccount.objects.get(user_id=username)
            print(f"✅ User found: {user_account.user_id}, status: {user_account.status}")
            
            # Check if user is active
            if not user_account.status:
                messages.error(request, 'Account is disabled. Please contact administrator.')
                return render(request, 'main_app/login.html')
            
            # Check password (same logic as admin panel)
            if user_account.password == password:
                # Update UserAccount with login info
                user_account.is_logged_in = True
                user_account.last_login = timezone.now()
                user_account.device_ip = request.META.get('REMOTE_ADDR')
                user_account.save()
                
                # Create UserSession for main app
                UserSession.objects.create(
                    user_account=user_account,
                    ip_address=request.META.get('REMOTE_ADDR'),
                    user_agent=request.META.get('HTTP_USER_AGENT', '')
                )
                
                # Store user info in session
                request.session['user_id'] = user_account.user_id
                request.session['user_status'] = user_account.status
                request.session.save()  # Ensure session is saved
                
                print(f"✅ Login successful for user: {username}")
                messages.success(request, f'Welcome back, {username}!')
                return redirect('main_app:main_dashboard')
            else:
                print(f"❌ Password mismatch for user: {username}")
                messages.error(request, 'Invalid username or password')
                return render(request, 'main_app/login.html')
                
        except UserAccount.DoesNotExist:
            print(f"❌ User not found: {username}")
            # Debug: Show all users in database
            all_users = UserAccount.objects.all()
            print(f"📊 Total users in database: {all_users.count()}")
            for user in all_users:
                print(f"   - {user.user_id} (status: {user.status})")
            
            messages.error(request, 'Invalid username or password')
            return render(request, 'main_app/login.html')
        except Exception as e:
            print(f"❌ Login error: {e}")
            messages.error(request, 'Login failed. Please try again.')
            return render(request, 'main_app/login.html')
            
    return render(request, 'main_app/login.html')

def main_dashboard(request):
    """Main app dashboard - only accessible after login"""
    user_id = request.session.get('user_id')
    if not user_id:
        messages.error(request, 'Please login first')
        return redirect('main_app:main_login')
    
    try:
        user_account = UserAccount.objects.get(user_id=user_id)
        if not user_account.status:
            messages.error(request, 'Account is disabled')
            del request.session['user_id']
            return redirect('main_app:main_login')
            
        # Get user's session info
        user_session = UserSession.objects.filter(
            user_account=user_account
        ).order_by('-session_start').first()
        
        context = {
            'user': user_account,
            'session': user_session,
            'login_time': user_account.last_login
        }
        return render(request, 'main_app/dashboard.html', context)
        
    except UserAccount.DoesNotExist:
        messages.error(request, 'User not found')
        del request.session['user_id']
        return redirect('main_app:main_login')

def main_logout(request):
    """Main app logout"""
    user_id = request.session.get('user_id')
    if user_id:
        try:
            user_account = UserAccount.objects.get(user_id=user_id)
            user_account.is_logged_in = False
            user_account.save()
            
            # End the current session
            current_session = UserSession.objects.filter(
                user_account=user_account,
                session_end__isnull=True
            ).order_by('-session_start').first()
            
            if current_session:
                current_session.session_end = timezone.now()
                current_session.save()
                
        except UserAccount.DoesNotExist:
            pass
    
    # Clear session
    request.session.flush()
    messages.success(request, 'Successfully logged out')
    return redirect('main_app:main_login')
