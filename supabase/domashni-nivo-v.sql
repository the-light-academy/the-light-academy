-- =====================================================================
--  Третото ниво на домашните в 6. клас — „ниво В група“
--  ---------------------------------------------------------------------
--  Към всяка тема от 6. клас има и трети лист — „ниво В група“: десет
--  състезателни задачи от вида, който се дава на Иван Салабашев,
--  Европейско кенгуру и на общинските кръгове. Страниците се сглобяват
--  от scripts/build_hw3.py, а задачите стоят в scripts/hw3/zadachi.py.
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
--  Файлът е написан от scripts/gen_hw3_sql.py — не го редактирай на ръка.
--
--  ПРЕДИ ТОВА трябва веднъж да са минали:
--    · supabase/subjects.sql
--    · supabase/assignments.sql   (основните листове)
-- =====================================================================


-- 6. клас, седмица 1 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за дробите. Тук не се пресмята дълго — тук се мисли. Всяка задача има една идея; намериш ли я, сметката е кратка.
-- sort_order е същият като на hw6-w01: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w01v',
   'Домашно — Обикновени и десетични дроби · ниво В група',
   'homework',
   'homework_6_w01v.html',
   'Десет състезателни задачи за дробите. Тук не се пресмята дълго — тук се мисли. Всяка задача има една идея; намериш ли я, сметката е кратка',
   10,
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


-- 6. клас, седмица 2 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за проценти. Внимавай от какво се взима процентът — при тези задачи грешката почти винаги е там.
-- sort_order е същият като на hw6-w02: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w02v',
   'Домашно — Част от число и процент · ниво В група',
   'homework',
   'homework_6_w02v.html',
   'Десет състезателни задачи за проценти. Внимавай от какво се взима процентът — при тези задачи грешката почти винаги е там',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 2 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи по геометрия. Повечето се решават с чертеж и с броене, а не с формула — затова първо рисувай.
-- sort_order е същият като на hw6-w02-geo: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w02-geo-v',
   'Домашно — Геометрични фигури от 5. клас · ниво В група',
   'homework',
   'homework_6_w02_geov.html',
   'Десет състезателни задачи по геометрия. Повечето се решават с чертеж и с броене, а не с формула — затова първо рисувай',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 11 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за степени. Големите степени не се пресмятат — гледа се какво се повтаря.
-- sort_order е същият като на hw6-w04: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w04v',
   'Домашно — Степен с естествен показател · ниво В група',
   'homework',
   'homework_6_w04v.html',
   'Десет състезателни задачи за степени. Големите степени не се пресмятат — гледа се какво се повтаря',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 12 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за действия със степени. Хитростта почти винаги е една.
-- sort_order е същият като на hw6-w05: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w05v',
   'Домашно — Деление и степенуване на степени · ниво В група',
   'homework',
   'homework_6_w05v.html',
   'Десет състезателни задачи за действия със степени. Хитростта почти винаги е една',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 13 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за големите числа. Тук калкулаторът не помага — числата не се побират в него.
-- sort_order е същият като на hw6-w06: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w06v',
   'Домашно — Изрази със степени. Стандартен запис · ниво В група',
   'homework',
   'homework_6_w06v.html',
   'Десет състезателни задачи за големите числа. Тук калкулаторът не помага — числата не се побират в него',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 4 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи с отрицателни числа. Повечето се решават на числовата ос — затова първо я начертай.
-- sort_order е същият като на hw6-w07: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w07v',
   'Домашно — Положителни и отрицателни числа · ниво В група',
   'homework',
   'homework_6_w07v.html',
   'Десет състезателни задачи с отрицателни числа. Повечето се решават на числовата ос — затова първо я начертай',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 5 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за модула. Помни.
-- sort_order е същият като на hw6-w08: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w08v',
   'Домашно — Абсолютна стойност. Сравняване · ниво В група',
   'homework',
   'homework_6_w08v.html',
   'Десет състезателни задачи за модула. Помни',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 6 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за събиране. Дългите сборове не се смятат член по член — групират се.
-- sort_order е същият като на hw6-w09: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w09v',
   'Домашно — Събиране на рационални числа · ниво В група',
   'homework',
   'homework_6_w09v.html',
   'Десет състезателни задачи за събиране. Дългите сборове не се смятат член по член — групират се',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 7 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за изваждане. Изваждането на отрицателно число е прибавяне — повечето грешки идват оттам.
