from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.utils import timezone
from .models import UserAccount

def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            return redirect('dashboard')
        messages.error(request, 'Invalid username or password')
        return redirect('login')
    return render(request, 'users/login.html')

@login_required
def dashboard(request):
    users = UserAccount.objects.all().order_by('user_id')
    msg = request.GET.get('msg')
    return render(request, 'users/dashboard.html', {'users': users, 'msg': msg})

@login_required
def logout_view(request):
    logout(request)
    return redirect('login')

@login_required
def create_user(request):
    if request.method == 'POST':
        uid = request.POST.get('user_id')
        pwd = request.POST.get('password')
        if uid and pwd:
            UserAccount.objects.create(user_id=uid, password=pwd, status=True)
            return redirect('/dashboard/?msg=User+created')
    return redirect('/dashboard/?msg=Missing+fields')

@login_required
def enable_user(request, user_id):
    u = get_object_or_404(UserAccount, user_id=user_id)
    u.status = True
    u.save()
    return redirect('/dashboard/?msg=Enabled')

@login_required
def disable_user(request, user_id):
    u = get_object_or_404(UserAccount, user_id=user_id)
    u.status = False
    u.save()
    return redirect('/dashboard/?msg=Disabled')

@login_required
def delete_user(request, user_id):
    u = get_object_or_404(UserAccount, user_id=user_id)
    u.delete()
    return redirect('/dashboard/?msg=Deleted')
