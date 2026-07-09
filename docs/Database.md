# Database

PostgreSQL via Supabase. Migrations live in `supabase/migrations/` and
apply in order with `supabase db push` (or `supabase db reset` locally,
which also runs `seed.sql`).

## Entity overview

```
auth.users ─1:1─ users ─┬─< shopping_lists ─< shopping_items >─ products
                        ├─< pantry          >─ products
                        ├─< receipts ─< receipt_items
                        ├─< meal_plans (meals jsonb)
                        ├─< favorites >─ products / stores
                        ├─< notifications
                        ├─< user_coupons >─ coupons
                        ├─< device_tokens
                        └─1:1 preferences (data jsonb)

stores ─< prices >─ products
stores ─< offers >─ products (optional)
products ─< price_history   (auto-archived by trigger)
```

## Tables

| Table | Purpose | Notes |
|---|---|---|
| `users` | Profile mirror of `auth.users` | Created by `on_auth_user_created` trigger |
| `stores` | Store locations & hours | `opening_hours` jsonb `{ "1": "08:00-21:00", ... }` |
| `products` | Catalog | `barcode` unique, `tags text[]`, `nutrition` jsonb, FTS index on name |
| `prices` | Current price per (product, store) | unique pair; `regular_price` marks promos |
| `price_history` | Time series | inserted by `on_price_change` trigger on `prices` |
| `offers` | Weekly ads, BOGO, cashback, loyalty | typed check constraint |
| `coupons` | Store/product/basket coupons | amount XOR percent enforced by check |
| `user_coupons` | Clip state per user | PK (user_id, coupon_id) |
| `shopping_lists` / `shopping_items` | Lists | items cascade on list delete |
| `pantry` | Home inventory | expiry index for alerts |
| `receipts` / `receipt_items` | Scanned purchases | feeds analytics |
| `meal_plans` | One row per user-week | `meals` jsonb array; unique (user, week) |
| `favorites` | Starred products/stores | drives price-drop pushes |
| `notifications` | In-app inbox | written by edge functions (service role) |
| `preferences` | User settings | single jsonb doc, local-first sync |
| `analytics` | Client event log | insert-only for users |
| `device_tokens` | FCM tokens | for push fan-out |

## Row Level Security

- **Catalog** (`stores`, `products`, `prices`, `price_history`, `offers`,
  `coupons`): `select` for everyone; no client write policies — ingestion
  jobs use the service role.
- **User data**: owner-only `for all` policies on `auth.uid()`;
  child tables (`shopping_items`, `receipt_items`) check ownership
  through their parent.
- **notifications**: users can read/update (mark read) their own;
  inserts come from edge functions.
- **Storage**: `receipts` bucket is private with per-user folder
  policies; `product-images` is public-read.

## SQL functions

- `find_price_drops(threshold_percent)` — products currently ≥ N% below
  their 90-day average (needs ≥5 history points). Used by the
  `price-alerts` cron function.
- `search_products(search_query, category_filter, page_size, page_offset)`
  — paginated catalog search for REST consumers.

## Local development

```bash
supabase start          # local stack (Docker)
supabase db reset       # apply migrations + seed.sql
supabase functions serve ai-proxy
```
