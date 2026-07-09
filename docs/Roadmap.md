# Roadmap

## Now (v1.0 — shipped in this repo)

- Basket optimizer (1–3 stores, coupons, travel cost, explanations)
- Lists (voice, barcode, AI generation), products, price history
- Stores, map, offers, digital coupons
- Pantry with expiry tracking; receipt OCR → spending analytics
- AI meal planner + assistant behind a provider-agnostic LLM layer
- Demo mode: full app with zero backend
- Supabase schema/RLS/edge functions; CI for analyze/test/builds

## Next (v1.1)

- **Live price data ingestion** — the architecture isolates this behind
  `ProductRepository`/`prices`; add per-chain ingestion jobs (retailer
  APIs / weekly-ad feeds) writing via service role.
- Realtime shared lists (schema already in the realtime publication)
- Push notification fan-out worker consuming `device_tokens`
- Receipt line-item → catalog product matching (fuzzy match) so scans
  update pantry automatically
- Recipe import (URL → ingredients → list)

## Later (v1.2+)

- Price prediction upgrade: replace linear trend with seasonal model
  served from an edge function
- Loyalty-card wallet and per-chain member pricing
- Household sharing (multi-user lists & pantry)
- In-store mode: aisle sorting, offline-first checklists
- Web/desktop targets (repositories are platform-agnostic)
- Localization (intl scaffolding in place, strings currently English)

## Known limitations

- Live grocery prices are mocked/seeded — commercial feeds need
  contracts; see the ingestion point above.
- iOS release signing is intentionally left to the owner's pipeline.
- `users.is_premium` flips via Stripe webhook you must configure.
