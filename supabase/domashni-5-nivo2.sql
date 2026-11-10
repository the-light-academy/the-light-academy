-- =====================================================================
--  Вторите нива на домашните в 5. клас — редовете в базата
--  ---------------------------------------------------------------------
--  Към всяко домашно за 5. клас има втори лист „ниво 2“: същата тема,
--  същият вид оценяване, но 10 по-трудни задачи. Страниците се сглобяват
--  от scripts/build_hw5n2.py, а задачите стоят в scripts/hw5n2/.
--
--  Този файл е другата половина: без ред в assignments резултатът няма
--  къде да се запише. Седмицата и подредбата са същите като на основния
--  лист, за да стоят двата един до друг в таблото и в календара.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА — нищо не се трие и не се
--  дублира. published нарочно не се пипа при повторно пускане: кога
--  листът отива при учениците се решава от таблото („Сложи в
--  библиотеката“, после „Дай на моите“).
--
--  Седмица 9 има вече втори лист (hw5-w09b), затова новият ѝ лист е
--  hw5-w09c — третият за тази седмица.
--
--  Файлът е написан от scripts/gen_hw5n2_sql.py — не го редактирай на ръка.
--
--  ПРЕДИ ТОВА трябва веднъж да са минали:
--    · supabase/subjects.sql
--    · supabase/assignments.sql   (основните листове)
-- =====================================================================

-- 5. клас, седмица 1 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи върху естествените числа: ред на действията, умно смятане, неизвестно събираемо и задачи в две стъпки.
-- sort_order е същият като на hw5-w01: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w01b',
   'Домашно — Начален преговор: естествени числа · ниво 2',
   'homework',
   'homework_5_w01b.html',
   '10 по-трудни задачи върху естествените числа: ред на действията, умно смятане, неизвестно събираемо и задачи в две стъпки',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 2 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: периметър и лице на съставни фигури, превръщане на мерни единици и задачи в две стъпки.
-- sort_order е същият като на hw5-w02: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w02b',
   'Домашно — Геометрични фигури и мерни единици · ниво 2',
   'homework',
   'homework_5_w02b.html',
   '10 по-трудни задачи: периметър и лице на съставни фигури, превръщане на мерни единици и задачи в две стъпки',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 4 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: делители, прости и съставни числа, брой на делителите и задачи с остатък.
-- sort_order е същият като на hw5-w04: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w04b',
   'Домашно — Делимост. Прости и съставни числа · ниво 2',
   'homework',
   'homework_5_w04b.html',
   '10 по-трудни задачи: делители, прости и съставни числа, брой на делителите и задачи с остатък',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 5 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи върху признаците за 2, 5 и 10: неизвестна цифра, броене и няколко условия наведнъж.
-- sort_order е същият като на hw5-w05: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w05b',
   'Домашно — Признаци за делимост на 2, 5 и 10 · ниво 2',
   'homework',
   'homework_5_w05b.html',
   '10 по-трудни задачи върху признаците за 2, 5 и 10: неизвестна цифра, броене и няколко условия наведнъж',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 6 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи върху признаците за 3 и 9: неизвестна цифра, няколко условия наведнъж и разсъждения.
-- sort_order е същият като на hw5-w06: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w06b',
   'Домашно — Признаци за делимост на 3 и 9 · ниво 2',
   'homework',
   'homework_5_w06b.html',
   '10 по-трудни задачи върху признаците за 3 и 9: неизвестна цифра, няколко условия наведнъж и разсъждения',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 7 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: разлагане на прости множители, брой на делителите и намиране на число по разлагането му.
-- sort_order е същият като на hw5-w07: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w07b',
   'Домашно — Разлагане на прости множители · ниво 2',
   'homework',
   'homework_5_w07b.html',
   '10 по-трудни задачи: разлагане на прости множители, брой на делителите и намиране на число по разлагането му',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 8 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: НОД на две и на три числа, взаимно прости числа и задачи за разделяне поравно.
-- sort_order е същият като на hw5-w08: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w08b',
   'Домашно — Най-голям общ делител (НОД) · ниво 2',
   'homework',
   'homework_5_w08b.html',
   '10 по-трудни задачи: НОД на две и на три числа, взаимно прости числа и задачи за разделяне поравно',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 9 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: НОК на две и на три числа, връзката между НОД и НОК и задачи за срещи и обиколки.
-- sort_order е същият като на hw5-w09: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w09c',
   'Домашно — Най-малко общо кратно (НОК) · ниво 2',
   'homework',
   'homework_5_w09c.html',
   '10 по-трудни задачи: НОК на две и на три числа, връзката между НОД и НОК и задачи за срещи и обиколки',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 10 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: правилни и неправилни дроби, смесени числа и дроби върху числов лъч.
-- sort_order е същият като на hw5-w10: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w10b',
   'Домашно — Обикновени дроби. Смесени числа · ниво 2',
   'homework',
   'homework_5_w10b.html',
   '10 по-трудни задачи: правилни и неправилни дроби, смесени числа и дроби върху числов лъч',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 11 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: основното свойство, съкращаване докрай и намиране на липсващото число в равенство на дроби.
