from django.urls import path
from . import views
from django.shortcuts import redirect
from rest_framework_simplejwt.views import TokenRefreshView
from .auth import SingleSessionTokenObtainPairView

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
    # JWT + API endpoints
    path('api/token/', SingleSessionTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/me/', views.api_me, name='api_me'),
    path('api/users/<int:user_id>/presence/', views.api_user_presence, name='api_user_presence'),
]
