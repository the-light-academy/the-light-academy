-- =====================================================================
--  The Light Academy — редактиране на записан час
--  ---------------------------------------------------------------------
--  Какво прави: разделя едното правило върху lessons на четири — по
--  едно за четене, записване, редакция и триене. Таблицата не се пипа,
--  записаните часове не се пипат.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА.
--  ПРЕДИ ТОВА трябва веднъж да е минал supabase/schema-v10.sql.
--
--  ЗАЩО Е НУЖНО
--
--  Досега правилото беше едно, „for all“, и искаше при всяко писане
--  часът да е мой И аз да съм го записал. За вмъкване това е вярно:
--  никой не бива да записва час от чуждо име.
--
--  За РЕДАКЦИЯ обаче е твърде строго. Часовете, които админът е записал
--  за някой преподавател — както станa с октомври — носят неговото име
--  в „записал го е“. Преподавателят ги вижда, часовете са негови, но
--  при опит да ги поправи базата отказваше: „не си ти този, който ги е
--  записал“. Редакцията иска само едно условие — часът да е мой.
-- =====================================================================

drop policy if exists "lessons: own"       on public.lessons;
drop policy if exists "lessons: read own"  on public.lessons;
drop policy if exists "lessons: add own"   on public.lessons;
drop policy if exists "lessons: edit own"  on public.lessons;
drop policy if exists "lessons: drop own"  on public.lessons;

-- Чете своите.
create policy "lessons: read own" on public.lessons
  for select to authenticated
  using (teacher_id = auth.uid());

-- Записва само свои часове и само от свое име.
create policy "lessons: add own" on public.lessons
  for insert to authenticated
  with check (teacher_id = auth.uid() and created_by = auth.uid());

-- Поправя своите — и остават негови. Кой го е записал не се проверява:
-- важното е часът да е негов и преди, и след промяната.
create policy "lessons: edit own" on public.lessons
  for update to authenticated
  using (teacher_id = auth.uid())
  with check (teacher_id = auth.uid());

-- Трие своите.
create policy "lessons: drop own" on public.lessons
  for delete to authenticated
  using (teacher_id = auth.uid());

-- Правилото на админа остава, каквото си беше: всичко.
drop policy if exists "lessons: admin all" on public.lessons;
create policy "lessons: admin all" on public.lessons
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());


-- ---------------------------------------------------------------------
--  Потвърждение: трябва да са пет правила.
-- ---------------------------------------------------------------------
select count(*) as правила,
       string_agg(polname, ', ' order by polname) as кои
  from pg_policy
 where polrelid = 'public.lessons'::regclass;
