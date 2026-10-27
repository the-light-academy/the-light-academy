-- =====================================================================
--  Вторите нива на домашните в 6. клас — редовете в базата
--  ---------------------------------------------------------------------
--  Към всяко домашно за 6. клас има втори лист „ниво 2“: същата тема,
--  същият вид оценяване, но 12 по-трудни задачи. Страниците се сглобяват
--  от scripts/build_hw2.py, а задачите стоят в scripts/hw2/questions.py.
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
--  Файлът е написан от scripts/gen_hw2_sql.py — не го редактирай на ръка.
--
--  ПРЕДИ ТОВА трябва веднъж да са минали:
--    · supabase/subjects.sql
--    · supabase/assignments.sql   (основните листове)
-- =====================================================================


-- 6. клас, седмица 1 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи върху дробите от 5. клас.
-- sort_order е същият като на hw6-w01: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w01b',
   'Домашно — Обикновени и десетични дроби · ниво 2',
   'homework',
   'homework_6_w01b.html',
   '12 по-трудни задачи върху дробите от 5. клас',
   12,
   false,
   390,
   1,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 2 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи за част от число и процент.
-- sort_order е същият като на hw6-w02: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w02b',
   'Домашно — Част от число и процент · ниво 2',
   'homework',
   'homework_6_w02b.html',
   '12 по-трудни задачи за част от число и процент',
   12,
   false,
   392,
   2,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 2 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи по геометрията от 5. клас.
-- sort_order е същият като на hw6-w02-geo: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w02-geo-b',
   'Домашно — Геометрични фигури от 5. клас · ниво 2',
   'homework',
   'homework_6_w02_geob.html',
   '12 по-трудни задачи по геометрията от 5. клас',
   12,
   false,
   392,
   2,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 11 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи със степени.
-- sort_order е същият като на hw6-w04: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w04b',
   'Домашно — Степен с естествен показател · ниво 2',
   'homework',
   'homework_6_w04b.html',
   '12 по-трудни задачи със степени',
   12,
   false,
   399,
   11,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 12 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи с трите правила.
-- sort_order е същият като на hw6-w05: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w05b',
   'Домашно — Деление и степенуване на степени · ниво 2',
   'homework',
   'homework_6_w05b.html',
   '12 по-трудни задачи с трите правила',
   12,
   false,
   400,
   12,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 13 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи с изрази, в които има по няколко степени, и със стандартния запис на големи числа. Пази реда на действията.
-- sort_order е същият като на hw6-w06: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w06b',
   'Домашно — Изрази със степени. Стандартен запис · ниво 2',
   'homework',
   'homework_6_w06b.html',
   '12 по-трудни задачи с изрази, в които има по няколко степени, и със стандартния запис на големи числа. Пази реда на действията',
   12,
   false,
   401,
   13,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 4 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи с отрицателни числа.
-- sort_order е същият като на hw6-w07: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w07b',
   'Домашно — Положителни и отрицателни числа · ниво 2',
   'homework',
   'homework_6_w07b.html',
   '12 по-трудни задачи с отрицателни числа',
   12,
   false,
   393,
   4,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 5 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи с модул.
-- sort_order е същият като на hw6-w08: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w08b',
   'Домашно — Абсолютна стойност. Сравняване · ниво 2',
   'homework',
   'homework_6_w08b.html',
   '12 по-трудни задачи с модул',
   12,
   false,
   394,
   5,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 6 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи за събиране на рационални числа.
-- sort_order е същият като на hw6-w09: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w09b',
   'Домашно — Събиране на рационални числа · ниво 2',
   'homework',
   'homework_6_w09b.html',
   '12 по-трудни задачи за събиране на рационални числа',
   12,
   false,
   394,
   6,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 8 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи за умножение на рационални числа.
-- sort_order е същият като на hw6-w11: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w11b',
   'Домашно — Умножение на рационални числа · ниво 2',
   'homework',
   'homework_6_w11b.html',
   '12 по-трудни задачи за умножение на рационални числа',
   12,
   false,
   396,
   8,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 9 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи за деление на рационални числа.
