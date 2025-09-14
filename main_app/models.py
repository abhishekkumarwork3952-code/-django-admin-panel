from django.db import models
from users.models import UserAccount

class UserSession(models.Model):
    """Track user sessions for the main app"""
    user_account = models.ForeignKey(UserAccount, on_delete=models.CASCADE)
    session_start = models.DateTimeField(auto_now_add=True)
    session_end = models.DateTimeField(null=True, blank=True)
    ip_address = models.GenericIPAddressField()
    user_agent = models.TextField(blank=True)
    
    def __str__(self):
        return f"{self.user_account.user_id} - {self.session_start}"
