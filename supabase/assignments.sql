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

-- 7. клас, седмица 5 — многочлен: нормален вид, степен, събиране и изваждане.
-- Десет задачи с избор, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w05',
   'Домашно 5 — Многочлен. Събиране и изваждане',
   'homework',
   'homework_7_w05.html',
   10,
   false,
   140,
   5,
   (select id from public.subjects where slug = 'matematika'),
   '{7}')
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


-- 7. клас, седмица 4 — едночлен, нормален вид и действия с едночлени.
-- Десет задачи с избор, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w04',
   'Домашно 4 — Едночлен. Действия с едночлени',
   'homework',
   'homework_7_w04.html',
   10,
   false,
   130,
   4,
   (select id from public.subjects where slug = 'matematika'),
   '{7}')
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


-- 5. клас, седмица 1 — начален преговор: естествени числа.
-- Десет задачи с избор, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w01',
   'Домашно — Начален преговор: естествени числа',
   'homework',
   'homework_5_w01.html',
   10,
   false,
   380,
   1,
   (select id from public.subjects where slug = 'matematika'),
   '{5}')
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


-- 6. клас, седмица 1 — начален преговор: обикновени и десетични дроби.
-- 45 отговора в две части (23 + 22), всеки по една точка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w01',
   'Домашно — Обикновени и десетични дроби',
   'homework',
   'homework_6_w01.html',
   45,
   false,
   390,
   1,
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


-- 6. клас, седмица 2 — намиране на част от число и процент.
-- Четирите задачи на Мишо, осем отговора, по една точка всеки.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w02',
   'Домашно — Част от число и процент',
   'homework',
   'homework_6_w02.html',
   8,
   false,
   392,
   2,
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

-- ── 6. клас, седмица 3 (5–9 окт. 2026): входно ниво ──
-- Тринайсет задачи по материала на 5. клас, 25 точки, 35 минути.
-- Оценява се изцяло от страницата и се записва като опит в профила.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('entrance_test_6',
   'Входно ниво — 6. клас',
   'exam',
   'entrance_test_6.html',
   25,
   false,
   40,
   3,
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

-- ── 6. клас, седмица 4 (12–16 окт. 2026): степенуване ──
-- Понятие за степен с естествен показател и умножение на степени с равни
-- основи. Десет задачи с избор, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w04',
   'Домашно — Степен с естествен показател',
   'homework',
   'homework_6_w04.html',
   10,
   false,
   393,
   4,
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

-- ── 6. клас, седмица 5 (19–23 окт. 2026): степенуване, втора част ──
-- Деление на степени с равни основи и степенуване на произведение,
-- частно и степен. Десет задачи с избор, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w05',
   'Домашно — Деление и степенуване на степени',
   'homework',
   'homework_6_w05.html',
   10,
   false,
   394,
   5,
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
--   select slug, title, grades, week, max_points, published
--     from public.assignments
--    where grades is not null order by grades, week;
