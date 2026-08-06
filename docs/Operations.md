# Operations Runbook

Who does what when the beta is live. Companion to
[Deployment.md](Deployment.md) (how to ship), [Beta.md](Beta.md)
(tester-facing), [Observability.md](Observability.md) (what we
measure).

## Monitoring & alerting — the honest state

There is **no hosted monitoring or paging** during the closed beta, on
purpose (single-operator scale; every added system is an added
failure). Monitoring is *pull-based on a schedule*:

| Check | How | Cadence |
|---|---|---|
| App errors | `app_error` triage SQL in Observability.md | Weekly + after any tester report |
| Event flow sane | Event-proportion SQL | Before each rc tag |
| CI green | GitHub Actions tab | Every push |
| Web demo up | Open the Pages URL | With each release |
| Edge functions healthy | Supabase Dashboard → Edge Functions → logs/error rate | Weekly |
| DB size / rate limits hit | Dashboard → Database; `ai_usage` + `price_submissions` counts | Weekly |
| Moderation queue | `select count(*) from price_submissions where status='pending'` | Weekly |

Graduation trigger: >50 active testers or the first missed incident →
wire `AppConfig.sentryDsn` (integration point already in
`Telemetry.recordError`) and Supabase log drains.

## Incident response guide

Severity:
- **SEV1** — data loss/exposure, auth broken, backend down for all
  connected users. Act immediately.
- **SEV2** — a core journey broken (optimize, lists, sync) for some
  users, or any security report. Act same day.
- **SEV3** — degraded UX, single-feature failure with workaround.
  Next release.

Steps (SEV1/SEV2):
1. **Acknowledge** the reporting tester (or note the detection) with a
   timestamp. Open a GitHub issue labeled `incident` — it is the
   timeline of record.
2. **Stabilize before diagnosing.** Fastest levers, in order:
   - Bad app build → pull the release link / halt the Play track;
     testers keep the previous build (see Rollback in Deployment.md).
   - Bad edge function → redeploy previous version
     (`git checkout <good> -- supabase/functions/<fn> && supabase functions deploy <fn>`).
   - Bad migration → forward-fix migration (never edit applied ones).
   - Suspected key/secret leak → rotate in Supabase/Stripe dashboards
     first, ask questions second. The anon key is public by design;
     the service role key, `CRON_SECRET`, `STRIPE_*`, `LLM_API_KEY`
     are not.
   - Abuse of an endpoint → tighten its quota (env var for ai-proxy;
     rate trigger for submissions) and, worst case, disable the
     function.
3. **Diagnose** with the analytics SQL, Supabase function logs, and a
   local repro.
4. **Fix forward** through the normal gates (analyze, tests, CI, tag).
5. **Write it down**: append a short blameless postmortem to the
   incident issue (what happened, user impact, timeline, root cause,
   what now prevents it) and update Known issues in Beta.md.

Data-exposure note: if user data was exposed, GDPR-style notification
duties may apply — document scope (which users, which fields, which
window) in the incident issue before deciding on notifications.

## Disaster recovery / business continuity

- **Code + docs + schema**: everything lives in the GitHub repo;
  any machine with Flutter + the secrets can rebuild every artifact.
  The repo IS the DR plan for the software.
- **Database**: Supabase automated backups (Pro tier) — restore to a
  new project, repoint `SUPABASE_URL`/anon key, redeploy the five edge
  functions, re-set secrets. Catalog data is reproducible from
  seed/CSV; user data comes from the backup.
- **Secrets**: stored in Supabase + GitHub secret stores; a keeper list
  of *which* secrets exist (not values) is in Deployment.md §1. If the
  GitHub account is lost, Pages/CI move with a fork + new secrets.
- **Stripe**: account-bound; nothing in the repo is needed to keep
  payments flowing except the webhook redeploy.
- **Demo mode**: cannot have a disaster — it has no server.

## Support workflow

Inbox: support@grocery-assistant.app (see Beta.md for SLA).
Templates in [docs/beta/support-templates.md](beta/support-templates.md).
Path: email → reproduce (ask for Settings→About version if missing) →
GitHub issue via template → fix lands in next rc → reply with the
release note line. Feature requests get the `feature-request` label
and a yes/no/later answer — silence is the only wrong response.

## Tester roster

Track in a private `TESTERS.md` (never committed — contains emails):
name, email, platform(s), invite date, build/mode, status
(invited/active/quiet/offboarded), notes. "Quiet" = no events for 14
days → send the check-in template once; no reply → offboard.

Offboarding: send the offboarding template (thanks + what ships next +
delete-in-app reminder), remove from the roster and distribution
links. Their data: they delete in-app (Settings → Delete account);
operator deletes only on explicit request (service role, same cascade).
