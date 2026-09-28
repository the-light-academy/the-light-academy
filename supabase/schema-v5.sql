-- =====================================================================
--  The Light Academy — състезанието и за учениците
--  ---------------------------------------------------------------------
--  ПУСНИ ЦЕЛИЯ ФАЙЛ. Редакторът на Supabase изпълнява само маркираното,
--  ако има маркирано — файл, пуснат на парчета, оставя базата наполовина.
--
--  Какво прави: една-единствена функция, с която ученикът вижда
--  класирането на своята група — същият клас, същият предмет, същият
--  преподавател. Нищо не се създава и нищо не се пипа: няма нова
--  таблица, няма нова политика, няма промяна по съществуващите.
--
--  ЗАЩО ИЗОБЩО ТРЯБВА ФУНКЦИЯ
--
--  Ученикът днес не вижда чужди редове — нито в `profiles`, нито в
--  `attempts`. Това е правилно и остава така. Но класиране без
--  съучениците не е класиране. Вместо да се разхлабват политиките (с
--  което ученикът би могъл да чете чужди работи изобщо), тук стои
--  SECURITY DEFINER функция, която отдава точно четири неща за всеки
--  съученик: име, точки, възможни точки и дали това съм аз. Нищо
--  друго — без имейли, без дати, без бележки от преподавателя.
--
--  КОЙ КОГО ВИЖДА
--
--  Функцията се хваща за `auth.uid()` — този, който я вика. Оттам
--  намира групите, в които ТОЙ учи, и връща само тях. Чужда група не
--  може да се поиска: функцията не приема параметър. Преподавател,
--  който я извика, получава нула реда — той си има таблото.
--
--  ЕДНО НЕЩО, КОЕТО ТРЯБВА ДА СЕ ЗНАЕ
--
--  След този файл всяко дете в групата вижда имената и точките на
--  съучениците си. Точно това е смисълът на класирането — но е
--  решение, а не подробност. Ако някой ден не го искаш, отдолу пише
--  как се маха с един ред.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
--  Класирането на моите групи
-- ---------------------------------------------------------------------
--  Сметката тук ТРЯБВА да съвпада ред по ред с тази в таблото на
--  преподавателя (assets/race.js). Ако се разминат, детето и
--  преподавателят ще гледат различни числа за едно и също нещо:
--
--    * броят се само предадените работи (`status <> 'in_progress'`);
--    * по публикувани задания на този предмет и общите без предмет;
--    * възможните точки са тези на самата работа, а ако ги няма —
--      тези на заданието.
-- ---------------------------------------------------------------------
create or replace function public.my_race()
returns table (
  subject_id   uuid,
  subject_name text,
  teacher_id   uuid,
  teacher_name text,
  grade        int,
  student_name text,
  points       numeric,
  max_points   numeric,
  is_me        boolean
)
language sql
stable
security definer
set search_path = public
as $$
  with me as (
    select auth.uid() as id
  ),
  my_grade as (
    select public.current_grade((select id from me)) as g
  ),
  -- групите, в които аз уча: предмет + преподавател
  mine as (
    select distinct t.subject_id, t.teacher_id
    from public.teaching t
    where t.student_id = (select id from me)
      and t.active
  ),
  -- съучениците в тези групи — същият клас като моя
  peers as (
    select m.subject_id, m.teacher_id, p.id as student_id, p.full_name
    from mine m
    join public.teaching t
      on t.subject_id = m.subject_id
     and t.teacher_id = m.teacher_id
     and t.active
    join public.profiles p
      on p.id = t.student_id
     and p.role = 'student'
     and p.active
    where (select g from my_grade) is not null
      and public.current_grade(p.id) = (select g from my_grade)
  ),
  -- Работите се филтрират ВЪТРЕ в подзаявката. Ако условието за
  -- заданието стоеше в left join-а отвън, работа по чужд предмет щеше
  -- да остане с празно задание, но точките ѝ пак щяха да се съберат.
  work as (
    select at.user_id,
           a.subject_id,
           at.total_score,
           coalesce(
             nullif(coalesce(at.auto_max, 0) + coalesce(at.manual_max, 0), 0),
             a.max_points, 0) as cap
    from public.attempts at
    join public.assignments a on a.id = at.assignment_id
    where at.status <> 'in_progress'
      and a.published
  ),
  scored as (
    select pe.subject_id, pe.teacher_id, pe.student_id, pe.full_name,
           coalesce(sum(w.total_score), 0) as points,
           coalesce(sum(w.cap), 0)         as max_points
    from peers pe
    left join work w
      on w.user_id = pe.student_id
     and (w.subject_id is null or w.subject_id = pe.subject_id)
    group by 1, 2, 3, 4
  )
  select s.subject_id,
         sub.name,
         s.teacher_id,
         tp.full_name,
         (select g from my_grade),
         s.full_name,
         s.points,
         s.max_points,
         s.student_id = (select id from me)
  from scored s
  join public.subjects sub on sub.id = s.subject_id
  join public.profiles tp  on tp.id  = s.teacher_id
  order by s.points desc, s.full_name;
$$;

grant execute on function public.my_race() to authenticated;

commit;

-- ---------------------------------------------------------------------
-- Ако трябва да се махне (учениците спират да виждат класирането,
-- таблото на преподавателя остава непокътнато):
--   drop function if exists public.my_race();
-- ---------------------------------------------------------------------

-- Потвърждение, че е минало. Не raise notice: SQL Editor-ът на Supabase
-- показва само таблици с резултат.
select 'Готово' as статус,
       (select count(*) from pg_proc p
          join pg_namespace n on n.oid = p.pronamespace
         where n.nspname = 'public' and p.proname = 'my_race') as функцията,
       has_function_privilege('authenticated', 'public.my_race()', 'execute')
         as учениците_могат;
