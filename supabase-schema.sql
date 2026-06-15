-- ============================================================
--  Beauty Salon Outreach — Supabase schema
--  Run this in Supabase → SQL Editor (replaces the old minimal
--  `clients` table; this one keeps ALL the lead fields the card shows)
-- ============================================================

create extension if not exists pgcrypto;

create table public.leads (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  type          text,            -- "Nails", "Hair salon", ...
  city          text,            -- "Riga – Centrs"
  address       text,
  phone         text,
  email         text,
  ig            text,            -- instagram handle (no @)
  fb            text,            -- facebook handle
  website       text,            -- bare domain, e.g. "strogonovs.lv"
  booking       text,            -- "Fresha" / "Versum" / "Instagram only"
  note          text,            -- original research note
  priority      text not null default 'med' check (priority in ('hi','med','low')),
  comment       text,            -- your own running comment
  outreached    boolean not null default false,
  contacted_by  text,            -- email of whoever marked it
  contacted_at  timestamptz,
  deleted       boolean not null default false,   -- soft-delete (mirrors the "Restore deleted" button)
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- auto-touch updated_at on every write
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

create trigger leads_touch before update on public.leads
  for each row execute function public.set_updated_at();

-- realtime: stream row changes + include full row on update/delete
alter publication supabase_realtime add table public.leads;
alter table public.leads replica identity full;

-- Row Level Security: only signed-in users can read/write
alter table public.leads enable row level security;

create policy "authenticated read"   on public.leads
  for select to authenticated using (true);
create policy "authenticated insert" on public.leads
  for insert to authenticated with check (true);
create policy "authenticated update" on public.leads
  for update to authenticated using (true) with check (true);
-- (no hard-delete policy on purpose — we soft-delete via deleted=true)
