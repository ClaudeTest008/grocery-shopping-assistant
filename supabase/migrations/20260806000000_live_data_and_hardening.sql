-- Beta validation: real-data ingestion (price provenance + user price
-- submissions) and hardening confirmed by the 2026-08-06 audit.

-- ---------------------------------------------------------------------
-- 1. Price provenance. Every price row now says where it came from, so
--    seeded demo data can never masquerade as a real feed.
-- ---------------------------------------------------------------------
alter table public.prices
  add column source text not null default 'seed'
  check (source in ('seed', 'import', 'official'));

-- The Price model and the optimizer's stock-awareness already use
-- in_stock, but the table never had the column — connected builds
-- silently defaulted every row to "in stock". Real feeds carry it.
alter table public.prices
  add column in_stock boolean not null default true;

alter table public.price_history
  add column source text not null default 'catalog';

-- archive_price: carry provenance through, and skip no-op updates — a
-- daily import upserting an unchanged price must not bloat history and
-- skew 90-day averages. Definer + pinned search_path so the trigger
-- works regardless of the writing role's grants.
create or replace function public.archive_price()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.price_history (product_id, store_id, price, source, recorded_at)
  values (new.product_id, new.store_id, new.price, new.source, now());
  return new;
end;
$$;

drop trigger on_price_change on public.prices;
create trigger on_price_insert
  after insert on public.prices
  for each row execute function public.archive_price();
create trigger on_price_update
  after update of price on public.prices
  for each row
  when (old.price is distinct from new.price)
  execute function public.archive_price();

-- ---------------------------------------------------------------------
-- 2. Community/receipt price submissions — the app's first-party live
--    data. Owner-only until an operator promotes them into the shared
--    price_history; the submitter always sees their own rows.
-- ---------------------------------------------------------------------
create table public.price_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  product_id text not null references public.products (id) on delete cascade,
  store_id text references public.stores (id) on delete set null,
  price numeric(10, 2) not null check (price > 0 and price < 10000),
  source text not null default 'community'
    check (source in ('community', 'receipt')),
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  -- When the user saw the price (a receipt may be days old)...
  submitted_at timestamptz not null default now(),
  -- ...vs when the row was written; rate limiting keys on this one so
  -- backdating cannot dodge it.
  created_at timestamptz not null default now(),
  -- submitted_at flows into shared price_history.recorded_at on
  -- approval, where it shapes 90-day averages — so it may not be in
  -- the future nor implausibly old. A receipt is at most weeks old.
  check (
    submitted_at <= created_at + interval '1 hour'
    and submitted_at >= created_at - interval '30 days'
  )
);

create index price_submissions_user_product_idx
  on public.price_submissions (user_id, product_id, submitted_at);
create index price_submissions_status_idx
  on public.price_submissions (status, created_at);

alter table public.price_submissions enable row level security;
create policy "own submissions insert" on public.price_submissions
  for insert with check (auth.uid() = user_id and status = 'pending');
create policy "own submissions read" on public.price_submissions
  for select using (auth.uid() = user_id);
-- No update/delete policies: observations are immutable; moderation and
-- promotion happen with the service role.

-- Abuse guard: a person reports a handful of prices per trip; hundreds
-- a day is a script. Counts by created_at (server-set).
create or replace function public.check_submission_rate()
returns trigger
language plpgsql
as $$
begin
  if (
    select count(*) from public.price_submissions
    where user_id = new.user_id
      and created_at > now() - interval '1 day'
  ) >= 200 then
    raise exception 'Daily price-submission limit reached';
  end if;
  return new;
end;
$$;

create trigger price_submissions_rate_limit
  before insert on public.price_submissions
  for each row execute function public.check_submission_rate();

-- Operator path: approve reviewed submissions and copy them into the
-- shared history in one transaction. The pending->approved transition
-- guarantees a row is promoted at most once. Service role only.
create or replace function public.approve_price_submissions(ids uuid[])
returns integer
language plpgsql
security definer set search_path = public
as $$
declare n integer;
begin
  with approved as (
    update public.price_submissions
       set status = 'approved'
     where id = any (ids) and status = 'pending'
     returning product_id, store_id, price, source, submitted_at
  )
  insert into public.price_history (product_id, store_id, price, source, recorded_at)
  select product_id, store_id, price, source, submitted_at from approved;
  get diagnostics n = row_count;
  return n;
end;
$$;

revoke execute on function public.approve_price_submissions(uuid[])
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. Entitlement fix (audit blocker): the unrestricted own-row UPDATE
--    policy let any user set is_premium=true on themselves. Column-level
--    grants limit client writes to profile fields; RLS still scopes to
--    the owner's row. is_premium becomes service-role-writable only
--    (set by the Stripe webhook).
-- ---------------------------------------------------------------------
revoke update on public.users from authenticated, anon;
grant update (display_name, avatar_url) on public.users to authenticated;

-- Same shape for notifications: clients may only flip the read flag,
-- not rewrite title/body/route of stored notifications.
revoke update on public.notifications from authenticated, anon;
grant update (read) on public.notifications to authenticated;

-- ---------------------------------------------------------------------
-- 4. Freshness: the app shows "updated Xd ago" from prices.updated_at,
--    so the column must actually update.
-- ---------------------------------------------------------------------
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger prices_touch_updated_at
  before update on public.prices
  for each row execute function public.touch_updated_at();

-- ---------------------------------------------------------------------
-- 5. Indexes matched to the queries the app actually runs.
--    The old tsvector index never served the client's ilike '%q%'.
-- ---------------------------------------------------------------------
create extension if not exists pg_trgm;
create index products_name_trgm_gin_idx
  on public.products using gin (name gin_trgm_ops);
create index products_brand_trgm_gin_idx
  on public.products using gin (brand gin_trgm_ops);
drop index if exists public.products_name_trgm_idx;
-- Redundant with unique (product_id, store_id):
drop index if exists public.prices_product_idx;
-- No caller anywhere in app or functions:
drop index if exists public.stores_chain_idx;

create index offers_valid_to_idx on public.offers (valid_to);
create index user_coupons_coupon_idx on public.user_coupons (coupon_id);
create index favorites_product_idx on public.favorites (product_id);

-- ---------------------------------------------------------------------
-- 6. categories() previously selected every product row and deduped
--    client-side — silently truncated at max_rows once the catalog
--    grows past 1000. Distinct on the server instead.
-- ---------------------------------------------------------------------
create or replace function public.product_categories()
returns setof text
language sql
stable
set search_path = public
as $$
  select distinct category from public.products order by 1;
$$;

grant execute on function public.product_categories() to anon, authenticated;
