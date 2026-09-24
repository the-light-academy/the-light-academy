-- =====================================================================
--  Проверка на записването на часове
--  ---------------------------------------------------------------------
--  НЕ ПУСКАЙ ТОВА ВЪРХУ ЖИВАТА БАЗА. Създава измислени профили и трие
--  редове. Пазачът отдолу отказва да тръгне, ако види истински данни.
-- =====================================================================
\set ON_ERROR_STOP on

do $$ begin
  if (select count(*) from public.profiles) > 20 then
    raise exception 'Това прилича на истинска база — тестът отказва да тръгне.';
  end if;
end $$;

create or replace function pg_temp.chk(name text, got anyelement, want anyelement)
returns void language plpgsql as $$ begin
  if got is not distinct from want then raise notice '  OK   % (% = %)', name, got, want;
  else raise exception '  ПАДА % : % вместо %', name, got, want; end if;
end $$;

-- ---- почва ----------------------------------------------------------
delete from public.lessons;
delete from public.availability_blocks;
delete from public.teacher_availability;

-- Петя е свободна всеки вторник 17:00–20:00 по математика.
insert into public.teacher_availability (teacher_id, subject_id, weekday, starts_at, ends_at, valid_from)
select '22222222-2222-2222-2222-222222222222',
       (select id from public.subjects where slug = 'matematika'),
       2, '17:00', '20:00', date '2026-01-01';

-- ---- 1. ЛЯТНОТО ВРЕМЕ ------------------------------------------------
-- Часовникът се мести на 25 октомври 2026. „Вторник 18:00“ трябва да си е
-- 18:00 местно и от двете страни — 20 и 27 октомври.
select pg_temp.chk('20 окт. дава 18:00 местно',
  (select to_char(f.starts_at at time zone 'Europe/Sofia', 'YYYY-MM-DD HH24:MI')
     from public.free_slots((select id from public.subjects where slug='matematika'),
                            date '2026-10-20', date '2026-10-20') f
    where to_char(f.starts_at at time zone 'Europe/Sofia','HH24:MI') = '18:00'),
  '2026-10-20 18:00');

select pg_temp.chk('27 окт. също дава 18:00 местно (след разместването)',
  (select to_char(f.starts_at at time zone 'Europe/Sofia', 'YYYY-MM-DD HH24:MI')
     from public.free_slots((select id from public.subjects where slug='matematika'),
                            date '2026-10-27', date '2026-10-27') f
    where to_char(f.starts_at at time zone 'Europe/Sofia','HH24:MI') = '18:00'),
  '2026-10-27 18:00');

-- и че UTC отместването наистина е различно — иначе тестът горе би минал
-- дори ако часовата зона се игнорира
select pg_temp.chk('и отместването спрямо UTC наистина се сменя',
  (select count(distinct to_char(f.starts_at at time zone 'UTC','HH24:MI'))::int
     from public.free_slots((select id from public.subjects where slug='matematika'),
                            date '2026-10-20', date '2026-10-27') f
    where to_char(f.starts_at at time zone 'Europe/Sofia','HH24:MI') = '18:00'), 2);

-- ---- 2. какво free_slots НЕ показва ----------------------------------
select pg_temp.chk('прозорец 17–20 дава 3 часа на ден',
  (select count(*)::int from public.free_slots(
     (select id from public.subjects where slug='matematika'),
     date '2026-10-20', date '2026-10-20')), 3);

select pg_temp.chk('друг предмет не показва нищо',
  (select count(*)::int from public.free_slots(
     (select id from public.subjects where slug='sastezatelna-matematika'),
     date '2026-10-20', date '2026-10-20')), 0);

select pg_temp.chk('сряда няма прозорец',
  (select count(*)::int from public.free_slots(
     (select id from public.subjects where slug='matematika'),
     date '2026-10-21', date '2026-10-21')), 0);

-- зает час изчезва от свободните — и ЗАПАЗЕНИЯТ брои за зает
insert into public.lessons (teacher_id, subject_id, starts_at, ends_at, status,
                            parent_name, parent_phone, child_name)
values ('22222222-2222-2222-2222-222222222222',
        (select id from public.subjects where slug='matematika'),
        (timestamp '2026-10-20 18:00') at time zone 'Europe/Sofia',
        (timestamp '2026-10-20 19:00') at time zone 'Europe/Sofia',
        'held', 'Родител', '0888000001', 'Дете');

