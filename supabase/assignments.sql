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

-- ── 6. клас, седмица 2 (28 септ. – 2 окт. 2026): геометрия ──
-- Седмица 2 преговаря две неща: част от число и процент (това е hw6-w02)
-- и геометричните фигури от 5. клас — това е листът тук. Двата стоят на
-- една и съща седмица нарочно.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w02-geo',
   'Домашно — Геометрични фигури от 5. клас',
   'homework',
   'homework_6_w02_geo.html',
   10,
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

-- Провери какво се получи:
--   select slug, title, grades, week, max_points, published
--     from public.assignments
--    where grades is not null order by grades, week;

-- ── 6. клас, седмица 3 (5–9 окт. 2026): състезание „Входно ниво“ ──
-- Шестнайсет задачи от целия материал на 5. клас, 32 точки, 60 минути.
-- Стои в същата седмица като входното ниво и не го замества: входното
-- показва откъде тръгва детето, състезанието — докъде стига. Затова и
-- sort_order е 41, точно след него.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('contest_6_entry',
   'Състезание „Входно ниво“ — 6. клас',
   'exam',
   'contest_6_entry.html',
   32,
   false,
   41,
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

-- ── 5. клас, седмица 3 (5–9 окт. 2026): определяне на нивото ──
-- Двайсет и шест задачи по целия материал на 4. клас, по осем теми, по
-- 1 точка всяка. БЕЗ часовник: това е разговор с дете, което виждаме за
-- пръв път, а броенето назад мери стрес, не знания. Накрая дава карта по
-- теми с проценти, която се праща на родителя.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('level_check_5',
   'Определяне на нивото — пълно входно ниво',
   'exam',
   'level_check_5.html',
   26,
   false,
   30,
   3,
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


-- 5. клас, седмица 2 — геометрични фигури от началното училище и мерни единици.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w02',
   'Домашно — Геометрични фигури и мерни единици',
   'homework',
   'homework_5_w02.html',
   10,
   false,
   381,
   2,
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


-- 5. клас, седмица 4 — делимост, прости и съставни числа.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w04',
   'Домашно — Делимост. Прости и съставни числа',
   'homework',
   'homework_5_w04.html',
   10,
   false,
   382,
   4,
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


-- 5. клас, седмица 5 — признаци за делимост на 2, на 5 и на 10.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w05',
   'Домашно — Признаци за делимост на 2, 5 и 10',
   'homework',
   'homework_5_w05.html',
   10,
   false,
   383,
   5,
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


-- 5. клас, седмица 6 — признаци за делимост на 3 и на 9.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w06',
   'Домашно — Признаци за делимост на 3 и 9',
   'homework',
   'homework_5_w06.html',
   10,
   false,
   384,
   6,
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


-- 5. клас, седмица 7 — разлагане на съставни числа на прости множители.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w07',
   'Домашно — Разлагане на прости множители',
   'homework',
   'homework_5_w07.html',
   10,
   false,
   385,
   7,
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


-- 5. клас, седмица 8 — общи делители и най-голям общ делител.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w08',
   'Домашно — Най-голям общ делител (НОД)',
   'homework',
   'homework_5_w08.html',
   10,
   false,
   386,
   8,
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


-- 5. клас, седмица 9 — общи кратни и най-малко общо кратно.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w09',
   'Домашно — Най-малко общо кратно (НОК)',
   'homework',
   'homework_5_w09.html',
   10,
   false,
   387,
   9,
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


-- 5. клас, седмица 10 — понятие за обикновена дроб, правилни и неправилни дроби, смесени числа.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w10',
   'Домашно — Обикновени дроби. Смесени числа',
   'homework',
   'homework_5_w10.html',
   10,
   false,
   388,
   10,
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


-- 5. клас, седмица 11 — основно свойство на дробите, разширяване и съкращаване.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w11',
   'Домашно — Основно свойство. Разширяване и съкращаване',
   'homework',
   'homework_5_w11.html',
   10,
   false,
   389,
   11,
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


-- 5. клас, седмица 12 — привеждане към общ знаменател и сравняване.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w12',
   'Домашно — Общ знаменател. Сравняване на дроби',
   'homework',
   'homework_5_w12.html',
   10,
   false,
   390,
   12,
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
-- 5. клас, седмица 13 — събиране и изваждане на дроби с еднакви знаменатели.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w13',
   'Домашно — Събиране и изваждане при еднакви знаменатели',
   'homework',
   'homework_5_w13.html',
   10,
   false,
   391,
   13,
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


-- 5. клас, седмица 14 — събиране и изваждане на дроби с различни знаменатели.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w14',
   'Домашно — Събиране и изваждане при различни знаменатели',
   'homework',
   'homework_5_w14.html',
   10,
   false,
   392,
   14,
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
-- 5. клас, седмица 15 — умножение на обикновени дроби и намиране на част от число.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w15',
   'Домашно — Умножение на дроби. Част от число',
   'homework',
   'homework_5_w15.html',
   10,
   false,
   393,
   15,
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
-- 5. клас, седмица 16 — деление на обикновени дроби и числови изрази.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w16',
   'Домашно — Деление на дроби. Числови изрази',
   'homework',
   'homework_5_w16.html',
   10,
   false,
   394,
   16,
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
-- 5. клас, седмица 17 — текстови задачи с обикновени дроби.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w17',
   'Домашно — Текстови задачи с обикновени дроби',
   'homework',
   'homework_5_w17.html',
   10,
   false,
   395,
   17,
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


-- 5. клас, седмица 18 — обобщение на първия срок и подготовка за класна работа №1.
-- Петнайсет задачи през целия срок, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w18',
   'Домашно — Обобщение на първия срок',
   'homework',
   'homework_5_w18.html',
   15,
   false,
   396,
   18,
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


-- 5. клас, седмица 19 — понятие за десетична дроб, четене, писане и сравняване.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w19',
   'Домашно — Десетични дроби: четене, писане, сравняване',
   'homework',
   'homework_5_w19.html',
   10,
   false,
   397,
   19,
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


-- 5. клас, седмица 20 — събиране и изваждане на десетични дроби, закръгляне.
-- Четири задачи с избор и шест писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w20',
   'Домашно — Събиране и изваждане на десетични дроби. Закръгляне',
   'homework',
   'homework_5_w20.html',
   10,
   false,
   398,
   20,
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


-- 5. клас, седмица 21 — умножение на десетични дроби и умножение с 10, 100 и 1000.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w21',
   'Домашно — Умножение на десетични дроби',
   'homework',
   'homework_5_w21.html',
   10,
   false,
   399,
   21,
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