-- sort_order е същият като на hw6-w10: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w10v',
   'Домашно — Изваждане на рационални числа · ниво В група',
   'homework',
   'homework_6_w10v.html',
   'Десет състезателни задачи за изваждане. Изваждането на отрицателно число е прибавяне — повечето грешки идват оттам',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 8 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за умножение. Първо гледай знака и нулата — чак после смятай.
-- sort_order е същият като на hw6-w11: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w11v',
   'Домашно — Умножение на рационални числа · ниво В група',
   'homework',
   'homework_6_w11v.html',
   'Десет състезателни задачи за умножение. Първо гледай знака и нулата — чак после смятай',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 9 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за деление. Делението на дроб е умножение с обратната ѝ — оттам нататък е внимание.
-- sort_order е същият като на hw6-w12: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w12v',
   'Домашно — Деление на рационални числа · ниво В група',
   'homework',
   'homework_6_w12v.html',
   'Десет състезателни задачи за деление. Делението на дроб е умножение с обратната ѝ — оттам нататък е внимание',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 10 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи в координатната система. Всяка започва с чертеж — без чертеж тези задачи не се решават.
-- sort_order е същият като на hw6-w13: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w13v',
   'Домашно — Координатна система · ниво В група',
   'homework',
   'homework_6_w13v.html',
   'Десет състезателни задачи в координатната система. Всяка започва с чертеж — без чертеж тези задачи не се решават',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 14 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за уравнения. Две от тях нямат корен или имат безброй корени — това също е отговор.
-- sort_order е същият като на hw6-w14: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w14v',
   'Домашно — Линейни уравнения · ниво В група',
   'homework',
   'homework_6_w14v.html',
   'Десет състезателни задачи за уравнения. Две от тях нямат корен или имат безброй корени — това също е отговор',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 15 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи със скоби. Минусът пред скоба сменя знака на всичко вътре — тук това е половината работа.
-- sort_order е същият като на hw6-w15: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w15v',
   'Домашно — Уравнения със скоби · ниво В група',
   'homework',
   'homework_6_w15v.html',
   'Десет състезателни задачи със скоби. Минусът пред скоба сменя знака на всичко вътре — тук това е половината работа',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 16 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни текстови задачи. При всяка първо решаваш кое ще е x — това е половината от задачата.
-- sort_order е същият като на hw6-w16: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w16v',
   'Домашно — Текстови задачи с уравнения · ниво В група',
   'homework',
   'homework_6_w16v.html',
   'Десет състезателни текстови задачи. При всяка първо решаваш кое ще е x — това е половината от задачата',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 17 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи от целия първи срок. Тук всяка задача е от различна тема — както на състезание.
-- sort_order е същият като на hw6-w17: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w17v',
   'Домашно — Обобщение на първия срок · ниво В група',
   'homework',
   'homework_6_w17v.html',
   'Десет състезателни задачи от целия първи срок. Тук всяка задача е от различна тема — както на състезание',
   10,
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


-- 6. клас, седмица 19 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за отношения. Отношението не казва колко са — казва само как се делят на части.
-- sort_order е същият като на hw6-w19: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w19v',
   'Домашно — Отношение и пропорция · ниво В група',
   'homework',
   'homework_6_w19v.html',
   'Десет състезателни задачи за отношения. Отношението не казва колко са — казва само как се делят на части',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 20 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за проценти чрез пропорция. Винаги питай.
-- sort_order е същият като на hw6-w20: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w20v',
   'Домашно — Процент чрез пропорция · ниво В група',
   'homework',
   'homework_6_w20v.html',
   'Десет състезателни задачи за проценти чрез пропорция. Винаги питай',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 21 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за двата вида зависимост. Първият въпрос винаги е.
-- sort_order е същият като на hw6-w21: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w21v',
   'Домашно — Права и обратна пропорционалност · ниво В група',
   'homework',
   'homework_6_w21v.html',
   'Десет състезателни задачи за двата вида зависимост. Първият въпрос винаги е',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 22 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за мащаб и графики. Най-коварното е лицето.
-- sort_order е същият като на hw6-w22: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w22v',
   'Домашно — Графики и мащаб · ниво В група',
   'homework',
   'homework_6_w22v.html',
   'Десет състезателни задачи за мащаб и графики. Най-коварното е лицето',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 23 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за данни. Най-често се бърка едно.
-- sort_order е същият като на hw6-w23: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w23v',
   'Домашно — Организиране на данни · ниво В група',
   'homework',
   'homework_6_w23v.html',
   'Десет състезателни задачи за данни. Най-често се бърка едно',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 24 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за средноаритметично. Трикът почти винаги е да минеш през СБОРА, а не през средното.
