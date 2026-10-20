-- =====================================================================
--  Пробните теми по състезания — 4. клас, състезателна математика
--  ---------------------------------------------------------------------
--  Това са същите редове, които стоят и накрая на
--  supabase/assignments.sql. Изваден е отделно, защото онзи файл е към
--  4000 реда и е излишно да се пуска целият заради две задания.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА: вече записаните редове се
--  обновяват, нови не се дублират.
--
--  ПРЕДИ ТОВА трябва веднъж да са минали:
--    · supabase/subjects.sql    — за предмета „Състезателна математика“
--    · supabase/schema-v8.sql   — за колоните track и section
--
--  Тестовете влизат като ЧЕРНОВИ. После в таблото, в календара
--  (4. клас · Състезателна математика): „Сложи в библиотеката“, а след
--  това „Дай на моите“.
--
--  Разделите идват от assets/tracks.js: „Състезание „Иван Салабашев““
--  (salabashev / minali) и „Олимпиада по математика“ (olimpiada /
--  obshtinski, oblasten).
-- =====================================================================

insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, subject_id, grades, track, section)
values
  ('sal-2025-4',
   'Пробен „Иван Салабашев“ — 2025',
   'exam',
   'probni_testove/probna_salabashev_2025_4klas.html',
   60,
   false,
   4025,
   (select id from public.subjects where slug = 'sastezatelna-matematika'),
   '{4}',
   'salabashev',
   'minali'),
  ('sal-2024-4',
   'Пробен „Иван Салабашев“ — 2024',
   'exam',
   'probni_testove/probna_salabashev_2024_4klas.html',
   60,
   false,
   4024,
   (select id from public.subjects where slug = 'sastezatelna-matematika'),
   '{4}',
   'salabashev',
   'minali'),
  ('probna-obshtinski-2018-4',
   'Пробен общински кръг — 2018',
   'exam',
   'probni_testove/probna_obshtinski_2018_4klas.html',
   21,
   false,
   4018,
   (select id from public.subjects where slug = 'sastezatelna-matematika'),
   '{4}',
   'olimpiada',
   'obshtinski'),
  ('probna-obshtinski-2020-4',
   'Пробен общински кръг — 2020',
   'exam',
   'probni_testove/probna_obshtinski_2020_4klas.html',
   21,
   false,
   4020,
   (select id from public.subjects where slug = 'sastezatelna-matematika'),
   '{4}',
   'olimpiada',
   'obshtinski')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades,
  track       = excluded.track,
  section     = excluded.section;
  -- published нарочно липсва: решава се от таблото.


-- Потвърждение. Трябва да излязат четири реда: двата Салабашев в раздел
-- salabashev / minali и двата общински в olimpiada / obshtinski, всички
-- с предмет „Състезателна математика“. Ако предметът е празен, значи
-- subjects.sql още не е минал.
select slug,
       title,
       published                                             as в_библиотеката,
       track                                                 as раздел,
       section                                               as кръг,
       grades                                                as класове,
       (select name from public.subjects s where s.id = a.subject_id) as предмет
  from public.assignments a
 where slug like 'probna-obshtinski%' or slug like 'sal-%'
 order by slug;
