from django.contrib.auth.models import User
from django.test import override_settings
from rest_framework.test import APITestCase

from .models import CloudSave, GameEvent


class GameApiTests(APITestCase):
    def register(self):
        return self.client.post("/api/v1/auth/register/", {
            "email": "player@example.com",
            "password": "StrongPass123!",
            "display_name": "Pathfinder",
        }, format="json")

    def authenticate(self):
        response = self.register()
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['access']}")
        return response

    def test_register_login_profile(self):
        created = self.register()
        self.assertEqual(created.status_code, 201)
        self.assertEqual(created.data["user"]["display_name"], "Pathfinder")
        login = self.client.post("/api/v1/auth/login/", {
            "email": "player@example.com",
            "password": "StrongPass123!",
        }, format="json")
        self.assertEqual(login.status_code, 200)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {login.data['access']}")
        profile = self.client.get("/api/v1/me/")
        self.assertEqual(profile.status_code, 200)

    def test_cloud_save_round_trip(self):
        self.authenticate()
        saved = self.client.put("/api/v1/save/", {"save_json": {"coins": 42, "current_level": 6}}, format="json")
        self.assertEqual(saved.status_code, 200)
        loaded = self.client.get("/api/v1/save/")
        self.assertEqual(loaded.data["save_json"]["coins"], 42)
        self.assertEqual(CloudSave.objects.count(), 1)

    def test_scores_are_monotonic(self):
        self.authenticate()
        self.client.post("/api/v1/scores/endless/", {"best_distance_m": 100}, format="json")
        lower = self.client.post("/api/v1/scores/endless/", {"best_distance_m": 20}, format="json")
        self.assertEqual(lower.data["best_distance_m"], 100)
        board = self.client.get("/api/v1/leaderboards/endless/?limit=10")
        self.assertEqual(board.data[0]["best_distance_m"], 100)

    def test_anonymous_event_tracking(self):
        response = self.client.post("/api/v1/events/", {"events": [{"event_name": "game_started", "event_data": {"mode": "story"}}]}, format="json")
        self.assertEqual(response.status_code, 202)
        self.assertEqual(GameEvent.objects.count(), 1)

    @override_settings(GOOGLE_OAUTH2_CLIENT_ID="client-id", GOOGLE_OAUTH2_CLIENT_SECRET="secret")
    def test_google_start_returns_pollable_state(self):
        response = self.client.post("/api/v1/auth/google/start/", {}, format="json")
        self.assertEqual(response.status_code, 200)
        self.assertIn("accounts.google.com", response.data["authorization_url"])
        pending = self.client.get(f"/api/v1/auth/google/poll/{response.data['state']}/")
        self.assertEqual(pending.status_code, 202)

