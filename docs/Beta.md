# Closed Beta Guide

## What testers get

The full product: lists (voice/barcode/AI input), the basket optimizer
with honest all-in totals and savings, price verdicts from history, the
interactive map with trip navigation, pantry, receipt scanning, budget
analytics, and the AI assistant. Since rc.2, receipts and "Report a
price" feed **your own real prices** into the history charts.

## Getting the app installed

| Platform | How |
|---|---|
| **Web (fastest)** | Open <https://claudetest008.github.io/grocery-shopping-assistant/> — demo mode, nothing to install, nothing leaves the browser. |
| **Android** | Install link comes in your welcome email (Play internal-track invite once store accounts exist; until then the APK/AAB attached to the latest [GitHub release](https://github.com/ClaudeTest008/grocery-shopping-assistant/releases) — enable "install unknown apps" for your browser). |
| **Windows** | Unzip the `windows-release.zip` from the welcome email / GitHub release and run `grocery_shopping_assistant.exe` from inside the folder (keep the folder together). |
| **iOS** | TestFlight — pending Apple developer account; not yet available. |

**Connected mode** (real account + AI + sync) requires the team's
Supabase-configured build; the welcome email says which mode your build
is. Demo builds work fully offline with seeded data.

## Your first session (5 steps, ~10 minutes)

1. Tap **Explore the demo** (or create an account on connected builds).
2. Open **Lists → Weekly groceries**, add three items — type one, use
   the mic for one, scan a barcode for one (desktop: type the number).
3. Tap **Cheapest trip** and read the comparison — does the
   recommendation make sense to you? Tap the explanation.
4. Open the **Map**, start the trip, and see the stop order.
5. **Scan or type a receipt** (Receipts → +). Check the product's
   price history afterward — your receipt price should appear.

Then use it however you actually shop. The unscripted parts are where
the useful feedback lives.

## FAQ

**Why do prices look artificial?** Unless your build is connected to a
price feed, prices are seeded demo data — realistic mechanics, not
live shelf prices. Prices from your own receipts and reports are real
and marked as yours. See [DataProviders.md](DataProviders.md).

**Why can't I scan with the camera on Windows or web?** The barcode
and receipt-OCR libraries are mobile-only. You get a typed fallback on
desktop; it's a platform gap, not a bug ([details](../Development.md)).

**Where is my data?** Demo mode: only on your device (browser storage
/ app folder). Connected: owner-scoped rows in the project's Supabase
DB, exportable and deletable in-app (Settings → Account & data).

**How do I reset demo data?** Settings → Reset demo data. On web, a
private/incognito window also starts pristine.

**The AI assistant stopped answering.** It is rate-limited to 60
requests/hour per user; wait and retry. Mock-AI builds answer canned
responses by design.

**Does my receipt upload anywhere?** The image is processed on-device
(mobile OCR). Connected builds store the parsed rows (not the photo,
unless you attach it) under your account.

**Why did my price report not change the chart for others?**
Community prices show in *your* history immediately; they reach the
shared catalog only after operator review — that's the anti-poisoning
gate.

**A sync banner says changes are waiting.** You were offline; ticked
items are queued and replay automatically on reconnect. Force it by
reopening the app with a connection.

## Troubleshooting

- **Can't sign in with Google/Apple on Windows** — OAuth needs the
  mobile/web app; use email/password on desktop.
- **App opens to a blank window on Windows** — you moved the `.exe`
  out of its folder; run it from inside the unzipped `Release/` folder.
- **"Rate limited — try again shortly"** — the AI hourly cap, above.
- **Barcode not recognized** — the code isn't in the catalog or Open
  Food Facts; add the item by name (that miss is itself useful data we
  collect as `barcode_external_lookup`).
- **Voice input does nothing on Windows** — enable online speech
  recognition in Windows Settings → Privacy → Speech.
- **Something crashed** — Settings → Send feedback. The draft email
  shows the recent-error summary before you send it.

## Known issues (living list — updated each rc)

- iOS distribution not yet available (no Apple developer account).
- Offline queueing covers list check-offs; other edits need a
  connection (they fail loudly, nothing is lost silently).
- Data export includes the current week's meal plan only (labeled).
- Deleting your account does not require re-entering your password
  (single confirm dialog).
- Prices are seeded until a retailer feed is connected.

## Feedback & support

Settings → Account & data → **Send feedback** — the email pre-fills
app version, platform, mode and recent error summaries; you see
exactly what is included before sending. Address:
support@grocery-assistant.app.

- **Ownership**: the mailbox is checked by the release owner every
  weekday; target first response within 2 business days during beta.
- **Triage**: each actionable report becomes a GitHub issue via the
  [bug-report template](../.github/ISSUE_TEMPLATE/bug_report.md)
  (platform, version, mode, steps); the reporter gets the issue link.
- Check the Known issues list above before reporting.

## Privacy in one line

Demo mode sends nothing anywhere; with an account your shopping data
is owner-scoped on the backend, exportable and deletable in-app at any
time. Analytics contain no personal data —
[Observability.md](Observability.md) lists every event. Full text:
[PRIVACY.md](../PRIVACY.md).

## For the team

### Releasing a beta build

1. Update `CHANGELOG.md` (curated notes — paste into the GitHub
   release body, don't rely on auto-generated commit lists).
2. `git tag v1.0.0-rc.N && git push --tags` → release workflow builds
   a signed AAB (when keystore secrets exist) + unsigned iOS archive.
   **Bump rule**: rc.N increments per tester-visible build; the
   release owner tags; `pubspec.yaml` build number bumps with it.
3. Web deploys itself on every push to `main`.
4. Windows: `.\scripts\build.ps1 -Target windows`, zip the whole
   `Release/` folder.
5. **Promote gate**: four CI jobs green, `startup` / `optimizer`
   numbers in test logs unchanged, one manual smoke run of the actual
   built artifact on one device, distribution links updated.

### Crash monitoring during beta

Error reports land in the `analytics` table as `app_error` rows
(scrubbed + truncated — see [Observability.md](Observability.md) for
the exact pipeline and triage SQL). Review cadence: weekly, and after
any tester crash report. Hosted crash reporting (Sentry/Crashlytics)
is deliberately deferred until SQL triage stops scaling;
`AppConfig.sentryDsn` is already plumbed for the switch.

### Local data across versions

Demo/offline state lives in Hive as JSON. Policy: entity `fromJson`
must tolerate missing keys (defaults), so **adding** fields is always
safe; **removing or retyping** a field requires either a
compatibility default in `fromJson` or a documented
box-drop-and-reseed in the changelog. The round-trip tests in
`test/core/local_store_json_test.dart` are the regression gate.

### Analytics validation

After each rc, run the event-proportion query in
[Observability.md](Observability.md) and confirm new events
(`screen_view`, `receipt_prices_recorded`, `price_reported`,
`barcode_external_lookup`) are arriving. Beta success metrics are
defined there too.
