-- Jungle Escape: Lost Path — Analytics Schema
-- Paste into: Supabase Dashboard → SQL Editor → New Query → Run
--
-- Philosophy: game progress stays on device.
-- Server only receives anonymous play events used to improve levels.
-- No personal data. No account required.

-- ─── Events ───────────────────────────────────────────────────────────────────
-- One row per game event (level_start, level_fail, level_complete, etc.)

CREATE TABLE IF NOT EXISTS game_events (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  device_id   TEXT        NOT NULL,   -- random UUID generated once on device
  session_id  TEXT        NOT NULL,   -- changes each app launch
  event_type  TEXT        NOT NULL,   -- see list below
  payload     JSONB       NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Event types and their payload keys:
--   level_start    : { level_id, character, attempt }
--   level_complete : { level_id, stars, coins, time_sec, attempt }
--   level_fail     : { level_id, fail_reason, row_reached, time_sec, attempt }
--   obstacle_hit   : { level_id, obstacle_type, row, lane }
--   resource_pick  : { level_id, resource_type, row }
--   session_start  : { app_version, platform }

-- Open INSERT for anonymous clients (no auth needed).
-- No SELECT allowed — raw data stays private.
ALTER TABLE game_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_insert" ON game_events;
CREATE POLICY "anon_insert" ON game_events
  FOR INSERT WITH CHECK (true);

-- Index for fast aggregation queries
CREATE INDEX IF NOT EXISTS idx_events_type_level
  ON game_events (event_type, (payload->>'level_id'));

-- ─── Views (for dashboard / level improvement decisions) ─────────────────────

-- How many players finish each level and how many stars they earn
CREATE OR REPLACE VIEW v_level_completion AS
SELECT
  (payload->>'level_id')::int                                              AS level_id,
  COUNT(*) FILTER (WHERE event_type = 'level_start')                      AS starts,
  COUNT(*) FILTER (WHERE event_type = 'level_complete')                   AS completions,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE event_type = 'level_complete')
          / NULLIF(COUNT(*) FILTER (WHERE event_type = 'level_start'), 0)
  , 1)                                                                     AS completion_pct,
  ROUND(AVG((payload->>'stars')::numeric)
        FILTER (WHERE event_type = 'level_complete'), 2)                   AS avg_stars,
  ROUND(AVG((payload->>'time_sec')::numeric)
        FILTER (WHERE event_type = 'level_complete'), 1)                   AS avg_time_sec
FROM game_events
WHERE event_type IN ('level_start', 'level_complete')
  AND payload->>'level_id' IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- Where players die in each level (use to find unfair spots)
CREATE OR REPLACE VIEW v_level_fail_heatmap AS
SELECT
  (payload->>'level_id')::int  AS level_id,
  payload->>'fail_reason'      AS obstacle_type,
  COUNT(*)                     AS fail_count,
  ROUND(AVG((payload->>'row_reached')::numeric), 1) AS avg_fail_row,
  MIN((payload->>'row_reached')::numeric)           AS earliest_fail_row,
  MAX((payload->>'row_reached')::numeric)           AS latest_fail_row
FROM game_events
WHERE event_type = 'level_fail'
  AND payload->>'level_id' IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

-- Which obstacle types kill players most across all levels
CREATE OR REPLACE VIEW v_obstacle_lethality AS
SELECT
  payload->>'fail_reason' AS obstacle_type,
  COUNT(*)                AS total_deaths,
  COUNT(DISTINCT payload->>'level_id') AS levels_affected,
  ROUND(AVG((payload->>'row_reached')::numeric), 1) AS avg_death_row
FROM game_events
WHERE event_type = 'level_fail'
GROUP BY 1
ORDER BY 2 DESC;

-- Daily active players (device count, privacy-safe)
CREATE OR REPLACE VIEW v_daily_active AS
SELECT
  DATE(created_at) AS day,
  COUNT(DISTINCT device_id) AS unique_devices,
  COUNT(*) FILTER (WHERE event_type = 'level_complete') AS completions,
  COUNT(*) FILTER (WHERE event_type = 'level_fail')     AS fails
FROM game_events
GROUP BY 1
ORDER BY 1 DESC;
