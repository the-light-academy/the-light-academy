-- =====================================================================
--  Английски, 5. клас, Unit 1 — петте листа: редове и права
--  ---------------------------------------------------------------------
--  НЕ ПУСКАЙ ТОВА ВЪРХУ ЖИВАТА БАЗА. Файлът пише по assignments,
--  profiles, enrollments и attempts. Всичко е в транзакция, която
--  завършва с rollback, но пазачът отдолу така или иначе отказва да
--  тръгне, ако види истински данни.
--
--  Доказва пет неща за supabase/domashni-angliyski-5-u1.sql:
--
--  1. Петте листа влизат веднъж и остават пет, колкото пъти и да се
--     пусне файлът.
--  2. Всички са по английски, за 5. клас, в Unit 1 — и БЕЗ седмица.
--  3. Повторното пускане не отменя публикуването.
--  4. Петокласник, на когото листът е даден, записва резултат — и за
--     разказа запазва и свободните отговори за ръчна оценка.
--  5. Ученик от друг клас не вижда нищо от тях.
--
--  Как се пуска локално:
--     psql -d tla -f supabase/domashni-angliyski-5-u1.sql
--     psql -d tla -f supabase/tests/english5-unit1-test.sql
-- =====================================================================
\set ON_ERROR_STOP on

do $$ begin
  if (select count(*) from public.profiles) > 20 then
    raise exception 'Това прилича на истинска база — тестът отказва да тръгне.';
  end if;
end $$;
set client_min_messages = notice;

create or replace function pg_temp.chk(name text, got anyelement, want anyelement)
returns void language plpgsql as $$
begin
  if got is not distinct from want then
    raise notice '   ✓ % · %', name, got;
  else
    raise exception '   ✗ % · получих % вместо %', name, got, want;
  end if;
end $$;

begin;

-- ── 1. Петте реда са там и са каквито трябва ─────────────────────────
do $$
declare n int;
begin
  perform pg_temp.chk('листовете са пет',
    (select count(*)::int from public.assignments where slug like 'en5-u1-%'), 5);

  select count(*)::int into n
    from public.assignments a
    join public.subjects s on s.id = a.subject_id
   where a.slug like 'en5-u1-%' and s.slug = 'angliiski';
  perform pg_temp.chk('всички са по английски', n, 5);

  select count(*)::int into n from public.assignments
   where slug like 'en5-u1-%' and grades = array[5];
  perform pg_temp.chk('всички са за 5. клас', n, 5);

  select count(*)::int into n from public.assignments
   where slug like 'en5-u1-%' and track = 'ep1_unit1';
  perform pg_temp.chk('всички са в Unit 1', n, 5);

  select count(*)::int into n from public.assignments
   where slug like 'en5-u1-%' and week is not null;
  perform pg_temp.chk('нито един няма седмица', n, 0);

  select count(*)::int into n from public.assignments
   where slug like 'en5-u1-%' and published;
  perform pg_temp.chk('нито един не се вижда още', n, 0);

  select count(distinct section)::int into n from public.assignments
   where slug like 'en5-u1-%';
  perform pg_temp.chk('разпределени са в четири части на юнита', n, 4);

  select count(*)::int into n from public.assignments
   where slug like 'en5-u1-%' and kind = 'homework' and url like 'homework_5_en_u1_%';
  perform pg_temp.chk('всички сочат към своя лист', n, 5);

  perform pg_temp.chk('точките са 27+24+30+30+34',
    (select sum(max_points)::int from public.assignments where slug like 'en5-u1-%'), 145);
end $$;

-- ── 2. Повторното пускане не отменя публикуването ────────────────────
do $$
declare id1 uuid; id2 uuid;
begin
  select id into id1 from public.assignments where slug = 'en5-u1-story';
  update public.assignments set published = true where slug = 'en5-u1-story';

  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u1-story', 'Домашно — Unit 1 · The Lost Backpack', 'homework',
     'homework_5_en_u1_story.html', 'описание', 27, false, 5110, null,
     (select id from public.subjects where slug = 'angliiski'), '{5}',
     'ep1_unit1', 'reading')
  on conflict (slug) do update set
    title = excluded.title, kind = excluded.kind, url = excluded.url,
    description = excluded.description, max_points = excluded.max_points,
    sort_order = excluded.sort_order, week = excluded.week,
    subject_id = excluded.subject_id, grades = excluded.grades,
    track = excluded.track, section = excluded.section;

  select id into id2 from public.assignments where slug = 'en5-u1-story';
  perform pg_temp.chk('второто пускане не прави нов ред', id1 = id2, true);
  perform pg_temp.chk('и не отменя публикуването',
    (select published from public.assignments where slug = 'en5-u1-story'), true);
  perform pg_temp.chk('листовете пак са пет',
    (select count(*)::int from public.assignments where slug like 'en5-u1-%'), 5);
