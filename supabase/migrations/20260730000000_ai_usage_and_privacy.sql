-- AI usage accounting: one row per ai-proxy call. Read and written only
-- by the service role inside the edge function (RLS enabled, no
-- policies). Doubles as the endpoint's usage log.
create table public.ai_usage (
  user_id uuid not null references auth.users (id) on delete cascade,
  called_at timestamptz not null default now()
);

create index ai_usage_user_time_idx on public.ai_usage (user_id, called_at desc);

alter table public.ai_usage enable row level security;

-- Privacy: the analytics table previously kept rows after account
-- deletion (user_id set null), which contradicts the in-app promise
-- that deletion removes every trace. Error rows can contain free text;
-- cascade them away with the account.
alter table public.analytics
  drop constraint analytics_user_id_fkey,
  add constraint analytics_user_id_fkey
    foreign key (user_id) references public.users (id) on delete cascade;
