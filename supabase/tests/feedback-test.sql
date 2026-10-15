-- =====================================================================
--  Обратната връзка за родителя — кой може да я пише и кой да я чете
--  ---------------------------------------------------------------------
--  НЕ ПУСКАЙ ТОВА ВЪРХУ ЖИВАТА БАЗА. Файлът пише по feedback_reports.
--  Всичко е в транзакция, която завършва с rollback, но пазачът отдолу
--  така или иначе отказва да тръгне, ако види истински данни.
--
--  Доказва четирите неща, на които стъпва разделът „Обратна връзка“:
--
--  1. Преподавателят пише отчет за СВОЙ ученик и на СВОЕ име — чуждо
--     дете и чуждо име базата отказва.
--  2. Чете го авторът, другият преподавател на същото дете и админът.
--  3. ДЕТЕТО НЕ ГО ЧЕТЕ — нито своето, нито чуждо.
--  4. Периодът е наред: краят не е преди началото, бъдеще не минава, а
--     „изпратен“ без дата на изпращане — също.
--
--  Как се пуска локално:
--     psql -d tla -f supabase/schema-v15.sql
--     psql -d tla -f supabase/tests/feedback-test.sql
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

create or replace function pg_temp.must_fail(name text, sql text, want text)
returns void language plpgsql as $$
declare code text;
begin
  begin execute sql;
  exception when others then
    code := sqlstate;
    /* Тези кодове значат, че самият тест е написан накриво — липсваща
       колона, объркан тип, сбъркан синтаксис. Да ги броим за „базата
       спря нередното“ е най-лесният начин тестът да лъже. */
    if code in ('42601','42703','42804','42883','42P01','22P02') then
      raise exception '   ✗ % · тестът е сбъркан, не базата: % (%)', name, sqlerrm, code;
    end if;
    if code <> want then
      raise exception '   ✗ % · спря с %, а трябваше с %: %', name, code, want, sqlerrm;
    end if;
    raise notice '   ✓ % (%)', name, code; return;
  end;
  raise exception '   ✗ % · МИНА, а не трябваше', name;
end $$;

begin;

create temporary table t_who on commit drop as
select
  (select id from public.profiles where role = 'teacher' and is_admin     limit 1) as admin_id,
  (select id from public.profiles where role = 'teacher' and not is_admin limit 1) as teach_id,
  (select t.student_id from public.teaching t
     join public.profiles p on p.id = t.teacher_id
    where p.role = 'teacher' and not p.is_admin and t.active              limit 1) as kid_id,
  (select p.id from public.profiles p
    where p.role = 'student'
      and not exists (select 1 from public.teaching t
                       join public.profiles tp on tp.id = t.teacher_id
                      where t.student_id = p.id and t.active and not tp.is_admin)
                                                                          limit 1) as other_kid;

do $$
declare w record;
begin
  select * into w from t_who;
  if w.admin_id is null or w.teach_id is null or w.kid_id is null or w.other_kid is null then
    raise exception 'Няма с кого да се тества: трябват админ, преподавател и две деца — едното негово, другото не.';
  end if;
  raise notice '   ✓ има с кого да се тества';
end $$;

-- ── 1. Преподавателят пише отчет за своя ученик ──────────────────────
do $$
declare w record; n int;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  insert into public.feedback_reports
    (student_id, teacher_id, period_from, period_to, summary, focus, stats)
  values (w.kid_id, w.teach_id, current_date - 60, current_date,
          'Върви стабилно.', 'Ред на действията.',
          '{"handed":7,"avg":78}'::jsonb);
  get diagnostics n = row_count;
  reset role;
  perform pg_temp.chk('преподавателят написа отчет за своя ученик', n, 1);
end $$;

-- ── 2. За чуждо дете — не ────────────────────────────────────────────
do $$
declare w record;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  perform pg_temp.must_fail('отчет за чуждо дете не минава',
    format($q$insert into public.feedback_reports
               (student_id, teacher_id, period_from, period_to)
             values (%L, %L, current_date - 30, current_date)$q$,
           w.other_kid, w.teach_id),
    '42501');
  reset role;
end $$;

-- ── 3. На чуждо име — също не ────────────────────────────────────────
--  Иначе един преподавател би подписал отчет с името на друг.
do $$
declare w record;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  perform pg_temp.must_fail('чуждо име под отчета не минава',
    format($q$insert into public.feedback_reports
               (student_id, teacher_id, period_from, period_to)
             values (%L, %L, current_date - 30, current_date)$q$,
           w.kid_id, w.admin_id),
    '42501');
  reset role;
end $$;

-- ── 4. Детето не чете обратната връзка за себе си ────────────────────
do $$
declare w record; n int;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.kid_id::text, true);
  set local role authenticated;
  select count(*) into n from public.feedback_reports;
  reset role;
  perform pg_temp.chk('детето не вижда нито един отчет', n, 0);
end $$;

