-- =====================================================================
--  Домашното по английски за 4. клас — ред в базата и права
--  ---------------------------------------------------------------------
--  НЕ ПУСКАЙ ТОВА ВЪРХУ ЖИВАТА БАЗА. Файлът пише по assignments,
--  profiles, enrollments и attempts. Всичко е в транзакция, която
--  завършва с rollback, но пазачът отдолу така или иначе отказва да
--  тръгне, ако види истински данни.
--
--  Доказва четири неща за supabase/domashno-angliyski-4.sql:
--
--  1. Редът влиза веднъж и остава един, колкото пъти и да се пусне.
--  2. Закачен е за предмета „Английски“, за 4. клас, с 49 точки, и
--     не се вижда, докато таблото не го пусне.
--  3. Повторното пускане НЕ отменя публикуването — published остава
--     такова, каквото таблото го е оставило.
--  4. Четвъртокласник, на когото домашното е дадено, може да запише
--     опит; ученик от друг клас не го вижда изобщо.
--
--  Как се пуска локално:
--     psql -d tla -f supabase/domashno-angliyski-4.sql
--     psql -d tla -f supabase/tests/english-homework-test.sql
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

-- ── 1. Редът е там, един, и е какъвто трябва ─────────────────────────
do $$
declare a record;
begin
  perform pg_temp.chk('домашното е точно едно',
    (select count(*)::int from public.assignments where slug = 'hw4-en-tobe'), 1);

  select a2.*, s.name as predmet, s.slug as predmet_slug
    into a
    from public.assignments a2
    left join public.subjects s on s.id = a2.subject_id
   where a2.slug = 'hw4-en-tobe';

  perform pg_temp.chk('предметът е „Английски“', a.predmet, 'Английски'::text);
  perform pg_temp.chk('и това е предметът от schema-v13', a.predmet_slug, 'angliiski'::text);
  perform pg_temp.chk('вид', a.kind, 'homework'::text);
  perform pg_temp.chk('файл', a.url, 'homework_4_english_to_be.html'::text);
  perform pg_temp.chk('точки', a.max_points, 49::numeric);
  perform pg_temp.chk('клас', a.grades, array[4]);
  perform pg_temp.chk('седмица 8 — там го търси порталът', a.week, 8);
  perform pg_temp.chk('и застава до математиката за тази седмица',
    a.sort_order, (select sort_order from public.assignments where slug = 'hw4-w08'));
  perform pg_temp.chk('още не се вижда', a.published, false);
end $$;

-- ── 2. Файлът е безопасен за повторно пускане ────────────────────────
--  Таблото публикува домашното; после файлът се пуска пак (например за
--  поправено заглавие). Публикуването НЕ бива да се отменя.
do $$
declare id1 uuid; id2 uuid;
begin
  select id into id1 from public.assignments where slug = 'hw4-en-tobe';
  update public.assignments set published = true where slug = 'hw4-en-tobe';

  --  Същият insert, какъвто прави файлът.
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades)
  values
    ('hw4-en-tobe', 'Домашно — To be: am, is, are (Monster Family Album)',
     'homework', 'homework_4_english_to_be.html', 'описание', 49, false, 408, 8,
     (select id from public.subjects where slug = 'angliiski'), '{4}')
  on conflict (slug) do update set
    title = excluded.title, kind = excluded.kind, url = excluded.url,
    description = excluded.description, max_points = excluded.max_points,
    sort_order = excluded.sort_order, week = excluded.week,
    subject_id = excluded.subject_id, grades = excluded.grades;

  select id into id2 from public.assignments where slug = 'hw4-en-tobe';
  perform pg_temp.chk('второто пускане не прави нов ред', id1 = id2, true);
  perform pg_temp.chk('и не отменя публикуването',
    (select published from public.assignments where slug = 'hw4-en-tobe'), true);
  perform pg_temp.chk('домашните пак са едно',
    (select count(*)::int from public.assignments where slug = 'hw4-en-tobe'), 1);
end $$;

