-- =====================================================================
--  Защо един лист не се вижда от едно дете
--  ---------------------------------------------------------------------
--  Пусни ЦЕЛИЯ файл в SQL редактора на Supabase. Нищо не променя — само
--  гледа. Казва за всеки лист кое от шестте условия не е изпълнено.
--
--  ЗА ДА ВИДИ ДЕТЕТО ЕДИН ЛИСТ, ТРЯБВАТ ШЕСТ НЕЩА ЕДНОВРЕМЕННО:
--
--    1. Профилът му е активен.
--    2. Листът е ПУБЛИКУВАН („Сложи в библиотеката“).
--    3. Класът на листа съвпада с класа, в който детето е СЕГА.
--    4. Детето е ЗАПИСАНО по предмета (Ученици → колоната „Предмети“).
--    5. Има негов ПРЕПОДАВАТЕЛ по ТОЗИ предмет (Ученици → преподавател).
--    6. СЪЩИЯТ преподавател му е дал листа („Дай на моите“) и не го е
--       скрил.
--
--  Най-честата засечка е между 5 и 6: „Дай на моите“ закача листа за
--  ТОЗИ, който е натиснал бутона. Ако детето няма него за преподавател
--  ПО ТОЗИ ПРЕДМЕТ, листът не стига до него, колкото и пъти да се
--  натисне бутонът.
--
--  Втората по честота е 4: по английски никой не се записва автоматично
--  (auto_enroll е изключено), затова записването се прави на ръка.
-- =====================================================================

--  ⬇⬇⬇  ТУК СЕ СМЕНЯТ ДВЕТЕ НЕЩА  ⬇⬇⬇
--  Име на детето (стига и част от него) и предмет (част от името му).
with pitane as (
  select 'Калина'   as dete,
         'нглийск'  as predmet
),

--  Детето, за което питаме.
uchenik as (
  select p.*
    from public.profiles p, pitane q
   where p.role = 'student'
     and p.full_name ilike '%' || q.dete || '%'
),

--  Предметът, за който питаме.
predmet as (
  select s.*
    from public.subjects s, pitane q
   where s.name ilike '%' || q.predmet || '%'
      or s.slug ilike '%' || q.predmet || '%'
),

--  Листовете по този предмет, които изобщо биха могли да го засягат.
listove as (
  select a.*
    from public.assignments a
    join predmet s on s.id = a.subject_id
)