select pg_temp.chk('запазеният час изчезва от свободните',
  (select count(*)::int from public.free_slots(
     (select id from public.subjects where slug='matematika'),
     date '2026-10-20', date '2026-10-20')), 2);

-- блокиран ден
insert into public.availability_blocks (teacher_id, starts_at, ends_at, note)
values ('22222222-2222-2222-2222-222222222222',
        (timestamp '2026-10-27 00:00') at time zone 'Europe/Sofia',
        (timestamp '2026-10-28 00:00') at time zone 'Europe/Sofia', 'отпуска');

select pg_temp.chk('блокиран ден не дава нищо',
  (select count(*)::int from public.free_slots(
     (select id from public.subjects where slug='matematika'),
     date '2026-10-27', date '2026-10-27')), 0);

-- ---- 3. ограничението отказва застъпване -----------------------------
do $$
declare ok boolean := false;
begin
  begin
    insert into public.lessons (teacher_id, subject_id, starts_at, ends_at, status,
                                parent_name, parent_phone, child_name)
    values ('22222222-2222-2222-2222-222222222222',
            (select id from public.subjects where slug='matematika'),
            (timestamp '2026-10-20 18:30') at time zone 'Europe/Sofia',
            (timestamp '2026-10-20 19:30') at time zone 'Europe/Sofia',
            'confirmed', 'Друг', '0888000002', 'Друго дете');
  exception when exclusion_violation then ok := true;
  end;
  if ok then raise notice '  OK   застъпващ се час се отказва от базата';
  else raise exception '  ПАДА базата пусна застъпващ се час'; end if;
end $$;

-- отказаният час обаче освобождава мястото
update public.lessons set status = 'declined'
 where starts_at = (timestamp '2026-10-20 18:00') at time zone 'Europe/Sofia';
select pg_temp.chk('отказан час връща мястото',
  (select count(*)::int from public.free_slots(
     (select id from public.subjects where slug='matematika'),
     date '2026-10-20', date '2026-10-20')), 3);
delete from public.lessons;

\echo '=== ЧАСОВАТА ЗОНА И ОГРАНИЧЕНИЕТО МИНАХА ==='


-- =====================================================================
--  Част 2 — права и ограничения
-- =====================================================================
delete from public.lessons;

-- ---- 4. срещу заливане ----------------------------------------------
-- Страницата е публична: без таван един посетител може да запълни всичко.
do $$
declare v_slot timestamptz; v_subj uuid; v_n int := 0; v_stopped boolean := false;
begin
  v_subj := (select id from public.subjects where slug='matematika');
  for v_slot in
    select f.starts_at from public.free_slots(v_subj, current_date, current_date + 30) f
     order by f.starts_at limit 5
  loop
    begin
      perform public.request_lesson(
        '22222222-2222-2222-2222-222222222222', v_subj, v_slot,
        'Същият родител', '0899123456', 'a@abv.bg', 'Дете', 4, null);
      v_n := v_n + 1;
    exception when others then
      if sqlerrm like '%заявки за днес%' then v_stopped := true; exit;
      else raise; end if;
    end;
  end loop;
  if v_stopped and v_n = 3 then
    raise notice '  OK   спира на 4-тата заявка от същия телефон (минаха %)', v_n;
  else
    raise exception '  ПАДА минаха % заявки, спряно=%', v_n, v_stopped;
  end if;
end $$;

-- ---- 5. измислен час не минава --------------------------------------
do $$
declare ok boolean := false;
begin
  begin
    perform public.request_lesson(
      '22222222-2222-2222-2222-222222222222',
      (select id from public.subjects where slug='matematika'),
      (timestamp '2026-10-06 03:00') at time zone 'Europe/Sofia',   -- 3 ч. през нощта
      'Хитрец', '0777777777', null, 'Дете', 4, null);
  exception when others then ok := (sqlerrm like '%не е свободен%');
  end;
  if ok then raise notice '  OK   час извън прозорец се отказва';
  else raise exception '  ПАДА функцията прие 3 ч. през нощта'; end if;
end $$;

