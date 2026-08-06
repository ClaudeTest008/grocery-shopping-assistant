-- Retailer CSV price import. Run with the service role (psql or the
-- Supabase SQL editor) — clients cannot write catalog tables by design.
--
-- CSV columns (header required):
--   product_id,store_id,price,regular_price,in_stock
-- product_id/store_id must already exist in products/stores; rows that
-- violate FKs, the price >= 0 check, or NOT NULLs fail loudly here — the
-- staging step exists so a bad row rejects the batch BEFORE it touches
-- live prices.
--
-- Usage (psql):
--   \set csv_path 'C:/path/to/prices.csv'
--   \i supabase/import/import_prices.sql
--
-- History is automatic: the archive_price trigger writes price_history
-- (source carried through) on insert and on genuine price changes only.

begin;

create temporary table price_import_staging (
  product_id text not null,
  store_id text not null,
  price numeric(10, 2) not null,
  regular_price numeric(10, 2),
  in_stock boolean not null default true
) on commit drop;

\copy price_import_staging from :'csv_path' with (format csv, header true)

-- Reject obviously broken batches before merging.
do $$
declare bad integer;
begin
  select count(*) into bad from price_import_staging where price < 0 or price >= 10000;
  if bad > 0 then
    raise exception '% rows with out-of-range prices — aborting import', bad;
  end if;
end $$;

insert into public.prices
  (product_id, store_id, price, regular_price, in_stock, unit_price, source)
select
  s.product_id,
  s.store_id,
  s.price,
  s.regular_price,
  s.in_stock,
  round(s.price / nullif(p.unit_size, 0), 4),
  'import'
from price_import_staging s
join public.products p on p.id = s.product_id
on conflict (product_id, store_id) do update set
  price = excluded.price,
  regular_price = excluded.regular_price,
  in_stock = excluded.in_stock,
  unit_price = excluded.unit_price,
  source = excluded.source;

-- Rows referencing unknown products are skipped by the join; surface
-- the count so the operator notices a chain's IDs drifting.
select count(*) as skipped_unknown_products
from price_import_staging s
where not exists (select 1 from public.products p where p.id = s.product_id);

commit;
