-- =====================================================================
--  Има ли този преподавател ученици — и какво ще отнесе изтриването му
--  ---------------------------------------------------------------------
--  Пусни ЦЕЛИЯ файл в SQL редактора на Supabase. Нищо не променя — само
--  гледа. Смени името най-горе и толкова.
--
--  Показва три неща:
--    1. Кого е намерил по това име (може да е повече от един!).
--    2. Колко ученици, часове, листа и обратни връзки виси на него.
--    3. Присъда: може ли да се трие и какво ще се влачи след него.
--
--  Истинското изтриване е в ОТДЕЛЕН файл: supabase/iztrij-prepodavatel.sql
--  Той сам отказва да тръгне, ако тук излезе, че има ученици.
-- =====================================================================

--  ⬇⬇⬇  ТУК СЕ СМЕНЯ ИМЕТО  ⬇⬇⬇  (стига и част от него)
with pitane as (
  select 'Лили' as ime
),

namereni as (
  select p.*
    from public.profiles p, pitane q
   where p.full_name ilike '%' || q.ime || '%'
),

broevki as (
  select
    n.id,
    n.full_name,
    n.role,
    n.active,
    coalesce(n.is_admin, false) as is_admin,
    (select count(*) from public.teaching t
      where t.teacher_id = n.id)                       as uchenici_vsichko,
    (select count(*) from public.teaching t
      where t.teacher_id = n.id and t.active)          as uchenici_aktivni,
    (select count(distinct t.subject_id) from public.teaching t
      where t.teacher_id = n.id)                       as predmeti_s_deca,
    (select count(*) from public.teacher_subjects ts
      where ts.teacher_id = n.id)                      as predmeti_zapisani,
    (select count(*) from public.lessons l
      where l.teacher_id = n.id or l.created_by = n.id) as chasove,
    (select count(*) from public.assignment_releases r
      where r.teacher_id = n.id)                       as dadeni_listove,
    (select count(*) from public.feedback_reports f
      where f.teacher_id = n.id)                       as obratni_vruzki
  from namereni n
)

select
  full_name                                            as "име",
  role                                                 as "роля",
  case when active then 'да' else 'не' end             as "активен",
  case when is_admin then '⚠ ДА' else 'не' end         as "администратор",
  uchenici_aktivni                                     as "ученици сега",
  uchenici_vsichko                                     as "ученици някога",
  predmeti_zapisani                                    as "предмети",
  chasove                                              as "часове",
  dadeni_listove                                       as "дадени листа",
  obratni_vruzki                                       as "обратни връзки",
  case
    when role <> 'teacher'
      then '⛔ това не е преподавател — не го трий с този файл'
    when is_admin
      then '⛔ това е администратор — не се трие автоматично'
    when uchenici_vsichko > 0
      then '🚫 ИМА ученици — НЕ трий. Първо ги прехвърли на друг преподавател.'
    when chasove > 0
      then '⚠ няма ученици, но има ' || chasove || ' часа в календара. '
           || 'Изтриването ще откаже, докато часовете стоят.'
    else '✅ няма ученици — може да се изтрие'
  end                                                  as "присъда",
  id                                                   as "номер в базата"
from broevki
order by full_name;


-- ---------------------------------------------------------------------
--  Ако горното е празно: няма такъв човек. Тази справка показва всички
--  преподаватели, за да се види как точно е записано името.
-- ---------------------------------------------------------------------
select p.full_name                                     as "всички преподаватели",
       case when p.active then 'активен' else 'спрян' end as "състояние",
       (select count(*) from public.teaching t
         where t.teacher_id = p.id and t.active)       as "ученици сега"
  from public.profiles p
 where p.role = 'teacher'
 order by p.full_name;


-- ---------------------------------------------------------------------
--  Кои са учениците му — ако има. Показва ги поименно, за да се знае
--  кого трябва да поемеш, преди да изтриеш преподавателя.
-- ---------------------------------------------------------------------
with pitane as (
  select 'Лили' as ime
)
select u.full_name                                     as "ученик",
       s.name                                          as "предмет",
       case when t.active then 'активна връзка' else 'спряна' end as "връзка",
       p.full_name                                     as "преподавател"
  from public.teaching t
  join public.profiles p on p.id = t.teacher_id
  join public.profiles u on u.id = t.student_id
  left join public.subjects s on s.id = t.subject_id
  , pitane q
 where p.full_name ilike '%' || q.ime || '%'
 order by u.full_name, s.name;
