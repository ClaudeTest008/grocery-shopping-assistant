-- Beta dashboard: paste any block into the Supabase SQL editor.
-- The "dashboard" is deliberately SQL, not a hosted tool — one
-- operator, weekly cadence, zero new infrastructure (Operations.md).

-- 1. Pulse: DAU by day, last 14 days --------------------------------
select date_trunc('day', created_at)::date as day,
       count(distinct user_id) as dau,
       count(*) filter (where event = 'startup') as launches
from analytics
where created_at > now() - interval '14 days'
group by 1 order by 1 desc;

-- 2. Funnel, last 7 days (unique users per step) --------------------
select
  count(distinct user_id) filter (where event = 'startup') as launched,
  count(distinct user_id) filter (where event = 'onboarding_complete') as onboarded,
  count(distinct user_id) filter (where event = 'auth_success') as signed_in,
  count(distinct user_id) filter (where event = 'list_created') as made_list,
  count(distinct user_id) filter (where event = 'optimize_run') as optimized,
  count(distinct user_id) filter (where event = 'trip_started') as started_trip
from analytics
where created_at > now() - interval '7 days';

-- 3. Optimizer acceptance rate --------------------------------------
select
  count(*) filter (where event = 'trip_started')::float
    / nullif(count(*) filter (where event = 'optimize_run'), 0)
    as acceptance_rate,
  avg((properties->>'duration_ms')::int)
    filter (where event = 'optimize_run') as avg_optimize_ms
from analytics
where created_at > now() - interval '7 days';

-- 4. Live data accumulating? ----------------------------------------
select
  sum((properties->>'recorded')::int)
    filter (where event = 'receipt_prices_recorded') as receipt_prices,
  count(*) filter (where event = 'price_reported') as community_reports,
  count(*) filter (where event = 'barcode_external_lookup'
                   and properties->>'found' = 'false') as unknown_barcodes,
  count(*) filter (where event = 'product_search'
                   and properties->>'results' = '0') as zero_result_searches
from analytics
where created_at > now() - interval '7 days';

-- 5. Reliability: errors grouped by shape ---------------------------
select properties->>'type' as error_type,
       properties->>'error' as error,
       count(*) as occurrences,
       max(created_at) as last_seen
from analytics
where event = 'app_error' and created_at > now() - interval '7 days'
group by 1, 2 order by occurrences desc limit 20;

-- 6. Sync health (dropped should stay ~0) ---------------------------
select sum((properties->>'applied')::int) as ops_applied,
       sum((properties->>'dropped')::int) as ops_dropped
from analytics
where event = 'pending_ops_drained'
  and created_at > now() - interval '7 days';

-- 7. Session length distribution ------------------------------------
select percentile_cont(0.5) within group
         (order by (properties->>'seconds')::int) as p50_seconds,
       percentile_cont(0.9) within group
         (order by (properties->>'seconds')::int) as p90_seconds,
       count(*) as sessions
from analytics
where event = 'session_end'
  and created_at > now() - interval '7 days';

-- 8. Platform / mode mix --------------------------------------------
select properties->>'platform' as platform,
       properties->>'mode' as mode,
       count(distinct user_id) as users
from analytics
where event = 'startup' and created_at > now() - interval '7 days'
group by 1, 2 order by users desc;

-- 9. Moderation queue + AI quota pressure ---------------------------
select
  (select count(*) from price_submissions where status = 'pending')
    as submissions_pending,
  (select count(*) from ai_usage
    where called_at > now() - interval '1 day') as ai_calls_24h;
