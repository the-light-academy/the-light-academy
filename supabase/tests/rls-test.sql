\set ON_ERROR_STOP on
\set QUIET on
\pset pager off
\pset tuples_only on
\pset format unaligned

-- =====================================================================
-- ПРОВЕРКА НА ПРАВАТА — доказва, че един преподавател не стига до
-- учениците на друг.
--
-- ⚠️  НЕ ПУСКАЙ ТОВА ВЪРХУ ИСТИНСКАТА БАЗА. Файлът трие таблицата
--     teaching и пренарежда кой кого учи. Той е за чернова база.
--     Пазачът отдолу отказва да продължи, ако тестовите потребители ги
--     няма — тоест ако това не е чернова, направена с rls-seed.sql.
--
-- Как се пуска (локално, срещу празен Postgres):
--     psql -f supabase/schema.sql
--     psql -f supabase/schema-v2.sql
--     psql -f supabase/tests/rls-seed.sql
--     psql -f supabase/schema-v3.sql
--     psql -f supabase/tests/rls-test.sql        ← този файл
--
-- auth.uid() в чернова база се подменя така, че тестът да може да
-- „влиза“ като различни хора:
--     create or replace function auth.uid() returns uuid language sql
--     stable as $$ select nullif(current_setting('tla.uid', true), '')::uuid $$;
-- =====================================================================

do $$
begin
  if not exists (select 1 from auth.users
                  where id = '00000000-0000-0000-0000-0000000000a1'
                    and email = 'the.light.academy56@gmail.com') then
    raise exception
      'Отказвам: тестовите потребители липсват, значи това не е чернова база. Пусни първо supabase/tests/rls-seed.sql.';
  end if;
  if (select count(*) from public.profiles) > 20 then
    raise exception
      'Отказвам: тази база има % профила — прилича на истинската, а тестът трие taблицата teaching.',
      (select count(*) from public.profiles);
  end if;
end $$;


-- ── assertion helpers (created as superuser) ────────────────────────
create or replace function test_eq(label text, expected bigint, actual bigint)
returns void language plpgsql as $$
begin
  if expected is distinct from actual then
    raise exception 'ПАДНА  % — очаквани % реда, получени %', label, expected, actual;
  end if;
  raise notice 'ok    %  (% реда)', label, actual;
end $$;

-- ── the scenario ────────────────────────────────────────────────────
--   Ани  (админ)  учи Георги (7. клас)
--   Петя (учител) учи Иван и Мария (6. клас)
--   Сам   няма никакъв преподавател
delete from public.teaching;
insert into public.teaching (teacher_id, student_id, subject_id)
select '00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-0000000000b3',
       id from public.subjects where slug='matematika';
insert into public.teaching (teacher_id, student_id, subject_id)
select '00000000-0000-0000-0000-0000000000a2', s, id
  from public.subjects, unnest(array['00000000-0000-0000-0000-0000000000b1'::uuid,
                                     '00000000-0000-0000-0000-0000000000b2'::uuid]) s
 where slug='matematika';
delete from public.assignment_releases;

-- истинските бройки, взети като суперпотребител: админът трябва да вижда
-- точно толкова, а не число, което съм написал на ръка
select count(*) as n_profile from public.profiles \gset
select count(*) as n_assign  from public.assignments \gset
select count(*) as n_attempt from public.attempts \gset

\echo ''
\echo '───────────────  ПЕТЯ (обикновен преподавател)  ───────────────'
set role authenticated;
set tla.uid = '00000000-0000-0000-0000-0000000000a2';

select test_eq('вижда профилите само на своите двама ученици', 2,
  (select count(*) from public.profiles where role='student'));
select test_eq('Георги (на Ани) е невидим за нея', 0,
  (select count(*) from public.profiles where id='00000000-0000-0000-0000-0000000000b3'));
select test_eq('Сам (без преподавател) е невидим за нея', 0,
  (select count(*) from public.profiles where id='00000000-0000-0000-0000-0000000000b4'));
select test_eq('вижда работите само на своите ученици', 2,
  (select count(*) from public.attempts));
select test_eq('в библиотеката вижда само 6. клас — нейните ученици', 1,
  (select count(*) from public.assignments));
select test_eq('и това е точно листът за 6. клас', 1,
  (select count(*) from public.assignments where slug='t-hw6'));

do $$ declare ok boolean := false; begin
  begin insert into public.assignments (slug,title,kind,url) values ('hack','x','homework','x.html');
  exception when insufficient_privilege then ok := true; end;
  if not ok then raise exception 'ПАДНА  Петя успя да СЪЗДАДЕ задание'; end if;
  raise notice 'ok    не може да създава задания';
end $$;

do $$ declare ok boolean := false; begin
  begin update public.assignments set title='х' where slug='t-hw6';
        if not found then ok := true; end if;
  exception when insufficient_privilege then ok := true; end;
  if not ok then raise exception 'ПАДНА  Петя успя да РЕДАКТИРА задание'; end if;
  raise notice 'ok    не може да редактира задания';
end $$;

do $$ declare ok boolean := false; begin
  begin insert into public.assignment_releases (assignment_id, teacher_id)
        values ('00000000-0000-0000-0000-0000000000c1','00000000-0000-0000-0000-0000000000a1');
  exception when insufficient_privilege then ok := true; end;
  if not ok then raise exception 'ПАДНА  Петя написа публикация от името на Ани'; end if;
  raise notice 'ok    не може да публикува от чуждо име';
