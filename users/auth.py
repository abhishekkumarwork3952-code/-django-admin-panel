from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from django.utils import timezone

from .models import UserAccount


class SingleSessionTokenObtainPairView(TokenObtainPairView):
    def post(self, request, *args, **kwargs):
        username = request.data.get('username')
        password = request.data.get('password')

        if not username or not password:
            return Response({'detail': 'username and password required'}, status=status.HTTP_400_BAD_REQUEST)

        # Verify UserAccount exists and active
        try:
            user_account = UserAccount.objects.get(user_id=username)
        except UserAccount.DoesNotExist:
            return Response({'detail': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

        if not user_account.status:
            return Response({'detail': 'Account disabled'}, status=status.HTTP_403_FORBIDDEN)

        # Enforce single session: if already logged in elsewhere, block
        if user_account.is_logged_in and user_account.current_session:
            return Response({'detail': 'User already logged in elsewhere'}, status=status.HTTP_409_CONFLICT)

        # Proceed with default serializer validation
        serializer = self.get_serializer(data=request.data)
        try:
            serializer.is_valid(raise_exception=True)
        except Exception:
            return Response({'detail': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

        data = serializer.validated_data

        # Extract refresh token JTI as the logical session id
        try:
            refresh_obj = RefreshToken(data.get('refresh'))
            logical_session_id = str(refresh_obj.get('jti'))
        except Exception:
            logical_session_id = None

        # Update presence and tracking
        user_account.is_logged_in = True
        user_account.last_login = timezone.now()
        user_account.current_session = logical_session_id or 'jwt'
        user_account.session_key = user_account.current_session
        user_account.save()

        return Response(data, status=status.HTTP_200_OK)
