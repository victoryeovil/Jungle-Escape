-- Jungle Escape: Lost Path — Full Backend Schema
-- Paste into: Supabase Dashboard → SQL Editor → New Query → Run
--
-- Design principles:
--   • Game progress lives on device — cloud is a backup, not the source of truth
--   • Analytics are anonymous — no personal data in game_events
--   • Account deletion has a 14-day grace window for recovery
--   • All tables use Row Level Security so users only see their own data

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. ANALYTICS (no auth required)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS game_events (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  device_id   TEXT        NOT NULL,   -- random UUID generated once on device
  session_id  TEXT        NOT NULL,   -- changes each app launch
  event_type  TEXT        NOT NULL,   -- level_start | level_fail | level_complete | obstacle_hit | resource_pick | session_start
  payload     JSONB       NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Payload keys per event_type:
--   level_start    : { level_id, character, attempt }
--   level_complete : { level_id, stars, coins, time_sec, attempt }
--   level_fail     : { level_id, fail_reason, row_reached, time_sec, attempt }
--   obstacle_hit   : { level_id, obstacle_type, row, lane }
--   resource_pick  : { level_id, resource_type, row }
--   session_start  : { app_version, platform }

ALTER TABLE game_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_insert" ON game_events;
CREATE POLICY "anon_insert" ON game_events FOR INSERT WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_events_type_level
  ON game_events (event_type, (payload->>'level_id'));

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. USER ACCOUNTS (auth required — tracks display name + deletion requests)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS user_accounts (
  id                    UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  display_name          TEXT        NOT NULL DEFAULT 'Explorer',
  deletion_requested_at TIMESTAMPTZ,          -- NULL = active; set = pending deletion
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE user_accounts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "owner_all_accounts" ON user_accounts;
CREATE POLICY "owner_all_accounts" ON user_accounts
  FOR ALL USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. CLOUD SAVES (auth required — cross-device progress backup)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS cloud_saves (
  user_id    UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  save_json  JSONB       NOT NULL DEFAULT '{}',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE cloud_saves ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "owner_all_saves" ON cloud_saves;
CREATE POLICY "owner_all_saves" ON cloud_saves
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Auto-update updated_at on upsert
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;

DROP TRIGGER IF EXISTS trg_cloud_saves_updated_at ON cloud_saves;
CREATE TRIGGER trg_cloud_saves_updated_at
  BEFORE UPDATE ON cloud_saves
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. ACCOUNT DELETION — scheduled nullify after 14 days
-- ═══════════════════════════════════════════════════════════════════════════════
-- Run this function daily via pg_cron (Pro) or a Supabase Edge Function cron.
-- It deletes auth users whose 14-day grace period has expired,
-- which cascades to user_accounts and cloud_saves automatically.

CREATE OR REPLACE FUNCTION process_expired_deletions()
RETURNS INTEGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  deleted_count INTEGER := 0;
  rec RECORD;
BEGIN
  FOR rec IN
    SELECT id FROM user_accounts
    WHERE deletion_requested_at IS NOT NULL
      AND deletion_requested_at + INTERVAL '14 days' <= NOW()
  LOOP
    DELETE FROM auth.users WHERE id = rec.id;
    deleted_count := deleted_count + 1;
  END LOOP;
  RETURN deleted_count;
END; $$;

-- To schedule daily (requires pg_cron extension — available on Supabase Pro):
-- SELECT cron.schedule('expire-deletions', '0 3 * * *', 'SELECT process_expired_deletions()');
--
-- On free tier: create a Supabase Edge Function that calls:
--   await supabase.rpc('process_expired_deletions')
-- and schedule it via the Edge Functions cron schedule.

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. ANALYTICS VIEWS (read-only — for level improvement decisions)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Completion rates and avg stars per level
CREATE OR REPLACE VIEW v_level_completion AS
SELECT
  (payload->>'level_id')::int                                                 AS level_id,
  COUNT(*) FILTER (WHERE event_type = 'level_start')                         AS starts,
  COUNT(*) FILTER (WHERE event_type = 'level_complete')                      AS completions,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE event_type = 'level_complete')
          / NULLIF(COUNT(*) FILTER (WHERE event_type = 'level_start'), 0)
  , 1)                                                                        AS completion_pct,
  ROUND(AVG((payload->>'stars')::numeric)
        FILTER (WHERE event_type = 'level_complete'), 2)                      AS avg_stars,
  ROUND(AVG((payload->>'time_sec')::numeric)
        FILTER (WHERE event_type = 'level_complete'), 1)                      AS avg_time_sec
FROM game_events
WHERE event_type IN ('level_start', 'level_complete')
  AND payload->>'level_id' IS NOT NULL
GROUP BY 1 ORDER BY 1;

-- Where players die per level (find unfair rows)
CREATE OR REPLACE VIEW v_level_fail_heatmap AS
SELECT
  (payload->>'level_id')::int                                  AS level_id,
  payload->>'fail_reason'                                      AS obstacle_type,
  COUNT(*)                                                     AS fail_count,
  ROUND(AVG((payload->>'row_reached')::numeric), 1)           AS avg_fail_row,
  MIN((payload->>'row_reached')::numeric)                      AS earliest_fail_row,
  MAX((payload->>'row_reached')::numeric)                      AS latest_fail_row
FROM game_events
WHERE event_type = 'level_fail' AND payload->>'level_id' IS NOT NULL
GROUP BY 1, 2 ORDER BY 1, 3 DESC;

-- Most lethal obstacle types overall
CREATE OR REPLACE VIEW v_obstacle_lethality AS
SELECT
  payload->>'fail_reason'                                      AS obstacle_type,
  COUNT(*)                                                     AS total_deaths,
  COUNT(DISTINCT (payload->>'level_id'))                       AS levels_affected,
  ROUND(AVG((payload->>'row_reached')::numeric), 1)           AS avg_death_row
FROM game_events WHERE event_type = 'level_fail'
GROUP BY 1 ORDER BY 2 DESC;

-- Daily unique devices (privacy-safe retention metric)
CREATE OR REPLACE VIEW v_daily_active AS
SELECT
  DATE(created_at)                                             AS day,
  COUNT(DISTINCT device_id)                                    AS unique_devices,
  COUNT(*) FILTER (WHERE event_type = 'level_complete')        AS completions,
  COUNT(*) FILTER (WHERE event_type = 'level_fail')            AS fails
FROM game_events GROUP BY 1 ORDER BY 1 DESC;

-- Accounts currently in the deletion grace window
CREATE OR REPLACE VIEW v_pending_deletions AS
SELECT
  ua.id,
  ua.display_name,
  ua.deletion_requested_at,
  ua.deletion_requested_at + INTERVAL '14 days'               AS final_deletion_date,
  EXTRACT(DAY FROM (ua.deletion_requested_at + INTERVAL '14 days') - NOW())::int AS days_remaining
FROM user_accounts ua
WHERE ua.deletion_requested_at IS NOT NULL
  AND ua.deletion_requested_at + INTERVAL '14 days' > NOW()
ORDER BY ua.deletion_requested_at;
