# Privacy Policy — Grocery Shopping Assistant (Beta)

_Last updated: 2026-07-30_

This policy describes what the Grocery Shopping Assistant app ("the
app") collects, where it goes, and the controls you have. It is written
to be read, not to be skimmed past.

## The short version

- **Demo mode collects nothing.** Without an account, every piece of
  data (lists, pantry, receipts, settings) lives only on your device and
  never leaves it.
- With an account, your shopping data is stored on our backend
  (Supabase), scoped to you by row-level security, and used for nothing
  except showing it back to you.
- You can export everything and delete everything, in-app, at any time.

## What we store, and where

| Data | Demo mode | With an account |
|---|---|---|
| Shopping lists & items | This device only | Our database, owner-only access |
| Pantry, receipts, meal plans | This device only | Our database, owner-only access |
| Preferences (budget, diet, units) | This device only | This device + synced copy |
| Email address | Not collected | For sign-in and nothing else |
| Location | Used on-device to sort stores; never stored or transmitted | Same |
| Receipt photos | Processed on-device (OCR); the photo is not uploaded | Same |

## Analytics and errors

With an account, the app records a small number of product events
(e.g. "an optimization ran", "onboarding completed") and error reports.
Error text is truncated to a short summary before it is stored, and all
analytics rows — including error reports — are deleted with your account.
Demo mode sends nothing. There is no advertising, no third-party
analytics SDK, and no sale of data of any kind.

## External lookups you trigger

Two features call open, non-commercial services directly, in every
mode including demo — only when you use them:

- **Scanning a barcode** the catalog doesn't know sends that barcode
  (nothing else) to Open Food Facts (openfoodfacts.org) to identify
  the product.
- **Searching a place on the map** (a city or postal code that matches
  no store) sends that search text (nothing else) to OpenStreetMap's
  Nominatim (openstreetmap.org) to find the location.

Neither request carries your account, device identifiers, or
location; both services receive only what you typed or scanned.

## AI features

When you use the assistant, meal planner or trip explanations, the text
of your request (and relevant context such as list item names) is sent
to a large-language-model provider via our server-side proxy. Your API
credentials never exist; the provider sees the request content but no
account identifiers. In demo mode, AI responses are generated locally
and nothing is sent anywhere.

## Your controls

- **Export my data** (Settings → Account & data) — a JSON copy of your
  lists, pantry, receipts, current-week meal plan and preferences.
- **Delete account** (Settings → Account & data) — permanently removes
  your account and all server-side data, immediately, via cascading
  deletion. In demo mode it erases all local data.

## Data retention

Account data is kept until you delete it. Deleted means deleted — the
deletion path removes the auth record and every row that references it.

## Contact

support@grocery-assistant.app

Changes to this policy will be noted in the app's changelog.
