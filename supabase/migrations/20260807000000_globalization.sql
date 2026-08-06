-- Globalization: country becomes data, not an assumption.
-- The client already works from these columns being absent (nullable /
-- defaulted), so this migration is forward-compatible with old builds.

-- Stores belong to a country and a city. Existing rows are the legacy
-- US demo dataset.
alter table public.stores
  add column country text not null default 'US',
  add column city text;

create index stores_country_idx on public.stores (country);
-- The bounding-box query stays global; country narrows it when the
-- client filters (country, lat).
create index stores_country_lat_idx on public.stores (country, lat);

-- Products: regional barcode variants, availability, localized names.
-- names_i18n: {"es": "Leche Entera", "fr": "Lait Entier", ...} — the
-- catalog serves one language per country dataset today; this column
-- lets one shared catalog carry all of them when catalogs merge.
alter table public.products
  add column barcodes text[] not null default '{}',
  add column countries text[],
  add column names_i18n jsonb;

create index products_barcodes_idx on public.products using gin (barcodes);
create index products_countries_idx on public.products using gin (countries);

-- Prices already carry currency (default USD); widen the accepted set
-- is unnecessary — ISO 4217 is free text by design. No change needed.
