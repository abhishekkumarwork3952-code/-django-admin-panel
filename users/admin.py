from django.contrib import admin
from .models import UserAccount

@admin.register(UserAccount)
class UserAccountAdmin(admin.ModelAdmin):
    list_display = ('user_id','status','is_logged_in','device_ip','last_login')
    search_fields = ('user_id',)
