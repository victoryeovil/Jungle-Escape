from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import (
    CloudSaveView,
    DeletionView,
    EndlessLeaderboardView,
    EndlessScoreView,
    EventBatchView,
    GoogleCallbackView,
    GooglePollView,
    GoogleStartView,
    HealthView,
    LoginView,
    ProfileView,
    RegisterView,
    WeeklyLeaderboardView,
    WeeklyScoreView,
)

urlpatterns = [
    path("health/", HealthView.as_view()),
    path("auth/register/", RegisterView.as_view()),
    path("auth/login/", LoginView.as_view()),
    path("auth/refresh/", TokenRefreshView.as_view()),
    path("auth/google/start/", GoogleStartView.as_view()),
    path("auth/google/callback/", GoogleCallbackView.as_view()),
    path("auth/google/poll/<str:state_value>/", GooglePollView.as_view()),
    path("me/", ProfileView.as_view()),
    path("me/deletion/", DeletionView.as_view()),
    path("save/", CloudSaveView.as_view()),
    path("scores/endless/", EndlessScoreView.as_view()),
    path("leaderboards/endless/", EndlessLeaderboardView.as_view()),
    path("scores/weekly/", WeeklyScoreView.as_view()),
    path("leaderboards/weekly/<str:week_key>/", WeeklyLeaderboardView.as_view()),
    path("events/", EventBatchView.as_view()),
]
