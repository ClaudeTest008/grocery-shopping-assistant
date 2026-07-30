# Changelog

All notable changes, newest first. Format loosely follows
[Keep a Changelog](https://keepachangelog.com).

## 1.0.0-rc.1 — 2026-07-30 (release candidate)

### Store compliance & security
- In-app **account deletion** with cascading server-side removal
  (Apple 5.1.1(v) / Google Play requirement)
- **Data export**: full JSON of lists, pantry, receipts, current-week
  meal plan and preferences
- Privacy policy and Terms of use, linked from Settings and consented to
  at sign-in
- AI requests route through the server-side **ai-proxy** by default on
  configured builds — no provider key in the binary, web CORS-safe —
  with input caps, type validation and a per-user hourly quota
- Analytics rows (including error reports) are deleted with the account;
  release builds log only truncated error text
- Send feedback from Settings with build info and recent-error context

### Reliability
- Offline check-off outbox hardened: poison-pill entries can no longer
  block the queue, replays write only the checked state (never clobber
  newer edits), and the queue is cleared on sign-out
- Account-deletion flow survives its own sign-out redirect
- Expired sessions surface a sign-in prompt instead of a crash

### Quality gates
- Accessibility guideline tests (tap targets, labels, contrast) run in
  CI against four key screens; OS reduce-motion respected
- Performance measured, not guessed: optimizer 1.6ms per 50-item run
  (benchmarked in CI), Windows startup 768ms to first frame (debug),
  startup timing logged on every launch

## 1.0.0-beta — 2026-07-30

- Price verdicts ("Lowest in 90 days", "12% below usual") on every
  product, computed from recorded history — descriptive, never predictive
- Trip savings vs your nearest store on the optimizer and map
- "Start trip" hands the optimized stop order to your navigation app
- Undo for deletions; haptics; dietary restrictions respected in
  substitutions; AI actions show progress
- Offline check-off queue; durable across restarts

## 1.0.0-alpha — 2026-07-10..30

- Four platforms from one codebase: Android, iOS, Web, Windows
- Basket optimizer (multi-store, coupons, fuel, time, stock, driving
  order) with plain-language explanations
- Key-free interactive map: clustering, route polylines, trip comparison
- Demo mode: full app with zero backend; 104 products, 12 stores
- AI assistant, meal planner, receipt OCR, price history, budget charts
- Supabase schema with RLS; CI across all targets; GitHub Pages web demo
