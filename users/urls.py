from django.urls import path
from . import views
from django.shortcuts import redirect

urlpatterns = [
    path('', lambda request: redirect('login'), name='root'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('dashboard/', views.dashboard, name='dashboard'),
    path('create/', views.create_user, name='create_user'),
    path('enable/<str:user_id>/', views.enable_user, name='enable_user'),
    path('disable/<str:user_id>/', views.disable_user, name='disable_user'),
    path('delete/<str:user_id>/', views.delete_user, name='delete_user'),
    # API endpoint for AI Mailer Pro automatic logout
    path('api/logout/', views.api_logout_user, name='api_logout'),
]
