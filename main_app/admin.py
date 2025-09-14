from django.contrib import admin
from .models import UserSession

@admin.register(UserSession)
class UserSessionAdmin(admin.ModelAdmin):
    list_display = ('user_account', 'session_start', 'session_end', 'ip_address')
    list_filter = ('session_start', 'session_end', 'ip_address')
    search_fields = ('user_account__user_id', 'ip_address')
    readonly_fields = ('session_start', 'ip_address', 'user_agent')
    
    def get_queryset(self, request):
        return super().get_queryset(request).select_related('user_account')