-- sort_order е същият като на hw5-w11: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w11b',
   'Домашно — Основно свойство. Разширяване и съкращаване · ниво 2',
   'homework',
   'homework_5_w11b.html',
   '10 по-трудни задачи: основното свойство, съкращаване докрай и намиране на липсващото число в равенство на дроби',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 12 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: най-малък общ знаменател, сравняване на дроби с различни знаменатели и подреждане по големина.
-- sort_order е същият като на hw5-w12: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w12b',
   'Домашно — Общ знаменател. Сравняване на дроби · ниво 2',
   'homework',
   'homework_5_w12b.html',
   '10 по-трудни задачи: най-малък общ знаменател, сравняване на дроби с различни знаменатели и подреждане по големина',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 13 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: събиране и изваждане при еднакви знаменатели, смесени числа и заемане от цялото.
-- sort_order е същият като на hw5-w13: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w13b',
   'Домашно — Събиране и изваждане при еднакви знаменатели · ниво 2',
   'homework',
   'homework_5_w13b.html',
   '10 по-трудни задачи: събиране и изваждане при еднакви знаменатели, смесени числа и заемане от цялото',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 14 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: събиране и изваждане при различни знаменатели, смесени числа и изрази по няколко стъпки.
-- sort_order е същият като на hw5-w14: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w14b',
   'Домашно — Събиране и изваждане при различни знаменатели · ниво 2',
   'homework',
   'homework_5_w14b.html',
   '10 по-трудни задачи: събиране и изваждане при различни знаменатели, смесени числа и изрази по няколко стъпки',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 15 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: умножение на дроби, съкращаване преди умножение и намиране на част от число.
-- sort_order е същият като на hw5-w15: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w15b',
   'Домашно — Умножение на дроби. Част от число · ниво 2',
   'homework',
   'homework_5_w15b.html',
   '10 по-трудни задачи: умножение на дроби, съкращаване преди умножение и намиране на част от число',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 16 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: деление на дроби, обратно число, сложни изрази и ред на действията.
-- sort_order е същият като на hw5-w16: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w16b',
   'Домашно — Деление на дроби. Числови изрази · ниво 2',
   'homework',
   'homework_5_w16b.html',
   '10 по-трудни задачи: деление на дроби, обратно число, сложни изрази и ред на действията',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 17 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи с условие: части от число, остатъци и задачи в две и три стъпки.
-- sort_order е същият като на hw5-w17: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w17b',
   'Домашно — Текстови задачи с обикновени дроби · ниво 2',
   'homework',
   'homework_5_w17b.html',
   '10 по-трудни задачи с условие: части от число, остатъци и задачи в две и три стъпки',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 18 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи от целия първи срок: числови изрази, делимост, обикновени дроби и геометрия.
-- sort_order е същият като на hw5-w18: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w18b',
   'Домашно — Обобщение на първия срок · ниво 2',
   'homework',
   'homework_5_w18b.html',
   '10 по-трудни задачи от целия първи срок: числови изрази, делимост, обикновени дроби и геометрия',
   10,
   false,
   396,
   18,
   (select id from public.subjects where slug = 'matematika'),
   '{5}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 19 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: записване на десетични дроби, разряди, превръщане и сравняване.
-- sort_order е същият като на hw5-w19: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w19b',
   'Домашно — Десетични дроби: четене, писане, сравняване · ниво 2',
   'homework',
   'homework_5_w19b.html',
   '10 по-трудни задачи: записване на десетични дроби, разряди, превръщане и сравняване',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 20 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: събиране и изваждане на десетични дроби, неизвестно събираемо и закръгляне.
-- sort_order е същият като на hw5-w20: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w20b',
   'Домашно — Събиране и изваждане на десетични дроби. Закръгляне · ниво 2',
   'homework',
   'homework_5_w20b.html',
   '10 по-трудни задачи: събиране и изваждане на десетични дроби, неизвестно събираемо и закръгляне',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 21 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: умножение на десетични дроби, мястото на запетаята, изрази и текстови задачи.
-- sort_order е същият като на hw5-w21: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w21b',
   'Домашно — Умножение на десетични дроби · ниво 2',
   'homework',
   'homework_5_w21b.html',
   '10 по-трудни задачи: умножение на десетични дроби, мястото на запетаята, изрази и текстови задачи',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 22 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: деление на десетични дроби, преместване на запетаята, изрази и текстови задачи.
-- sort_order е същият като на hw5-w22: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w22b',
   'Домашно — Деление на десетични дроби · ниво 2',
   'homework',
   'homework_5_w22b.html',
   '10 по-трудни задачи: деление на десетични дроби, преместване на запетаята, изрази и текстови задачи',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 23 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: обикновени и десетични дроби заедно — превръщане, сравняване и смятане.
-- sort_order е същият като на hw5-w23: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w23b',
   'Домашно — Обикновени и десетични дроби заедно · ниво 2',
   'homework',
   'homework_5_w23b.html',
   '10 по-трудни задачи: обикновени и десетични дроби заедно — превръщане, сравняване и смятане',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 24 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи с условие: сметки с пари, мерки и средна стойност в две и три стъпки.
