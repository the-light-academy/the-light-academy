-- =====================================================================
--  Математика, 5. клас — вторите нива: редове, подредба и права
--  ---------------------------------------------------------------------
--  НЕ ПУСКАЙ ТОВА ВЪРХУ ЖИВАТА БАЗА. Файлът пише по assignments,
--  profiles, enrollments и attempts. Всичко е в транзакция, която
--  завършва с rollback, но пазачът отдолу така или иначе отказва да
--  тръгне, ако види истински данни.
--
--  Доказва шест неща за supabase/domashni-5-nivo2.sql:
--
--  1. Трийсет и двата листа влизат и остават трийсет и два, колкото
--     пъти и да се пусне файлът.
--  2. Всички са по математика, за 5. клас, по 10 точки и със седмица.
--  3. Всеки стои в СЪЩАТА седмица и с СЪЩАТА подредба като основния си
--     лист — за да са един до друг в таблото и в календара.
--  4. Повторното пускане не отменя публикуването.
--  5. Петокласник, на когото листът е даден, записва резултат 10 от 10.
--  6. Шестокласник не вижда нищо от тях.
--
--  Как се пуска локално:
--     psql -d tla -f supabase/assignments.sql
--     psql -d tla -f supabase/domashni-5-nivo2.sql
--     psql -d tla -f supabase/tests/hw5-nivo2-test.sql
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

--  Кои редове гледаме: тези с „· ниво 2“ в заглавието, за 5. клас.
--  Старият лист hw5-w09b не е от тях — той си има свое заглавие.
create or replace view pg_temp.nivo2 as
  select * from public.assignments
   where grades = array[5] and title like '%· ниво 2';

begin;

-- ── 1. Редовете са там и са каквито трябва ───────────────────────────
do $$
declare n int;
begin
  perform pg_temp.chk('листовете са 32',
    (select count(*)::int from pg_temp.nivo2), 32);

  select count(*)::int into n
    from pg_temp.nivo2 a
    join public.subjects s on s.id = a.subject_id
   where s.slug = 'matematika';
  perform pg_temp.chk('всички са по математика', n, 32);

  select count(*)::int into n from pg_temp.nivo2 where max_points = 10;
  perform pg_temp.chk('всички са по 10 точки', n, 32);

  select count(*)::int into n from pg_temp.nivo2 where kind = 'homework';
  perform pg_temp.chk('всички са домашни', n, 32);

  select count(*)::int into n from pg_temp.nivo2 where week between 1 and 36;
  perform pg_temp.chk('всички имат седмица в годината', n, 32);

  select count(*)::int into n from pg_temp.nivo2
   where url like 'homework_5_w%.html';
  perform pg_temp.chk('всички сочат към свой лист', n, 32);

  select count(distinct url)::int into n from pg_temp.nivo2;
  perform pg_temp.chk('нито два не сочат към един и същ файл', n, 32);

  select count(*)::int into n from pg_temp.nivo2 where published;
  perform pg_temp.chk('нито един не се вижда още', n, 0);

  select count(*)::int into n from pg_temp.nivo2 where description is null;
  perform pg_temp.chk('всеки си носи описание', n, 0);
end $$;

-- ── 2. Всеки стои при основния си лист ───────────────────────────────
--  Листът „ниво 2“ за седмица X трябва да е в седмица X и с подредбата
--  на основния лист за същата седмица. Основният се намира по url: от
--  homework_5_w12b.html се маха последната буква.
do $$
declare n int;
begin
  select count(*)::int into n
    from pg_temp.nivo2 a
    join public.assignments o
      on o.url = regexp_replace(a.url, '[bc]\.html$', '.html')
   where o.week = a.week;
  perform pg_temp.chk('всеки е в седмицата на основния си лист', n, 32);

  select count(*)::int into n
    from pg_temp.nivo2 a
    join public.assignments o
      on o.url = regexp_replace(a.url, '[bc]\.html$', '.html')
   where o.sort_order = a.sort_order;
  perform pg_temp.chk('и с неговата подредба', n, 32);

  select count(*)::int into n
    from pg_temp.nivo2 a
    join public.assignments o
      on o.url = regexp_replace(a.url, '[bc]\.html$', '.html')
   where a.title = o.title || ' · ниво 2';
  perform pg_temp.chk('заглавието е неговото плюс „· ниво 2“', n, 32);
end $$;

