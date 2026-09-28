-- =====================================================================
--  my_race() — какво вижда ученикът и какво НЕ вижда
--  ---------------------------------------------------------------------
--  НЕ ПУСКАЙ ТОВА ВЪРХУ ЖИВАТА БАЗА. Създава измислени профили. Всичко
--  е в транзакция, която завършва с rollback, но пазачът отдолу така
--  или иначе отказва да тръгне, ако види истински данни.
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

-- ── 6. клас, математика, при Петя — четирима. Плюс капани: седмокласник
--    при същия преподавател, шестокласник при ДРУГ преподавател,
--    непубликувано задание, задание по друг предмет и незавършена работа.
insert into auth.users (id) values
  ('aaaa0001-0000-0000-0000-000000000001'),
  ('aaaa0002-0000-0000-0000-000000000002'),
  ('aaaa0003-0000-0000-0000-000000000003'),
  ('aaaa0004-0000-0000-0000-000000000004'),
  ('aaaa0005-0000-0000-0000-000000000005'),
  ('aaaa0006-0000-0000-0000-000000000006');

update public.profiles set full_name='Ани',  role='teacher' where id='11111111-1111-1111-1111-111111111111';
update public.profiles set full_name='Петя', role='teacher' where id='22222222-2222-2222-2222-222222222222';

-- Профилите ги прави тригерът върху auth.users; тук само се доизпълват.
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
-- същият клас, същият предмет, НО друг преподавател
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
  raise notice '══ Боряна гледа своето класиране ══';
  set local "tla.uid" = 'aaaa0001-0000-0000-0000-000000000001';
  perform pg_temp.chk('в групата сме четирима',
    (select count(*)::int from public.my_race()), 4);
  perform pg_temp.chk('седмокласникът не е вътре',
    (select count(*)::int from public.my_race() where student_name = 'Седмокласник'), 0);
  perform pg_temp.chk('нито ученикът на друг преподавател',
    (select count(*)::int from public.my_race() where student_name = 'Чужд Шестокласник'), 0);
  perform pg_temp.chk('моите точки: 8 + 7 + 4 от общото',
    (select points from public.my_race() where is_me), 19::numeric);
  perform pg_temp.chk('и възможните: 10 + 10 + 5',
    (select max_points from public.my_race() where is_me), 25::numeric);
  perform pg_temp.chk('чернова, чужд предмет и незавършена работа не се броят',
    (select points from public.my_race() where student_name = 'Даниел Георгиев'), 10::numeric);
  perform pg_temp.chk('който нищо не е предал, е с нула, но е в класирането',
    (select points from public.my_race() where student_name = 'Никола Тодоров'), 0::numeric);
  perform pg_temp.chk('водачът е първи по точки',
    (select student_name from public.my_race() limit 1), 'Боряна Иванова');
  perform pg_temp.chk('пише кой е преподавателят',
    (select distinct teacher_name from public.my_race()), 'Петя');
  perform pg_temp.chk('и кой е класът',
    (select distinct grade from public.my_race()), 6);
  perform pg_temp.chk('точно един ред е мой',
    (select count(*)::int from public.my_race() where is_me), 1);

  raise notice '';
  raise notice '══ Даниел вижда същото класиране ══';
  set local "tla.uid" = 'aaaa0002-0000-0000-0000-000000000002';
  perform pg_temp.chk('същите четирима',
    (select count(*)::int from public.my_race()), 4);
  perform pg_temp.chk('но „аз“ вече е той',
    (select student_name from public.my_race() where is_me), 'Даниел Георгиев');

  raise notice '';
  raise notice '══ капаните ══';
  set local "tla.uid" = 'aaaa0005-0000-0000-0000-000000000005';
  perform pg_temp.chk('седмокласникът вижда само себе си, не шестокласниците',
    (select count(*)::int from public.my_race()), 1);

  set local "tla.uid" = 'aaaa0006-0000-0000-0000-000000000006';
  perform pg_temp.chk('ученикът на Ани вижда СВОЯТА група',
    (select string_agg(student_name, ', ' order by student_name) from public.my_race()),
    'Иван, Чужд Шестокласник');
  perform pg_temp.chk('нито един от четиримата на Петя не се вижда',
    (select count(*)::int from public.my_race()
      where student_name in ('Боряна Иванова','Даниел Георгиев','Кристина Илиева','Никола Тодоров')), 0);

  set local "tla.uid" = '22222222-2222-2222-2222-222222222222';
  perform pg_temp.chk('преподавател не получава нищо — той си има табло',
    (select count(*)::int from public.my_race()), 0);

  set local "tla.uid" = '';
  perform pg_temp.chk('невлязъл не получава нищо',
    (select count(*)::int from public.my_race()), 0);

  raise notice '';
  raise notice '══ ученик без зададен клас ══';
  update public.profiles set grade_at_entry = null, entry_school_year = null
   where id = 'aaaa0003-0000-0000-0000-000000000003';
  set local "tla.uid" = 'aaaa0003-0000-0000-0000-000000000003';
  perform pg_temp.chk('без клас няма и състезание, вместо грешка',
    (select count(*)::int from public.my_race()), 0);
  set local "tla.uid" = 'aaaa0001-0000-0000-0000-000000000001';
  perform pg_temp.chk('а останалите просто са с един по-малко',
    (select count(*)::int from public.my_race()), 3);

  raise notice '';
  raise notice '═══ ВСИЧКО РАБОТИ ═══';
end $$;

rollback;
