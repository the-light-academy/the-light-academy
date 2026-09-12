-- =====================================================================
-- The Light Academy — student portal schema
-- Run this once in the Supabase dashboard: SQL Editor -> New query -> Run.
-- Safe to re-run: every statement is idempotent.
--
-- !!! ВНИМАНИЕ: този файл е вече надграден от supabase/schema-v2.sql
-- (класове и предмети). Ако си пуснала v2, НЕ пускай този файл наново —
-- той ще върне старата колона `grade`, стария тригер за нов потребител
-- и стария достъп на `anon` до заданията. v2 очаква v1 да е минал веднъж
-- и после да не се пипа.
--
-- Passwords are NOT stored here. Supabase Auth owns auth.users and keeps a
-- salted hash; this schema only ever references users by id.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Tables
-- ---------------------------------------------------------------------

-- One row per person, created automatically by the trigger further down.
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text not null default '',
  role        text not null default 'student' check (role in ('student','teacher')),
  active      boolean not null default true,
  grade       text,
  created_at  timestamptz not null default now()
);

-- Exams and homework. `content` holds the questions for homework;
-- the two existing exams keep their questions in their own .html file
-- and leave it null.
create table if not exists public.assignments (
  id          uuid primary key default gen_random_uuid(),
  slug        text unique not null,
  title       text not null,
  kind        text not null check (kind in ('exam','homework')),
  url         text not null,
  max_points  numeric not null default 100,
  published   boolean not null default false,
  due_at      timestamptz,
  sort_order  int not null default 0,
  content     jsonb,
  created_at  timestamptz not null default now()
);

-- One row per sitting. `records` and `part2` store verbatim what the
-- exam page's own buildPart1Records() / buildPart2Records() produce, so
-- no result format is invented here.
create table if not exists public.attempts (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  assignment_id uuid not null references public.assignments(id) on delete cascade,
  status        text not null default 'submitted'
                  check (status in ('in_progress','submitted','graded')),
  auto_score    numeric,
  auto_max      numeric,
  manual_score  numeric,
  manual_max    numeric,
  total_score   numeric generated always as
                  (coalesce(auto_score,0) + coalesce(manual_score,0)) stored,
  records       jsonb,
  part2         jsonb,
  teacher_note  text,
  started_at    timestamptz,
  submitted_at  timestamptz not null default now(),
  graded_at     timestamptz
);

-- Added with the AI marking of free-text answers. When this is set, the
-- manual_score on the row came from Claude, not from a person: the teacher
-- copies the answers out of teacher.html, pastes them into their own Claude,
-- and pastes the marks back. Their own marking clears it, by setting
-- status='graded'.
alter table public.attempts add column if not exists ai_graded_at timestamptz;

-- Added with the teacher's calendar. A homework or exam can be pinned to one
-- of the 36 teaching weeks, so the week that says what is being taught can
-- also carry what is set for it. Null means "not pinned to a week", which is
-- what everything created before this was.
alter table public.assignments add column if not exists week int
  check (week is null or (week between 1 and 36));

create index if not exists attempts_user_idx       on public.attempts(user_id);
create index if not exists attempts_assignment_idx on public.attempts(assignment_id);
create index if not exists attempts_submitted_idx  on public.attempts(submitted_at desc);

-- ---------------------------------------------------------------------
-- 2. Give every new auth user a profile row
--    Without this, a user created in the dashboard would have no name
--    and no role, and would fail every policy below.
-- ---------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'role', 'student')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- 3. Who is a teacher?
--    SECURITY DEFINER on purpose: this runs inside the profiles policies,
--    so if it read profiles as the caller it would recurse forever.
-- ---------------------------------------------------------------------

create or replace function public.is_teacher()
returns boolean
language sql
stable
security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'teacher' and active
  );
$$;

-- ---------------------------------------------------------------------
-- 4. Row Level Security
--    This is the actual access control. Nothing in the browser enforces
--    anything -- the anon key is public by design, and these policies are
--    what stop one student reading another's results.
-- ---------------------------------------------------------------------

alter table public.profiles    enable row level security;
alter table public.assignments enable row level security;
alter table public.attempts    enable row level security;

-- Supabase normally grants these by default; stated explicitly so the
-- schema is self-contained and the policies below are the only thing
-- deciding access.
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.profiles, public.assignments, public.attempts to authenticated;
grant select on public.assignments to anon;

-- profiles ------------------------------------------------------------
drop policy if exists "profiles: read own"        on public.profiles;
drop policy if exists "profiles: teacher reads"   on public.profiles;
drop policy if exists "profiles: teacher writes"  on public.profiles;
drop policy if exists "profiles: update own name" on public.profiles;

create policy "profiles: read own"
  on public.profiles for select
  using (id = auth.uid());

