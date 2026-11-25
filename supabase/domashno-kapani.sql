-- =====================================================================
--  Домашно „Осемте капана“ — 7. клас — редът в базата
--  ---------------------------------------------------------------------
--  Домашното не е по нова тема. То идва от анализа на сгрешените
--  задачи в таблото: десет въпроса по осемте места, на които сметката
--  се обърква най-често — минусът пред скобата, средният член при
--  (a ± b)², скоба по скоба, разликата на квадрати срещу пълния
--  квадрат, заместването на стойност, знаците при числата, степените
--  и процентът.
--
--  Числата са ДРУГИ, не тези от урока: проверява се разбирането, не
--  паметта. Грешните отговори пък са точно тези, които са дадени в
--  таблото — затова, ако някой избере пак същото, веднага се вижда кой
--  капан още стои.
--
--  Листът е homework_7_kapani.html, сглобява се от
--  scripts/build_hw7_kapani.py, а въпросите стоят в
--  scripts/kapani/domashno.py.
--
--  week е null: домашното не е вързано за седмица, дава се когато
--  потрябва. sort_order 145 го слага след всички седмични листове за
--  7. клас.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА — нищо не се трие и не се
--  дублира. published нарочно НЕ се пипа при повторно пускане: кога
--  листът отива при учениците се решава от таблото („Сложи в
--  библиотеката“, после „Дай на моите“).
--
--  ПРЕДИ ТОВА трябва веднъж да са минали:
--    · supabase/subjects.sql
--    · supabase/assignments.sql
-- =====================================================================

insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('hw7-kapani',
   'Домашно — Осемте капана (по грешките)',
   'homework',
   'homework_7_kapani.html',
   10,
   false,
   145,
   null,
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

-- Проверка: редът е вътре и сочи към правилния лист.
select slug, title, max_points, published, sort_order, week, grades
from public.assignments
where slug = 'hw7-kapani';