-- sort_order е същият като на hw6-w12: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w12b',
   'Домашно — Деление на рационални числа · ниво 2',
   'homework',
   'homework_6_w12b.html',
   '12 по-трудни задачи за деление на рационални числа',
   12,
   false,
   397,
   9,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 10 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи в координатната система.
-- sort_order е същият като на hw6-w13: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w13b',
   'Домашно — Координатна система · ниво 2',
   'homework',
   'homework_6_w13b.html',
   '12 по-трудни задачи в координатната система',
   12,
   false,
   398,
   10,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 14 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни линейни уравнения.
-- sort_order е същият като на hw6-w14: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w14b',
   'Домашно — Линейни уравнения · ниво 2',
   'homework',
   'homework_6_w14b.html',
   '12 по-трудни линейни уравнения',
   12,
   false,
   402,
   14,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 15 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни уравнения със скоби.
-- sort_order е същият като на hw6-w15: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w15b',
   'Домашно — Уравнения със скоби · ниво 2',
   'homework',
   'homework_6_w15b.html',
   '12 по-трудни уравнения със скоби',
   12,
   false,
   403,
   15,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 16 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни текстови задачи, които се решават с уравнение.
-- sort_order е същият като на hw6-w16: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w16b',
   'Домашно — Текстови задачи с уравнения · ниво 2',
   'homework',
   'homework_6_w16b.html',
   '12 по-трудни текстови задачи, които се решават с уравнение',
   12,
   false,
   404,
   16,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 17 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи от целия първи срок.
-- sort_order е същият като на hw6-w17: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w17b',
   'Домашно — Обобщение на първия срок · ниво 2',
   'homework',
   'homework_6_w17b.html',
   '12 по-трудни задачи от целия първи срок',
   12,
   false,
   405,
   17,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 19 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи с отношения и пропорции.
-- sort_order е същият като на hw6-w19: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w19b',
   'Домашно — Отношение и пропорция · ниво 2',
   'homework',
   'homework_6_w19b.html',
   '12 по-трудни задачи с отношения и пропорции',
   12,
   false,
   406,
   19,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 20 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи с проценти.
-- sort_order е същият като на hw6-w20: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w20b',
   'Домашно — Процент чрез пропорция · ниво 2',
   'homework',
   'homework_6_w20b.html',
   '12 по-трудни задачи с проценти',
   12,
   false,
   407,
   20,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 21 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи с право и обратно пропорционални величини.
-- sort_order е същият като на hw6-w21: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w21b',
   'Домашно — Права и обратна пропорционалност · ниво 2',
   'homework',
   'homework_6_w21b.html',
   '12 по-трудни задачи с право и обратно пропорционални величини',
   12,
   false,
   408,
   21,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 22 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи с мащаб и графики.
-- sort_order е същият като на hw6-w22: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w22b',
   'Домашно — Графики и мащаб · ниво 2',
   'homework',
   'homework_6_w22b.html',
   '12 по-трудни задачи с мащаб и графики',
   12,
   false,
   409,
   22,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 23 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи с данни.
-- sort_order е същият като на hw6-w23: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w23b',
   'Домашно — Организиране на данни · ниво 2',
   'homework',
   'homework_6_w23b.html',
   '12 по-трудни задачи с данни',
   12,
   false,
   410,
   23,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 24 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи с диаграми.
-- sort_order е същият като на hw6-w24: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w24b',
   'Домашно — Диаграми и средноаритметично · ниво 2',
   'homework',
   'homework_6_w24b.html',
   '12 по-трудни задачи с диаграми',
   12,
   false,
   411,
   24,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 25 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи с вероятности.
-- sort_order е същият като на hw6-w25: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w25b',
   'Домашно — Вероятност · ниво 2',
   'homework',
   'homework_6_w25b.html',
   '12 по-трудни задачи с вероятности',
   12,
   false,
   412,
   25,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 26 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи за окръжност и кръг с π ≈ 3,14.
