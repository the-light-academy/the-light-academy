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
-- 5. клас, седмица 22 — деление на десетична дроб на естествено число и на десетична дроб.
-- Две задачи с избор и осем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w22',
   'Домашно — Деление на десетични дроби',
   'homework',
   'homework_5_w22.html',
   10,
   false,
   400,
   22,
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
-- 5. клас, седмица 23 — превръщане между обикновени и десетични дроби и смесени изрази.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w23',
   'Домашно — Обикновени и десетични дроби заедно',
   'homework',
   'homework_5_w23.html',
   10,
   false,
   401,
   23,
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
-- 5. клас, седмица 24 — текстови задачи и практически пресмятания с десетични дроби.
-- Две задачи с избор и осем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w24',
   'Домашно — Текстови задачи с десетични дроби',
   'homework',
   'homework_5_w24.html',
   10,
   false,
   402,
   24,
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
-- 5. клас, седмица 25 — понятие за процент, превръщане на процент в дроб и обратно.
-- Четири задачи с избор и шест писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w25',
   'Домашно — Понятие за процент',
   'homework',
   'homework_5_w25.html',
   10,
   false,
   403,
   25,
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
-- 5. клас, седмица 26 — намиране на процент от число и на число по даден процент.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w26',
   'Домашно — Процент от число. Отстъпки и лихви',
   'homework',
   'homework_5_w26.html',
   10,
   false,
   404,
   26,
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
-- 5. клас, седмица 27 — основни понятия в геометрията и лице на правоъгълен триъгълник.
-- Четири задачи с избор и шест писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w27',
   'Домашно — Правоъгълен триъгълник',
   'homework',
   'homework_5_w27.html',
   10,
   false,
   405,
   27,
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
-- 5. клас, седмица 28 — лице на произволен триъгълник, височина и страна.
-- Четири задачи с избор и шест писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w28',
   'Домашно — Лице на произволен триъгълник',
   'homework',
   'homework_5_w28.html',
   10,
   false,
   406,
   28,
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
-- 5. клас, седмица 29 — успоредник и ромб: свойства, периметър и лице.
-- Четири задачи с избор и шест писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w29',
   'Домашно — Успоредник и ромб',
   'homework',
   'homework_5_w29.html',
   10,
   false,
   407,
   29,
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
-- 5. клас, седмица 30 — трапец: свойства, елементи, периметър и лице.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w30',
   'Домашно — Трапец',
   'homework',
   'homework_5_w30.html',
   10,
   false,
   408,
   30,
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
-- 5. клас, седмица 31 — правоъгълен паралелепипед и куб: елементи, развивка и повърхнина.
-- Четири задачи с избор и шест писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w31',
   'Домашно — Паралелепипед и куб. Лице на повърхнина',
   'homework',
   'homework_5_w31.html',
   10,
   false,
   409,
   31,
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
-- 5. клас, седмица 32 — обем на правоъгълен паралелепипед и куб, мерни единици за обем.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w32',
   'Домашно — Обем на паралелепипед и куб',
   'homework',
   'homework_5_w32.html',
   10,
   false,
   410,
   32,
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
-- 5. клас, седмица 33 — годишен преговор и подготовка за класна работа №2.
-- Петнайсет задачи през цялата година, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw5-w33',
   'Домашно — Годишен преговор',
   'homework',
   'homework_5_w33.html',
   15,
   false,
   411,
   33,
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
-- 5. клас, седмица 34 — изходно ниво по целия материал на годината.
-- Двайсет и две задачи по целия материал, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('exit_level_5',
   'Изходно ниво — 5. клас',
   'exam',
   'exit_level_5.html',
   22,
   false,
   31,
   34,
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


-- 6. клас, седмица 6 — пресмятане на числови изрази със степени и стандартен запис.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w06',
   'Домашно — Изрази със степени. Стандартен запис',
   'homework',
   'homework_6_w06.html',
   10,
   false,
   394,
   6,
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


-- 6. клас, седмица 7 — положителни и отрицателни числа, рационални числа и числова ос.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w07',
   'Домашно — Положителни и отрицателни числа',
   'homework',
   'homework_6_w07.html',
   10,
   false,
   395,
   7,
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


-- 6. клас, седмица 8 — абсолютна стойност (модул) и сравняване на рационални числа.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w08',
   'Домашно — Абсолютна стойност. Сравняване',
   'homework',
   'homework_6_w08.html',
   10,
   false,
   396,
   8,
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


-- 6. клас, седмица 9 — събиране на рационални числа с еднакви и с различни знаци.
-- Четири задачи с избор и шест писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w09',
   'Домашно — Събиране на рационални числа',
   'homework',
   'homework_6_w09.html',
   10,
   false,
   397,
   9,
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


-- 6. клас, седмица 10 — изваждане на рационални числа и алгебричен сбор.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w10',
   'Домашно — Изваждане на рационални числа',
   'homework',
   'homework_6_w10.html',
   10,
   false,
   398,
   10,
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


-- 6. клас, седмица 11 — умножение на рационални числа и свойства на умножението.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w11',
   'Домашно — Умножение на рационални числа',
   'homework',
   'homework_6_w11.html',
   10,
   false,
   399,
   11,
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


-- 6. клас, седмица 12 — деление на рационални числа и намиране на неизвестно число.
-- Две задачи с избор и осем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w12',
   'Домашно — Деление на рационални числа',
   'homework',
   'homework_6_w12.html',
   10,
   false,
   400,
   12,
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


-- 6. клас, седмица 13 — правоъгълна координатна система, координати на точка и разстояние.
-- Пет задачи с избор и пет писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w13',
   'Домашно — Координатна система',
   'homework',
   'homework_6_w13.html',
   10,
   false,
   401,
   13,
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


-- 6. клас, седмица 14 — понятие за уравнение и линейни уравнения от вида ax + b = 0.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w14',
   'Домашно — Линейни уравнения',
   'homework',
   'homework_6_w14.html',
   10,
   false,
   402,
   14,
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


-- 6. клас, седмица 15 — уравнения, които се свеждат до линейни.
-- Две задачи с избор и осем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w15',
   'Домашно — Уравнения със скоби',
   'homework',
   'homework_6_w15.html',
   10,
   false,
   403,
   15,
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


-- 6. клас, седмица 16 — текстови задачи, решавани с уравнения.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w16',
   'Домашно — Текстови задачи с уравнения',
   'homework',
   'homework_6_w16.html',
   10,
   false,
   404,
   16,
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


-- 6. клас, седмица 17 — обобщение на темите от първия срок.
-- Петнайсет задачи през целия срок, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w17',
   'Домашно — Обобщение на първия срок',
   'homework',
   'homework_6_w17.html',
   15,
   false,
   405,
   17,
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


-- 6. клас, седмица 18 — класна работа за първия срок.
-- Петнайсет задачи по целия срок, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('exam6_term1',
   'Класна работа №1 — 6. клас',
   'exam',
   'exam6_term1.html',
   15,
   false,
   32,
   18,
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


-- 6. клас, седмица 19 — отношение и пропорция, основно свойство на пропорциите.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w19',
   'Домашно — Отношение и пропорция',
   'homework',
   'homework_6_w19.html',
   10,
   false,
   406,
   19,
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


-- 6. клас, седмица 20 — неизвестен член на пропорция и основна задача от процент.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w20',
   'Домашно — Процент чрез пропорция',
   'homework',
   'homework_6_w20.html',
   10,
   false,
   407,
   20,
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


-- 6. клас, седмица 21 — права и обратна пропорционалност, коефициент на пропорционалност.
-- Четири задачи с избор и шест писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w21',
   'Домашно — Права и обратна пропорционалност',
   'homework',
   'homework_6_w21.html',
   10,
   false,
   408,
   21,
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


-- 6. клас, седмица 22 — графики на права пропорционалност и мащаб.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w22',
   'Домашно — Графики и мащаб',
   'homework',
   'homework_6_w22.html',
   10,
   false,
   409,
   22,
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


-- 6. клас, седмица 23 — организиране и представяне на данни в таблици.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w23',
   'Домашно — Организиране на данни',
   'homework',
   'homework_6_w23.html',
   10,
   false,
   410,
   23,
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


-- 6. клас, седмица 24 — четене на кръгови и стълбовидни диаграми, средноаритметично.
-- Четири задачи с избор и шест писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w24',
   'Домашно — Диаграми и средноаритметично',
   'homework',
   'homework_6_w24.html',
   10,
   false,
   411,
   24,
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


-- 6. клас, седмица 25 — случайно събитие и вероятност като отношение на възможности.
-- Четири задачи с избор и шест писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w25',
   'Домашно — Вероятност',
   'homework',
   'homework_6_w25.html',
   10,
   false,
   412,
   25,
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


-- 6. клас, седмица 26 — окръжност и кръг, дължина на окръжност и лице на кръг.
-- Четири задачи с избор и шест писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w26',
   'Домашно — Окръжност и кръг',
   'homework',
   'homework_6_w26.html',
   10,
   false,
   413,
   26,
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


-- 6. клас, седмица 27 — правилен многоъгълник, централен ъгъл, периметър и лице.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w27',
   'Домашно — Правилен многоъгълник',
   'homework',
   'homework_6_w27.html',
   10,
   false,
   414,
   27,
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


-- 6. клас, седмица 28 — права призма: развивка, лице на повърхнина и обем.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w28',
   'Домашно — Права призма',
   'homework',
   'homework_6_w28.html',
   10,
   false,
   415,
   28,
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


-- 6. клас, седмица 29 — правилна пирамида: елементи, лице на повърхнина и обем.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w29',
   'Домашно — Правилна пирамида',
   'homework',
   'homework_6_w29.html',
   10,
   false,
   416,
   29,
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


-- 6. клас, седмица 30 — прав кръгов цилиндър: повърхнина и обем.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w30',
   'Домашно — Цилиндър',
   'homework',
   'homework_6_w30.html',
   10,
   false,
   417,
   30,
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


-- 6. клас, седмица 31 — прав кръгов конус и кълбо: основни формули и понятия.
-- Три задачи с избор и седем писани, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w31',
   'Домашно — Конус и кълбо',
   'homework',
   'homework_6_w31.html',
   10,
   false,
   418,
   31,
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


-- 6. клас, седмица 33 — изходно ниво по целия материал на годината.
-- Двайсет и две задачи по целия материал, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('exit_level_6',
   'Изходно ниво — 6. клас',
   'exam',
   'exit_level_6.html',
   22,
   false,
   33,
   33,
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


-- 6. клас, седмица 34 — годишен преговор на най-важните теми.
-- Петнайсет задачи от всички теми, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw6-w34',
   'Домашно — Годишен преговор',
   'homework',
   'homework_6_w34.html',
   15,
   false,
   419,
   34,
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


-- ── 6. клас, седмица 3: определяне на нивото ──
-- Трийсет задачи по целия материал на 5. клас, по десет теми, по 3 задачи
-- на тема и по 1 точка всяка. БЕЗ часовник — това е първият разговор с
-- дете, което още не познаваме, а броенето назад мери стрес, не знания.
-- Накрая дава карта по теми с проценти, която се сваля като PDF на една
-- страница. Стои редом с „Входно ниво — 6. клас“ и състезателното входно
-- от същата седмица: то мери за оценка, това — за посока.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('level_check_6',
   'Определяне на нивото — пълно входно ниво',
   'exam',
   'level_check_6.html',
   30,
   false,
   39,
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


-- 7. клас, седмица 1 — начален преговор — рационални числа.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w01',
   'Домашно 1 — Начален преговор: рационални числа',
   'homework',
   'homework_7_w01.html',
   10,
   false,
   101,
   1,
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


-- 7. клас, седмица 2 — начален преговор — степени.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w02',
   'Домашно 2 — Начален преговор: степени',
   'homework',
   'homework_7_w02.html',
   10,
   false,
   102,
   2,
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


-- 7. клас, седмица 3 — начален преговор — уравнения, лица и обеми.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w03',
   'Домашно 3 — Начален преговор: уравнения, лица и обеми',
   'homework',
   'homework_7_w03.html',
   10,
   false,
   103,
   3,
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


-- 7. клас, седмица 6 — умножение на едночлен с многочлен.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w06',
   'Домашно 6 — Умножение на едночлен с многочлен',
   'homework',
   'homework_7_w06.html',
   10,
   false,
   106,
   6,
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


-- 7. клас, седмица 7 — умножение на многочлен с многочлен.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w07',
   'Домашно 7 — Умножение на многочлен с многочлен',
   'homework',
   'homework_7_w07.html',
   10,
   false,
   107,
   7,
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


-- 7. клас, седмица 8 — квадрат на сбор и на разлика.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w08',
   'Домашно 8 — Квадрат на сбор и на разлика',
   'homework',
   'homework_7_w08.html',
   10,
   false,
   108,
   8,
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


-- 7. клас, седмица 9 — разлика на квадрати.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w09',
   'Домашно 9 — Разлика на квадрати',
   'homework',
   'homework_7_w09.html',
   10,
   false,
   109,
   9,
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


-- 7. клас, седмица 10 — разлагане чрез изнасяне на общ множител.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w10',
   'Домашно 10 — Разлагане: изнасяне на общ множител',
   'homework',
   'homework_7_w10.html',
   10,
   false,
   110,
   10,
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


-- 7. клас, седмица 11 — разлагане чрез групиране.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w11',
   'Домашно 11 — Разлагане чрез групиране',
   'homework',
   'homework_7_w11.html',
   10,
   false,
   111,
   11,
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


-- 7. клас, седмица 12 — разлагане чрез формулите за съкратено умножение.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w12',
   'Домашно 12 — Разлагане чрез формулите',
   'homework',
   'homework_7_w12.html',
   10,
   false,
   112,
   12,
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


-- 7. клас, седмица 13 — обобщение — тъждествени преобразувания.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w13',
   'Домашно 13 — Тъждествени преобразувания (обобщение)',
   'homework',
   'homework_7_w13.html',
   10,
   false,
   113,
   13,
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


-- 7. клас, седмица 14 — линейно уравнение.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w14',
   'Домашно 14 — Линейно уравнение',
   'homework',
   'homework_7_w14.html',
   10,
   false,
   114,
   14,
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


-- 7. клас, седмица 15 — уравнения със скоби и с дроби.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w15',
   'Домашно 15 — Уравнения със скоби и с дроби',
   'homework',
   'homework_7_w15.html',
   10,
   false,
   115,
   15,
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


-- 7. клас, седмица 16 — текстови задачи с уравнения — числа и възраст.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w16',
   'Домашно 16 — Текстови задачи: числа и възраст',
   'homework',
   'homework_7_w16.html',
   10,
   false,
   116,
   16,
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


-- 7. клас, седмица 17 — текстови задачи за движение.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w17',
   'Домашно 17 — Текстови задачи: движение',
   'homework',
   'homework_7_w17.html',
   10,
   false,
   117,
   17,
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


-- 7. клас, седмица 18 — обобщение на първия срок.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w18',
   'Домашно 18 — Обобщение на първия срок',
   'homework',
   'homework_7_w18.html',
   10,
   false,
   118,
   18,
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


-- 7. клас, седмица 19 — успоредни прави и ъгли.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w19',
   'Домашно 19 — Успоредни прави и ъгли',
   'homework',
   'homework_7_w19.html',
   10,
   false,
   119,
   19,
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


-- 7. клас, седмица 20 — сбор на ъглите в триъгълник и външен ъгъл.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w20',
   'Домашно 20 — Сбор на ъглите в триъгълник. Външен ъгъл',
   'homework',
   'homework_7_w20.html',
   10,
   false,
   120,
   20,
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


-- 7. клас, седмица 21 — еднакви триъгълници.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w21',
   'Домашно 21 — Еднакви триъгълници',
   'homework',
   'homework_7_w21.html',
   10,
   false,
   121,
   21,
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


-- 7. клас, седмица 22 — равнобедрен триъгълник.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w22',
   'Домашно 22 — Равнобедрен триъгълник',
   'homework',
   'homework_7_w22.html',
   10,
   false,
   122,
   22,
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


-- 7. клас, седмица 23 — медиани, височини, ъглополовящи и симетрала.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w23',
   'Домашно 23 — Медиани, височини, ъглополовящи. Симетрала',
   'homework',
   'homework_7_w23.html',
   10,
   false,
   123,
   23,
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


-- 7. клас, седмица 24 — правоъгълен триъгълник и ъгълът от 30 градуса.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w24',
   'Домашно 24 — Правоъгълен триъгълник. Ъгълът от 30°',
   'homework',
   'homework_7_w24.html',
   10,
   false,
   124,
   24,
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


-- 7. клас, седмица 25 — неравенство на триъгълника.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w25',
   'Домашно 25 — Неравенство на триъгълника',
   'homework',
   'homework_7_w25.html',
   10,
   false,
   125,
   25,
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


-- 7. клас, седмица 26 — права и обратна теорема, геометрични места.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w26',
   'Домашно 26 — Права и обратна теорема',
   'homework',
   'homework_7_w26.html',
   10,
   false,
   126,
   26,
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


-- 7. клас, седмица 27 — построения с линийка и пергел.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w27',
   'Домашно 27 — Построения с линийка и пергел',
   'homework',
   'homework_7_w27.html',
   10,
   false,
   127,
   27,
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


-- 7. клас, седмица 28 — обобщение по геометрия.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w28',
   'Домашно 28 — Обобщение по геометрия',
   'homework',
   'homework_7_w28.html',
   10,
   false,
   128,
   28,
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


-- 7. клас, седмица 29 — вероятност на случайно събитие.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w29',
   'Домашно 29 — Вероятност на случайно събитие',
   'homework',
   'homework_7_w29.html',
   10,
   false,
   129,
   29,
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


-- 7. клас, седмица 30 — статистика — честота, мода, средна стойност.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w30',
   'Домашно 30 — Статистика: честота, мода, средна стойност',
   'homework',
   'homework_7_w30.html',
   10,
   false,
   130,
   30,
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


-- 7. клас, седмица 31 — годишен преговор — изрази и формули.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w31',
   'Домашно 31 — Годишен преговор: изрази и формули',
   'homework',
   'homework_7_w31.html',
   10,
   false,
   131,
   31,
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


-- 7. клас, седмица 32 — годишен преговор — разлагане на множители.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w32',
   'Домашно 32 — Годишен преговор: разлагане на множители',
   'homework',
   'homework_7_w32.html',
   10,
   false,
   132,
   32,
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


-- 7. клас, седмица 33 — годишен преговор — уравнения и текстови задачи.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w33',
   'Домашно 33 — Годишен преговор: уравнения и текстови задачи',
   'homework',
   'homework_7_w33.html',
   10,
   false,
   133,
   33,
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


-- 7. клас, седмица 34 — годишен преговор на целия материал.
-- Десет задачи, по една точка всяка.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-w34',
   'Домашно 34 — Годишен преговор: всичко от 7. клас',
   'homework',
   'homework_7_w34.html',
   10,
   false,
   134,
   34,
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
