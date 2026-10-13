-- =====================================================================
--  Уроците от календара ти — октомври 2026
--  ---------------------------------------------------------------------
--  Четиринайсет часа, пренесени от снимката: само жълтите, личните ги
--  няма. Всеки е по 60 минути. Твои са всички освен онези, на които
--  пише „Лили“.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА. Второто пускане не добавя
--  нищо: ограничението „един преподавател, едно време“ разпознава вече
--  записания час и редът се пропуска мълчаливо.
--
--  ПРЕДИ ТОВА трябва веднъж да е минал supabase/schema-v10.sql.
--
--  ЧАСОВЕТЕ СА В МЕСТНО ВРЕМЕ. Пише се „17:15“ и базата сама го
--  превръща — включително през нощта на 25 октомври, когато часовникът
--  се мести. Затова никъде няма +02 или +03 на ръка: за 13 октомври и
--  за 29 октомври отговорът е различен и ръчното писане го сбърква.
-- =====================================================================


-- ---------------------------------------------------------------------
--  СТЪПКА 0 — кого намира файлът. Погледни резултата, преди да пуснеш
--  останалото: трябва да има точно един ред за теб и един за Лили.
--  Ако Лили липсва, смени шаблона '%Лили%' по-долу с нейното име,
--  както е записано в „Преподаватели“.
-- ---------------------------------------------------------------------
select 'ти (админ)' as кой, id, full_name
  from public.profiles
 where role = 'teacher' and active and is_admin
union all
select 'Лили', id, full_name
  from public.profiles
 where role = 'teacher' and active and full_name ilike '%Лили%';


-- ---------------------------------------------------------------------
--  СТЪПКА 1 — предметът „Български език и литература“
--  Трябва за урока на Крис при Лили. Ако вече го има, редът не прави
--  нищо.
-- ---------------------------------------------------------------------
insert into public.subjects (slug, name, active, auto_enroll, sort_order)
values ('balgarski-ezik', 'Български език и литература', true, false, 15)
on conflict (slug) do nothing;


-- ---------------------------------------------------------------------
--  СТЪПКА 2 — самите часове
--
--  Колоните в списъка: начало · дете · предмет · чий е · бележка
-- ---------------------------------------------------------------------
with who as (
  select
    (select id from public.profiles
      where role = 'teacher' and active and is_admin
      order by created_at limit 1)                            as ani,
    (select id from public.profiles
      where role = 'teacher' and active and full_name ilike '%Лили%'
      order by created_at limit 1)                            as lili
)
insert into public.lessons
  (teacher_id, subject_id, child_name, starts_at, ends_at, note, created_by)
select
  case v.chij when 'lili' then w.lili else w.ani end,
  s.id,
  v.dete,
  (v.nachalo::timestamp at time zone 'Europe/Sofia'),
  (v.nachalo::timestamp at time zone 'Europe/Sofia') + interval '60 minutes',
  v.belezhka,
  w.ani
from (values
  -- вторник, 13 октомври
  ('2026-10-13 17:15', 'Крис',              'matematika',     'ani',  null),
  -- сряда, 14 октомври
  ('2026-10-14 16:45', 'Андрей и Боян',     'matematika',     'ani',  null),
  ('2026-10-14 17:00', 'Борис',             'matematika',     'lili', 'НВО — математика и БЕЛ'),
  ('2026-10-14 18:15', 'НВО 7 клас (група)','matematika',     'ani',  'НВО 7 клас'),
  -- четвъртък, 15 октомври
  ('2026-10-15 16:45', 'Крис',              'balgarski-ezik', 'lili', null),
  ('2026-10-15 18:00', 'Андрей',            'matematika',     'ani',  null),
  -- понеделник, 19 октомври
  ('2026-10-19 16:45', 'Андрей и Боян',     'matematika',     'ani',  null),
  -- сряда, 21 октомври
  ('2026-10-21 17:00', 'Борис',             'matematika',     'lili', 'НВО — математика и БЕЛ'),
  ('2026-10-21 18:15', 'НВО 7 клас (група)','matematika',     'ani',  'НВО 7 клас'),
  -- четвъртък, 22 октомври
  ('2026-10-22 18:00', 'Андрей',            'matematika',     'ani',  null),
  -- понеделник, 26 октомври
  ('2026-10-26 16:45', 'Андрей и Боян',     'matematika',     'ani',  null),
  -- сряда, 28 октомври
  ('2026-10-28 17:00', 'Борис',             'matematika',     'lili', 'НВО — математика и БЕЛ'),
  ('2026-10-28 18:15', 'НВО 7 клас (група)','matematika',     'ani',  'НВО 7 клас'),
  -- четвъртък, 29 октомври
  ('2026-10-29 18:00', 'Андрей',            'matematika',     'ani',  null)
) as v(nachalo, dete, predmet, chij, belezhka)
cross join who w
join public.subjects s on s.slug = v.predmet
on conflict do nothing;


-- ---------------------------------------------------------------------
--  Потвърждение. Трябва да излязат 14 реда — ако са по-малко, значи
--  някой от тях вече е бил записан и е прескочен.
-- ---------------------------------------------------------------------
select
  to_char(l.starts_at at time zone 'Europe/Sofia', 'DD.MM (Dy) HH24:MI') as кога,
  l.child_name                                                          as дете,
  s.name                                                                as предмет,
  p.full_name                                                           as преподавател,
  l.note                                                                as бележка
from public.lessons l
join public.subjects s on s.id = l.subject_id
join public.profiles p on p.id = l.teacher_id
where l.starts_at >= ('2026-10-01'::timestamp at time zone 'Europe/Sofia')
  and l.starts_at <  ('2026-11-01'::timestamp at time zone 'Europe/Sofia')
order by l.starts_at;