-- ── 5. Нито може да пише по него ─────────────────────────────────────
do $$
declare w record; n int;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.kid_id::text, true);
  set local role authenticated;
  update public.feedback_reports set summary = 'пипнато от детето';
  get diagnostics n = row_count;
  reset role;
  perform pg_temp.chk('детето не промени нищо', n, 0);
end $$;

-- ── 6. Чуждото дете — също нищо ──────────────────────────────────────
do $$
declare w record; n int;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.other_kid::text, true);
  set local role authenticated;
  select count(*) into n from public.feedback_reports;
  reset role;
  perform pg_temp.chk('съученик не вижда чужда обратна връзка', n, 0);
end $$;

-- ── 7. Авторът и админът четат ───────────────────────────────────────
do $$
declare w record; n_author int; n_admin int;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  select count(*) into n_author from public.feedback_reports;
  reset role;
  perform set_config('tla.uid', w.admin_id::text, true);
  set local role authenticated;
  select count(*) into n_admin from public.feedback_reports;
  reset role;
  perform pg_temp.chk('авторът чете своя отчет', n_author, 1);
  perform pg_temp.chk('админът го чете също', n_admin, 1);
end $$;

-- ── 8. Чужд отчет не се поправя ──────────────────────────────────────
--  Админът пише свой отчет за същото дете; преподавателят не бива да
--  може да го редактира, макар да чете.
do $$
declare w record; n int;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.admin_id::text, true);
  set local role authenticated;
  insert into public.feedback_reports
    (student_id, teacher_id, period_from, period_to, summary)
  values (w.kid_id, w.admin_id, current_date - 60, current_date, 'От админа.');
  reset role;

  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  update public.feedback_reports set summary = 'пипнато от друг'
   where teacher_id = w.admin_id;
  get diagnostics n = row_count;
  select count(*) into n from public.feedback_reports;
  reset role;
  perform pg_temp.chk('чуждият отчет остана непипнат',
    (select summary from public.feedback_reports where teacher_id = w.admin_id),
    'От админа.');
  perform pg_temp.chk('но преподавателят го ЧЕТЕ', n, 2);
end $$;

-- ── 9. Периодът — базата пази подредбата ─────────────────────────────
do $$
declare w record;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  perform pg_temp.must_fail('краят преди началото не минава',
    format($q$insert into public.feedback_reports
               (student_id, teacher_id, period_from, period_to)
             values (%L, %L, current_date, current_date - 10)$q$, w.kid_id, w.teach_id),
    '23514');
  perform pg_temp.must_fail('период в бъдещето не минава',
    format($q$insert into public.feedback_reports
               (student_id, teacher_id, period_from, period_to)
             values (%L, %L, current_date, current_date + 30)$q$, w.kid_id, w.teach_id),
    '23514');
  perform pg_temp.must_fail('„изпратен“ без дата на изпращане не минава',
    format($q$insert into public.feedback_reports
               (student_id, teacher_id, period_from, period_to, status)
             values (%L, %L, current_date - 10, current_date, 'sent')$q$, w.kid_id, w.teach_id),
    '23514');
  perform pg_temp.must_fail('непознат статус не минава',
    format($q$insert into public.feedback_reports
               (student_id, teacher_id, period_from, period_to, status)
             values (%L, %L, current_date - 10, current_date, 'изпратено')$q$, w.kid_id, w.teach_id),
    '23514');
  reset role;
end $$;

-- ── 10. Отбелязването „изпратено“ работи ─────────────────────────────
do $$
declare w record; st text;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  update public.feedback_reports
     set status = 'sent', sent_at = now()
   where teacher_id = w.teach_id;
  select status into st from public.feedback_reports where teacher_id = w.teach_id;
  reset role;
  perform pg_temp.chk('отчетът се отбелязва като изпратен', st, 'sent');
end $$;

-- ── 11. updated_at го пише базата ────────────────────────────────────
do $$
declare w record; t1 timestamptz; t2 timestamptz;
begin
  select * into w from t_who;
  select updated_at into t1 from public.feedback_reports where teacher_id = w.teach_id;
  perform pg_temp.chk('updated_at е попълнен при вмъкване', t1 is not null, true);
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  update public.feedback_reports
     set summary = 'допълнено после', updated_at = timestamptz '2001-01-01'
   where teacher_id = w.teach_id;
  reset role;
  select updated_at into t2 from public.feedback_reports where teacher_id = w.teach_id;
  perform pg_temp.chk('и подадена отвън дата не минава — базата го пише',
    t2 > timestamptz '2020-01-01', true);
end $$;

-- ── 12. Трие се само своето ──────────────────────────────────────────
do $$
declare w record; n int;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  delete from public.feedback_reports where teacher_id = w.admin_id;
  get diagnostics n = row_count;
  reset role;
  perform pg_temp.chk('чужд отчет не се трие', n, 0);

  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  delete from public.feedback_reports where teacher_id = w.teach_id;
  get diagnostics n = row_count;
  reset role;
  perform pg_temp.chk('своят се трие', n, 1);
end $$;

rollback;
do $$ begin raise notice 'Всички проверки минаха.'; end $$;
