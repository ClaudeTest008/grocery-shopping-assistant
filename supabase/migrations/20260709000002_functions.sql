-- Helper invoked by the price-alerts edge function: products whose
-- current price sits >= threshold_percent below their 90-day average.
create or replace function public.find_price_drops(threshold_percent numeric)
returns table (
  product_id text,
  product_name text,
  store_id text,
  store_name text,
  price numeric,
  avg_price numeric,
  percent_below numeric
)
language sql
stable
as $$
  with averages as (
    select
      ph.product_id,
      avg(ph.price) as avg_price
    from public.price_history ph
    where ph.recorded_at > now() - interval '90 days'
    group by ph.product_id
    having count(*) >= 5
  )
  select
    p.product_id,
    pr.name as product_name,
    p.store_id,
    s.name as store_name,
    p.price,
    round(a.avg_price, 2) as avg_price,
    round((1 - p.price / a.avg_price) * 100, 0) as percent_below
  from public.prices p
  join averages a on a.product_id = p.product_id
  join public.products pr on pr.id = p.product_id
  join public.stores s on s.id = p.store_id
  where a.avg_price > 0
    and (1 - p.price / a.avg_price) * 100 >= threshold_percent;
$$;

-- Paginated product search used by the REST layer
-- (GET /rest/v1/rpc/search_products).
create or replace function public.search_products(
  search_query text default '',
  category_filter text default null,
  page_size int default 20,
  page_offset int default 0
)
returns setof public.products
language sql
stable
as $$
  select *
  from public.products p
  where (category_filter is null or p.category = category_filter)
    and (
      search_query = ''
      or p.name ilike '%' || search_query || '%'
      or p.brand ilike '%' || search_query || '%'
    )
  order by p.name
  limit least(page_size, 100)
  offset page_offset;
$$;
