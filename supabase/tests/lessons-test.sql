-- Часовете на преподавателите: ограниченията и правилата кой какво вижда.
-- Всичко в транзакция с rollback — базата остава както е била.
\set ON_ERROR_STOP on
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

-- ── подготовка: двама преподаватели, един админ, един предмет ─────────
-- Взимат се истински редове от базата, за да не се борим с външни ключове.
create temporary table t_who on commit drop as
select
  (select id from public.profiles where role = 'teacher' and is_admin      limit 1) as admin_id,
  (select id from public.profiles where role = 'teacher' and not is_admin  limit 1) as teach_id,
  (select id from public.profiles where role = 'student'                   limit 1) as stud_id,
  (select id from public.subjects where active                             limit 1) as subj_id;

do $$
declare w record;
begin
  select * into w from t_who;
  if w.admin_id is null or w.teach_id is null or w.subj_id is null then
    raise exception 'Няма с кого да се тества: трябват админ, обикновен преподавател и предмет.';
  end if;
  raise notice '   ✓ има с кого да се тества';
end $$;

-- ── 1. Нормален час влиза ─────────────────────────────────────────────
do $$
declare w record;
begin
  select * into w from t_who;
  insert into public.lessons (teacher_id, subject_id, child_name, starts_at, ends_at, created_by)
  values (w.teach_id, w.subj_id, 'Мария',
          '2026-10-14 17:00+03', '2026-10-14 18:00+03', w.teach_id);
  raise notice '   ✓ час от 17:00 до 18:00 се записва';
end $$;

-- ── 2. Два часа на един преподавател в едно и също време не минават ───
select pg_temp.must_fail('същият час, същият преподавател',
  $$insert into public.lessons (teacher_id, subject_id, child_name, starts_at, ends_at, created_by)
    select teach_id, subj_id, 'Иван', '2026-10-14 17:00+03', '2026-10-14 18:00+03', teach_id
      from t_who$$, '23P01');

select pg_temp.must_fail('час, който влиза в края на друг',
  $$insert into public.lessons (teacher_id, subject_id, child_name, starts_at, ends_at, created_by)
    select teach_id, subj_id, 'Иван', '2026-10-14 17:30+03', '2026-10-14 18:30+03', teach_id
      from t_who$$, '23P01');

do $$
declare w record;
begin
  select * into w from t_who;
  /* точно след края — минава, краищата не се броят за застъпване */
  insert into public.lessons (teacher_id, subject_id, child_name, starts_at, ends_at, created_by)
  values (w.teach_id, w.subj_id, 'Иван',
          '2026-10-14 18:00+03', '2026-10-14 19:00+03', w.teach_id);
  raise notice '   ✓ час веднага след предишния минава';

  /* същото време, но ДРУГ преподавател — минава */
  insert into public.lessons (teacher_id, subject_id, child_name, starts_at, ends_at, created_by)
  values (w.admin_id, w.subj_id, 'Петър',
          '2026-10-14 17:00+03', '2026-10-14 18:00+03', w.admin_id);
  raise notice '   ✓ друг преподавател в същия час минава';
end $$;

-- ── 3. Нередните часове ───────────────────────────────────────────────
select pg_temp.must_fail('край преди начало',
  $$insert into public.lessons (teacher_id, subject_id, child_name, starts_at, ends_at, created_by)
    select teach_id, subj_id, 'Мария', '2026-10-15 18:00+03', '2026-10-15 17:00+03', teach_id
      from t_who$$, '23514');

select pg_temp.must_fail('час от девет часа',
  $$insert into public.lessons (teacher_id, subject_id, child_name, starts_at, ends_at, created_by)
    select teach_id, subj_id, 'Мария', '2026-10-15 09:00+03', '2026-10-15 18:00+03', teach_id
      from t_who$$, '23514');

select pg_temp.must_fail('без име на дете',
  $$insert into public.lessons (teacher_id, subject_id, child_name, starts_at, ends_at, created_by)
    select teach_id, subj_id, '   ', '2026-10-15 09:00+03', '2026-10-15 10:00+03', teach_id
      from t_who$$, '23514');

-- ── 4. Кой какво вижда ────────────────────────────────────────────────
do $$
declare w record; n int;
begin
  select * into w from t_who;

  /* преподавателят: само своите */
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  select count(*) into n from public.lessons;
  if n <> 2 then raise exception '   ✗ преподавателят вижда % часа вместо 2', n; end if;
  raise notice '   ✓ преподавателят вижда само своите два часа';
  reset role;

  /* админът: всичко */
  perform set_config('tla.uid', w.admin_id::text, true);
  set local role authenticated;
  select count(*) into n from public.lessons;
  if n <> 3 then raise exception '   ✗ админът вижда % часа вместо 3', n; end if;
  raise notice '   ✓ админът вижда и трите';
  reset role;

  /* ученикът: нищо */
  if w.stud_id is not null then
    perform set_config('tla.uid', w.stud_id::text, true);
    set local role authenticated;
    select count(*) into n from public.lessons;
    if n <> 0 then raise exception '   ✗ ученик вижда % часа, а не трябва нито един', n; end if;
    raise notice '   ✓ ученикът не вижда нито един час';
    reset role;
  else
    raise notice '   ⊘ няма ученик за проверка';
  end if;
end $$;

-- ── 5. Преподавател не пише от чуждо име и не трие чуждо ──────────────
do $$
declare w record; n int;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;

  begin
    insert into public.lessons (teacher_id, subject_id, child_name, starts_at, ends_at, created_by)
    values (w.admin_id, w.subj_id, 'Чужд час',
            '2026-10-16 17:00+03', '2026-10-16 18:00+03', w.teach_id);
    raise exception '   ✗ преподавател записа час на чуждо име';
  exception when insufficient_privilege then
    raise notice '   ✓ не може да запише час на чужд преподавател';
  end;

  /* чуждият час не се трие — политиката просто не го вижда */
  delete from public.lessons where teacher_id = w.admin_id;
  get diagnostics n = row_count;
  if n <> 0 then raise exception '   ✗ изтри % чужди часа', n; end if;
  raise notice '   ✓ чужд час не се трие';

  /* своя — да */
  delete from public.lessons where teacher_id = w.teach_id and starts_at = '2026-10-14 18:00+03';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '   ✗ своят час не се изтри (% реда)', n; end if;
  raise notice '   ✓ своя час се трие';
  reset role;
end $$;

-- ── 6. Поредица: един и същ series_id, седмица по седмица ─────────────
do $$
declare w record; sid uuid := gen_random_uuid(); n int;
begin
  select * into w from t_who;
  insert into public.lessons (teacher_id, subject_id, child_name, starts_at, ends_at, created_by, series_id)
  select w.teach_id, w.subj_id, 'Поредица',
         ('2026-11-03 17:00+02'::timestamptz + (k || ' weeks')::interval),
         ('2026-11-03 18:00+02'::timestamptz + (k || ' weeks')::interval),
         w.teach_id, sid
    from generate_series(0, 3) k;
  select count(*) into n from public.lessons where series_id = sid;
  if n <> 4 then raise exception '   ✗ поредицата е % реда вместо 4', n; end if;
  raise notice '   ✓ поредица от четири седмици влиза с общ номер';

  delete from public.lessons where series_id = sid and starts_at >= '2026-11-17';
  select count(*) into n from public.lessons where series_id = sid;
  if n <> 2 then raise exception '   ✗ след триене на опашката останаха % вместо 2', n; end if;
  raise notice '   ✓ и се трие от определена дата нататък';
end $$;

rollback;
\echo '═══ ВСИЧКО МИНА ═══'