create policy "profiles: teacher reads"
  on public.profiles for select
  using (public.is_teacher());

-- Note: students deliberately get no UPDATE policy on their own row.
-- A policy on profiles that reads profiles (to check "you didn't change
-- your own role") recurses infinitely, and letting a student write the row
-- unchecked would let them set role='teacher'. Names are set by the
-- teacher when the account is created.

create policy "profiles: teacher writes"
  on public.profiles for all
  using (public.is_teacher())
  with check (public.is_teacher());

-- assignments ---------------------------------------------------------
drop policy if exists "assignments: read published" on public.assignments;
drop policy if exists "assignments: teacher all"    on public.assignments;

create policy "assignments: read published"
  on public.assignments for select
  using (published or public.is_teacher());

create policy "assignments: teacher all"
  on public.assignments for all
  using (public.is_teacher())
  with check (public.is_teacher());

-- attempts ------------------------------------------------------------
drop policy if exists "attempts: read own"       on public.attempts;
drop policy if exists "attempts: insert own"     on public.attempts;
drop policy if exists "attempts: teacher reads"  on public.attempts;
drop policy if exists "attempts: teacher grades" on public.attempts;

create policy "attempts: read own"
  on public.attempts for select
  using (user_id = auth.uid());

-- A student may only file an attempt in their own name, and only against
-- an assignment that is actually published.
create policy "attempts: insert own"
  on public.attempts for insert
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.assignments a
      where a.id = assignment_id and a.published
    )
  );

create policy "attempts: teacher reads"
  on public.attempts for select
  using (public.is_teacher());

create policy "attempts: teacher grades"
  on public.attempts for update
  using (public.is_teacher())
  with check (public.is_teacher());

-- Deliberately no delete policy for students: a submitted attempt is a
-- record. Only a teacher (via the teacher-all path below) can remove one.
drop policy if exists "attempts: teacher deletes" on public.attempts;
create policy "attempts: teacher deletes"
  on public.attempts for delete
  using (public.is_teacher());

-- ---------------------------------------------------------------------
-- 5. Seed the two assignments that already exist as pages
--    Left unpublished so nothing appears to students until you say so
--    (teacher.html -> Assignments -> publish).
-- ---------------------------------------------------------------------

insert into public.assignments (slug, title, kind, url, max_points, published, sort_order)
values
  ('matura2026',
   'Пробна матура — НВО по математика, 7. клас',
   'exam', 'matura2026.html', 100, false, 10),
  -- the internal copy, not the public page: entrance_test.html unlocks its
  -- result against a parent's email and saves nothing, while
  -- entrance_test_internal.html is behind the login and writes the attempt.
  ('entrance_test',
   'Входящ тест за 7. клас',
   'exam', 'entrance_test_internal.html', 12, false, 20)
on conflict (slug) do nothing;

-- Homework lives one row per sheet. hw-w01 is a page of its own rather than
-- questions in `content`, because it came with its own layout; homework.html
-- stays the generic renderer for the ones that do live in the database.
insert into public.assignments (slug, title, kind, url, max_points, published, sort_order, week)
values
  ('hw-w01',
   'Домашно 1 — Рационални числа — седмица 1',
   'homework', 'homework_w01.html', 10, false, 100, 1),
  ('hw-w02',
   'Домашно 2 — Степени с естествен показател — седмица 2',
   'homework', 'homework_w02.html', 10, false, 110, 2),
  ('hw-w03',
   'Домашно 3 — Рационални изрази — седмица 3',
   'homework', 'homework_w03.html', 10, false, 120, 3)
on conflict (slug) do nothing;

-- The second entrance test, week 2 in the calendar ("Входно равнище").
-- 24 points, 25 minutes, marked entirely by the page.
insert into public.assignments (slug, title, kind, url, max_points, published, sort_order, week)
values
  ('entrance_test_2',
   'Входно ниво 2 — 7. клас',
   'exam', 'entrance_test_2.html', 24, false, 30, 2)
on conflict (slug) do nothing;

-- ---------------------------------------------------------------------
-- 6. After running this file
--    a) Authentication -> Providers -> Email -> turn OFF "Enable sign ups"
--    b) Authentication -> Users -> Add user (tick Auto Confirm), then:
--
--       update public.profiles
--          set role = 'teacher', full_name = 'Your Name'
--        where id = (select id from auth.users where email = 'you@example.com');
--
--    Check it worked -- this must return true while logged in as you:
--       select public.is_teacher();
--
--    Marking the free-text answers needs no setup and costs nothing: it
--    happens from teacher.html -> Резултати -> "Оценяване с Claude",
--    through your own Claude account, by copy and paste.
-- ---------------------------------------------------------------------
