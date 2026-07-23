from django.contrib import admin
from django.urls import include, path
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/auth/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("api/v1/", include("game_api.urls")),
]