-- ── 3. Повторното пускане не отменя публикуването ────────────────────
do $$
declare id1 uuid; id2 uuid;
begin
  select id into id1 from public.assignments where slug = 'hw5-w12b';
  update public.assignments set published = true where slug = 'hw5-w12b';

  insert into public.assignments
    (slug, title, kind, url, description, max_points, published, sort_order,
     week, subject_id, grades)
  values
    ('hw5-w12b', 'Домашно — Общ знаменател. Сравняване на дроби · ниво 2',
     'homework', 'homework_5_w12b.html', 'описание', 10, false, 390, 12,
     (select id from public.subjects where slug = 'matematika'), '{5}')
  on conflict (slug) do update set
    title = excluded.title, kind = excluded.kind, url = excluded.url,
    description = excluded.description, max_points = excluded.max_points,
    sort_order = excluded.sort_order, week = excluded.week,
    subject_id = excluded.subject_id, grades = excluded.grades;

  select id into id2 from public.assignments where slug = 'hw5-w12b';
  perform pg_temp.chk('второто пускане не прави нов ред', id1 = id2, true);
  perform pg_temp.chk('и не отменя публикуването',
    (select published from public.assignments where slug = 'hw5-w12b'), true);
  perform pg_temp.chk('листовете пак са 32',
    (select count(*)::int from pg_temp.nivo2), 32);

  update public.assignments set published = false where slug = 'hw5-w12b';
end $$;

-- ── 4. През очите на петокласник (под RLS) ───────────────────────────
do $$
declare uch uuid; prep uuid; mat uuid; hw uuid; n int; godina int;
begin
  select id into prep from public.profiles where role = 'teacher' and active limit 1;
  select id into mat  from public.subjects where slug = 'matematika';
  select id into hw   from public.assignments where slug = 'hw5-w17b';
  godina := (select coalesce(max(entry_school_year), 2026) from public.profiles);

  if prep is null then
    raise notice '   ⊘ няма преподавател в тази база — проверката под RLS се пропуска';
    return;
  end if;

  insert into auth.users (id, email) values (gen_random_uuid(), 'peti-n2@example.com')
    returning id into uch;
  insert into public.profiles (id, full_name, role, active, grade_at_entry, entry_school_year)
    values (uch, 'Петокласник', 'student', true, 5, godina)
  on conflict (id) do update set
    full_name = excluded.full_name, role = excluded.role, active = excluded.active,
    grade_at_entry = excluded.grade_at_entry, entry_school_year = excluded.entry_school_year;

  perform pg_temp.chk('детето е в 5. клас', public.current_grade(uch), 5);

  insert into public.enrollments (profile_id, subject_id, active) values (uch, mat, true);
  insert into public.teaching (student_id, teacher_id, subject_id, active)
    values (uch, prep, mat, true);
  update public.assignments a set published = true
   where a.id in (select id from pg_temp.nivo2);
  insert into public.assignment_releases (assignment_id, teacher_id, hidden)
    select id, prep, false from pg_temp.nivo2
  on conflict do nothing;

  select count(*)::int into n from pg_temp.nivo2 a
   where public.can_see_assignment(uch, a.id);
  perform pg_temp.chk('и трийсет и двата стигат до детето', n, 32);

  perform set_config('tla.uid', uch::text, true);
  set local role authenticated;

  insert into public.attempts
    (user_id, assignment_id, status, auto_score, auto_max, records)
  values (uch, hw, 'submitted', 10, 10,
          '[{"id":"1","correct":true,"points":1}]'::jsonb);
  get diagnostics n = row_count;
  perform pg_temp.chk('детето записва резултата си', n, 1);
  perform pg_temp.chk('и той е 10 от 10',
    (select auto_score::int || '/' || auto_max::int from public.attempts
      where user_id = uch and assignment_id = hw), '10/10');
  perform pg_temp.chk('няма какво да се оценява на ръка',
    (select manual_max from public.attempts
      where user_id = uch and assignment_id = hw), null::numeric);

  reset role;
end $$;

-- ── 5. Шестокласник не вижда нищо ────────────────────────────────────
do $$
declare drug uuid; n int; godina int;
begin
  godina := (select coalesce(max(entry_school_year), 2026) from public.profiles);
  insert into auth.users (id, email) values (gen_random_uuid(), 'shesti-n2@example.com')
    returning id into drug;
  insert into public.profiles (id, full_name, role, active, grade_at_entry, entry_school_year)
    values (drug, 'Шестокласник', 'student', true, 6, godina)
  on conflict (id) do update set
    full_name = excluded.full_name, role = excluded.role, active = excluded.active,
    grade_at_entry = excluded.grade_at_entry, entry_school_year = excluded.entry_school_year;

  select count(*)::int into n from pg_temp.nivo2 a
   where public.can_see_assignment(drug, a.id);
  perform pg_temp.chk('шестокласникът не вижда нито един', n, 0);

  perform set_config('tla.uid', drug::text, true);
  set local role authenticated;
  perform pg_temp.chk('и ги няма в списъка му',
    (select count(*)::int from public.assignments
      where grades = array[5] and title like '%· ниво 2'), 0);
  reset role;
end $$;

rollback;

\echo '  ✓ математика 5. клас: 32 листа ниво 2, подредбата, правата и повторното пускане'
