-- =====================================================================
--  The Light Academy — интерактивните уроци
--  ---------------------------------------------------------------------
--  ПУСНИ ЦЕЛИЯ ФАЙЛ. Пуска се толкова пъти, колкото трябва: вече
--  записаните уроци се обновяват, нови не се дублират.
--
--  ПРЕДИ ТОВА веднъж трябва да е минал supabase/schema-v9.sql — той
--  разрешава вида 'lesson'. Без него тези редове ще спрат с грешка за
--  нарушено ограничение.
--
--  КАК СЕ ДОБАВЯ УРОК
--  1. Файлът на урока влиза в папка uroci/ (виж uroci/README.md).
--  2. Копираш един блок отдолу и сменяш в него четири неща:
--       slug   — кратко име без интервали, уникално: 'urok-4-w05'
--       title  — както ще се чете в календара
--       url    — пътят до файла: 'uroci/urok_4_w05.html'
--                или пълен чужд адрес: 'https://wordwall.net/...'
--       week   — коя седмица е, и grades — за кой клас
--  3. Пускаш файла. Урокът влиза като ЧЕРНОВА.
--
--  max_points е 0 и остава 0 — урокът не се оценява и базата не го
--  приема с други точки (ограничението се казва
--  assignments_lesson_no_points).
--  4. В таблото: „Сложи в библиотеката“, после „Дай на моите“.
--
--  published нарочно липсва в on conflict do update — дали урокът е в
--  библиотеката се решава от таблото, не от този файл. Иначе всяко
--  пускане щеше да връща обратно вече публикуваното.
--
--  sort_order: ползва се схемата от домашните — клас · 100 + седмица
--  (4. клас, седмица 5 → 405). Уроците са с 10 000 отгоре, за да стоят
--  отделно: 10405.
-- =====================================================================

-- ---------------------------------------------------------------------
-- ОБРАЗЕЦ — копирай блока и смени четирите неща.
-- Заради `where false` този ред НЕ влиза в базата; за истински урок
-- махни последния ред с where и напиши своето.
-- ---------------------------------------------------------------------
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
select
  'urok-4-w05',                               -- slug
  'Урок — Деление с едноцифрено число',       -- title
  'lesson',
  'uroci/urok_4_w05.html',                    -- url
  0,                                          -- max_points: урокът НЕ се оценява, винаги 0
  false,
  10405,                                      -- sort_order: 10000 + клас·100 + седмица
  5,                                          -- week
  (select id from public.subjects where slug = 'matematika'),
  '{4}'                                       -- grades
where false                                   -- ← махни този ред за истински урок
on conflict (slug) do update set
  title      = excluded.title,
  kind       = excluded.kind,
  url        = excluded.url,
  max_points = excluded.max_points,
  sort_order = excluded.sort_order,
  week       = excluded.week,
  subject_id = excluded.subject_id,
  grades     = excluded.grades;


-- ---------------------------------------------------------------------
-- Оттук надолу се редят истинските уроци.
-- ---------------------------------------------------------------------

-- 7. клас, седмица 2 — три учебни часа: преговор на 6. клас (рационални
-- числа и степени; уравнения, пропорции, проценти) и първата нова тема
-- „числена стойност на израз и едночлени“.
-- Страницата е ЗА ПРЕПОДАВАТЕЛЯ: вижда се планът по минути, отговорите
-- на всички задачи и бележките за работата с децата.
insert into public.assignments
  (slug, title, kind, url, max_points, published, sort_order, week, subject_id, grades)
values
  ('urok-7-w02',
   'Урок 1 — От числата към буквите',
   'lesson',
   'uroci/urok_7_w02.html',
   0,
   false,
   10702,
   2,
   (select id from public.subjects where slug = 'matematika'),
   '{7}')
on conflict (slug) do update set
  title      = excluded.title,
  kind       = excluded.kind,
  url        = excluded.url,
  max_points = excluded.max_points,
  sort_order = excluded.sort_order,
  week       = excluded.week,
  subject_id = excluded.subject_id,
  grades     = excluded.grades;
  -- published нарочно липсва: решава се от таблото.



-- Какво има до момента:
select kind as вид,
       count(*) as брой,
       count(*) filter (where published) as в_библиотеката
  from public.assignments
 group by kind
 order by kind;
