import json
import re
import secrets
from datetime import timedelta
from urllib.parse import urlencode

import requests
from django.conf import settings
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.db import transaction
from django.http import HttpResponse
from django.utils import timezone
from google.auth.transport import requests as google_auth_requests
from google.oauth2 import id_token
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import CloudSave, EndlessScore, GameEvent, GoogleLoginAttempt, PlayerProfile, WeeklyScore


WEEK_KEY_RE = re.compile(r"^W\d{1,12}$")


def token_payload(user):
    refresh = RefreshToken.for_user(user)
    profile, _ = PlayerProfile.objects.get_or_create(
        user=user,
        defaults={"display_name": user.first_name or user.email.split("@", 1)[0]},
    )
    return {
        "access": str(refresh.access_token),
        "refresh": str(refresh),
        "user": {
            "id": str(user.pk),
            "email": user.email,
            "display_name": profile.display_name,
        },
    }


def request_data(request):
    return request.data if isinstance(request.data, dict) else {}


class HealthView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return Response({"status": "ok", "service": "jungle-escape-api"})


class RegisterView(APIView):
    permission_classes = [AllowAny]

    @transaction.atomic
    def post(self, request):
        data = request_data(request)
        email = str(data.get("email", "")).strip().lower()
        password = str(data.get("password", ""))
        display_name = str(data.get("display_name", "")).strip()[:80]
        if not email or "@" not in email:
            return Response({"error": "Enter a valid email address."}, status=status.HTTP_400_BAD_REQUEST)
        if len(password) < 8:
            return Response({"error": "Password must contain at least 8 characters."}, status=status.HTTP_400_BAD_REQUEST)
        if not display_name:
            return Response({"error": "Display name is required."}, status=status.HTTP_400_BAD_REQUEST)
        if User.objects.filter(username=email).exists():
            return Response({"error": "An account with this email already exists."}, status=status.HTTP_409_CONFLICT)
        user = User.objects.create_user(username=email, email=email, password=password, first_name=display_name)
        PlayerProfile.objects.create(user=user, display_name=display_name)
        return Response(token_payload(user), status=status.HTTP_201_CREATED)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        data = request_data(request)
        email = str(data.get("email", "")).strip().lower()
        user = authenticate(request, username=email, password=str(data.get("password", "")))
        if user is None or not user.is_active:
            return Response({"error": "Invalid email or password."}, status=status.HTTP_401_UNAUTHORIZED)
        return Response(token_payload(user))


