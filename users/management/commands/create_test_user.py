from django.core.management.base import BaseCommand
from users.models import UserAccount

class Command(BaseCommand):
    help = 'Create a test user for authentication testing'

    def add_arguments(self, parser):
        parser.add_argument('--username', type=str, default='admin', help='Username for test user')
        parser.add_argument('--password', type=str, default='admin123', help='Password for test user')

    def handle(self, *args, **options):
        username = options['username']
        password = options['password']
        
        # Check if user already exists
        if UserAccount.objects.filter(user_id=username).exists():
            self.stdout.write(
                self.style.WARNING(f'User "{username}" already exists!')
            )
            return
        
        # Create the test user
        user = UserAccount.objects.create(
            user_id=username,
            password=password,
            status=True,
            is_logged_in=False
        )
        
        self.stdout.write(
            self.style.SUCCESS(f'Successfully created test user "{username}" with password "{password}"')
        )
        self.stdout.write(
            self.style.SUCCESS('You can now login with these credentials at /login/')
        )
