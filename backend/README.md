# Jungle Escape Django backend

Standalone API for game registration, Google login, cloud saves, leaderboards,
account deletion, and analytics. It does not import or modify Mhuri models.

## Local setup

```powershell
python scripts/import_mhuri_oauth.py C:\Users\dell\Documents\mhuri_new\backend
python -m venv .venv
.venv\Scripts\pip install -r requirements.txt
.venv\Scripts\python manage.py migrate
.venv\Scripts\python manage.py runserver 0.0.0.0:8000
```

The import script copies only the Google OAuth web-client ID and secret into the
gitignored `backend/.env`; it never edits Mhuri or prints credential values.

## Production

1. Copy `.env.example` to `.env` and configure PostgreSQL, the public HTTPS API
   URL, allowed host, and OAuth credentials.
2. Add this exact authorized redirect URI to the Google OAuth web client:
   `https://YOUR_API_HOST/api/v1/auth/google/callback/`.
3. Run `docker compose up -d --build`.
4. Reverse proxy HTTPS traffic to `127.0.0.1:8087`.
5. Add this setting to `project.godot`, using the same public URL, then rebuild
   the Android bundle and publish the new version:

   ```ini
   [jungle_escape]
   backend_url="https://YOUR_API_HOST"
   ```

   Until this is set, the game uses `http://127.0.0.1:8000` for local testing.

The Android game opens Google's web login and polls the backend for completion,
so it does not need a custom URL scheme or expose the Google client secret.