end $$;

-- ── 3. През очите на петокласник (под RLS) ───────────────────────────
do $$
declare uch uuid; prep uuid; eng uuid; hw uuid; n int; godina int;
begin
  select id into prep from public.profiles where role = 'teacher' and active limit 1;
  select id into eng  from public.subjects where slug = 'angliiski';
  select id into hw   from public.assignments where slug = 'en5-u1-story';
  godina := (select coalesce(max(entry_school_year), 2026) from public.profiles);

  if prep is null then
    raise notice '   ⊘ няма преподавател в тази база — проверката под RLS се пропуска';
    return;
  end if;

  insert into auth.users (id, email) values (gen_random_uuid(), 'peti@example.com')
    returning id into uch;
  insert into public.profiles (id, full_name, role, active, grade_at_entry, entry_school_year)
    values (uch, 'Петокласник', 'student', true, 5, godina)
  on conflict (id) do update set
    full_name = excluded.full_name, role = excluded.role, active = excluded.active,
    grade_at_entry = excluded.grade_at_entry, entry_school_year = excluded.entry_school_year;

  perform pg_temp.chk('детето е в 5. клас', public.current_grade(uch), 5);

  insert into public.enrollments (profile_id, subject_id, active) values (uch, eng, true);
  insert into public.teaching (student_id, teacher_id, subject_id, active)
    values (uch, prep, eng, true);
  update public.assignments set published = true where slug like 'en5-u1-%';
  insert into public.assignment_releases (assignment_id, teacher_id, hidden)
    select id, prep, false from public.assignments where slug like 'en5-u1-%'
  on conflict do nothing;

  select count(*)::int into n from public.assignments a
   where a.slug like 'en5-u1-%' and public.can_see_assignment(uch, a.id);
  perform pg_temp.chk('и петте стигат до детето', n, 5);

  perform set_config('tla.uid', uch::text, true);
  set local role authenticated;

  --  Разказът: двайсет автоматични точки и седем за ръчна оценка.
  insert into public.attempts
    (user_id, assignment_id, status, auto_score, auto_max, manual_max, records, part2)
  values (uch, hw, 'submitted', 20, 20, 7,
          '[{"id":"1.1","correct":true}]'::jsonb,
          ('[{"id":"2.1","prompt":"Where do Tom and Mia live?",'
           || '"studentAnswer":"They live in England.",'
           || '"solution":"They live in a small town in England."}]')::jsonb);
  get diagnostics n = row_count;
  perform pg_temp.chk('детето записва резултата си', n, 1);
  perform pg_temp.chk('свободните отговори чакат ръчна оценка',
    (select manual_max::int from public.attempts
      where user_id = uch and assignment_id = hw), 7);
  perform pg_temp.chk('и са запазени в part2',
    (select jsonb_array_length(part2) from public.attempts
      where user_id = uch and assignment_id = hw), 1);

  reset role;
end $$;

-- ── 4. Ученик от друг клас не вижда нищо ─────────────────────────────
do $$
declare drug uuid; n int; godina int;
begin
  godina := (select coalesce(max(entry_school_year), 2026) from public.profiles);
  insert into auth.users (id, email) values (gen_random_uuid(), 'chetvurti5@example.com')
    returning id into drug;
  insert into public.profiles (id, full_name, role, active, grade_at_entry, entry_school_year)
    values (drug, 'Четвъртокласник', 'student', true, 4, godina)
  on conflict (id) do update set
    full_name = excluded.full_name, role = excluded.role, active = excluded.active,
    grade_at_entry = excluded.grade_at_entry, entry_school_year = excluded.entry_school_year;

  select count(*)::int into n from public.assignments a
   where a.slug like 'en5-u1-%' and public.can_see_assignment(drug, a.id);
  perform pg_temp.chk('четвъртокласникът не вижда нито един', n, 0);

  perform set_config('tla.uid', drug::text, true);
  set local role authenticated;
  perform pg_temp.chk('и ги няма в списъка му',
    (select count(*)::int from public.assignments where slug like 'en5-u1-%'), 0);
  reset role;
end $$;

rollback;

\echo '  ✓ английски 5. клас, Unit 1: петте листа, правата и повторното пускане'
