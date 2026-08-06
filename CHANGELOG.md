# Changelog

All notable changes, newest first. Format loosely follows
[Keep a Changelog](https://keepachangelog.com).

## Unreleased — globalization

- **Nine countries, one codebase**: Spain, Portugal, France, Germany,
  Italy, Netherlands, Belgium, Ireland — and the US as just one more
  entry. Country is data (`CountryConfig`): chains, demo city,
  currency, VAT, units, date order, price level.
- Choose your country at onboarding, in Settings, or on the map;
  automatic detection from the device locale on first launch.
- Per-country demo datasets: real chain names (Mercadona, Continente,
  E.Leclerc, Edeka, Esselunga, Albert Heijn, Colruyt, Tesco…), euro
  prices with honest VAT labeling, product names in the local
  language, metric units.
- Receipts parse European formats: €/£, DD/MM dates, IVA/MwSt/BTW/TVA
  keywords, all supported chains recognized.
- Map works anywhere: no hardcoded bounds, fallback centre follows
  your country, countries load independently.
- Adding a country requires configuration + translations only — the
  registry tests prove every entry generates a full working dataset.

## 1.0.0-rc.2 — 2026-08-06 (beta validation)

### Real data
- **Your receipts now feed your price history**: confidently-matched
  receipt lines become real price points, visible immediately
- **Report a price** on any product — community prices, rate-limited
  and reviewed before joining the shared history
- **Provenance on every price row** (seed / import / receipt /
  community) — demo data can never masquerade as a feed
- **Open Food Facts** identifies scanned barcodes the catalog doesn't
  know (live, key-free) instead of dead-ending
- Retailer **CSV price import** for operators (staging + validation;
  history archived automatically)

### Security
- Closed a privilege hole: users can no longer set their own
  `is_premium` (column-level grants); the new **stripe-webhook**
  (signature-verified) is the only writer
- `price-alerts` now requires a scheduler secret and dedups
  notifications over 24h
- Error reports are scrubbed (emails, query strings, digit runs)
  before leaving the device

### Experience
- Forgot password, password visibility, and a clear message when
  sign-up needs email confirmation
- Shopping-list items: visible Edit/Delete (quantity finally
  editable); pending-offline-changes banner; queued check-offs replay
  at startup too
- Screens with cached data show it during outages instead of a
  full-screen error; stores and offers work from cache offline
- Substitute suggestions can be applied with one tap
- Stores tab search; meal planner creates a list when none exists and
  confirms before regenerating; receipt form guards against
  accidental back-discard; dozens of audited wording fixes

### Observability
- Screen views (route templates only), optimize duration, map render
  time, external-request latency — full dictionary in
  docs/Observability.md

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
