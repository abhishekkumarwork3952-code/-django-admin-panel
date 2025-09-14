from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('users.urls')),  # Admin panel routes
    path('app/', include('main_app.urls')),  # Main app routes
]
