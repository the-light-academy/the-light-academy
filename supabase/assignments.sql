-- =====================================================================
-- The Light Academy — редовете на заданията
-- ---------------------------------------------------------------------
-- Всяко ново домашно или изпит има две части: страницата в хранилището
-- и един ред тук, който казва на платформата, че я има, за кой клас е и
-- за коя седмица.
--
-- Пуска се в Supabase: SQL Editor -> New query -> Run.
-- Може да се пуска колкото пъти искаш: редът се обновява, но
-- `published` НЕ се пипа — това остава твое решение от таблото.
--
-- Изисква supabase/schema-v2.sql да е минал (заради subjects и grades).
-- =====================================================================

-- 6. клас, седмица 32 — преговор на геометричните тела.
-- Басейнът на Мишо: лице на основата, обем на права призма, 3/4 от обем
-- и превръщане на m³ в литри. Четири задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w32',
   'Домашно — Геометрични тела: басейнът на Мишо',
   'homework',
   'homework_6_w32.html',
   4,
   false,
   400,
   32,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- Провери какво се получи:
--   select slug, title, grades, week, published
--     from public.assignments where slug = 'hw6-w32';
