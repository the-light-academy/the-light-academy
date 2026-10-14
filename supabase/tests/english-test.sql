-- =====================================================================
--  Английски, „кой какво преподава“ и общият поглед върху часовете
--  ---------------------------------------------------------------------
--  НЕ ПУСКАЙ ТОВА ВЪРХУ ЖИВАТА БАЗА. Файлът пише по teacher_subjects и
--  lessons. Всичко е в транзакция, която завършва с rollback, но пазачът
--  отдолу така или иначе отказва да тръгне, ако види истински данни.
--
--  Доказва трите неща от schema-v13.sql:
--
--  1. „Кой какво преподава“ се чете от всеки преподавател, но се пише
--     само от администратора — и ученик не вижда нищо от него.
--  2. Редът за Валя се закача по име и е безобиден, когато такава няма.
--  3. Часовете: всеки преподавател ВИЖДА чуждите часове, но не може да
--     ги поправя и трие — това си остава на собственика.
--
--  Как се пуска локално:
--     psql -d tla -f supabase/schema-v13.sql
--     psql -d tla -f supabase/tests/english-test.sql
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

create temporary table t_who on commit drop as
select
  (select id from public.profiles where role = 'teacher' and is_admin     limit 1) as admin_id,
  (select id from public.profiles where role = 'teacher' and not is_admin limit 1) as teach_id,
  (select id from public.profiles where role = 'student'                  limit 1) as stud_id,
  (select id from public.subjects where slug = 'angliiski')                        as eng_id,
  (select id from public.subjects where slug = 'matematika')                       as mat_id;

do $$
declare w record;
begin
  select * into w from t_who;
  if w.admin_id is null or w.teach_id is null or w.stud_id is null then
    raise exception 'Няма с кого да се тества.';
  end if;
  perform pg_temp.chk('предметът „Английски“ го има',
    (select name from public.subjects where id = w.eng_id), 'Английски'::text);
  perform pg_temp.chk('и никой не се записва в него автоматично',
    (select auto_enroll from public.subjects where id = w.eng_id), false);
end $$;

-- ── 1. Кой какво преподава: четене и писане ──────────────────────────
do $$
declare w record; n int;
begin
  select * into w from t_who;

  -- админът вписва: Валя-та тук е обикновеният преподавател
  perform set_config('tla.uid', w.admin_id::text, true);
  set local role authenticated;
  insert into public.teacher_subjects (teacher_id, subject_id)
  values (w.teach_id, w.eng_id) on conflict do nothing;
  get diagnostics n = row_count;
  perform pg_temp.chk('админът вписва кой какво преподава', n, 1);
  reset role;

  -- другият преподавател го вижда
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  perform pg_temp.chk('преподавателят вижда списъка',
    (select count(*) from public.teacher_subjects where subject_id = w.eng_id), 1::bigint);

  -- но не може да си припише предмет
  insert into public.teacher_subjects (teacher_id, subject_id)
  values (w.teach_id, w.mat_id) on conflict do nothing;
  reset role;
  raise exception 'не се стига дотук';
exception when insufficient_privilege or others then
  if sqlstate = '42501' then
    raise notice '   ✓ преподавател не може да си припише предмет (42501)';
  elsif sqlerrm = 'не се стига дотук' then
    raise exception '   ✗ преподавател си приписа предмет, а не биваше';
  else
    raise;
  end if;
end $$;

do $$
declare w record;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.stud_id::text, true);
  set local role authenticated;
  perform pg_temp.chk('ученик не вижда нищо от списъка',
    (select count(*) from public.teacher_subjects), 0::bigint);
  reset role;
end $$;

