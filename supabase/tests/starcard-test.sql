-- =====================================================================
--  star_cards — космическият паспорт на ученика („Моят космически
--  паспорт“ на екрана; таблицата си остава star_cards)
--  ---------------------------------------------------------------------
--  НЕ ПУСКАЙ ТОВА ВЪРХУ ЖИВАТА БАЗА. Файлът пише и трие карти. Всичко е
--  в транзакция, която завършва с rollback, но пазачът отдолу така или
--  иначе отказва да тръгне, ако види истински данни.
--
--  Доказва двете неща, на които разделът „Профил“ стъпва:
--
--  1. Паспортът е ЧАСТЕН. Нито съученик, нито преподавател, нито
--     администраторът стига до нея — и не защото страницата не я
--     показва, а защото базата не я отдава.
--  2. В нея не може да влезе каквото и да е. Формата се пази от базата,
--     не само от браузъра: дете с отворена конзола не може да напише в
--     собствения си ред нито дълъг текст, нито чужд вид стойност.
--
--  Как се пуска локално:
--     psql -d tla -f supabase/schema-v7.sql
--     psql -d tla -f supabase/tests/starcard-test.sql
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

-- Очаква се да ПАДНЕ, и то с определен код. Третият довод казва с кой:
-- 42501 значи „правата го спряха“, 23514 — „ограничението го спря“.
--
-- Проверката НЕ приема как да е падане. Ако заявката се счупи заради
-- сбъркан оператор, колона или тип, това е мой пропуск в теста, не
-- защита на базата — и тогава тук пада самият тест. Първата му версия
-- мина точно така: идентификаторът влизаше в SQL-а без кавички, трите
-- твърдения за чужда карта се чупеха още при разбора и се отчитаха като
-- „спряно“, без изобщо да са стигнали до политиките.
create or replace function pg_temp.must_fail(name text, sql text, want text)
returns void language plpgsql as $$
declare code text; msg text;
begin
  begin
    execute sql;
  exception when others then
    code := sqlstate; msg := sqlerrm;
    if code in ('42601','42703','42804','42883','42P01','22P02') then
      raise exception '   ✗ % · тестът е сбъркан, не базата: % (%)', name, msg, code;
    end if;
    if code <> want then
      raise exception '   ✗ % · спря с %, а трябваше с %: %', name, code, want, msg;
    end if;
    raise notice '   ✓ % · % (%)', name, left(msg, 64), code;
    return;
  end;
  raise exception '   ✗ % · МИНА, а не трябваше', name;
end $$;

begin;

-- Иван и Мария са ученици, Петя е преподавател, Ани е администратор.
-- Същите, с които работят и другите тестове.
-- Идентификаторите се пишат изцяло, навсякъде. По-рано тук стояха
-- psql-променливи и при слепване в текста на заявката кавичките им се
-- изяждаха: „values (' || '44444444-4444-4444-4444-444444444444' || ', 'rocket')“ ставаше
-- „values (44444444-4444-…, 'rocket')“ — изваждане на числа. Заявката
-- падаше при разбора и тестът го четеше като „правата го спряха“.

set role authenticated;

-- ═══════════════════════════════════════════════════════════════════
\echo ''
\echo '══ Иван си прави карта ══'
set tla.uid = '33333333-3333-3333-3333-333333333333';

insert into public.star_cards (user_id, avatar, interests, answers) values
  ('33333333-3333-3333-3333-333333333333', 'astronaut', '["football","space","reading"]'::jsonb,
   '{"football_team":"Левски","planet":"Сатурн"}'::jsonb);

select pg_temp.chk('картата се записа',
  (select count(*)::int from public.star_cards), 1);
select pg_temp.chk('аватарът е негов избор',
  (select avatar from public.star_cards), 'astronaut');
select pg_temp.chk('темите са три',
  (select jsonb_array_length(interests)::int from public.star_cards), 3);
select pg_temp.chk('отговорът към футбола е запазен',
  (select answers->>'football_team' from public.star_cards), 'Левски');
select pg_temp.chk('updated_at го пише базата, не страницата',
  (select updated_at is not null from public.star_cards), true);

-- ═══════════════════════════════════════════════════════════════════
\echo ''
\echo '══ Иван не може да пише в чужда карта ══'
-- 42501 е „new row violates row-level security policy“: with check на
-- политиката е казал не.
select pg_temp.must_fail('карта на Мария от името на Иван',
  $$insert into public.star_cards (user_id, avatar)
    values ('44444444-4444-4444-4444-444444444444', 'rocket')$$, '42501');
select pg_temp.must_fail('своята карта, преписана на чуждо име',
  $$update public.star_cards
       set user_id = '44444444-4444-4444-4444-444444444444'$$, '42501');

-- ═══════════════════════════════════════════════════════════════════
\echo ''
\echo '══ формата се пази от базата, не от браузъра ══'
select pg_temp.must_fail('аватар с главни букви',
  'update public.star_cards set avatar = ''Astronaut''', '23514');
select pg_temp.must_fail('аватар на кирилица',
  'update public.star_cards set avatar = ''астронавт''', '23514');
