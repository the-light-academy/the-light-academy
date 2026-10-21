-- =====================================================================
--  Пробните теми по състезания — отваряне за учениците (4. клас)
--  ---------------------------------------------------------------------
--  ЗАЩО Е НУЖЕН ТОЗИ ФАЙЛ
--
--  supabase/probni-v-razdel.sql (и краят на assignments.sql) въвежда
--  темите като ЧЕРНОВИ: published = false. Черновата не се вижда от
--  ученик — затова разделът „Пробни изпити“ стоеше празен, въпреки че
--  темите си стоят на сървъра. Досега това се оправяше на ръка от
--  таблото: „Сложи в библиотеката“, после „Дай на моите“.
--
--  Този файл го прави наведнъж за всички теми по състезания:
--    1. пуска ги в библиотеката (published = true);
--    2. дава ги на всеки преподавател, който води „Състезателна
--       математика“ — това е второто условие в can_see_assignment().
--
--  СТРАНИЦИТЕ СЕ ВИЖДАТ И БЕЗ ТОЗИ ФАЙЛ. От 21 октомври 2026 г.
--  порталът показва готовите теми направо от сайта (assets/probni.js).
--  Този файл е за другото: за да СЕ ЗАПИСВА резултатът в профила на
--  детето. Без ред в базата няма къде да отиде опитът.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА. Нищо не се трие и не се
--  дублира; скрита тема се връща обратно на видимо.
--
--  ПРЕДИ ТОВА трябва веднъж да са минали:
--    · supabase/subjects.sql
--    · supabase/schema-v8.sql        (колоните track и section)
--    · supabase/probni-v-razdel.sql  (самите теми)
-- =====================================================================

-- 1. В библиотеката -----------------------------------------------------
update public.assignments
   set published = true
 where slug in ('sal-2025-4', 'sal-2024-4', 'probna-obshtinski-2018-4',
                'probna-obshtinski-2020-4', 'probna-obshtinski-2023-4')
   and published is distinct from true;


-- 2. На всеки преподавател по състезателна математика -------------------
--    Редът в assignment_releases е „този преподавател е дал това на
--    своите“. Без него ученикът не вижда нищо, колкото и да е пуснато.
insert into public.assignment_releases (assignment_id, teacher_id)
select a.id, t.teacher_id
  from public.assignments a
  join public.teaching t
    on t.subject_id = a.subject_id
   and t.active
 where a.slug in ('sal-2025-4', 'sal-2024-4', 'probna-obshtinski-2018-4',
                  'probna-obshtinski-2020-4', 'probna-obshtinski-2023-4')
 group by a.id, t.teacher_id
    on conflict (assignment_id, teacher_id)
    do update set hidden = false;


-- 3. Какво се вижда сега ------------------------------------------------
--    Ред по ред: всеки четвъртокласник срещу всяка тема. „да“ значи, че
--    детето ще я види в раздел „Пробни изпити“ с бутон, който записва
--    резултата. „не“ почти винаги значи едно от двете: детето не е
--    записано по предмета, или няма преподавател по него.
select p.full_name                                   as uchenik,
       a.title                                       as tema,
       case when public.can_see_assignment(p.id, a.id) then 'да' else 'не' end as vijda_li_q,
       case when exists (select 1 from public.enrollments e
                          where e.profile_id = p.id
                            and e.subject_id = a.subject_id
                            and e.active) then 'да' else 'не' end as zapisan_po_predmeta,
       case when exists (select 1 from public.teaching t
                          where t.student_id = p.id
                            and t.subject_id = a.subject_id
                            and t.active) then 'да' else 'не' end as ima_prepodavatel
  from public.profiles p
  cross join public.assignments a
 where a.slug in ('sal-2025-4', 'sal-2024-4', 'probna-obshtinski-2018-4',
                  'probna-obshtinski-2020-4', 'probna-obshtinski-2023-4')
   and p.role = 'student'
   and p.active
   and public.current_grade(p.id) = 4
 order by p.full_name, a.title;
