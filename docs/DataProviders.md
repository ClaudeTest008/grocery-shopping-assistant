# Data providers

Where prices and product data come from, what is real, and what is
deliberately not built. Provenance is recorded on every price row
(`prices.source`, `price_history.source`, `price_submissions.source`)
so seeded data can never masquerade as a feed.

## Implemented (real, shipping)

### 1. Receipts — first-party live prices
Every saved receipt runs through `ReceiptPriceRecorder`
([receipt_price_recorder.dart](../lib/features/receipts/domain/receipt_price_recorder.dart)):
line items that **confidently** match a catalog product (exact
normalized name, or the full catalog name inside the receipt line —
`ProductMatcher`, deliberately conservative because a wrong price
poisons history) become price observations with `source='receipt'`.
The shopper sees them in their own price history immediately;
connected builds store them in `price_submissions` for review.

### 2. Community price reports
"Report a price" on the product screen. Same pipeline,
`source='community'`. Server-side guardrails: value range check
(0 < p < 10000), 200/day rate limit keyed on server-set `created_at`,
owner-only RLS, immutable rows.

**Review → promotion**: an operator (service role) inspects
`price_submissions` where `status='pending'` and calls
`select approve_price_submissions(array['<id>', ...]::uuid[]);`
which flips them to `approved` and copies them into the shared
`price_history` in one transaction. Rows are promoted at most once.

### 3. Retailer CSV import
[supabase/import/import_prices.sql](../supabase/import/import_prices.sql) —
service-role psql script: staging table → validation (range check
aborts the batch, unknown product IDs skipped and counted) → upsert
into `prices` with `source='import'`. History is automatic via the
`archive_price` trigger, which skips no-op updates so a daily import
of unchanged prices doesn't bloat history or skew averages.
CSV columns: `product_id,store_id,price,regular_price,in_stock`.

### 4. Open Food Facts — barcode identification
[open_food_facts_client.dart](../lib/features/products/data/open_food_facts_client.dart),
live against `world.openfoodfacts.org/api/v2` (no key, ODbL license,
User-Agent identifies the app; response contract verified 2026-08-06).
Used when a scanned barcode is not in the catalog: identifies the
product (name/brand/image) so the scan adds a named list item or
prefills search instead of dead-ending. **Metadata only** — OFF does
not know store prices, and we do not pretend it does.

### 5. Seed data
`DemoSeed` (demo mode, on-device) and `supabase/seed.sql`
(`source='seed'`). Kept fully functional: every feature works with
zero external dependencies, and provenance keeps it distinguishable.

## Documented, not implemented — and why

| Provider | Status | Reason |
|---|---|---|
| Kroger Public API | Real API, free registration | Needs a registered API key to verify against. Building the adapter without credentials would ship untested code that *looks* integrated — exactly the fabrication this project refuses. The CSV path ingests Kroger data today; a native adapter is v1.1 work once keys exist. |
| Walmart / Target / Aldi APIs | No public price API | Affiliate/partner programs only; no price feed offered. |
| Store-website scraping | Rejected | Violates retailer terms of service; brittle; legal risk. Not acceptable for a commercial product. |
| Instacart / delivery-platform prices | Rejected for now | Marked-up prices that misrepresent shelf prices — would corrupt the "is this a good price" verdicts. |
| Open Prices (OFF's price project) | Watch | Promising crowdsourced price DB, but coverage is currently too sparse in the target market to serve verdicts from. Re-evaluate for v1.1. |
| Supplier/wholesaler catalogs | Supported via CSV path | Same staging pipeline as retailer CSV (`import_prices.sql`); product rows go through the products table with `countries`/`names_i18n`. No separate adapter until a supplier feed with a different shape exists. |
| European retailer APIs (Carrefour, Tesco, Rewe…) | No public price APIs | Partner/affiliate programs only; the CSV path ingests partner exports today. Registry `ChainSpec` is the anchor an adapter would key on. |
| Scraping services | Rejected | Same grounds as store-website scraping: retailer ToS, brittleness, legal exposure — commercial products don't build on it. |

## Operational characteristics

**Legal.**
- Open Food Facts: ODbL. We read metadata and attribute in-UI
  ("identified via Open Food Facts"); we do not currently redistribute
  a derived database. If OFF-derived rows ever enter the shared
  catalog, ODbL share-alike applies to that extract — decide then.
- Receipts: the user's own data, processed on-device (OCR) — no
  retailer relationship implied. Parsed rows are user content.
- Community prices: user-generated facts (prices are not
  copyrightable); moderation gate exists for quality, not rights.
- CSV imports: only under an agreement with the data owner. Scraping
  remains rejected (retailer ToS).

**Rate limits.**
- Open Food Facts asks ≤100 req/min for product lookups; we send one
  request per unknown-barcode scan (human-paced, orders of magnitude
  below), identify via User-Agent, and treat failures as "not found"
  — no retry loops.
- Inbound: community submissions 200/day/user (DB trigger,
  server-clock keyed); ai-proxy 60/hr/user (fail-closed).

**Caching.**
- Prices per product: 6h TTL, offline-fallback-only (network first).
- Stores: 24h TTL; offers: 1h TTL — same pattern, auth errors rethrow
  so an expired session is never masked by cache.
- OFF responses: not cached (each scan is a fresh identification; a
  hit usually converts into a list item immediately).

**Synchronization & conflict resolution.**
- Catalog flows one way (operator → Supabase → clients); clients never
  write catalog tables, so catalog conflicts cannot exist.
- User data is last-write-wins full-row today, with one exception:
  offline check-off replay writes ONLY the `checked` column so it can
  never clobber newer online edits. Multi-device concurrent editing is
  not advertised; before it is, meal_plans (whole-jsonb upsert) needs
  per-meal merge or compare-and-swap — tracked in the roadmap.
- Price observations are immutable append-only rows; "conflict" is
  resolved by provenance + moderation, not by overwriting.

## Design rules

- Business logic never knows the source: the optimizer and price
  verdicts consume `Price`/`PricePoint` regardless of provenance.
  Swapping seed → import → official feeds requires zero logic changes.
- No provider-registry abstraction exists, on purpose: there is one
  read path (Supabase tables) and several *write* paths into it. Build
  the registry when a second read-path provider actually exists.
- User-visible honesty: history charts caption how many points came
  from the user's own receipts/reports; Beta docs state that prices
  are seeded until a feed is connected.