-- ── 2. Редът за Валя: закача се по име ───────────────────────────────
do $$
declare w record; v uuid; n int;
begin
  select * into w from t_who;
  -- нова преподавателка на име Валя (профилът се създава от тригера)
  insert into auth.users (id, email) values (gen_random_uuid(), 'valya@test.local')
  returning id into v;
  update public.profiles set full_name = 'Валя Стоянова', role = 'teacher', active = true
   where id = v;

  insert into public.teacher_subjects (teacher_id, subject_id)
  select p.id, s.id
    from public.profiles p
    cross join public.subjects s
   where p.role = 'teacher' and p.active
     and p.full_name ilike '%Валя%'
     and s.slug = 'angliiski'
  on conflict (teacher_id, subject_id) do update set active = true;
  get diagnostics n = row_count;

  perform pg_temp.chk('редът от файла закача Валя за английския', n, 1);
  perform pg_temp.chk('и тя наистина го преподава',
    (select count(*) from public.teacher_subjects
      where teacher_id = v and subject_id = w.eng_id and active), 1::bigint);
end $$;

-- ── 3. Часовете: вижда се чуждото, не се пипа ────────────────────────
do $$
declare w record; n int;
begin
  select * into w from t_who;

  -- админът записва свой час
  perform set_config('tla.uid', w.admin_id::text, true);
  set local role authenticated;
  insert into public.lessons (teacher_id, subject_id, child_name, starts_at, ends_at, created_by)
  values (w.admin_id, w.mat_id, 'Мими',
          '2026-11-10 17:00+02', '2026-11-10 18:00+02', w.admin_id);
  reset role;

  -- другият преподавател го ВИЖДА
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  perform pg_temp.chk('преподавателят вижда чуждия час',
    (select count(*) from public.lessons where teacher_id = w.admin_id), 1::bigint);
  perform pg_temp.chk('и вижда името на детето в него',
    (select child_name from public.lessons where teacher_id = w.admin_id), 'Мими'::text);

  -- но не го поправя
  update public.lessons set child_name = 'Друго' where teacher_id = w.admin_id;
  get diagnostics n = row_count;
  perform pg_temp.chk('но не може да го поправи', n, 0);

  -- и не го трие
  delete from public.lessons where teacher_id = w.admin_id;
  get diagnostics n = row_count;
  perform pg_temp.chk('и не може да го изтрие', n, 0);

  -- своя си час може
  insert into public.lessons (teacher_id, subject_id, child_name, starts_at, ends_at, created_by)
  values (w.teach_id, w.mat_id, 'Сашо',
          '2026-11-10 19:00+02', '2026-11-10 20:00+02', w.teach_id);
  update public.lessons set child_name = 'Сашо Петров' where teacher_id = w.teach_id;
  get diagnostics n = row_count;
  perform pg_temp.chk('своя си час поправя', n, 1);
  reset role;

  -- ученикът не вижда никакви часове
  perform set_config('tla.uid', w.stud_id::text, true);
  set local role authenticated;
  perform pg_temp.chk('ученик не вижда часове',
    (select count(*) from public.lessons), 0::bigint);
  reset role;

  perform pg_temp.chk('а двата часа си стоят в базата',
    (select count(*) from public.lessons), 2::bigint);
end $$;

-- ── 4. Имената на преподавателите ───────────────────────────────────
do $$
declare w record; n int;
begin
  select * into w from t_who;

  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  select count(*) into n from public.teacher_names();
  perform pg_temp.chk('преподавателят получава имената на колегите си', n >= 2, true);
  perform pg_temp.chk('и своето сред тях',
    (select count(*) from public.teacher_names() where id = w.teach_id), 1::bigint);
  perform pg_temp.chk('а ученик не е сред тях',
    (select count(*) from public.teacher_names() where id = w.stud_id), 0::bigint);
  reset role;

  perform set_config('tla.uid', w.stud_id::text, true);
  set local role authenticated;
  perform pg_temp.chk('ученик не получава никакви имена',
    (select count(*) from public.teacher_names()), 0::bigint);
  reset role;

  perform pg_temp.chk('невлезлият няма право дори да я извика',
    has_function_privilege('anon', 'public.teacher_names()', 'execute'), false);
end $$;

rollback;

do $$ begin raise notice '';
  raise notice '═══ АНГЛИЙСКИЯТ И ОБЩИЯТ КАЛЕНДАР СА НАРЕД ═══'; end $$;