class GoogleStartView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        if not settings.GOOGLE_OAUTH2_CLIENT_ID or not settings.GOOGLE_OAUTH2_CLIENT_SECRET:
            return Response({"error": "Google login is not configured."}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        state_value = secrets.token_urlsafe(36)
        GoogleLoginAttempt.objects.create(
            state=state_value,
            expires_at=timezone.now() + timedelta(minutes=10),
        )
        callback = f"{settings.GAME_PUBLIC_URL}/api/v1/auth/google/callback/"
        query = urlencode({
            "client_id": settings.GOOGLE_OAUTH2_CLIENT_ID,
            "redirect_uri": callback,
            "response_type": "code",
            "scope": "openid email profile",
            "state": state_value,
            "prompt": "select_account",
        })
        return Response({
            "state": state_value,
            "authorization_url": f"https://accounts.google.com/o/oauth2/v2/auth?{query}",
            "expires_in": 600,
        })


class GoogleCallbackView(APIView):
    permission_classes = [AllowAny]

    @transaction.atomic
    def get(self, request):
        state_value = request.query_params.get("state", "")
        code = request.query_params.get("code", "")
        attempt = GoogleLoginAttempt.objects.select_for_update().filter(state=state_value).first()
        if not attempt or attempt.expires_at <= timezone.now() or attempt.completed_at:
            return HttpResponse("Google login request expired. Return to the game and try again.", status=400)
        if not code:
            return HttpResponse("Google login was cancelled. Return to the game and try again.", status=400)

        callback = f"{settings.GAME_PUBLIC_URL}/api/v1/auth/google/callback/"
        response = requests.post(
            "https://oauth2.googleapis.com/token",
            data={
                "code": code,
                "client_id": settings.GOOGLE_OAUTH2_CLIENT_ID,
                "client_secret": settings.GOOGLE_OAUTH2_CLIENT_SECRET,
                "redirect_uri": callback,
                "grant_type": "authorization_code",
            },
            timeout=15,
        )
        if not response.ok:
            return HttpResponse("Google login could not be completed. Return to the game and try again.", status=401)
        identity_token = response.json().get("id_token", "")
        try:
            info = id_token.verify_oauth2_token(
                identity_token,
                google_auth_requests.Request(),
                settings.GOOGLE_OAUTH2_CLIENT_ID,
            )
        except ValueError:
            return HttpResponse("Google returned an invalid identity token.", status=401)
        if not info.get("email_verified"):
            return HttpResponse("Your Google email address must be verified.", status=401)

        email = str(info.get("email", "")).strip().lower()
        google_sub = str(info.get("sub", ""))
        display_name = str(info.get("name") or email.split("@", 1)[0])[:80]
        if not email or not google_sub:
            return HttpResponse("Google did not return the required account details.", status=401)

        profile = PlayerProfile.objects.filter(google_sub=google_sub).select_related("user").first()
        if profile:
            user = profile.user
        else:
            user, created = User.objects.get_or_create(
                username=email,
                defaults={"email": email, "first_name": display_name},
            )
            if created:
                user.set_unusable_password()
                user.save(update_fields=("password",))
            profile, _ = PlayerProfile.objects.get_or_create(
                user=user,
                defaults={"display_name": display_name},
            )
            if profile.google_sub and profile.google_sub != google_sub:
                return HttpResponse("This email is linked to another Google account.", status=409)
            profile.google_sub = google_sub
            profile.display_name = display_name
            profile.save(update_fields=("google_sub", "display_name", "last_seen_at"))

        attempt.user = user
        attempt.completed_at = timezone.now()
        attempt.save(update_fields=("user", "completed_at"))
        return HttpResponse(
            "<!doctype html><title>Jungle Escape login</title>"
            "<h1>Login successful</h1><p>You can close this browser tab and return to Jungle Escape.</p>",
            content_type="text/html",
        )


class GooglePollView(APIView):
    permission_classes = [AllowAny]

    @transaction.atomic
    def get(self, request, state_value):
        attempt = GoogleLoginAttempt.objects.select_for_update().filter(state=state_value).first()
        if not attempt or attempt.expires_at <= timezone.now():
            return Response({"status": "expired"}, status=status.HTTP_410_GONE)
        if attempt.consumed_at:
            return Response({"status": "consumed"}, status=status.HTTP_410_GONE)
        if not attempt.completed_at or not attempt.user_id:
            return Response({"status": "pending"}, status=status.HTTP_202_ACCEPTED)
        attempt.consumed_at = timezone.now()
        attempt.save(update_fields=("consumed_at",))
        payload = token_payload(attempt.user)
        payload["status"] = "complete"
        return Response(payload)


class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        profile, _ = PlayerProfile.objects.get_or_create(
            user=request.user,
            defaults={"display_name": request.user.first_name or request.user.username},
        )
        return Response({
            "id": str(request.user.pk),
            "email": request.user.email,
            "display_name": profile.display_name,
            "deletion_requested_at": profile.deletion_requested_at,
        })


class CloudSaveView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        cloud = CloudSave.objects.filter(user=request.user).first()
        return Response({"save_json": cloud.save_json if cloud else {}, "revision": cloud.revision if cloud else 0})

    def put(self, request):
        data = request_data(request).get("save_json", {})
        if not isinstance(data, dict):
            return Response({"error": "save_json must be an object."}, status=status.HTTP_400_BAD_REQUEST)
        if len(json.dumps(data, separators=(",", ":"))) > 512_000:
            return Response({"error": "Save data is too large."}, status=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE)
        cloud, created = CloudSave.objects.get_or_create(user=request.user, defaults={"save_json": data})
        if not created:
            cloud.save_json = data
            cloud.revision += 1
            cloud.save(update_fields=("save_json", "revision", "updated_at"))
        return Response({"revision": cloud.revision, "updated_at": cloud.updated_at})


class EndlessScoreView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        distance = max(0, int(request_data(request).get("best_distance_m", 0)))
        profile, _ = PlayerProfile.objects.get_or_create(user=request.user, defaults={"display_name": request.user.username})
        score, _ = EndlessScore.objects.get_or_create(
            user=request.user,
            defaults={"display_name": profile.display_name, "best_distance_m": distance},
        )
        if distance > score.best_distance_m:
            score.best_distance_m = distance
            score.display_name = profile.display_name
            score.save(update_fields=("best_distance_m", "display_name", "updated_at"))
        return Response({"best_distance_m": score.best_distance_m})


class EndlessLeaderboardView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        limit = min(100, max(1, int(request.query_params.get("limit", 10))))
        rows = EndlessScore.objects.order_by("-best_distance_m", "updated_at")[:limit]
        return Response([{"display_name": row.display_name, "best_distance_m": row.best_distance_m} for row in rows])


class WeeklyScoreView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        data = request_data(request)
        week_key = str(data.get("week_key", ""))
        if not WEEK_KEY_RE.match(week_key):
            return Response({"error": "Invalid week key."}, status=status.HTTP_400_BAD_REQUEST)
        distance = max(0, int(data.get("best_distance_m", 0)))
        profile, _ = PlayerProfile.objects.get_or_create(user=request.user, defaults={"display_name": request.user.username})
        score, _ = WeeklyScore.objects.get_or_create(
            user=request.user,
            week_key=week_key,
            defaults={"display_name": profile.display_name, "best_distance_m": distance},
        )
        if distance > score.best_distance_m:
            score.best_distance_m = distance
            score.display_name = profile.display_name
            score.save(update_fields=("best_distance_m", "display_name", "updated_at"))
        return Response({"week_key": week_key, "best_distance_m": score.best_distance_m})


class WeeklyLeaderboardView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, week_key):
        if not WEEK_KEY_RE.match(week_key):
            return Response({"error": "Invalid week key."}, status=status.HTTP_400_BAD_REQUEST)
        limit = min(100, max(1, int(request.query_params.get("limit", 10))))
        rows = WeeklyScore.objects.filter(week_key=week_key).order_by("-best_distance_m", "updated_at")[:limit]
        return Response([
            {"user_id": str(row.user_id), "display_name": row.display_name, "best_distance_m": row.best_distance_m}
            for row in rows
        ])


