"""Import the existing Mhuri Google OAuth web client into backend/.env.

The values are deliberately never printed. The generated file is gitignored.
"""
import re
import secrets
import sys
from pathlib import Path


GAME_BACKEND = Path(__file__).resolve().parents[1]
MHURI_BACKEND = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.home() / "Documents" / "mhuri_new" / "backend"

settings_text = (MHURI_BACKEND / "okkindred" / "settings.py").read_text(encoding="utf-8")
views_text = (MHURI_BACKEND / "auth_api" / "views.py").read_text(encoding="utf-8")

client_match = re.search(r"GOOGLE_OAUTH2_CLIENT_ID\s*=\s*['\"]([^'\"]+)['\"]", settings_text)
secret_match = re.search(r"client_secret\s*=\s*['\"]([^'\"]+)['\"]", views_text)
if not client_match or not secret_match:
    raise SystemExit("Could not locate both Google OAuth values in the Mhuri backend.")

env_path = GAME_BACKEND / ".env"
existing = {}
if env_path.exists():
    for line in env_path.read_text(encoding="utf-8").splitlines():
        if line and not line.lstrip().startswith("#") and "=" in line:
            key, value = line.split("=", 1)
            existing[key] = value

existing.setdefault("SECRET_KEY", secrets.token_urlsafe(64))
existing.setdefault("DEBUG", "true")
existing.setdefault("ALLOWED_HOSTS", "localhost,127.0.0.1")
existing.setdefault("GAME_PUBLIC_URL", "http://127.0.0.1:8000")
existing["GOOGLE_OAUTH2_CLIENT_ID"] = client_match.group(1)
existing["GOOGLE_OAUTH2_CLIENT_SECRET"] = secret_match.group(1)

env_path.write_text("".join(f"{key}={value}\n" for key, value in existing.items()), encoding="utf-8")
print(f"Imported Google OAuth configuration into {env_path} (values hidden).")

