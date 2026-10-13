-- =====================================================================
--  Рожденият ден — кой може да го запише и кой може да го види
--  ---------------------------------------------------------------------
--  НЕ ПУСКАЙ ТОВА ВЪРХУ ЖИВАТА БАЗА. Файлът пише по profiles. Всичко е
--  в транзакция, която завършва с rollback, но пазачът отдолу така или
--  иначе отказва да тръгне, ако види истински данни.
--
--  Доказва трите неща, на които стъпва полето в паспорта:
--
--  1. Детето може да си запише САМО своя рожден ден и САМО него — не
--     чужд ред, не друга колона, не ролята си.
--  2. Датата е в разумни граници — базата отказва бъдеще и отдавна,
--     независимо кой пише.
--  3. Вижда се от детето, от неговия преподавател и от админа. От
--     никого друг — нито съученик, нито преподавател без връзка.
--
--  Как се пуска локално:
--     psql -d tla -f supabase/schema-v12.sql
--     psql -d tla -f supabase/tests/birthday-test.sql
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

-- Кой кой е: админ, преподавател без админски права, двете деца.
-- Преподавателят води първото дете, но НЕ и второто — точно разликата,
-- която трябва да си личи.
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

-- ── 1. Детето си записва рождения ден ────────────────────────────────
do $$
declare w record; got date;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.kid_id::text, true);
  set local role authenticated;
  got := public.set_my_birthday(date '2015-03-21');
  reset role;
  perform pg_temp.chk('детето си записва рождения ден', got, date '2015-03-21');
  perform pg_temp.chk('и той наистина стои в реда му',
    (select birthday from public.profiles where id = w.kid_id), date '2015-03-21');
end $$;

-- ── 2. Чуждият ред остава непипнат ───────────────────────────────────
--  id-то не е параметър на функцията — няма какво да се подаде. Това
--  тук проверява, че след запис от едното дете другото е както е било.
do $$
declare w record;
begin
  select * into w from t_who;
  perform pg_temp.chk('чуждият рожден ден не е пипнат',
    (select birthday from public.profiles where id = w.other_kid), null::date);
end $$;

-- ── 3. Детето НЕ може да пише направо в profiles ─────────────────────
--  Няма политика за update за ученик. Политиките не вдигат грешка —
--  просто не пускат нито един ред, затова тук се брои засегнатото.
do $$
declare w record; n int;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.kid_id::text, true);
  set local role authenticated;

  update public.profiles set birthday = date '2010-01-01' where id = w.kid_id;
  get diagnostics n = row_count;
  perform pg_temp.chk('дете, което пише направо в profiles, не мърда нито ред', n, 0);

  update public.profiles set is_admin = true where id = w.kid_id;
  get diagnostics n = row_count;
  perform pg_temp.chk('и не може да си вдигне правата', n, 0);

  update public.profiles set birthday = date '2010-01-01' where id = w.other_kid;
  get diagnostics n = row_count;
  perform pg_temp.chk('и не стига до чужд ред', n, 0);

  reset role;
  perform pg_temp.chk('рожденият ден си е останал какъвто беше',
    (select birthday from public.profiles where id = w.kid_id), date '2015-03-21');
  perform pg_temp.chk('и правата също',
    (select is_admin from public.profiles where id = w.kid_id), false);
end $$;

-- ── 4. Границите на датата ───────────────────────────────────────────
do $$
declare w record;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.kid_id::text, true);
end $$;

select pg_temp.must_fail('рожден ден в бъдещето (през функцията)',
  $$do $i$ begin
      set local role authenticated;
      perform public.set_my_birthday(current_date + 1);
    end $i$;$$, '23514');

select pg_temp.must_fail('рожден ден отпреди 1995 (през функцията)',
  $$do $i$ begin
      set local role authenticated;
      perform public.set_my_birthday(date '1980-05-05');
    end $i$;$$, '23514');

