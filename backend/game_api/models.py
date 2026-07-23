from django.contrib.auth.models import User
from django.db import models


class PlayerProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="game_profile")
    display_name = models.CharField(max_length=80)
    google_sub = models.CharField(max_length=255, unique=True, null=True, blank=True)
    deletion_requested_at = models.DateTimeField(null=True, blank=True)
    last_seen_at = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.display_name


class CloudSave(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="game_save")
    save_json = models.JSONField(default=dict)
    revision = models.PositiveIntegerField(default=1)
    updated_at = models.DateTimeField(auto_now=True)


class EndlessScore(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="endless_score")
    display_name = models.CharField(max_length=80)
    best_distance_m = models.PositiveIntegerField(default=0)
    updated_at = models.DateTimeField(auto_now=True)


class WeeklyScore(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="weekly_scores")
    week_key = models.CharField(max_length=20)
    display_name = models.CharField(max_length=80)
    best_distance_m = models.PositiveIntegerField(default=0)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [models.UniqueConstraint(fields=("user", "week_key"), name="unique_weekly_player")]
        indexes = [models.Index(fields=("week_key", "-best_distance_m"), name="game_api_we_week_ke_4d2420_idx")]


class GameEvent(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name="game_events")
    event_name = models.CharField(max_length=80)
    event_data = models.JSONField(default=dict, blank=True)
    session_id = models.CharField(max_length=80, blank=True)
    device_id = models.CharField(max_length=120, blank=True)
    app_version = models.CharField(max_length=40, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [
            models.Index(fields=("event_name", "-created_at"), name="game_api_ga_event_n_245ee2_idx"),
            models.Index(fields=("user", "-created_at"), name="game_api_ga_user_id_f320c3_idx"),
        ]


class GoogleLoginAttempt(models.Model):
    state = models.CharField(max_length=100, unique=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    completed_at = models.DateTimeField(null=True, blank=True)
    consumed_at = models.DateTimeField(null=True, blank=True)
