-- Grocery Shopping Assistant — initial schema.
-- Catalog tables (stores/products/prices/offers/coupons) are written by
-- data-ingestion jobs with the service role; clients read them.
-- User-owned tables are protected by RLS below (see 20260709000001).

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- users: profile row mirroring auth.users, created by trigger.
-- ---------------------------------------------------------------------
create table public.users (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  display_name text,
  avatar_url text,
  is_premium boolean not null default false,
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.users (id, email, display_name, avatar_url)
  values (
    new.id,
    coalesce(new.email, ''),
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- Catalog
-- ---------------------------------------------------------------------
create table public.stores (
  id text primary key,
  name text not null,
  chain text not null,
  address text not null,
  lat double precision not null,
  lng double precision not null,
  logo_url text,
  phone text,
  opening_hours jsonb,
  created_at timestamptz not null default now()
);

create index stores_lat_idx on public.stores (lat);
create index stores_chain_idx on public.stores (chain);

create table public.products (
  id text primary key,
  name text not null,
  brand text,
  barcode text unique,
  category text not null,
  unit text not null default 'ea',
  unit_size numeric not null default 1,
  image_url text,
  nutrition jsonb,
  tags text[] not null default '{}',
  created_at timestamptz not null default now()
);

create index products_category_idx on public.products (category);
create index products_name_trgm_idx on public.products
  using gin (to_tsvector('english', name));

create table public.prices (
  id text primary key default gen_random_uuid()::text,
  product_id text not null references public.products (id) on delete cascade,
  store_id text not null references public.stores (id) on delete cascade,
  price numeric(10, 2) not null check (price >= 0),
  unit_price numeric(10, 4),
  currency text not null default 'USD',
  regular_price numeric(10, 2),
  valid_from timestamptz,
  valid_to timestamptz,
  updated_at timestamptz not null default now(),
  unique (product_id, store_id)
);

create index prices_product_idx on public.prices (product_id);
create index prices_store_idx on public.prices (store_id);

create table public.price_history (
  id bigint generated always as identity primary key,
  product_id text not null references public.products (id) on delete cascade,
  store_id text references public.stores (id) on delete cascade,
  price numeric(10, 2) not null,
  recorded_at timestamptz not null default now()
);

create index price_history_product_time_idx
  on public.price_history (product_id, recorded_at);

-- Every price change is archived automatically.
create or replace function public.archive_price()
returns trigger
language plpgsql
as $$
begin
  insert into public.price_history (product_id, store_id, price, recorded_at)
  values (new.product_id, new.store_id, new.price, now());
  return new;
end;
$$;

create trigger on_price_change
  after insert or update of price on public.prices
  for each row execute function public.archive_price();

create table public.offers (
  id text primary key default gen_random_uuid()::text,
  store_id text not null references public.stores (id) on delete cascade,
  product_id text references public.products (id) on delete set null,
  title text not null,
  description text,
  type text not null default 'discount'
    check (type in ('weeklyAd', 'discount', 'bogo', 'cashback', 'loyalty')),
  discount_percent numeric(5, 2),
  discount_amount numeric(10, 2),
  valid_from timestamptz,
  valid_to timestamptz not null,
  image_url text
);

create index offers_store_valid_idx on public.offers (store_id, valid_to);

create table public.coupons (
  id text primary key default gen_random_uuid()::text,
  store_id text references public.stores (id) on delete cascade,
  product_id text references public.products (id) on delete cascade,
  title text not null,
  code text,
  description text,
  discount_amount numeric(10, 2),
  discount_percent numeric(5, 2),
  min_spend numeric(10, 2),
  expires_at timestamptz not null,
  is_digital boolean not null default true,
  check (discount_amount is not null or discount_percent is not null)
);

create index coupons_expires_idx on public.coupons (expires_at);

-- Which user clipped which coupon.
create table public.user_coupons (
  user_id uuid not null references public.users (id) on delete cascade,
  coupon_id text not null references public.coupons (id) on delete cascade,
  clipped_at timestamptz not null default now(),
  primary key (user_id, coupon_id)
);

-- ---------------------------------------------------------------------
-- User data
-- ---------------------------------------------------------------------
create table public.shopping_lists (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  name text not null,
  budget numeric(10, 2),
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index shopping_lists_user_idx on public.shopping_lists (user_id);

create table public.shopping_items (
  id uuid primary key default gen_random_uuid(),
  list_id uuid not null references public.shopping_lists (id) on delete cascade,
  product_id text references public.products (id) on delete set null,
  name text not null,
  quantity numeric not null default 1,
  unit text not null default 'ea',
  checked boolean not null default false,
  notes text,
  estimated_price numeric(10, 2)
);

create index shopping_items_list_idx on public.shopping_items (list_id);

create table public.pantry (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  product_id text references public.products (id) on delete set null,
  name text not null,
  quantity numeric not null default 1,
  unit text not null default 'ea',
  expires_at timestamptz,
  location text not null default 'pantry',
  added_at timestamptz not null default now()
);

create index pantry_user_idx on public.pantry (user_id);
create index pantry_expiry_idx on public.pantry (user_id, expires_at);

create table public.receipts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  store_id text references public.stores (id) on delete set null,
  store_name text,
  total numeric(10, 2) not null,
  currency text not null default 'USD',
  purchased_at timestamptz not null,
  image_url text,
  created_at timestamptz not null default now()
);

create index receipts_user_time_idx on public.receipts (user_id, purchased_at);

create table public.receipt_items (
  id uuid primary key default gen_random_uuid(),
  receipt_id uuid not null references public.receipts (id) on delete cascade,
  name text not null,
  quantity numeric not null default 1,
  price numeric(10, 2) not null,
  category text
);

create index receipt_items_receipt_idx on public.receipt_items (receipt_id);

create table public.meal_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  week_start date not null,
  meals jsonb not null default '[]',
  created_at timestamptz not null default now(),
  unique (user_id, week_start)
);

create table public.favorites (
  user_id uuid not null references public.users (id) on delete cascade,
  product_id text references public.products (id) on delete cascade,
  store_id text references public.stores (id) on delete cascade,
  created_at timestamptz not null default now(),
  check (product_id is not null or store_id is not null),
  unique nulls not distinct (user_id, product_id, store_id)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  type text not null default 'general',
  title text not null,
  body text not null,
  route text,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

create index notifications_user_idx
  on public.notifications (user_id, created_at desc);

create table public.preferences (
  user_id uuid primary key references public.users (id) on delete cascade,
  data jsonb not null default '{}',
  updated_at timestamptz not null default now()
);

-- Client analytics events (screen views, feature usage).
create table public.analytics (
  id bigint generated always as identity primary key,
  user_id uuid references public.users (id) on delete set null,
  event text not null,
  properties jsonb,
  created_at timestamptz not null default now()
);

create index analytics_event_time_idx on public.analytics (event, created_at);

-- Device push tokens for FCM.
create table public.device_tokens (
  user_id uuid not null references public.users (id) on delete cascade,
  token text not null,
  platform text,
  updated_at timestamptz not null default now(),
  primary key (user_id, token)
);