-- ── 3. През очите на четвъртокласник (под RLS) ───────────────────────
--  Сглобява се цялата верига: ученик в 4. клас, преподавател по
--  английски, записване по предмета, домашното дадено на класа. Чак
--  тогава се пробва записването на опит — иначе тишината минава за
--  забрана.
do $$
declare uch uuid; prep uuid; eng uuid; hw uuid; n int; godina int;
begin
  select id into prep from public.profiles where role = 'teacher' and active limit 1;
  select id into eng  from public.subjects where slug = 'angliiski';
  select id into hw   from public.assignments where slug = 'hw4-en-tobe';
  godina := (select coalesce(max(entry_school_year), 2026) from public.profiles);

  if prep is null then
    raise notice '   ⊘ няма преподавател в тази база — проверката под RLS се пропуска';
    return;
  end if;

  insert into auth.users (id, email) values (gen_random_uuid(), 'chetvurti@example.com')
    returning id into uch;
  --  Профилът може вече да е направен от тригер върху auth.users.
  insert into public.profiles (id, full_name, role, active, grade_at_entry, entry_school_year)
    values (uch, 'Четвъртокласник', 'student', true, 4, godina)
  on conflict (id) do update set
    full_name = excluded.full_name, role = excluded.role, active = excluded.active,
    grade_at_entry = excluded.grade_at_entry, entry_school_year = excluded.entry_school_year;

  perform pg_temp.chk('детето наистина е в 4. клас', public.current_grade(uch), 4);

  insert into public.enrollments (profile_id, subject_id, active) values (uch, eng, true);
  insert into public.teaching (student_id, teacher_id, subject_id, active)
    values (uch, prep, eng, true);
  update public.assignments set published = true where id = hw;
  insert into public.assignment_releases (assignment_id, teacher_id, hidden)
    values (hw, prep, false)
    on conflict do nothing;

  perform pg_temp.chk('домашното стига до детето', public.can_see_assignment(uch, hw), true);

  perform set_config('tla.uid', uch::text, true);
  set local role authenticated;

  perform pg_temp.chk('детето вижда домашното в списъка си',
    (select count(*)::int from public.assignments where slug = 'hw4-en-tobe'), 1);

  insert into public.attempts (user_id, assignment_id, status, auto_score, auto_max, records)
    values (uch, hw, 'submitted', 49, 49, '[{"id":"1.1","correct":true}]'::jsonb);
  get diagnostics n = row_count;
  perform pg_temp.chk('и записва резултата си', n, 1);
  perform pg_temp.chk('резултатът е 49 от 49',
    (select auto_score || '/' || auto_max from public.attempts
      where user_id = uch and assignment_id = hw), '49/49'::text);

  reset role;
end $$;

-- ── 4. Ученик от друг клас не вижда нищо ─────────────────────────────
do $$
declare drug uuid; hw uuid; godina int;
begin
  select id into hw from public.assignments where slug = 'hw4-en-tobe';
  godina := (select coalesce(max(entry_school_year), 2026) from public.profiles);

  insert into auth.users (id, email) values (gen_random_uuid(), 'shesti@example.com')
    returning id into drug;
  --  Профилът може вече да е направен от тригер върху auth.users.
  insert into public.profiles (id, full_name, role, active, grade_at_entry, entry_school_year)
    values (drug, 'Шестокласник', 'student', true, 6, godina)
  on conflict (id) do update set
    full_name = excluded.full_name, role = excluded.role, active = excluded.active,
    grade_at_entry = excluded.grade_at_entry, entry_school_year = excluded.entry_school_year;

  perform pg_temp.chk('шестокласникът не вижда домашното за 4. клас',
    public.can_see_assignment(drug, hw), false);

  perform set_config('tla.uid', drug::text, true);
  set local role authenticated;
  perform pg_temp.chk('и то липсва от списъка му',
    (select count(*)::int from public.assignments where slug = 'hw4-en-tobe'), 0);
  reset role;
end $$;

rollback;

\echo '  ✓ домашното по английски: ред, права и повторно пускане — проверени'
