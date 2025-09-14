from django.contrib.auth import logout
from .models import UserAccount

class SessionManagementMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Check if user is authenticated
        if request.user.is_authenticated:
            try:
                # Get user account
                user_account = UserAccount.objects.get(user_id=request.user.username)
                
                # Check if current session matches stored session
                if user_account.current_session != request.session.session_key:
                    # Session mismatch - logout user
                    logout(request)
                    user_account.is_logged_in = False
                    user_account.current_session = None
                    user_account.save()
                    
            except UserAccount.DoesNotExist:
                # User account not found - logout
                logout(request)
        
        response = self.get_response(request)
        return response
