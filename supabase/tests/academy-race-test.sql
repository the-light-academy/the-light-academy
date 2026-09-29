-- =====================================================================
--  academy_race() — общото класиране на академията
--  ---------------------------------------------------------------------
--  НЕ ПУСКАЙ ТОВА ВЪРХУ ЖИВАТА БАЗА. Създава измислени профили. Всичко
--  е в транзакция, която завършва с rollback, но пазачът отдолу така
--  или иначе отказва да тръгне, ако види истински данни.
--
--  Проверява точно онова, по което общото класиране се различава от
--  my_race(): че класът и преподавателят НЕ отрязват никого, че точките
--  се събират през всички предмети, и че въпреки това непубликуваното,
--  незавършеното и напусналите си остават отвън.
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

-- ── Същите деца, които и race-test.sql използва: четирима шестокласници
--    при Петя, един седмокласник и един шестокласник при ДРУГ
--    преподавател. В общото класиране всички те трябва да са заедно.
insert into auth.users (id) values
  ('aaaa0001-0000-0000-0000-000000000001'),
  ('aaaa0002-0000-0000-0000-000000000002'),
  ('aaaa0003-0000-0000-0000-000000000003'),
  ('aaaa0004-0000-0000-0000-000000000004'),
  ('aaaa0005-0000-0000-0000-000000000005'),
  ('aaaa0006-0000-0000-0000-000000000006');

update public.profiles set full_name='Ани',  role='teacher' where id='11111111-1111-1111-1111-111111111111';
update public.profiles set full_name='Петя', role='teacher' where id='22222222-2222-2222-2222-222222222222';

insert into public.profiles (id, full_name, role, active, grade_at_entry, entry_school_year) values
  ('aaaa0001-0000-0000-0000-000000000001','Боряна Иванова',  'student', true, 6, 2026),
  ('aaaa0002-0000-0000-0000-000000000002','Даниел Георгиев', 'student', true, 6, 2026),
  ('aaaa0003-0000-0000-0000-000000000003','Кристина Илиева', 'student', true, 6, 2026),
  ('aaaa0004-0000-0000-0000-000000000004','Никола Тодоров',  'student', true, 6, 2026),
  ('aaaa0005-0000-0000-0000-000000000005','Седмокласник',    'student', true, 7, 2026),
  ('aaaa0006-0000-0000-0000-000000000006','Чужд Шестокласник','student',true, 6, 2026)
on conflict (id) do update set
  full_name = excluded.full_name, role = excluded.role, active = excluded.active,
  grade_at_entry = excluded.grade_at_entry, entry_school_year = excluded.entry_school_year;

insert into public.teaching (teacher_id, student_id, subject_id, active)
select '22222222-2222-2222-2222-222222222222', id,
       '876a796e-8b3d-4f90-9476-bcb41f4f6253', true
from (values ('aaaa0001-0000-0000-0000-000000000001'::uuid),
             ('aaaa0002-0000-0000-0000-000000000002'),
             ('aaaa0003-0000-0000-0000-000000000003'),
             ('aaaa0004-0000-0000-0000-000000000004'),
             ('aaaa0005-0000-0000-0000-000000000005')) v(id);
insert into public.teaching (teacher_id, student_id, subject_id, active) values
  ('11111111-1111-1111-1111-111111111111','aaaa0006-0000-0000-0000-000000000006',
   '876a796e-8b3d-4f90-9476-bcb41f4f6253', true);

insert into public.assignments (id, slug, title, kind, url, max_points, published, subject_id, grades) values
  ('bbbb0001-0000-0000-0000-000000000001','t-a','Публикувано А','homework','a.html',10,true,
   '876a796e-8b3d-4f90-9476-bcb41f4f6253','{6}'),
  ('bbbb0002-0000-0000-0000-000000000002','t-b','Публикувано Б','homework','b.html',10,true,
   '876a796e-8b3d-4f90-9476-bcb41f4f6253','{6}'),
  ('bbbb0003-0000-0000-0000-000000000003','t-c','Чернова','homework','c.html',10,false,
   '876a796e-8b3d-4f90-9476-bcb41f4f6253','{6}'),
  ('bbbb0004-0000-0000-0000-000000000004','t-d','Общо за всички','homework','d.html',5,true,
   null,'{6}'),
  ('bbbb0005-0000-0000-0000-000000000005','t-e','По друг предмет','homework','e.html',10,true,
   'ff8a9598-7928-4815-aab4-1de61f67706e','{6}');

insert into public.attempts (user_id, assignment_id, status, auto_score, auto_max) values
  ('aaaa0001-0000-0000-0000-000000000001','bbbb0001-0000-0000-0000-000000000001','submitted',8,10),
  ('aaaa0001-0000-0000-0000-000000000001','bbbb0002-0000-0000-0000-000000000002','submitted',7,10),
  ('aaaa0001-0000-0000-0000-000000000001','bbbb0004-0000-0000-0000-000000000004','submitted',4,5),
  ('aaaa0002-0000-0000-0000-000000000002','bbbb0001-0000-0000-0000-000000000001','submitted',10,10),
  ('aaaa0002-0000-0000-0000-000000000002','bbbb0003-0000-0000-0000-000000000003','submitted',10,10),
  ('aaaa0002-0000-0000-0000-000000000002','bbbb0005-0000-0000-0000-000000000005','submitted',10,10),
  ('aaaa0002-0000-0000-0000-000000000002','bbbb0002-0000-0000-0000-000000000002','in_progress',9,10),
  ('aaaa0003-0000-0000-0000-000000000003','bbbb0001-0000-0000-0000-000000000001','submitted',6,10),
  ('aaaa0005-0000-0000-0000-000000000005','bbbb0001-0000-0000-0000-000000000001','submitted',10,10),
  ('aaaa0006-0000-0000-0000-000000000006','bbbb0001-0000-0000-0000-000000000001','submitted',10,10);