-- sort_order е същият като на hw6-w26: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w26b',
   'Домашно — Окръжност и кръг · ниво 2',
   'homework',
   'homework_6_w26b.html',
   '12 по-трудни задачи за окръжност и кръг с π ≈ 3,14',
   12,
   false,
   413,
   26,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 27 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи с правилни многоъгълници.
-- sort_order е същият като на hw6-w27: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w27b',
   'Домашно — Правилен многоъгълник · ниво 2',
   'homework',
   'homework_6_w27b.html',
   '12 по-трудни задачи с правилни многоъгълници',
   12,
   false,
   414,
   27,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 28 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи за права призма.
-- sort_order е същият като на hw6-w28: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w28b',
   'Домашно — Права призма · ниво 2',
   'homework',
   'homework_6_w28b.html',
   '12 по-трудни задачи за права призма',
   12,
   false,
   415,
   28,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 29 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи за правилна пирамида.
-- sort_order е същият като на hw6-w29: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w29b',
   'Домашно — Правилна пирамида · ниво 2',
   'homework',
   'homework_6_w29b.html',
   '12 по-трудни задачи за правилна пирамида',
   12,
   false,
   416,
   29,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 30 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи за цилиндър с π ≈ 3,14.
-- sort_order е същият като на hw6-w30: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w30b',
   'Домашно — Цилиндър · ниво 2',
   'homework',
   'homework_6_w30b.html',
   '12 по-трудни задачи за цилиндър с π ≈ 3,14',
   12,
   false,
   417,
   30,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 31 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи за конус и кълбо с π ≈ 3,14.
-- sort_order е същият като на hw6-w31: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w31b',
   'Домашно — Конус и кълбо · ниво 2',
   'homework',
   'homework_6_w31b.html',
   '12 по-трудни задачи за конус и кълбо с π ≈ 3,14',
   12,
   false,
   418,
   31,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 32 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни стъпки около един басейн 12 м на 5 м и дълбочина 1,8 м.
-- sort_order е същият като на hw6-w32: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w32b',
   'Домашно — Геометрични тела: басейнът на Мишо · ниво 2',
   'homework',
   'homework_6_w32b.html',
   '12 по-трудни стъпки около един басейн 12 м на 5 м и дълбочина 1,8 м',
   12,
   false,
   400,
   32,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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


-- 6. клас, седмица 34 — ВТОРИ лист за същата седмица, ниво 2.
-- 12 по-трудни задачи от целия 6. клас.
-- sort_order е същият като на hw6-w34: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w34b',
   'Домашно — Годишен преговор · ниво 2',
   'homework',
   'homework_6_w34b.html',
   '12 по-трудни задачи от целия 6. клас',
   12,
   false,
   419,
   34,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
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
--  Един ред на седмица: основният лист и неговото ниво 2 един до друг.
select a.week                                as sedmica,
       a.title                               as list,
       a.max_points                          as tochki,
       case when a.published then 'да' else 'не' end as v_biblioteka
  from public.assignments a
 where a.slug in ('hw6-w01b', 'hw6-w02b', 'hw6-w02-geo-b', 'hw6-w04b',
                  'hw6-w05b', 'hw6-w06b', 'hw6-w07b', 'hw6-w08b',
                  'hw6-w09b', 'hw6-w11b', 'hw6-w12b', 'hw6-w13b',
                  'hw6-w14b', 'hw6-w15b', 'hw6-w16b', 'hw6-w17b',
                  'hw6-w19b', 'hw6-w20b', 'hw6-w21b', 'hw6-w22b',
                  'hw6-w23b', 'hw6-w24b', 'hw6-w25b', 'hw6-w26b',
                  'hw6-w27b', 'hw6-w28b', 'hw6-w29b', 'hw6-w30b',
                  'hw6-w31b', 'hw6-w32b', 'hw6-w34b',
                  'hw6-w10b')
 order by a.week, a.title;

