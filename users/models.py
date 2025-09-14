from django.db import models

class UserAccount(models.Model):
    user_id = models.CharField(max_length=50, unique=True)
    password = models.CharField(max_length=255)  # demo only
    status = models.BooleanField(default=True)
    is_logged_in = models.BooleanField(default=False)
    device_ip = models.GenericIPAddressField(null=True, blank=True)
    last_login = models.DateTimeField(null=True, blank=True)
    current_session = models.CharField(max_length=100, null=True, blank=True)  # Added for session management
    session_key = models.CharField(max_length=100, null=True, blank=True)  # Added for session management

    def __str__(self):
        return self.user_id
