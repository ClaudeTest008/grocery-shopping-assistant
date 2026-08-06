# Deployment

## 0. Live web demo (GitHub Pages)

**URL: <https://claudetest008.github.io/grocery-shopping-assistant/>**

- Every push to `main` triggers `.github/workflows/deploy-web.yml`:
  `flutter build web --release --base-href /grocery-shopping-assistant/`
  → `actions/deploy-pages`. No secrets are injected — the build boots in
  **demo mode** (seeded local data, mock AI), which *is* the demo
  environment.
- **Environment separation**: a production web deployment is a second
  workflow/hosting target that adds `--dart-define` values from secrets
  (Supabase URL/key, LLM provider, Stripe key). Demo and production can
  never share data because demo has no backend at all.
- **Demo reset**: automatic per visitor (state lives in the browser's
  IndexedDB; new visitor = pristine seed). In-app: Settings → "Reset
  demo data". 
- **Rollback**: `git revert <bad-commit> && git push` (redeploys), or
  re-run the last green "Deploy web demo" run from the Actions tab
  ("Re-run all jobs") — Pages always serves the most recent successful
  deployment.
- **Local web run**: `flutter run -d chrome` (or
  `flutter build web && npx serve build/web`).

## 1. Supabase

```bash
supabase login
supabase link --project-ref <project-ref>
supabase db push                 # applies supabase/migrations
supabase db seed                 # optional: demo catalog (seed.sql)
supabase functions deploy ai-proxy delete-account stripe-checkout \
  stripe-webhook price-alerts
supabase secrets set LLM_PROVIDER=anthropic LLM_API_KEY=sk-ant-... \
  STRIPE_SECRET_KEY=sk_live_... STRIPE_WEBHOOK_SECRET=whsec_... \
  CRON_SECRET=<long-random-string>
```

- **All five functions are required.** `delete-account` backs the
  store-mandated in-app deletion — a backend without it ships a
  compliance feature that doesn't work. `stripe-webhook` is the only
  thing that ever sets `users.is_premium`.
- Enable Google/Apple providers under Auth → Providers; the app's
  redirect URL is `com.groceryassistant.grocery://login-callback`.
- Schedule `price-alerts` hourly: Dashboard → Edge Functions →
  Schedules, adding header `x-cron-secret: <CRON_SECRET>` — the
  function rejects calls without it.
- In the Stripe dashboard, point a webhook at
  `https://<ref>.functions.supabase.co/stripe-webhook` for
  `payment_intent.succeeded`, `charge.refunded` and
  `charge.dispute.created` (grant + revoke), and copy its signing
  secret into `STRIPE_WEBHOOK_SECRET`.

### Backups

The beta project must run with Supabase's automated daily backups
(included on Pro tier; enable Point-in-Time Recovery if the plan
allows). Restore procedure: Supabase Dashboard → Database → Backups →
restore to a new project, then repoint `SUPABASE_URL`/anon key at it.
Demo-mode data is on-device by design and has no server backup — say
so to testers rather than pretending otherwise.

### Rollback

- **App (Android/iOS)**: forward-fix by tagging `v1.0.0-rc.(N+1)` from
  the last good commit; on Play, halt the internal-track rollout of the
  bad build. Never re-tag an existing version.
- **Edge functions**: `git checkout <last-good> -- supabase/functions/<fn> && supabase functions deploy <fn>`
  (functions are stateless; safe any time).
- **Database migrations**: forward-only. No down-migrations exist, on
  purpose — write a new corrective migration instead of editing or
  reverting an applied one.
- **Web demo**: `git revert` or re-run the last green Pages deploy (see
  section 0).

## 2. App configuration (dart-define)

| Define | Purpose | Unset behavior |
|---|---|---|
| `SUPABASE_URL`, `SUPABASE_ANON_KEY` | backend | demo mode |
| `LLM_PROVIDER` (`anthropic`/`openai`/`mock`), `LLM_API_KEY`, `LLM_MODEL` | AI | mock AI |
| `STRIPE_PUBLISHABLE_KEY` | payments | paywall disabled dialog |

## 3. Maps

The map uses **flutter_map with OpenStreetMap/CARTO raster tiles — no
API key on any platform**, including the web demo. For production scale,
switch `urlTemplate` in
`lib/features/maps/presentation/map_screen.dart` to a contracted tile
provider (MapTiler, Protomaps, self-hosted) and keep the required
attribution widget.

## 4. Firebase Messaging

1. Create a Firebase project with Android app id
   `com.groceryassistant.grocery_shopping_assistant` and your iOS bundle.
2. Drop `google-services.json` into `android/app/` and
   `GoogleService-Info.plist` into `ios/Runner/` (both gitignored).
3. Android: apply the `com.google.gms.google-services` plugin in
   `android/app/build.gradle.kts` and its classpath in
   `android/settings.gradle.kts` when you add the config file.
4. Without config files the app runs normally with push disabled.

## 5. Stripe

- Set `STRIPE_PUBLISHABLE_KEY` dart-define at build time and
  `STRIPE_SECRET_KEY` + `STRIPE_WEBHOOK_SECRET` as Supabase secrets.
- The paywall calls the `stripe-checkout` edge function and presents
  the native PaymentSheet. Fulfillment is the `stripe-webhook`
  function: it verifies the Stripe signature and sets
  `users.is_premium` on `payment_intent.succeeded`. Clients cannot set
  the flag themselves (column-level grants since migration
  20260806000000).

## 6. Android release

```bash
keytool -genkey -v -keystore upload-keystore.jks -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

Create `android/key.properties` (see Flutter docs). CI signs when
`ANDROID_KEYSTORE_BASE64` + `ANDROID_KEY_PROPERTIES` secrets exist.

```bash
flutter build appbundle --release --dart-define=... 
```

## 7. iOS release

```bash
flutter build ipa --release --dart-define=...
```

Requires Xcode signing (team + provisioning). CI produces an unsigned
archive; sign in your fastlane/App Store Connect pipeline.

## 8. GitHub Actions

- `ci.yml`: analyze, format, tests, Android debug APK, iOS no-codesign
  build on every push/PR to `main`.
- `deploy-web.yml`: web demo to GitHub Pages on every push to `main`.
- `release.yml`: on `v*` tags — signed AAB (when secrets present)
  attached to a GitHub release, plus unsigned iOS archive.

Repository secrets used: `SUPABASE_URL`, `SUPABASE_ANON_KEY`,
`STRIPE_PUBLISHABLE_KEY`, `ANDROID_KEYSTORE_BASE64`,
`ANDROID_KEY_PROPERTIES`.