-- sort_order е същият като на hw5-w24: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w24b',
   'Домашно — Текстови задачи с десетични дроби · ниво 2',
   'homework',
   'homework_5_w24b.html',
   '10 по-трудни задачи с условие: сметки с пари, мерки и средна стойност в две и три стъпки',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 25 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: процентът като част от цяло, превръщане към дроб и десетична дроб и обратни задачи.
-- sort_order е същият като на hw5-w25: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w25b',
   'Домашно — Понятие за процент · ниво 2',
   'homework',
   'homework_5_w25b.html',
   '10 по-трудни задачи: процентът като част от цяло, превръщане към дроб и десетична дроб и обратни задачи',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 26 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: процент от число, обратни задачи, отстъпки, увеличения и лихви.
-- sort_order е същият като на hw5-w26: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w26b',
   'Домашно — Процент от число. Отстъпки и лихви · ниво 2',
   'homework',
   'homework_5_w26b.html',
   '10 по-трудни задачи: процент от число, обратни задачи, отстъпки, увеличения и лихви',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 27 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: остри ъгли, катети, лице и периметър на правоъгълен триъгълник.
-- sort_order е същият като на hw5-w27: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w27b',
   'Домашно — Правоъгълен триъгълник · ниво 2',
   'homework',
   'homework_5_w27b.html',
   '10 по-трудни задачи: остри ъгли, катети, лице и периметър на правоъгълен триъгълник',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 28 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: лице на триъгълник, намиране на основа или височина и съставни фигури.
-- sort_order е същият като на hw5-w28: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w28b',
   'Домашно — Лице на произволен триъгълник · ниво 2',
   'homework',
   'homework_5_w28b.html',
   '10 по-трудни задачи: лице на триъгълник, намиране на основа или височина и съставни фигури',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 29 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: лице и периметър на успоредник и ромб, диагонали на ромб и съседни ъгли.
-- sort_order е същият като на hw5-w29: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w29b',
   'Домашно — Успоредник и ромб · ниво 2',
   'homework',
   'homework_5_w29b.html',
   '10 по-трудни задачи: лице и периметър на успоредник и ромб, диагонали на ромб и съседни ъгли',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 30 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: лице на трапец, намиране на основа или височина, средна отсечка и периметър.
-- sort_order е същият като на hw5-w30: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w30b',
   'Домашно — Трапец · ниво 2',
   'homework',
   'homework_5_w30b.html',
   '10 по-трудни задачи: лице на трапец, намиране на основа или височина, средна отсечка и периметър',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 31 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: лице на повърхнина на паралелепипед и куб, сбор на ръбовете и обратни задачи.
-- sort_order е същият като на hw5-w31: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w31b',
   'Домашно — Паралелепипед и куб. Лице на повърхнина · ниво 2',
   'homework',
   'homework_5_w31b.html',
   '10 по-трудни задачи: лице на повърхнина на паралелепипед и куб, сбор на ръбовете и обратни задачи',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 32 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи: обем на паралелепипед и куб, превръщане в литри и обратни задачи.
-- sort_order е същият като на hw5-w32: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w32b',
   'Домашно — Обем на паралелепипед и куб · ниво 2',
   'homework',
   'homework_5_w32b.html',
   '10 по-трудни задачи: обем на паралелепипед и куб, превръщане в литри и обратни задачи',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.

-- 5. клас, седмица 33 — ВТОРИ лист за същата седмица, ниво 2.
-- 10 по-трудни задачи от цялата година: дроби, десетични дроби, процент, геометрия и текстови задачи.
-- sort_order е същият като на hw5-w33: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw5-w33b',
   'Домашно — Годишен преговор · ниво 2',
   'homework',
   'homework_5_w33b.html',
   '10 по-трудни задачи от цялата година: дроби, десетични дроби, процент, геометрия и текстови задачи',
   10,
   false,
   411,
   33,
   (select id from public.subjects where slug = 'matematika'),
   '{5}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- Какво има в базата сега ----------------------------------------------
--  Един ред на лист: заглавието, точките и дали е в библиотеката.
select a.week                                as sedmica,
       a.title                               as list,
       a.max_points                          as tochki,
       case when a.published then 'да' else 'не' end as v_biblioteka
  from public.assignments a
 where a.slug in ('hw5-w01b', 'hw5-w02b', 'hw5-w04b', 'hw5-w05b',
                  'hw5-w06b', 'hw5-w07b', 'hw5-w08b', 'hw5-w09c',
                  'hw5-w10b', 'hw5-w11b', 'hw5-w12b', 'hw5-w13b',
                  'hw5-w14b', 'hw5-w15b', 'hw5-w16b', 'hw5-w17b',
                  'hw5-w18b', 'hw5-w19b', 'hw5-w20b', 'hw5-w21b',
                  'hw5-w22b', 'hw5-w23b', 'hw5-w24b', 'hw5-w25b',
                  'hw5-w26b', 'hw5-w27b', 'hw5-w28b', 'hw5-w29b',
                  'hw5-w30b', 'hw5-w31b', 'hw5-w32b', 'hw5-w33b')
 order by a.week, a.title;
