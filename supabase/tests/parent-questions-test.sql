-- =====================================================================
--  Въпросите от родителите — кой може да пише и кой да чете
--  ---------------------------------------------------------------------
--  НЕ ПУСКАЙ ТОВА ВЪРХУ ЖИВАТА БАЗА. Файлът пише по parent_questions.
--  Всичко е в транзакция, която завършва с rollback, но пазачът отдолу
--  така или иначе отказва да тръгне, ако види истински данни.
--
--  Таблицата е единственото място в платформата, отворено за писане от
--  човек, който не е влязъл никъде. Затова се доказва точно това:
--
--  1. Родителят (anon) МОЖЕ да зададе въпрос.
--  2. Родителят НЕ МОЖЕ да прочете нищо — нито своя въпрос, нито чужд.
--  3. Преподавателят също не чете: това са запитвания към академията.
--  4. Администраторът чете и отмята.
--  5. Боклук не влиза: празен въпрос, твърде дълъг въпрос и въпрос без
--     начин за връзка се отказват.
--  6. Никой отвън не може да вкара въпрос, вече отметнат за приключен —
--     инак би го скрил от таблото в мига на писането.
--  7. Пазачът подрязва празнините и превръща празните полета в null.
--  8. Пазачът върху скоростта спира машина, която удря в кръг.
--
--  Как се пуска локално:
--     psql -d tla -f supabase/schema-v17.sql
--     psql -d tla -f supabase/tests/parent-questions-test.sql
-- =====================================================================
\set ON_ERROR_STOP on

do $$ begin
  if (select count(*) from public.profiles) > 20 then
    raise exception 'Това прилича на истинска база — тестът отказва да тръгне.';
  end if;
  if (select count(*) from public.parent_questions) > 0 then
    raise exception 'В parent_questions вече има въпроси — тестът отказва да тръгне.';
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
  (select id from public.profiles where role = 'teacher' and not is_admin limit 1) as teach_id;

do $$
declare w record;
begin
  select * into w from t_who;
  if w.admin_id is null or w.teach_id is null then
    raise exception 'Трябват админ и обикновен преподавател, за да има какво да се сравнява.';
  end if;
  raise notice '   ✓ има с кого да се тества';
end $$;

-- ── 1. Родителят пита ───────────────────────────────────────────────
do $$
declare n int;
begin
  set local role anon;
  insert into public.parent_questions (ime, imeyl, vupros)
  values ('Мария Иванова', 'maria@example.com',
          'Здравейте, има ли свободни места за 5. клас по математика?');
  get diagnostics n = row_count;
  reset role;
  perform pg_temp.chk('родителят може да зададе въпрос', n, 1);
end $$;

-- Само с телефон също минава: не всеки родител има имейл подръка.
do $$
declare n int;
begin
  set local role anon;
  insert into public.parent_questions (ime, telefon, vupros)
  values ('Петър Георгиев', '0888 123 456',
          'Кога започват часовете по английски за 6. клас?');
  get diagnostics n = row_count;
  reset role;
  perform pg_temp.chk('стига и само телефон', n, 1);
end $$;

-- ── 2. Родителят не чете ────────────────────────────────────────────
do $$
begin
  set local role anon;
  perform pg_temp.must_fail('родителят не чете въпросите',
    'select * from public.parent_questions', '42501');
  reset role;
end $$;

-- ── 3. Преподавателят също не чете ──────────────────────────────────
do $$
declare w record; n int;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.teach_id::text, true);
  set local role authenticated;
  select count(*) into n from public.parent_questions;
  reset role;
  perform pg_temp.chk('преподавателят вижда нула въпроса', n, 0);
end $$;

-- ── 4. Администраторът чете и отмята ────────────────────────────────
do $$
declare w record; n int; id_na_vupros uuid;
begin
  select * into w from t_who;
  perform set_config('tla.uid', w.admin_id::text, true);
  set local role authenticated;
  select count(*) into n from public.parent_questions;
  perform pg_temp.chk('администраторът вижда двата въпроса', n, 2);

  select id into id_na_vupros from public.parent_questions
   order by created_at limit 1;
  update public.parent_questions
     set handled = true, handled_at = now(), handled_by = w.admin_id,
         belejka = 'Обадих се, записахме дете за пробен час.'
   where id = id_na_vupros;
  get diagnostics n = row_count;
  reset role;
  perform pg_temp.chk('администраторът отмята въпрос', n, 1);
