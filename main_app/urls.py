from django.urls import path
from . import views
from . import api_views

app_name = 'main_app'

urlpatterns = [
    # Web views
    path('', views.main_login, name='main_login'),
    path('login/', views.main_login, name='main_login'),
    path('dashboard/', views.main_dashboard, name='main_dashboard'),
    path('logout/', views.main_logout, name='main_logout'),
    
    # API endpoints for AI Mailer Pro
    path('api/login/', api_views.api_login, name='api_login'),
    path('api/status/', api_views.api_status, name='api_status'),
    path('api/logout/', api_views.api_logout, name='api_logout'),
    path('api/health/', api_views.api_health, name='api_health'),
]