select pg_temp.must_fail('аватар, по-дълъг от позволеното',
  'update public.star_cards set avatar = ''' || repeat('a', 40) || '''', '23514');
select pg_temp.must_fail('теми, които не са масив',
  'update public.star_cards set interests = ''"football"''::jsonb', '23514');
select pg_temp.must_fail('тема, която е число',
  'update public.star_cards set interests = ''[1,2,3]''::jsonb', '23514');
select pg_temp.must_fail('тема със забранени знаци',
  'update public.star_cards set interests = ''["<script>"]''::jsonb', '23514');
select pg_temp.must_fail('повече от 60 теми',
  'update public.star_cards set interests = (select jsonb_agg(''t'' || i) from generate_series(1,61) i)', '23514');
select pg_temp.must_fail('отговори, които не са обект',
  'update public.star_cards set answers = ''[]''::jsonb', '23514');
select pg_temp.must_fail('отговор, по-дълъг от 80 знака',
  'update public.star_cards set answers = jsonb_build_object(''book'', ''' || repeat('я', 81) || ''')', '23514');
select pg_temp.must_fail('ключ на отговор със забранени знаци',
  'update public.star_cards set answers = ''{"book;drop":"x"}''::jsonb', '23514');
select pg_temp.must_fail('отговор, който не е текст',
  'update public.star_cards set answers = ''{"book":42}''::jsonb', '23514');

-- Това пък ТРЯБВА да минава: 80 знака са позволени, а кирилицата в
-- стойността е цялата идея.
update public.star_cards set answers = jsonb_build_object('book', repeat('я', 80));
select pg_temp.chk('точно 80 знака минават',
  (select length(answers->>'book')::int from public.star_cards), 80);

-- ═══════════════════════════════════════════════════════════════════
\echo ''
\echo '══ Мария не вижда картата на Иван ══'
set tla.uid = '44444444-4444-4444-4444-444444444444';
select pg_temp.chk('чуждата карта изобщо не съществува за нея',
  (select count(*)::int from public.star_cards), 0);

insert into public.star_cards (user_id, avatar, interests) values
  ('44444444-4444-4444-4444-444444444444', 'planet', '["drawing","animals"]'::jsonb);
select pg_temp.chk('своята си прави спокойно',
  (select avatar from public.star_cards), 'planet');
select pg_temp.chk('и вижда само нея',
  (select count(*)::int from public.star_cards), 1);

-- ═══════════════════════════════════════════════════════════════════
\echo ''
\echo '══ преподавателят и администраторът — също не ══'
set tla.uid = '22222222-2222-2222-2222-222222222222';
select pg_temp.chk('Петя не вижда нито една карта на учениците си',
  (select count(*)::int from public.star_cards), 0);
-- Тук нарочно НЕ се чака грешка. Update, който не вижда нито един ред,
-- не пада — просто не променя нищо. Затова се проверява точно това:
-- колко реда е засегнал и дали картата на Иван е същата след него.
do $$
declare n int;
begin
  update public.star_cards set avatar = 'rocket'
   where user_id = '33333333-3333-3333-3333-333333333333';
  get diagnostics n = row_count;
  perform pg_temp.chk('опитът ѝ не докосва нито един ред', n, 0);
end $$;

set tla.uid = '11111111-1111-1111-1111-111111111111';
select pg_temp.chk('и администраторът не вижда',
  (select count(*)::int from public.star_cards), 0);

-- И доказателството, че картата на Иван наистина е непокътната — четено
-- като суперпотребител, защото инак няма кой да го види.
reset role;
select pg_temp.chk('аватарът на Иван е този, който той е избрал',
  (select avatar from public.star_cards
    where user_id = '33333333-3333-3333-3333-333333333333'), 'astronaut');
set role authenticated;

-- ═══════════════════════════════════════════════════════════════════
\echo ''
\echo '══ невлязъл ══'
set tla.uid = '';
select pg_temp.chk('без сесия няма нито един ред',
  (select count(*)::int from public.star_cards), 0);
reset role;
set role anon;
select pg_temp.chk('и публикуемият ключ не стига до таблицата',
  has_table_privilege('anon', 'public.star_cards', 'select'), false);

-- ═══════════════════════════════════════════════════════════════════
\echo ''
\echo '══ Иван си сменя избора и после си трие картата ══'
reset role;
set role authenticated;
set tla.uid = '33333333-3333-3333-3333-333333333333';
update public.star_cards set avatar = 'comet', interests = '["chess"]'::jsonb;
select pg_temp.chk('новият аватар е на мястото си',
  (select avatar from public.star_cards), 'comet');
delete from public.star_cards;
select pg_temp.chk('картата си отиде',
  (select count(*)::int from public.star_cards), 0);

-- ═══════════════════════════════════════════════════════════════════
\echo ''
\echo '══ напуснал ученик ══'
reset role;
insert into public.star_cards (user_id, avatar) values ('33333333-3333-3333-3333-333333333333', 'moon');
delete from public.profiles where id = '33333333-3333-3333-3333-333333333333';
select pg_temp.chk('картата изчезва с профила (on delete cascade)',
  (select count(*)::int from public.star_cards where user_id = '33333333-3333-3333-3333-333333333333'), 0);

rollback;

\echo ''
\echo '═══ ВСИЧКО МИНА ═══'