do $$
begin
  raise notice '';
  raise notice '══ Боряна гледа общото класиране ══';
  set local "tla.uid" = 'aaaa0001-0000-0000-0000-000000000001';
  -- Шестимата измислени + Иван и Мария от началните данни.
  perform pg_temp.chk('вътре са всички действащи ученици',
    (select count(*)::int from public.academy_race()), 8);
  perform pg_temp.chk('седмокласникът СЕ брои — класът вече не отрязва никого',
    (select count(*)::int from public.academy_race() where student_name = 'Седмокласник'), 1);
  perform pg_temp.chk('ученикът на друг преподавател — също',
    (select count(*)::int from public.academy_race() where student_name = 'Чужд Шестокласник'), 1);
  perform pg_temp.chk('преподавателите не се състезават',
    (select count(*)::int from public.academy_race()
      where student_name in ('Ани','Петя')), 0);

  raise notice '';
  raise notice '══ сметката ══';
  perform pg_temp.chk('моите точки: 8 + 7 + 4 от общото',
    (select points from public.academy_race() where is_me), 19::numeric);
  perform pg_temp.chk('и възможните: 10 + 10 + 5',
    (select max_points from public.academy_race() where is_me), 25::numeric);
  -- Тук е разликата с my_race(): там Даниел има 10, защото чуждият
  -- предмет не влиза в групата. В общото класиране влиза всичко.
  perform pg_temp.chk('чуждият предмет СЕ брои: 10 по математика + 10 по другия',
    (select points from public.academy_race() where student_name = 'Даниел Георгиев'), 20::numeric);
  perform pg_temp.chk('но черновата и незавършената работа — не',
    (select max_points from public.academy_race() where student_name = 'Даниел Георгиев'), 20::numeric);
  perform pg_temp.chk('който нищо не е предал, е с нула, но е в класирането',
    (select points from public.academy_race() where student_name = 'Никола Тодоров'), 0::numeric);
  perform pg_temp.chk('водачът е първи по точки',
    (select student_name from public.academy_race() limit 1), 'Даниел Георгиев');

  raise notice '';
  raise notice '══ какво се отдава и какво не ══';
  perform pg_temp.chk('класът върви до името',
    (select grade from public.academy_race() where student_name = 'Седмокласник'), 7);
  perform pg_temp.chk('точно един ред е мой',
    (select count(*)::int from public.academy_race() where is_me), 1);
  perform pg_temp.chk('за преподавателя няма „аз“ — той само гледа',
    (select count(*)::int from public.academy_race()), 8);

  raise notice '';
  raise notice '══ капаните ══';
  set local "tla.uid" = '22222222-2222-2222-2222-222222222222';
  perform pg_temp.chk('преподавателят вижда ЦЯЛАТА академия, не само своите',
    (select count(*)::int from public.academy_race()), 8);
  perform pg_temp.chk('и нито един ред не е негов',
    (select count(*)::int from public.academy_race() where is_me), 0);

  set local "tla.uid" = 'aaaa0002-0000-0000-0000-000000000002';
  perform pg_temp.chk('„аз“ се мести заедно с този, който пита',
    (select student_name from public.academy_race() where is_me), 'Даниел Георгиев');

  update public.profiles set active = false
   where id = 'aaaa0004-0000-0000-0000-000000000004';
  perform pg_temp.chk('напусналият изчезва от класирането',
    (select count(*)::int from public.academy_race()), 7);

  update public.profiles set grade_at_entry = null, entry_school_year = null
   where id = 'aaaa0003-0000-0000-0000-000000000003';
  perform pg_temp.chk('ученик без зададен клас ОСТАВА — само класът му е празен',
    (select count(*)::int from public.academy_race() where student_name = 'Кристина Илиева'), 1);
  perform pg_temp.chk('и класът му наистина е празен, а не нула',
    (select grade from public.academy_race() where student_name = 'Кристина Илиева'), null::int);

  raise notice '';
  raise notice '══ кой има право да пита ══';
  perform pg_temp.chk('влезлите — да',
    has_function_privilege('authenticated', 'public.academy_race()', 'execute'), true);
  -- Двете ключалки поотделно: правата, и самата функция. Ако някой ден
  -- някое grant се пусне наопаки, втората проверка пак държи.
  perform pg_temp.chk('случайният минувач — не (права)',
    has_function_privilege('anon', 'public.academy_race()', 'execute'), false);
  set local "tla.uid" = '';
  perform pg_temp.chk('и дори да можеше да я извика, не получава нито ред',
    (select count(*)::int from public.academy_race()), 0);
  perform pg_temp.chk('същата ключалка и на my_race()',
    has_function_privilege('anon', 'public.my_race()', 'execute'), false);

  raise notice '';
  raise notice '═══ ВСИЧКО РАБОТИ ═══';
end $$;

rollback;