class EventBatchView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        raw_events = request.data if isinstance(request.data, list) else request_data(request).get("events", [])
        if not isinstance(raw_events, list):
            return Response({"error": "events must be a list."}, status=status.HTTP_400_BAD_REQUEST)
        events = []
        user = request.user if request.user.is_authenticated else None
        for item in raw_events[:50]:
            if not isinstance(item, dict):
                continue
            event_name = str(item.get("event_name", ""))[:80]
            if not event_name:
                continue
            event_data = item.get("event_data", {})
            events.append(GameEvent(
                user=user,
                event_name=event_name,
                event_data=event_data if isinstance(event_data, dict) else {},
                session_id=str(item.get("session_id", ""))[:80],
                device_id=str(item.get("device_id", ""))[:120],
                app_version=str(item.get("app_version", ""))[:40],
            ))
        GameEvent.objects.bulk_create(events)
        return Response({"accepted": len(events)}, status=status.HTTP_202_ACCEPTED)


class DeletionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        profile, _ = PlayerProfile.objects.get_or_create(user=request.user, defaults={"display_name": request.user.username})
        profile.deletion_requested_at = timezone.now()
        profile.save(update_fields=("deletion_requested_at", "last_seen_at"))
        return Response({"deletion_requested_at": profile.deletion_requested_at})

    def delete(self, request):
        profile, _ = PlayerProfile.objects.get_or_create(user=request.user, defaults={"display_name": request.user.username})
        profile.deletion_requested_at = None
        profile.save(update_fields=("deletion_requested_at", "last_seen_at"))
        return Response({"deletion_requested_at": None})

