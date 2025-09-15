"""
API Views for AI Mailer Pro Integration
Handles connection issues and provides stable endpoints
"""
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.utils import timezone
from django.contrib.sessions.models import Session
import json
import logging

from users.models import UserAccount
from .models import UserSession

# Setup logging
logger = logging.getLogger(__name__)

@csrf_exempt
@require_http_methods(["POST"])
def api_login(request):
    """
    API endpoint for AI Mailer Pro login
    Returns JSON response to avoid redirect issues
    """
    try:
        # Get data from request
        if request.content_type == 'application/json':
            data = json.loads(request.body)
            username = data.get('username', '').strip()
            password = data.get('password', '').strip()
        else:
            username = request.POST.get('username', '').strip()
            password = request.POST.get('password', '').strip()
        
        logger.info(f"API Login attempt: username={username}")
        
        if not username or not password:
            return JsonResponse({
                'success': False,
                'error': 'Username and password are required',
                'code': 'MISSING_CREDENTIALS'
            }, status=400)
        
        try:
            # Check if user exists
            user_account = UserAccount.objects.get(user_id=username)
            
            # Check if user is active
            if not user_account.status:
                return JsonResponse({
                    'success': False,
                    'error': 'Account is disabled',
                    'code': 'ACCOUNT_DISABLED'
                }, status=403)
            
            # Enforce single session
            if user_account.is_logged_in and user_account.current_session:
                logger.warning(f"API Login blocked - already logged in elsewhere: {username}")
                return JsonResponse({
                    'success': False,
                    'error': 'User already logged in elsewhere',
                    'code': 'ALREADY_LOGGED_IN'
                }, status=409)
            
            # Check password
            if user_account.password == password:
                # Update login info
                user_account.is_logged_in = True
                user_account.last_login = timezone.now()
                user_account.device_ip = request.META.get('REMOTE_ADDR')
                # Use session_key as logical session id for API caller context
                user_account.current_session = request.session.session_key or 'api'
                user_account.session_key = user_account.current_session
                user_account.save()
                
                # Create session tracking record
                UserSession.objects.create(
                    user_account=user_account,
                    ip_address=request.META.get('REMOTE_ADDR'),
                    user_agent=request.META.get('HTTP_USER_AGENT', '')
                )
                
                # Store in session
                request.session['user_id'] = user_account.user_id
                request.session['user_status'] = user_account.status
                request.session.save()
                
                logger.info(f"API Login successful: {username}")
                
                return JsonResponse({
                    'success': True,
                    'message': 'Login successful',
                    'user': {
                        'id': user_account.user_id,
                        'status': user_account.status,
                        'last_login': user_account.last_login.isoformat() if user_account.last_login else None
                    },
                    'session_id': request.session.session_key
                })
            else:
                logger.warning(f"API Login failed - wrong password: {username}")
                return JsonResponse({
                    'success': False,
                    'error': 'Invalid username or password',
                    'code': 'INVALID_CREDENTIALS'
                }, status=401)
                
        except UserAccount.DoesNotExist:
            logger.warning(f"API Login failed - user not found: {username}")
            return JsonResponse({
                'success': False,
                'error': 'Invalid username or password',
                'code': 'USER_NOT_FOUND'
            }, status=401)
            
    except json.JSONDecodeError:
        return JsonResponse({
            'success': False,
            'error': 'Invalid JSON data',
            'code': 'INVALID_JSON'
        }, status=400)
    except Exception as e:
        logger.error(f"API Login error: {e}")
        return JsonResponse({
            'success': False,
            'error': 'Internal server error',
            'code': 'SERVER_ERROR'
        }, status=500)

@csrf_exempt
@require_http_methods(["GET", "POST"])
def api_status(request):
    """
    API endpoint to check login status
    """
    try:
        user_id = request.session.get('user_id')
        if not user_id:
            return JsonResponse({
                'success': False,
                'authenticated': False,
                'message': 'Not logged in'
            })
        
        try:
            user_account = UserAccount.objects.get(user_id=user_id)
            if not user_account.status:
                return JsonResponse({
                    'success': False,
                    'authenticated': False,
                    'message': 'Account disabled'
                })
            
            return JsonResponse({
                'success': True,
                'authenticated': True,
                'user': {
                    'id': user_account.user_id,
                    'status': user_account.status,
                    'last_login': user_account.last_login.isoformat() if user_account.last_login else None
                }
            })
            
        except UserAccount.DoesNotExist:
            return JsonResponse({
                'success': False,
                'authenticated': False,
                'message': 'User not found'
            })
            
    except Exception as e:
        logger.error(f"API Status error: {e}")
        return JsonResponse({
            'success': False,
            'error': 'Internal server error'
        }, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def api_logout(request):
    """
    API endpoint for logout
    """
    try:
        user_id = request.session.get('user_id')
        if user_id:
            try:
                user_account = UserAccount.objects.get(user_id=user_id)
                user_account.is_logged_in = False
                user_account.current_session = None
                user_account.session_key = None
                user_account.save()
                
                # End current session
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
        
        return JsonResponse({
            'success': True,
            'message': 'Logged out successfully'
        })
        
    except Exception as e:
        logger.error(f"API Logout error: {e}")
        return JsonResponse({
            'success': False,
            'error': 'Internal server error'
        }, status=500)

@csrf_exempt
@require_http_methods(["GET"])
def api_health(request):
    """
    Health check endpoint
    """
    try:
        # Check database connection
        user_count = UserAccount.objects.count()
        
        return JsonResponse({
            'success': True,
            'status': 'healthy',
            'database': 'connected',
            'user_count': user_count,
            'timestamp': timezone.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Health check error: {e}")
        return JsonResponse({
            'success': False,
            'status': 'unhealthy',
            'error': str(e)
        }, status=500)
