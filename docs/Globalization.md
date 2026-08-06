# Globalization

The US is one supported country among nine. Everything country-specific
is **data** on a [CountryConfig](../lib/core/geo/countries.dart);
business logic (optimizer, verdicts, matcher, sync, budgets) never
branches on country.

## Phase 1 audit — every US assumption found, and its fate

| Location | Assumption | Replacement |
|---|---|---|
| `demo_seed.dart` (whole file) | Austin stores, US chains, USD, `oz/lb/gal`, US brands | Generated per `CountryConfig`: chains, city coords, currency, metric units, localized names |
| `location_service.dart:34` | `demoLocation` = Austin constant | Getter → selected country's city centre |
| `map_screen.dart:23,127` | `_austin` fallback + Austin `GeoPoint` | `_fallbackCenter` from selected country; camera fits loaded stores — no hardcoded bounds |
| `receipt_parser.dart` | US chains list, `$`-only prices, MM/DD dates | Chain map generated from the registry (all countries); `$/€/£`; `dmyDates` per country + impossible-date disambiguation; EU total/tax words (totale, gesamt, totaal, importe, IVA, MwSt, BTW, TVA) |
| `price_verdict.dart:_money` | Hardcoded `$` | `Formatters.currency` (selected-country default) |
| `formatters.dart` | `USD` default parameter | Mutable `defaultCurrency`, set at boot / country switch |
| `user_preferences.dart` defaults | `USD` + `imperial` | Fresh installs seed from the country (`_countryDefaults`) |
| `receipt_repositories.dart` seed | `aldi-1/heb-1/walmart-1/kroger-1` rotation | First four stores of the selected country |
| `notification_repository.dart` demo rows | "at Kroger", "at Walmart" | Genericized |
| `settings_screen.dart` | No country control | Country row (+ map switcher + onboarding selector) |
| `stores` table / model | No country column | `country`/`city` columns + indexes; nearby query filters by country so countries load independently |
| `optimize_screen.dart` | "all-in total" silent about tax | "VAT incl." / "before tax" from `pricesIncludeVat` |
| Store query, `stores_screen` copy | (already metric km — no change) | — |

Not US-specific and deliberately unchanged: CARTO/OSM tiles (global),
`distanceKm` (metric already), bounding-box store query (works at any
latitude), Open Food Facts (world catalog).

## The hierarchy

World → **Country** (`CountryConfig`) → City (demo city per country;
more cities = more data rows) → **Chain** (`ChainSpec`) → **Store**
(`country`/`city` columns) → Departments (`category`) → **Products**
(shared catalog, localized names, `countries` availability,
`barcodes[]`). Region/state exists in the model as data (`city`,
coordinates) rather than as a class — add a `region` column when a
real dataset needs one; nothing branches on it.

## Countries & chains shipped

| Country | City | Chains |
|---|---|---|
| 🇪🇸 Spain | Madrid | Mercadona, Carrefour, Lidl, Aldi, Dia, Alcampo, Consum, Eroski |
| 🇵🇹 Portugal | Lisbon | Continente, Pingo Doce, Auchan, Lidl, Aldi |
| 🇫🇷 France | Paris | Carrefour, E.Leclerc, Intermarché, Auchan, Monoprix |
| 🇩🇪 Germany | Berlin | Edeka, Rewe, Kaufland, Lidl, Aldi Nord, Aldi Süd |
| 🇮🇹 Italy | Milan | Esselunga, Coop, Conad, Eurospin |
| 🇳🇱 Netherlands | Amsterdam | Albert Heijn, Jumbo, PLUS, Lidl |
| 🇧🇪 Belgium | Brussels | Colruyt, Delhaize, Carrefour, Lidl |
| 🇮🇪 Ireland | Dublin | Tesco, SuperValu, Dunnes Stores, Lidl, Aldi |
| 🇺🇸 United States | Austin | Aldi, Walmart, Kroger, Target, H-E-B, Trader Joe's, Whole Foods, Costco |

Each config also carries: currency (EUR/USD), food VAT rate +
`pricesIncludeVat`, languages, `dmyDates`, units, and a
cost-of-living `priceLevel` that scales the shared baseline prices
(pinned by test: Irish milk > Portuguese milk).

## Demo data per country

Generated, deterministic, and honest about being a demo:
- **Stores**: first three chains get two branches, the rest one, at
  fixed offsets (~0.5–5 km) around the city centre. Addresses are
  generic district labels on purpose — we do not fabricate real street
  addresses for real shops.
- **Products**: one shared 104-item catalog; names in the country's
  primary language (26 base products × es/pt/fr/de/it/nl, English for
  IE/US); metric countries get `l/g/kg` with converted pack sizes;
  US-brand base products are unbranded outside the US.