-- sort_order е същият като на hw6-w24: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w24v',
   'Домашно — Диаграми и средноаритметично · ниво В група',
   'homework',
   'homework_6_w24v.html',
   'Десет състезателни задачи за средноаритметично. Трикът почти винаги е да минеш през СБОРА, а не през средното',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 25 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за вероятност. При две зарчета възможностите са 36 — брои се, не се гадае.
-- sort_order е същият като на hw6-w25: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w25v',
   'Домашно — Вероятност · ниво В група',
   'homework',
   'homework_6_w25v.html',
   'Десет състезателни задачи за вероятност. При две зарчета възможностите са 36 — брои се, не се гадае',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 26 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за окръжността (π ≈ 3,14). Повечето се свеждат до едно.
-- sort_order е същият като на hw6-w26: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w26v',
   'Домашно — Окръжност и кръг · ниво В група',
   'homework',
   'homework_6_w26v.html',
   'Десет състезателни задачи за окръжността (π ≈ 3,14). Повечето се свеждат до едно',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 27 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за правилни многоъгълници. Външният ъгъл е ключът — сборът им винаги е 360°.
-- sort_order е същият като на hw6-w27: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w27v',
   'Домашно — Правилен многоъгълник · ниво В група',
   'homework',
   'homework_6_w27v.html',
   'Десет състезателни задачи за правилни многоъгълници. Външният ъгъл е ключът — сборът им винаги е 360°',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 28 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за призмата. Две от тях са за боядисания куб — класика на състезанията.
-- sort_order е същият като на hw6-w28: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w28v',
   'Домашно — Права призма · ниво В група',
   'homework',
   'homework_6_w28v.html',
   'Десет състезателни задачи за призмата. Две от тях са за боядисания куб — класика на състезанията',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 29 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за пирамидата. Помни двете неща, които се бъркат.
-- sort_order е същият като на hw6-w29: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w29v',
   'Домашно — Правилна пирамида · ниво В група',
   'homework',
   'homework_6_w29v.html',
   'Десет състезателни задачи за пирамидата. Помни двете неща, които се бъркат',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 30 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за цилиндъра (π ≈ 3,14). При повечето се тръгва наобратно — от обема към радиуса.
-- sort_order е същият като на hw6-w30: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w30v',
   'Домашно — Цилиндър · ниво В група',
   'homework',
   'homework_6_w30v.html',
   'Десет състезателни задачи за цилиндъра (π ≈ 3,14). При повечето се тръгва наобратно — от обема към радиуса',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 31 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи за конуса и кълбото (π ≈ 3,14). Трите тела — цилиндър, конус, кълбо — се сравняват, не се помнят.
-- sort_order е същият като на hw6-w31: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w31v',
   'Домашно — Конус и кълбо · ниво В група',
   'homework',
   'homework_6_w31v.html',
   'Десет състезателни задачи за конуса и кълбото (π ≈ 3,14). Трите тела — цилиндър, конус, кълбо — се сравняват, не се помнят',
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
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва тук: то се управлява от таблото.


-- 6. клас, седмица 32 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни стъпки около един басейн 25 m на 10 m с наклонено дъно — от 1,2 m до 2,8 m дълбочина.
-- sort_order е същият като на hw6-w32: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w32v',
   'Домашно — Геометрични тела: басейнът на Мишо · ниво В група',
   'homework',
   'homework_6_w32v.html',
   'Десет състезателни стъпки около един басейн 25 m на 10 m с наклонено дъно — от 1,2 m до 2,8 m дълбочина',
   10,
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


-- 6. клас, седмица 34 — ТРЕТИ лист за същата тема: ниво В група.
-- Десет състезателни задачи от целия 6. клас — по една от всяка голяма тема. Точно такъв е и един кръг от състезание.
-- sort_order е същият като на hw6-w34: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('hw6-w34v',
   'Домашно — Годишен преговор · ниво В група',
   'homework',
   'homework_6_w34v.html',
   'Десет състезателни задачи от целия 6. клас — по една от всяка голяма тема. Точно такъв е и един кръг от състезание',
   10,
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
--  По един ред на лист: основният, ниво 2 и ниво В група един под друг.
select a.week                                as sedmica,
       a.title                               as list,
       a.max_points                          as tochki,
       case when a.published then 'да' else 'не' end as v_biblioteka
  from public.assignments a
 where a.kind = 'homework'
   and a.grades @> '{6}'
 order by a.week, a.title;

