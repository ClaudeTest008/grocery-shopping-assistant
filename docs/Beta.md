# Closed Beta Guide

## What testers get

The full product: lists (voice/barcode/AI input), the basket optimizer
with honest all-in totals and savings, price verdicts from history, the
interactive map with trip navigation, pantry, receipt scanning, budget
analytics, and the AI assistant.

**Instant path (no infrastructure):** the
[live web demo](https://claudetest008.github.io/grocery-shopping-assistant/)
or any unconfigured build — demo mode, seeded data, mock AI, nothing
leaves the device.

**Connected path:** a build with `--dart-define` Supabase credentials
plus the deployed edge functions (`ai-proxy`, `delete-account`,
`stripe-checkout`, `price-alerts`) and secrets
(`LLM_API_KEY`, `LLM_PROVIDER`, optionally `AI_HOURLY_LIMIT`).

## Known limitations during beta

- Prices are seeded demo data unless a price feed has been connected;
  treat totals as demonstrations of the mechanics.
- Windows: no camera scanning, OCR, payments or push (plugin gaps; all
  degrade gracefully with explanations). OAuth needs the mobile/web app.
- Offline queueing covers list check-offs; other edits need a
  connection.
- The AI assistant is rate-limited per user (default 60 requests/hour).

## Feedback

Settings → Account & data → **Send feedback**. The email pre-fills app
version, platform, mode and recent error summaries — you see exactly
what is included before sending. Address: support@grocery-assistant.app.

## Privacy in one line

Demo mode sends nothing anywhere; with an account your shopping data is
owner-scoped on the backend, exportable and deletable in-app at any
time. Full text: [PRIVACY.md](../PRIVACY.md).

## For the team: releasing a beta build

1. `git tag v1.0.0-rc.N && git push --tags` → release workflow builds a
   signed AAB (when keystore secrets exist) and an unsigned iOS archive.
2. Web deploys itself on every push to `main`.
3. Windows: `.\scripts\build.ps1 -Target windows`, ship the whole
   `Release/` folder.
4. Check the four CI jobs and the `startup` / `optimizer` numbers in
   the test logs before promoting any build.
