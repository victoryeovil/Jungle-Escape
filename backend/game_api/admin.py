from django.contrib import admin
from .models import CloudSave, EndlessScore, GameEvent, GoogleLoginAttempt, PlayerProfile, WeeklyScore

admin.site.register([PlayerProfile, CloudSave, EndlessScore, WeeklyScore, GameEvent, GoogleLoginAttempt])