end $$;

-- ── 5. Боклук не влиза ──────────────────────────────────────────────
do $$
begin
  set local role anon;
  perform pg_temp.must_fail('празен въпрос не минава',
    $q$insert into public.parent_questions (ime, imeyl, vupros)
       values ('Иван', 'ivan@example.com', '   ')$q$, '23514');
  perform pg_temp.must_fail('къс въпрос не минава',
    $q$insert into public.parent_questions (ime, imeyl, vupros)
       values ('Иван', 'ivan@example.com', 'здр')$q$, '23514');
  perform pg_temp.must_fail('роман вместо въпрос не минава',
    $q$insert into public.parent_questions (ime, imeyl, vupros)
       values ('Иван', 'ivan@example.com', repeat('а', 4001))$q$, '23514');
  perform pg_temp.must_fail('без име не минава',
    $q$insert into public.parent_questions (ime, imeyl, vupros)
       values ('', 'ivan@example.com', 'Имате ли свободни места?')$q$, '23514');
  perform pg_temp.must_fail('без начин за връзка не минава',
    $q$insert into public.parent_questions (ime, vupros)
       values ('Иван', 'Имате ли свободни места за 7. клас?')$q$, '23514');
  reset role;
end $$;

-- ── 6. Отвън не се пише „приключено“ ────────────────────────────────
do $$
begin
  set local role anon;
  perform pg_temp.must_fail('отвън не се пише „обработено“',
    $q$insert into public.parent_questions (ime, imeyl, vupros, handled, handled_at)
       values ('Иван', 'ivan@example.com', 'Скрит въпрос, който не бива да мине.',
               true, now())$q$, '42501');
  perform pg_temp.must_fail('отвън не се пише бележка',
    $q$insert into public.parent_questions (ime, imeyl, vupros, belejka)
       values ('Иван', 'ivan@example.com', 'Въпрос с чужда бележка.',
               'нещо си')$q$, '42501');
  reset role;
end $$;

-- ── 7. Пазачът подрязва ─────────────────────────────────────────────
do $$
declare w record; r record;
begin
  set local role anon;
  insert into public.parent_questions (ime, imeyl, telefon, vupros)
  values ('  Анна Петрова  ', '  anna@example.com  ', '   ',
          '  Колко струва един час по математика?  ');
  reset role;

  select * into w from t_who;
  perform set_config('tla.uid', w.admin_id::text, true);
  set local role authenticated;
  select ime, imeyl, telefon, vupros into r
    from public.parent_questions where imeyl = 'anna@example.com';
  reset role;

  perform pg_temp.chk('името е подрязано', r.ime, 'Анна Петрова');
  perform pg_temp.chk('имейлът е подрязан', r.imeyl, 'anna@example.com');
  perform pg_temp.chk('празният телефон става null', r.telefon, null::text);
  perform pg_temp.chk('въпросът е подрязан', r.vupros,
                      'Колко струва един час по математика?');
end $$;

-- ── 8. Пазачът върху скоростта ──────────────────────────────────────
do $$
declare i int;
begin
  set local role anon;
  --  Три вече има; добавяме до прага от десет за минута.
  for i in 4..10 loop
    insert into public.parent_questions (ime, imeyl, vupros)
    values ('Машина ' || i, 'bot' || i || '@example.com',
            'Въпрос номер ' || i || ', зададен от машина.');
  end loop;
  perform pg_temp.must_fail('единайсетият за минута се отказва',
    $q$insert into public.parent_questions (ime, imeyl, vupros)
       values ('Машина 11', 'bot11@example.com',
               'Въпрос номер 11, зададен от машина.')$q$, '53400');
  reset role;
end $$;

do $$ begin raise notice '   ✓ всичко мина'; end $$;

rollback;