end $$;

do $$ declare ok boolean := false; begin
  begin insert into public.assignment_releases (assignment_id, teacher_id)
        values ('00000000-0000-0000-0000-0000000000c2','00000000-0000-0000-0000-0000000000a2');
  exception when insufficient_privilege then ok := true; end;
  if not ok then raise exception 'ПАДНА  Петя публикува лист за 7. клас, а няма седмокласници'; end if;
  raise notice 'ok    не може да публикува лист, който не пасва на нейни ученици';
end $$;

do $$ declare n int; begin
  update public.attempts set teacher_note='х'
   where user_id='00000000-0000-0000-0000-0000000000b3';
  get diagnostics n = row_count;
  if n > 0 then raise exception 'ПАДНА  Петя оцени работа на ученик на Ани'; end if;
  raise notice 'ok    не може да оценява чужди ученици';
end $$;

do $$ declare n int; begin
  update public.attempts set teacher_note='Браво'
   where user_id='00000000-0000-0000-0000-0000000000b1';
  get diagnostics n = row_count;
  if n <> 1 then raise exception 'ПАДНА  Петя не можа да оцени СВОЙ ученик (% реда)', n; end if;
  raise notice 'ok    може да оценява своите ученици';
end $$;

\echo ''
\echo '───────────────  ИВАН (ученик на Петя)  ───────────────'
set tla.uid = '00000000-0000-0000-0000-0000000000b1';
select test_eq('преди Петя да му го даде — не вижда нищо', 0,
  (select count(*) from public.assignments));

reset role; set role authenticated;
set tla.uid = '00000000-0000-0000-0000-0000000000a2';
insert into public.assignment_releases (assignment_id, teacher_id)
values ('00000000-0000-0000-0000-0000000000c1','00000000-0000-0000-0000-0000000000a2');

set tla.uid = '00000000-0000-0000-0000-0000000000b1';
select test_eq('след като Петя го даде — вижда точно него', 1,
  (select count(*) from public.assignments where slug='t-hw6'));
select test_eq('не вижда листа за 7. клас', 0,
  (select count(*) from public.assignments where slug='t-hw7'));
select test_eq('не вижда черновата', 0,
  (select count(*) from public.assignments where slug='t-draft'));
select test_eq('не вижда чужди работи', 1, (select count(*) from public.attempts));

set tla.uid = '00000000-0000-0000-0000-0000000000a2';
update public.assignment_releases set hidden = true
 where assignment_id='00000000-0000-0000-0000-0000000000c1' and teacher_id='00000000-0000-0000-0000-0000000000a2';
set tla.uid = '00000000-0000-0000-0000-0000000000b1';
select test_eq('след като Петя го скрие — пак не вижда нищо', 0,
  (select count(*) from public.assignments));

\echo ''
\echo '───────────────  ГЕОРГИ (ученик на Ани) и САМ (без преподавател)  ───────────────'
set tla.uid = '00000000-0000-0000-0000-0000000000a1';
insert into public.assignment_releases (assignment_id, teacher_id)
values ('00000000-0000-0000-0000-0000000000c2','00000000-0000-0000-0000-0000000000a1');

set tla.uid = '00000000-0000-0000-0000-0000000000b3';
select test_eq('Георги вижда това, което Ани му е дала', 1,
  (select count(*) from public.assignments where slug='t-hw7'));
select test_eq('Георги не вижда листа, даден от Петя на нейните', 0,
  (select count(*) from public.assignments where slug='t-hw6'));

set tla.uid = '00000000-0000-0000-0000-0000000000b4';
select test_eq('Сам, без преподавател, не вижда НИЩО', 0,
  (select count(*) from public.assignments));
do $$ declare ok boolean := false; begin
  begin insert into public.attempts (user_id, assignment_id, auto_score, auto_max)
        values ('00000000-0000-0000-0000-0000000000b4','00000000-0000-0000-0000-0000000000c1',10,10);
  exception when insufficient_privilege then ok := true; end;
  if not ok then raise exception 'ПАДНА  Сам предаде работа по лист, който не му е даван'; end if;
  raise notice 'ok    Сам не може да предаде работа по недаден лист';
end $$;

\echo ''
\echo '───────────────  АНИ (админ)  ───────────────'
set tla.uid = '00000000-0000-0000-0000-0000000000a1';
select test_eq('вижда всички профили', :n_profile, (select count(*) from public.profiles));
select test_eq('вижда всички задания, включително черновата', :n_assign,
  (select count(*) from public.assignments));
select test_eq('вижда и трите тестови листа', 3,
  (select count(*) from public.assignments where slug like 't-%'));
select test_eq('вижда всички работи', :n_attempt, (select count(*) from public.attempts));
select test_eq('вижда всички връзки преподавател–ученик', 3, (select count(*) from public.teaching));
do $$ declare ok boolean := true; begin
  insert into public.assignments (slug,title,kind,url,published) values ('нов','Нов','homework','n.html',false);
  delete from public.assignments where slug='нов';
  raise notice 'ok    може да създава и трие задания';
end $$;

reset role;
\echo ''
\echo '═══  ВСИЧКИ ПРОВЕРКИ МИНАХА  ═══'
