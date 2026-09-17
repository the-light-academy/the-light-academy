-- =====================================================================
-- Хората и листовете, с които се пуска supabase/tests/rls-test.sql.
-- ⚠️  Само за чернова база. Създава потребители с нарочно фиксирани
--     номера (…a1, …b1 и т.н.), по които тестът познава, че базата е
--     чернова, а не истинската.
-- =====================================================================

-- People. Inserting into auth.users fires the on_auth_user_created trigger,
-- so this also exercises the profile + auto-enrolment path.
insert into auth.users (id, email, raw_user_meta_data) values
  ('00000000-0000-0000-0000-0000000000a1', 'the.light.academy56@gmail.com', '{"full_name":"Ани"}'),
  ('00000000-0000-0000-0000-0000000000a2', 'petya@example.com',             '{"full_name":"Петя"}'),
  ('00000000-0000-0000-0000-0000000000b1', 'ivan@example.com',   '{"full_name":"Иван","grade":"6"}'),
  ('00000000-0000-0000-0000-0000000000b2', 'maria@example.com',  '{"full_name":"Мария","grade":"6"}'),
  ('00000000-0000-0000-0000-0000000000b3', 'georgi@example.com', '{"full_name":"Георги","grade":"7"}'),
  ('00000000-0000-0000-0000-0000000000b4', 'sam@example.com',    '{"full_name":"Сам Безучител","grade":"6"}');

-- Ани and Петя are teachers (v3's migration will make Ани the admin)
update public.profiles set role = 'teacher'
 where id in ('00000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-0000000000a2');

-- Two sheets: one already live, one still a draft
insert into public.assignments (id, slug, title, kind, url, max_points, published, week, subject_id, grades)
values
  ('00000000-0000-0000-0000-0000000000c1','t-hw6','Домашно 6. клас','homework','hw6.html',10,true,4,
   (select id from public.subjects where slug='matematika'), '{6}'),
  ('00000000-0000-0000-0000-0000000000c2','t-hw7','Домашно 7. клас','homework','hw7.html',10,true,4,
   (select id from public.subjects where slug='matematika'), '{7}'),
  ('00000000-0000-0000-0000-0000000000c3','t-draft','Чернова','homework','draft.html',10,false,5,
   (select id from public.subjects where slug='matematika'), '{6}');

-- One attempt per student on the 6th-grade sheet
insert into public.attempts (id, user_id, assignment_id, auto_score, auto_max)
values
  ('00000000-0000-0000-0000-0000000000d1','00000000-0000-0000-0000-0000000000b1','00000000-0000-0000-0000-0000000000c1',8,10),
  ('00000000-0000-0000-0000-0000000000d2','00000000-0000-0000-0000-0000000000b2','00000000-0000-0000-0000-0000000000c1',9,10);
