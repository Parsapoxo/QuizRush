-- QuizRush — Supabase schema
-- Paste this whole file into: Supabase Dashboard → SQL Editor → New query → Run

create table if not exists rooms (
  code text primary key,
  topic text not null,
  phase text not null default 'lobby',
  q_index integer not null default -1,
  q_start_ts bigint not null default 0,
  played_count integer not null default 0,
  total_questions integer not null default 0,
  host_name text,
  created_at timestamptz not null default now()
);

-- Safe to re-run: adds the column if you already created this table before.
alter table rooms add column if not exists host_name text;

create table if not exists players (
  room_code text not null references rooms(code) on delete cascade,
  safe_name text not null,
  name text not null,
  answers jsonb not null default '{}'::jsonb,
  joined_at bigint not null default 0,
  avatar text,
  primary key (room_code, safe_name)
);

-- Safe to re-run: adds the column if you already created this table before.
alter table players add column if not exists avatar text;

-- This is a private trivia game for friends with no login system,
-- so we allow the public "anon" key to read/write freely.
-- Do NOT reuse this same Supabase project for anything containing
-- real personal or sensitive data.

alter table rooms enable row level security;
alter table players enable row level security;

drop policy if exists "rooms_all_anon" on rooms;
create policy "rooms_all_anon" on rooms
  for all
  to anon
  using (true)
  with check (true);

drop policy if exists "players_all_anon" on players;
create policy "players_all_anon" on players
  for all
  to anon
  using (true)
  with check (true);
