from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    initial = True
    dependencies = [migrations.swappable_dependency(settings.AUTH_USER_MODEL)]
    operations = [
        migrations.CreateModel(
            name="PlayerProfile",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("display_name", models.CharField(max_length=80)),
                ("google_sub", models.CharField(blank=True, max_length=255, null=True, unique=True)),
                ("deletion_requested_at", models.DateTimeField(blank=True, null=True)),
                ("last_seen_at", models.DateTimeField(auto_now=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("user", models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name="game_profile", to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name="CloudSave",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("save_json", models.JSONField(default=dict)),
                ("revision", models.PositiveIntegerField(default=1)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("user", models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name="game_save", to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name="EndlessScore",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("display_name", models.CharField(max_length=80)),
                ("best_distance_m", models.PositiveIntegerField(default=0)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("user", models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name="endless_score", to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name="GoogleLoginAttempt",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("state", models.CharField(max_length=100, unique=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("expires_at", models.DateTimeField()),
                ("completed_at", models.DateTimeField(blank=True, null=True)),
                ("consumed_at", models.DateTimeField(blank=True, null=True)),
                ("user", models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name="WeeklyScore",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("week_key", models.CharField(max_length=20)),
                ("display_name", models.CharField(max_length=80)),
                ("best_distance_m", models.PositiveIntegerField(default=0)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("user", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="weekly_scores", to=settings.AUTH_USER_MODEL)),
            ],
            options={"indexes": [models.Index(fields=["week_key", "-best_distance_m"], name="game_api_we_week_ke_4d2420_idx")]},
        ),
        migrations.AddConstraint(
            model_name="weeklyscore",
            constraint=models.UniqueConstraint(fields=("user", "week_key"), name="unique_weekly_player"),
        ),
        migrations.CreateModel(
            name="GameEvent",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("event_name", models.CharField(max_length=80)),
                ("event_data", models.JSONField(blank=True, default=dict)),
                ("session_id", models.CharField(blank=True, max_length=80)),
                ("device_id", models.CharField(blank=True, max_length=120)),
                ("app_version", models.CharField(blank=True, max_length=40)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("user", models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name="game_events", to=settings.AUTH_USER_MODEL)),
            ],
            options={"indexes": [
                models.Index(fields=["event_name", "-created_at"], name="game_api_ga_event_n_245ee2_idx"),
                models.Index(fields=["user", "-created_at"], name="game_api_ga_user_id_f320c3_idx"),
            ]},
        ),
    ]