--  Същото важи и за админа, който пише направо в таблицата: бъдещето го
--  спира тригерът, а отдавнашното — ограничението.
select pg_temp.must_fail('бъдеще и от админа направо в таблицата',
  $$do $i$ declare w record; begin
      select * into w from t_who;
      perform set_config('tla.uid', w.admin_id::text, true);
      set local role authenticated;
      update public.profiles set birthday = current_date + 30 where id = w.kid_id;
    end $i$;$$, '23514');

select pg_temp.must_fail('отдавна и от админа направо в таблицата',
  $$do $i$ declare w record; begin
      select * into w from t_who;
      perform set_config('tla.uid', w.admin_id::text, true);
      set local role authenticated;
      update public.profiles set birthday = date '1899-01-01' where id = w.kid_id;
    end $i$;$$, '23514');

reset role;

-- ── 5. Днешната дата минава (границата е „не утре“) ──────────────────
do $$
declare w record; got date;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.kid_id::text, true);
  set local role authenticated;
  got := public.set_my_birthday(current_date);
  perform pg_temp.chk('днес минава', got, current_date);
  got := public.set_my_birthday(date '2015-03-21');
  reset role;
  perform pg_temp.chk('и се връща обратно', got, date '2015-03-21');
end $$;

-- ── 6. Детето може да си махне датата ────────────────────────────────
do $$
declare w record; got date;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.kid_id::text, true);
  set local role authenticated;
  got := public.set_my_birthday(null);
  perform pg_temp.chk('null изчиства рождения ден', got, null::date);
  perform public.set_my_birthday(date '2015-03-21');
  reset role;
end $$;

-- ── 7. Кой го вижда ──────────────────────────────────────────────────
do $$
declare w record;
begin
  select * into w from t_who;

  perform set_config('tla.uid', w.kid_id::text, true);
  set local role authenticated;
  perform pg_temp.chk('детето вижда своя',
    (select birthday from public.profiles where id = w.kid_id), date '2015-03-21');
  reset role;

  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  perform pg_temp.chk('преподавателят вижда рождения ден на своя ученик',
    (select birthday from public.profiles where id = w.kid_id), date '2015-03-21');
  perform pg_temp.chk('а чуждото дете изобщо не му се показва',
    (select count(*) from public.profiles where id = w.other_kid), 0::bigint);
  reset role;

  perform set_config('tla.uid', w.admin_id::text, true);
  set local role authenticated;
  perform pg_temp.chk('админът вижда всички рождени дни',
    (select count(*) from public.profiles where role = 'student'), 2::bigint);
  reset role;
end $$;

-- ── 8. Съученик не вижда чужд профил ─────────────────────────────────
do $$
declare w record;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.other_kid::text, true);
  set local role authenticated;
  perform pg_temp.chk('съученик не стига до чужд ред',
    (select count(*) from public.profiles where id = w.kid_id), 0::bigint);
  reset role;
end $$;

-- ── 9. Невлезлият не може дори да извика функцията ───────────────────
do $$
begin
  perform pg_temp.chk('anon няма право да вика set_my_birthday',
    has_function_privilege('anon', 'public.set_my_birthday(date)', 'execute'), false);
  perform pg_temp.chk('влезлият има',
    has_function_privilege('authenticated', 'public.set_my_birthday(date)', 'execute'), true);
end $$;

-- ── 10. Паспортът си остава затворен ─────────────────────────────────
--  Рожденият ден излезе от star_cards точно за да не се отваря картата.
--  Ако някой ден някой добави политика там, това ще се обади.
do $$
declare w record; n int;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  select count(*) into n from public.star_cards;
  reset role;
  perform pg_temp.chk('преподавателят пак не вижда нито един паспорт', n, 0);
end $$;

rollback;

do $$ begin raise notice '';
  raise notice '═══ РОЖДЕНИЯТ ДЕН Е НАРЕД ═══'; end $$;
