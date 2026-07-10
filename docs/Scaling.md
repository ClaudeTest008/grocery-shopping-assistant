# Scaling & Extension Guide

## How to add a new grocery chain

Everything about a chain is data, not code:

1. **Store rows**: insert into `stores` (`id`, `name`, `chain` slug,
   coords, `opening_hours` jsonb). Demo mode: add to `DemoSeed.stores`.
2. **Prices**: upsert `(product_id, store_id)` rows into `prices` with
   the service role; the `on_price_change` trigger archives history
   automatically.
3. **Marker color** (optional): add the chain slug to `_chainColors` in
   `map_screen.dart`; unknown chains fall back to the theme primary.
4. **Offers/coupons**: plain inserts; the UI groups by store
   automatically.

No client release is needed for steps 1–2 and 4.

## How to add a new country

- **Currency**: already per-user (`UserPreferences.currency`,
  `Formatters.currency` via `intl`). Add the code to `_currencies` in
  `settings_screen.dart`.
- **Units**: `metric`/`imperial` preference exists; product `unit`
  strings are free-form per catalog.
- **Stores/catalog**: country is just more `stores` + `products` +
  `prices` rows. The nearby-store query is a lat/lng bounding box —
  location-agnostic.
- **Language**: strings are currently English literals. Localization
  path: `flutter gen-l10n` (intl is already a dependency); extract
  strings feature-by-feature. This is the only code-level work.
- **Maps**: OSM/CARTO tiles are worldwide; nothing to do.

## How to integrate commercial grocery pricing APIs

The integration point is one interface per concern — implement, then
switch the provider:

| Data | Interface | Where to plug in |
|---|---|---|
| Prices/catalog | `ProductRepository` | new `KrogerApiProductRepository` etc., or (better) a server-side ingestion job writing to `prices` so all clients benefit |
| Stores | `StoreRepository` | same pattern |
| Offers/coupons | `OfferRepository` / `CouponRepository` | same |
| Routing/traffic | `BasketOptimizer` inputs | replace haversine tour with an OSRM/Google Directions matrix; the optimizer only needs distances+durations |
| LLM | `LlmClient` | already pluggable (`LLM_PROVIDER`), or point at the `ai-proxy` edge function |

Recommended architecture: **ingest server-side** (scheduled edge
function or worker per chain: Kroger API, Walmart affiliate feed,
weekly-ad scrapers) → normalize into `products`/`prices` → clients stay
unchanged. Client-side API adapters are only worth it for
user-authenticated data (loyalty accounts).

## How to scale to millions of users

Current architecture is already mostly stateless-client + Postgres:

1. **Reads**: catalog endpoints (`stores`, `products`, `prices`,
   `offers`) are public and cacheable — put a CDN in front of PostgREST
   (or use Supabase's built-in caching + read replicas). Client-side 6h
   Hive TTL already cuts repeat traffic.
2. **Writes**: user data is owner-partitioned by RLS; Postgres scales to
   millions of users of this shape. Move `analytics` to an append-only
   pipeline (e.g. Tinybird/ClickHouse) when it grows hot.
3. **Search**: swap `ilike` product search for the existing FTS index
   (`products_name_trgm_idx`) via `search_products`, then to a search
   service (Meilisearch/Typesense) past ~1M products.
4. **Geo**: replace the lat bounding box with PostGIS (`geography` +
   GiST index) once store count exceeds a few thousand.
5. **Optimizer**: pure client-side Dart, O(C(6,3)·3!) per run — zero
   server cost; it scales with users for free. If routing matrices come
   from OSRM, cache distance matrices per (home-cell, store-set).
6. **AI**: all LLM traffic through `ai-proxy` — add per-user rate limits
   and provider failover there; keys never ship in clients.
7. **Push fan-out**: `device_tokens` table exists; add a worker consuming
   `notifications` inserts → FCM batch sends.
8. **Map tiles**: at real scale, self-host or contract a tile provider
   (Protomaps/MapTiler) instead of the free CARTO endpoints; only the
   `urlTemplate` in `map_screen.dart` changes.