select
  a.slug,
  a.title,

  --  1 ──────────────────────────────────────────────────────────────
  case when u.active then '✅' else '❌ профилът е спрян' end
    as "1·профил",

  --  2 ──────────────────────────────────────────────────────────────
  case when a.published then '✅'
       else '❌ още е чернова — „Сложи в библиотеката“' end
    as "2·публикуван",

  --  3 ──────────────────────────────────────────────────────────────
  case when a.grades is null then '✅ за всички'
       when public.current_grade(u.id) = any(a.grades) then
            '✅ ' || public.current_grade(u.id) || '. клас'
       else '❌ листът е за ' || array_to_string(a.grades, ', ')
            || '. клас, а детето е в '
            || coalesce(public.current_grade(u.id)::text, '?') || '.' end
    as "3·клас",

  --  4 ──────────────────────────────────────────────────────────────
  case when exists (select 1 from public.enrollments e
                     where e.profile_id = u.id
                       and e.subject_id = a.subject_id and e.active)
       then '✅'
       else '❌ не е записано по предмета' end
    as "4·записан",

  --  5 ──────────────────────────────────────────────────────────────
  case when exists (select 1 from public.teaching t
                     where t.student_id = u.id
                       and t.subject_id = a.subject_id and t.active)
       then '✅ ' || coalesce((select string_agg(pp.full_name, ', ')
                                 from public.teaching t
                                 join public.profiles pp on pp.id = t.teacher_id
                                where t.student_id = u.id
                                  and t.subject_id = a.subject_id and t.active), '')
       else '❌ няма преподавател по този предмет' end
    as "5·преподавател",

  --  6 ──────────────────────────────────────────────────────────────
  case when exists (select 1
                      from public.teaching t
                      join public.assignment_releases r
                        on r.assignment_id = a.id and r.teacher_id = t.teacher_id
                     where t.student_id = u.id and t.active
                       and t.subject_id = a.subject_id
                       and not r.hidden)
       then '✅ даден'
       when exists (select 1 from public.assignment_releases r
                     where r.assignment_id = a.id and r.hidden)
       then '❌ даден, но СКРИТ'
       when exists (select 1 from public.assignment_releases r
                     where r.assignment_id = a.id)
       then '❌ дал го е ' ||
            coalesce(nullif((select string_agg(coalesce(nullif(pp.full_name, ''),
                                                        '(без име)'), ', ')
                               from public.assignment_releases r
                               join public.profiles pp on pp.id = r.teacher_id
                              where r.assignment_id = a.id), ''), '(без име)')
            || ', но тя/той не е преподавател на детето по този предмет'
       else '❌ никой не го е дал' end
    as "6·даден",

  --  Заключението на машината, не на окото.
  case when public.can_see_assignment(u.id, a.id)
       then '👍 ВИЖДА ГО'
       else '🚫 не го вижда' end
    as "резултат",

  --  Първото, което трябва да се оправи — с думи, а не с кръстче.
  case when public.can_see_assignment(u.id, a.id) then ''
       when not u.active
         then 'Включи профила на детето.'
       when not a.published
         then 'Натисни „Сложи в библиотеката“ — листът още е чернова.'
       when a.grades is not null
            and (public.current_grade(u.id) is null
                 or not (public.current_grade(u.id) = any(a.grades)))
         then 'Провери класа на детето в „Ученици“ — листът е за друг клас.'
       when not exists (select 1 from public.enrollments e
                         where e.profile_id = u.id
                           and e.subject_id = a.subject_id and e.active)
         then 'Запиши детето по предмета: Ученици → колоната „Предмети“.'
       when not exists (select 1 from public.teaching t
                         where t.student_id = u.id
                           and t.subject_id = a.subject_id and t.active)
         then 'Дай на детето преподавател ПО ТОЗИ ПРЕДМЕТ: Ученици → „Преподавател“.'
       when exists (select 1 from public.teaching t
                      join public.assignment_releases r
                        on r.assignment_id = a.id and r.teacher_id = t.teacher_id
                     where t.student_id = u.id and t.active
                       and t.subject_id = a.subject_id and r.hidden)
         then 'Листът е скрит — натисни пак „Дай на моите“.'
       else 'Натисни „Дай на моите“ от профила на НЕЙНИЯ преподавател по този предмет.'
       end
    as "какво да направя"

from listove a
cross join uchenik u
order by a.sort_order, a.slug;


-- ---------------------------------------------------------------------
--  Ако горната таблица е празна, значи не е намерено детето или
--  предметът. Тази справка казва кое от двете.
-- ---------------------------------------------------------------------
with pitane as (
  select 'Калина'   as dete,
         'нглийск'  as predmet
)
select
  (select count(*) from public.profiles p, pitane q
    where p.role = 'student' and p.full_name ilike '%' || q.dete || '%')
    as "намерени деца",
  (select string_agg(p.full_name, ', ') from public.profiles p, pitane q
    where p.role = 'student' and p.full_name ilike '%' || q.dete || '%')
    as "кои",
  (select count(*) from public.subjects s, pitane q
    where s.name ilike '%' || q.predmet || '%' or s.slug ilike '%' || q.predmet || '%')
    as "намерени предмети",
  (select string_agg(s.name, ', ') from public.subjects s, pitane q
    where s.name ilike '%' || q.predmet || '%' or s.slug ilike '%' || q.predmet || '%')
    as "кои предмети";
