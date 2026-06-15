-- ============================================================
-- Rast Studio — shared outreach tracker: clients table + RLS
-- Run this whole file in the Supabase SQL editor (project: leads).
-- ============================================================

create extension if not exists pgcrypto;

create table if not exists public.clients (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  contact       text,
  status        text not null default 'todo'
                check (status in ('todo','contacted','replied','client')),
  priority      text,
  notes         text,
  contacted_by  text,
  contacted_at  timestamptz,
  updated_at    timestamptz not null default now()
);

-- keep updated_at fresh on every UPDATE
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists clients_touch on public.clients;
create trigger clients_touch
  before update on public.clients
  for each row execute function public.set_updated_at();

-- realtime: stream row changes; full row payload on update/delete
alter publication supabase_realtime add table public.clients;
alter table public.clients replica identity full;

-- ---- Row Level Security: only signed-in users can read/write ----
alter table public.clients enable row level security;

drop policy if exists "authenticated read"   on public.clients;
drop policy if exists "authenticated insert" on public.clients;
drop policy if exists "authenticated update" on public.clients;

create policy "authenticated read"   on public.clients
  for select to authenticated using (true);
create policy "authenticated insert" on public.clients
  for insert to authenticated with check (true);
create policy "authenticated update" on public.clients
  for update to authenticated using (true) with check (true);
-- (intentionally no delete policy -> nobody can delete rows)

-- After this runs, paste & run supabase_seed.sql to load the 72 leads.
