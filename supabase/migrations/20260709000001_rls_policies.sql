-- Row Level Security.
-- Catalog: readable by everyone (anon included) so the app can browse
-- before sign-in; writes only via service role (no policies).
-- User data: owner-only.

-- Catalog -------------------------------------------------------------
alter table public.stores enable row level security;
alter table public.products enable row level security;
alter table public.prices enable row level security;
alter table public.price_history enable row level security;
alter table public.offers enable row level security;
alter table public.coupons enable row level security;

create policy "catalog read" on public.stores
  for select using (true);
create policy "catalog read" on public.products
  for select using (true);
create policy "catalog read" on public.prices
  for select using (true);
create policy "catalog read" on public.price_history
  for select using (true);
create policy "catalog read" on public.offers
  for select using (true);
create policy "catalog read" on public.coupons
  for select using (true);

-- Profiles ------------------------------------------------------------
alter table public.users enable row level security;

create policy "own profile read" on public.users
  for select using (auth.uid() = id);
create policy "own profile update" on public.users
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- Simple owner-only tables ---------------------------------------------
alter table public.user_coupons enable row level security;
create policy "own coupons" on public.user_coupons
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table public.shopping_lists enable row level security;
create policy "own lists" on public.shopping_lists
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table public.shopping_items enable row level security;
create policy "own list items" on public.shopping_items
  for all using (
    exists (
      select 1 from public.shopping_lists l
      where l.id = list_id and l.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.shopping_lists l
      where l.id = list_id and l.user_id = auth.uid()
    )
  );

alter table public.pantry enable row level security;
create policy "own pantry" on public.pantry
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table public.receipts enable row level security;
create policy "own receipts" on public.receipts
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table public.receipt_items enable row level security;
create policy "own receipt items" on public.receipt_items
  for all using (
    exists (
      select 1 from public.receipts r
      where r.id = receipt_id and r.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.receipts r
      where r.id = receipt_id and r.user_id = auth.uid()
    )
  );

alter table public.meal_plans enable row level security;
create policy "own meal plans" on public.meal_plans
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table public.favorites enable row level security;
create policy "own favorites" on public.favorites
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table public.notifications enable row level security;
create policy "own notifications read" on public.notifications
  for select using (auth.uid() = user_id);
create policy "own notifications update" on public.notifications
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
-- Inserts come from edge functions with service role.

alter table public.preferences enable row level security;
create policy "own preferences" on public.preferences
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table public.analytics enable row level security;
create policy "own analytics insert" on public.analytics
  for insert with check (auth.uid() = user_id);

alter table public.device_tokens enable row level security;
create policy "own device tokens" on public.device_tokens
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Realtime ------------------------------------------------------------
alter publication supabase_realtime add table public.shopping_lists;
alter publication supabase_realtime add table public.shopping_items;
alter publication supabase_realtime add table public.notifications;

-- Storage buckets -------------------------------------------------------
insert into storage.buckets (id, name, public)
values
  ('receipts', 'receipts', false),
  ('product-images', 'product-images', true)
on conflict (id) do nothing;

-- Receipt images: users manage files under their own uid/ prefix.
create policy "own receipt images"
  on storage.objects for all
  using (
    bucket_id = 'receipts'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'receipts'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "public product images read"
  on storage.objects for select
  using (bucket_id = 'product-images');