- **Prices**: baseline × country priceLevel × chain multiplier ±
  deterministic jitter; currency from the config; promos/stock-outs
  derived per store id so optimizer demos stay interesting everywhere.
- **Offers/coupons/receipts/notifications**: reference the generated
  stores, symbols follow the currency.

## Country selection & switching

- **Automatic**: device locale country on first launch
  (`SelectedCountry.resolveInitial`), fallback US.
- **Manual**: onboarding header selector, Settings → Country, map 🌍
  button — all one `showCountryPicker` flow.
- **Switching** wipes local demo data (stated in the confirm dialog),
  persists the choice, re-seeds preferences (currency/units), and
  restarts the app scope (`AppBootstrap.restartGlobal`) so every
  provider re-reads. Telemetry: `country_switched {from, to}`.

## Localization architecture

Three layers, each data-driven:
1. **Config** (`CountryConfig`): currency, units, VAT, date order.
2. **Catalog language**: product names localized at the data layer —
   the UI renders `product.name` and never knows about languages. The
   connected schema mirrors this (`products.names_i18n` jsonb) so one
   shared catalog can carry all languages when catalogs merge.
3. **UI strings**: still English (deliberate: beta testers are
   English-speaking). The seam for `flutter gen-l10n` is clean — no
   country logic lives in widgets — and full UI translation is v1.1
   scope, listed under limitations.

## Database changes (migration 20260807000000)

`stores.country` (+ default `'US'` for legacy rows, indexed, and a
`(country, lat)` index for the narrowed nearby query), `stores.city`,
`products.barcodes text[]` (GIN), `products.countries text[]` (GIN),
`products.names_i18n jsonb`. Backward-compatible: every column is
defaulted or nullable, old clients keep working.

## Adding country #10 (the test of this design)

1. Add a `CountryConfig` entry (chains, city, VAT, currency…).
2. Add a product-name map for its language if new (26 strings).
3. `flutter test` — the registry/generation tests run for every entry
   automatically.
Nothing else: no screen, repository, optimizer, parser or migration
changes. Non-eurozone countries (UK/CH/PL) need only their currency
code in the config — `Formatters` and the £ symbol path already work.

## European production upgrade (2026-08-06)

Beyond the base globalization:
- **Chain coverage grew to 66 chains** (ES 10, PT 7, FR 8, DE 8, IT 7,
  NL 6, BE 6, IE 5, US 8) matching the production spec, each with a
  `privateLabel` where one exists (Hacendado, Ja!, Gut&Günstig, Boni,
  Marque Repère…) — data awaiting private-label product ranges.
- **Store realism as data**: varied opening hours (discounters
  9:00–20:00, city-centre full-liners to 22:00, short EU Sundays,
  Germany Sunday-closed), `hasParking` (city-centre = no),
  `wheelchairAccessible` (one legacy branch per country), `services`
  (bakery → full counters by segment). All deterministic, all shown in
  the store sheet, all pinned by tests.
- **Catalog: 40 base products / 160 entries across 12 categories**,
  adding health, baby, pet, household and drinks with translations in
  all six languages, EU allergen chips (milk, gluten, peanuts, soy,
  egg — real facts only), and nutrition panels dropped from non-food.
  `ingredients` exists as a column/field and stays null in demo data —
  populated by real catalogs, never fabricated. Alcohol: the category
  model gates by data (`category` + age flag when a real dataset
  needs it); deliberately not implemented.
- **Localization plumbing**: `flutter_localizations` delegates +
  `supportedLocales` from the registry, `Intl.defaultLocale` set per
  country (dates/numbers render locale-correct app-wide),
  accent-insensitive search and receipt matching (`foldDiacritics`),
  AI prompts instructed to reply in the country's language (JSON keys
  stay English), currency symbols in input fields from the selected
  currency, optimizer explanations through `Formatters.currency`.
- **Map**: city/postal-code/address search via OSM Nominatim (real,
  key-free, country-biased, one request per explicit submit),
  closing-soon filter + store-sheet chip, city matched in store
  search. Route modes: the navigation handoff URL accepts
  `travelmode` — walking/cycling/transit are a parameter away, not an
  architecture change.
- **Shopping intelligence**: every option card states its coverage
  ("Prices 18 of 20 items" / "All items priced") — confidence as a
  countable fact, never a score pulled from air.

## Remaining limitations (honest)

- UI chrome is English everywhere; only catalog data is localized.
- One demo city per country; "Region/Province" is data waiting for a
  real dataset, not a modeled layer.
- VAT is a single food rate per country (real VAT has category bands);
  used for labeling, never for price math — prices are VAT-inclusive
  as scanned/fed.
- Demo store coordinates are city-centre offsets, not real branch
  locations (by design).
- AI assistant replies and voice input remain English; es-ES etc.
  speech locales are untested.
- Receipt parser keywords cover the six launch languages, not all
  retailer formats — receipts remain best-effort everywhere.