-- ---- 6. непознатият посетител не чете таблиците ----------------------
do $$
declare ok_les boolean := false; ok_av boolean := false;
begin
  set local role anon;
  begin perform 1 from public.lessons limit 1;
  exception when insufficient_privilege then ok_les := true; end;
  begin perform 1 from public.teacher_availability limit 1;
  exception when insufficient_privilege then ok_av := true; end;
  reset role;
  if ok_les and ok_av then
    raise notice '  OK   anon не чете нито lessons, нито teacher_availability';
  else
    raise exception '  ПАДА anon вижда таблица: lessons=% avail=%', not ok_les, not ok_av;
  end if;
end $$;

-- ---- 7. но ВИЖДА каквото трябва, през функциите ----------------------
-- Първият опит на този тест падна с „permission denied for table subjects“
-- и това не беше грешка в теста: anon наистина не чете subjects, тоест
-- страницата нямаше да може да покаже дори от какво да се избира. Оттам
-- се роди bookable_subjects().
do $$
declare v_subj uuid; n int; m int;
begin
  set local role anon;
  select count(*) into m from public.bookable_subjects();
  select id into v_subj from public.bookable_subjects() where slug = 'matematika';
  select count(*) into n from public.free_slots(v_subj, date '2026-10-13', date '2026-10-13');
  reset role;
  if m = 1 then raise notice '  OK   anon вижда точно предметите с отворени часове (%)', m;
  else raise exception '  ПАДА bookable_subjects върна % предмета вместо 1', m; end if;
  if n = 3 then raise notice '  OK   и свободните часове през free_slots (%)', n;
  else raise exception '  ПАДА anon вижда % часа вместо 3', n; end if;
end $$;

-- ---- 8. преподавателят решава само своите ----------------------------
delete from public.lessons;
insert into public.lessons (id, teacher_id, subject_id, starts_at, ends_at, status,
                            parent_name, parent_phone, child_name)
values ('aaaaaaaa-0000-0000-0000-000000000001',
        '22222222-2222-2222-2222-222222222222',
        (select id from public.subjects where slug='matematika'),
        (timestamp '2026-10-13 18:00') at time zone 'Europe/Sofia',
        (timestamp '2026-10-13 19:00') at time zone 'Europe/Sofia',
        'held', 'Родител', '0888000009', 'Дете');

set role authenticated;
set tla.uid = '33333333-3333-3333-3333-333333333333';   -- Иван, ученик
do $$
declare ok boolean := false;
begin
  begin perform public.decide_lesson('aaaaaaaa-0000-0000-0000-000000000001','confirmed');
  exception when others then ok := (sqlerrm like '%не е ваш%'); end;
  if ok then raise notice '  OK   ученик не може да потвърди час';
  else raise exception '  ПАДА ученик потвърди час'; end if;
end $$;

set tla.uid = '22222222-2222-2222-2222-222222222222';   -- Петя, нейният час
select public.decide_lesson('aaaaaaaa-0000-0000-0000-000000000001','confirmed');
reset role;
select pg_temp.chk('Петя потвърди своя час',
  (select status from public.lessons where id='aaaaaaaa-0000-0000-0000-000000000001'),
  'confirmed');
select pg_temp.chk('и се записа кой е решил',
  (select decided_by from public.lessons where id='aaaaaaaa-0000-0000-0000-000000000001'),
  '22222222-2222-2222-2222-222222222222'::uuid);

-- ---- 9. предпазителят пуска забравените заявки -----------------------
delete from public.lessons;
insert into public.lessons (teacher_id, subject_id, starts_at, ends_at, status,
                            parent_name, parent_phone, child_name, hold_expires_at)
values ('22222222-2222-2222-2222-222222222222',
        (select id from public.subjects where slug='matematika'),
        (timestamp '2026-10-13 17:00') at time zone 'Europe/Sofia',
        (timestamp '2026-10-13 18:00') at time zone 'Europe/Sofia',
        'held', 'Забравен', '0888000010', 'Дете', now() - interval '1 day');
select pg_temp.chk('изтеклата заявка се пуска', public.release_expired_holds(), 1);
select pg_temp.chk('и часът се връща в свободните',
  (select count(*)::int from public.free_slots(
     (select id from public.subjects where slug='matematika'),
     date '2026-10-13', date '2026-10-13')), 3);

delete from public.lessons;
delete from public.availability_blocks;
delete from public.teacher_availability;
\echo '=== ВСИЧКО МИНА ==='
