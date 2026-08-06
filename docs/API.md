# API

The app consumes Supabase's auto-generated REST (PostgREST) plus three
edge functions. All requests carry the standard Supabase headers
(`apikey`, `Authorization: Bearer <jwt>`).

## REST (PostgREST)

Base: `https://<project>.supabase.co/rest/v1`

Conventions used by the app and available to other clients:

- **Pagination**: `Range` headers or `limit`/`offset` query params;
  `search_products` RPC caps `page_size` at 100. `max_rows` is 1000.
- **Filtering**: PostgREST operators — `?category=eq.dairy`,
  `?valid_to=gt.2026-07-09`, `?product_id=in.(milk,eggs)`.
- **Searching**: `?name=ilike.*milk*` or
  `POST /rpc/search_products {"search_query":"milk","page_size":20}`.
- **Embedding**: `?select=*,shopping_items(*)` joins children in one
  round trip (used for lists and receipts).
- **Caching**: clients cache reads in Hive with a 6h TTL and serve
  stale-on-error. Catalog endpoints are safe to CDN-cache.
- **Rate limiting**: Supabase project-level limits apply; the AI proxy
  additionally caps `max_tokens` at 4096 per call.
- **Errors**: PostgREST errors surface as
  `{"code","message","details"}`; the app maps them to typed `Failure`s.

### Key endpoints

| Method & path | Purpose |
|---|---|
| `GET /stores?lat=gte.X&lat=lte.Y` | bounding-box store prefilter |
| `GET /products?category=eq.dairy&limit=50` | catalog browse |
| `GET /prices?product_id=in.(...)` | bulk prices for the optimizer |
| `GET /price_history?product_id=eq.X&order=recorded_at` | history chart |
| `GET /offers?valid_to=gt.now()` | active offers |
| `GET /coupons?select=*,user_coupons(user_id)` | coupons + clip state |
| `POST /user_coupons` / `DELETE ...` | clip / unclip |
| `GET /shopping_lists?select=*,shopping_items(*)` | lists with items |
| CRUD on `shopping_items`, `pantry`, `receipts`, `meal_plans` | user data |
| `POST /rpc/search_products` | paginated search |

## Edge functions

Base: `https://<project>.supabase.co/functions/v1`

### `POST /ai-proxy`  (JWT required)

Server-side LLM gateway — API keys never ship in the app binary.

```json
// request
{ "messages": [{"role":"user","content":"Build me a list under $40"}],
  "system": "You are a grocery assistant.",
  "max_tokens": 800, "temperature": 0.7 }
// response
{ "text": "..." }
```

Errors: `401` no session, `400` bad body, `503` LLM unconfigured,
`502` upstream failure.

### `POST /stripe-checkout`  (JWT required)

Creates a PaymentIntent for a one-time premium purchase (there is no
recurring Stripe Subscription — "monthly" is aspirational metadata).
Fulfillment and refund-revocation happen in `stripe-webhook`.

```json
// response
{ "clientSecret": "pi_..._secret_..." }
```

The client feeds this to Stripe's PaymentSheet. Errors: `401`, `503`
(no `STRIPE_SECRET_KEY`), `502`.

### `POST /price-alerts`  (scheduler-invoked)

Cron-style function (schedule hourly in the dashboard). Finds ≥15%
price drops for favorited products and coupons expiring within 48h,
then inserts `notifications` rows with the service role. Returns
`{ "created": <n> }`.

## Client HTTP stack

Non-Supabase HTTP (direct LLM providers) goes through a shared Dio
instance with timeouts and an interceptor that maps transport/status
errors to the app's `Failure` types
([dio_client.dart](../lib/core/network/dio_client.dart)).
