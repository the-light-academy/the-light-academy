-- =====================================================================
-- The Light Academy — НЯКОЛКО ПРЕПОДАВАТЕЛИ, ЕДИН АДМИН
--
-- Пусни този файл ЦЕЛИЯ и наведнъж: SQL Editor → New query → Run.
-- Всичко е в една транзакция — или минава изцяло, или не се променя нищо.
--
-- ⚠️  ВАЖНО: ако в редактора има МАРКИРАН текст, Supabase пуска само него,
--     а не целия файл. Натисни някъде в полето и Ctrl+A (Cmd+A на Mac),
--     за да си сигурна, че тръгва всичко. Файл, пуснат на парчета, дава
--     объркващи грешки от рода на „function public.teaches(uuid) does not
--     exist“ — функцията се създава в раздел 2, а се използва в раздел 5.
--
-- Очаква schema.sql и schema-v2.sql да са минали веднъж преди него.
-- Безопасен е за повторно пускане.
--
-- ---------------------------------------------------------------------
-- КАКВО ПРАВИ
--
-- Досега `is_teacher()` пазеше всяка политика в базата и отговаряше едно
-- и също за всички: преподавател виждаше всеки ученик, всеки резултат и
-- всяко задание. Това беше вярно, докато преподавателят беше един.
--
-- Оттук нататък:
--   * АДМИН (ти) — създаваш заданията, подреждаш календара, правиш
--     профили и виждаш всичко. Същевременно си и преподавател със свои
--     ученици и публикуваш за тях като всеки друг.
--   * ПРЕПОДАВАТЕЛ — вижда САМО своите ученици, оценява техните работи и
--     публикува/скрива задания за тях. Не създава задания, не пипа
--     календара, не прави профили, не вижда чужди ученици.
--   * УЧЕНИК — вижда задание само ако негов преподавател му го е дал.
--
-- Най-важната промяна е последната. Досега `published` беше един ключ за
-- цялата академия: щом един преподавател го вдигне, заданието се появява
-- при ВСИЧКИ ученици от този клас и предмет, включително при учениците на
-- друг преподавател, който още не е готов. Сега `published` значи само
-- „готово в библиотеката“, а даването на учениците е отделно и е на всеки
-- преподавател поотделно.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 0. Кой е админът
--
--    ЕДИНСТВЕНИЯТ ред, който може да се наложи да смениш, е следващият.
--    Това трябва да е имейлът, с който ТИ влизаш в платформата — не
--    непременно имейлът за контакти на сайта.
-- ---------------------------------------------------------------------

create table if not exists public._v3_admin (email text primary key);
truncate public._v3_admin;
insert into public._v3_admin (email) values
  ('the.light.academy56@gmail.com');          -- ← твоят имейл за вход


-- ---------------------------------------------------------------------
-- 1. Таблици
-- ---------------------------------------------------------------------

-- Админът е флаг, а не трета роля, защото ти си и двете: администратор на
-- академията И преподавател със свои ученици. Ако беше роля, щеше да се
-- наложи да избираш едното.
alter table public.profiles add column if not exists is_admin boolean not null default false;

-- Кой кого учи и по какво. Един ред = „Ани учи Иван по математика“.
-- Един преподавател има много ученици и много предмети; един ученик може
-- да има различен преподавател по различните предмети.
create table if not exists public.teaching (
  id          uuid primary key default gen_random_uuid(),
  teacher_id  uuid not null references public.profiles(id) on delete cascade,
  student_id  uuid not null references public.profiles(id) on delete cascade,
  subject_id  uuid not null references public.subjects(id) on delete cascade,
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  unique (teacher_id, student_id, subject_id)
);

create index if not exists teaching_teacher_idx on public.teaching(teacher_id) where active;
create index if not exists teaching_student_idx on public.teaching(student_id) where active;

-- Кой преподавател кое задание е дал на своите ученици.
-- Няма ред → никой негов ученик не вижда заданието.
-- Ред с hidden = true → дал го е и после го е скрил; редът остава, за да
-- се вижда, че го е имало, и за да се върне с едно кликване.
create table if not exists public.assignment_releases (
  id             uuid primary key default gen_random_uuid(),
  assignment_id  uuid not null references public.assignments(id) on delete cascade,
  teacher_id     uuid not null references public.profiles(id) on delete cascade,
  hidden         boolean not null default false,
  released_at    timestamptz not null default now(),
  unique (assignment_id, teacher_id)
);

create index if not exists releases_assignment_idx on public.assignment_releases(assignment_id);
create index if not exists releases_teacher_idx    on public.assignment_releases(teacher_id);


-- ---------------------------------------------------------------------
-- 2. Кой какво може — функциите, на които стъпват политиките
--
--    Всички са SECURITY DEFINER по две причини. Първата е същата като при
--    is_teacher(): функция, която чете profiles вътре в политика върху
--    profiles, иначе се извиква безкрайно. Втората е по-важна тук —
--    УЧЕНИК трябва да може да пита „дал ли ми е някой преподавател това
--    задание“, без да може да чете таблиците teaching и
--    assignment_releases. Функцията отговаря да/не и нищо повече.
-- ---------------------------------------------------------------------

create or replace function public.is_admin()
returns boolean
language sql stable
security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and is_admin and active
  );
$$;

-- Учи ли викащият този ученик — по кой да е предмет.
create or replace function public.teaches(student uuid)
returns boolean
language sql stable
security definer set search_path = public
as $$
  select exists (
    select 1 from public.teaching t
    where t.teacher_id = auth.uid() and t.student_id = student and t.active
  );
$$;

-- Същото, но по конкретен предмет.
create or replace function public.teaches_subject(student uuid, subject uuid)
returns boolean
language sql stable
security definer set search_path = public
as $$
  select exists (
    select 1 from public.teaching t
    where t.teacher_id = auth.uid() and t.student_id = student
      and t.subject_id = subject and t.active
  );
$$;

-- Цялото правило „вижда ли този човек това задание“, на едно място.
-- Админът вижда всичко. Преподавателят вижда каквото е готово в
-- библиотеката и пасва на някой негов ученик. Ученикът вижда само това,
-- което негов преподавател му е дал.
create or replace function public.can_see_assignment(uid uuid, a_id uuid)
returns boolean
language plpgsql stable
security definer set search_path = public
as $$
declare
  a public.assignments%rowtype;
  viewer public.profiles%rowtype;
  g int;
begin
  select * into a from public.assignments where id = a_id;
  if not found then return false; end if;

  select * into viewer from public.profiles where id = uid;
  if not found or not viewer.active then return false; end if;

  -- админ: всичко, включително недовършените чернови
  if viewer.is_admin then return true; end if;

  -- преподавател: готовото в библиотеката, което пасва на негов ученик
  if viewer.role = 'teacher' then
    return a.published and exists (
      select 1
        from public.teaching t
       where t.teacher_id = uid
         and t.active
         and (a.subject_id is null or t.subject_id = a.subject_id)
         and (a.grades is null or public.current_grade(t.student_id) = any(a.grades))
    );
  end if;

  -- ученик: същите три условия както досега…
  g := public.current_grade(uid);
  if not a.published then return false; end if;
  if g is null or g < -1 or g > 12 then return false; end if;
  if a.grades is not null and not (g = any(a.grades)) then return false; end if;
  if a.subject_id is not null and not exists (
       select 1 from public.enrollments e
        where e.profile_id = uid and e.subject_id = a.subject_id and e.active
     ) then
    return false;
  end if;

  -- …плюс новото: негов преподавател да му го е дал и да не го е скрил
  return exists (
    select 1
      from public.teaching t
      join public.assignment_releases r
        on r.assignment_id = a.id
       and r.teacher_id = t.teacher_id
     where t.student_id = uid
       and t.active
       and (a.subject_id is null or t.subject_id = a.subject_id)
       and not r.hidden
  );
end;
$$;

-- За портала: кой ми преподава и по какво. Връща само имена, за да не се
-- налага ученикът да има право да чете чужди профили.
create or replace function public.my_teachers()
returns table (teacher_id uuid, full_name text, subject_name text)
language sql stable
security definer set search_path = public
as $$
  select p.id, p.full_name, s.name
    from public.teaching t
    join public.profiles p on p.id = t.teacher_id
    join public.subjects s on s.id = t.subject_id
   where t.student_id = auth.uid() and t.active and p.active
   order by s.sort_order, p.full_name;
$$;

revoke all on function public.is_admin()                      from public, anon;
revoke all on function public.teaches(uuid)                   from public, anon;
revoke all on function public.teaches_subject(uuid, uuid)     from public, anon;
revoke all on function public.can_see_assignment(uuid, uuid)  from public, anon;
revoke all on function public.my_teachers()                   from public, anon;

grant execute on function public.is_admin()                     to authenticated;
grant execute on function public.teaches(uuid)                  to authenticated;
grant execute on function public.teaches_subject(uuid, uuid)    to authenticated;
grant execute on function public.can_see_assignment(uuid, uuid) to authenticated;
grant execute on function public.my_teachers()                  to authenticated;


-- ---------------------------------------------------------------------
-- 3. Задаване на клас — вече не всеки преподавател на всеки ученик
-- ---------------------------------------------------------------------

create or replace function public.set_student_grade(student uuid, new_grade int)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  if not (public.is_admin() or public.teaches(student)) then
    raise exception 'Клас се задава от админа или от преподавателя на този ученик.';
  end if;
  if new_grade is null or new_grade < -1 or new_grade > 12 then
    raise exception 'Класът трябва да е между -1 и 12.';
  end if;

  update public.profiles
     set grade_at_entry    = new_grade,
         entry_school_year = public.current_school_year(),
         grade_set_at      = now()
   where id = student;
end;
$$;

revoke all on function public.set_student_grade(uuid, int) from public, anon;
grant execute on function public.set_student_grade(uuid, int) to authenticated;


-- #####################################################################
-- #  4. ПРЕНАСЯНЕ НА СЪЩЕСТВУВАЩИТЕ ДАННИ
-- #
-- #  Този раздел ПИПА данни и стои НАРОЧНО преди новите политики.
-- #  Ако политиките се сложат първи, всеки портал на сайта ще осъмне
-- #  празен: ученик без преподавател не вижда нищо, а в момента никой
-- #  ученик няма записан преподавател.
-- #####################################################################

do $$
declare
  admin_email text;
  admin_id    uuid;
  n_teach     int;
  n_rel       int;
begin
  select email into admin_email from public._v3_admin limit 1;

  select u.id into admin_id
    from auth.users u
   where lower(u.email) = lower(admin_email);

  if admin_id is null then
    raise exception
      'Няма потребител с имейл "%". Оправи реда в раздел 0 и пусни файла отново — нищо не е променено.',
      admin_email;
  end if;

  -- ти ставаш админ и оставаш преподавател
  update public.profiles
     set is_admin = true, role = 'teacher', active = true
   where id = admin_id;

  -- всеки съществуващ ученик става твой ученик по всеки предмет, в който
  -- е записан — за да не изчезне нищо от това, което вече работи
  insert into public.teaching (teacher_id, student_id, subject_id)
  select admin_id, e.profile_id, e.subject_id
    from public.enrollments e
    join public.profiles p on p.id = e.profile_id
   where p.role = 'student' and e.active
  on conflict (teacher_id, student_id, subject_id) do nothing;
  get diagnostics n_teach = row_count;

  -- всяко вече публикувано задание се брои за дадено от теб, иначе то би
  -- изчезнало от портала на учениците ти в мига, в който минат политиките
  insert into public.assignment_releases (assignment_id, teacher_id)
  select a.id, admin_id
    from public.assignments a
   where a.published
  on conflict (assignment_id, teacher_id) do nothing;
  get diagnostics n_rel = row_count;

  raise notice 'Админ: %. Нови връзки преподавател–ученик: %. Пренесени публикации: %.',
    admin_email, n_teach, n_rel;
end $$;


-- ---------------------------------------------------------------------
-- 5. Политиките
--
--    Първо се уверяваме, че четирите функции от раздел 2 наистина ги има.
--    Ако файлът е пуснат на парчета, оттук нататък грешките са неразбираеми
--    („function public.teaches(uuid) does not exist“), затова казваме право
--    какво се е случило.
-- ---------------------------------------------------------------------

do $$
declare
  missing text;
begin
  select string_agg(want, ', ')
    into missing
    from (values ('is_admin()'), ('teaches(uuid)'), ('teaches_subject(uuid,uuid)'),
                 ('can_see_assignment(uuid,uuid)'), ('my_teachers()')) as v(want)
   where to_regprocedure('public.' || want) is null;

  if missing is not null then
    raise exception
      'Липсват функции: %. Това значи, че файлът е пуснат на парчета. Маркирай всичко (Ctrl+A) и пусни schema-v3.sql целия — нищо не е променено.',
      missing;
  end if;
end $$;



alter table public.teaching            enable row level security;
alter table public.assignment_releases enable row level security;

grant select, insert, update, delete on public.teaching            to authenticated;
grant select, insert, update, delete on public.assignment_releases to authenticated;

-- profiles ------------------------------------------------------------
-- Досега „profiles: teacher writes“ беше for all с using(is_teacher()).
-- С един преподавател това нямаше значение. С двама значи, че всеки
-- преподавател може да си вдигне ролята или да пипне чужд профил.
drop policy if exists "profiles: read own"          on public.profiles;
drop policy if exists "profiles: teacher reads"     on public.profiles;
drop policy if exists "profiles: teacher writes"    on public.profiles;
drop policy if exists "profiles: admin all"         on public.profiles;
drop policy if exists "profiles: teacher reads own students" on public.profiles;

create policy "profiles: read own"
  on public.profiles for select
  using (id = auth.uid());

create policy "profiles: teacher reads own students"
  on public.profiles for select
  using (public.teaches(id));

create policy "profiles: admin all"
  on public.profiles for all
  using (public.is_admin())
  with check (public.is_admin());

-- teaching ------------------------------------------------------------
drop policy if exists "teaching: admin all"      on public.teaching;
drop policy if exists "teaching: teacher reads"  on public.teaching;
drop policy if exists "teaching: student reads"  on public.teaching;

create policy "teaching: admin all"
  on public.teaching for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "teaching: teacher reads"
  on public.teaching for select
  using (teacher_id = auth.uid());

create policy "teaching: student reads"
  on public.teaching for select
  using (student_id = auth.uid());

-- assignment_releases -------------------------------------------------
-- Преподавателят е пълен стопанин на СВОИТЕ редове и няма никакъв достъп
-- до чуждите. with check пази и от подменен teacher_id при запис.
drop policy if exists "releases: admin all"   on public.assignment_releases;
drop policy if exists "releases: teacher own" on public.assignment_releases;

create policy "releases: admin all"
  on public.assignment_releases for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "releases: teacher own"
  on public.assignment_releases for all
  using (teacher_id = auth.uid())
  with check (
    teacher_id = auth.uid()
    and public.can_see_assignment(auth.uid(), assignment_id)
  );

-- subjects / enrollments ----------------------------------------------
drop policy if exists "subjects: teacher all"    on public.subjects;
drop policy if exists "subjects: admin all"      on public.subjects;
drop policy if exists "enrollments: teacher all" on public.enrollments;
drop policy if exists "enrollments: admin all"   on public.enrollments;
drop policy if exists "enrollments: teacher reads" on public.enrollments;

create policy "subjects: admin all"
  on public.subjects for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "enrollments: admin all"
  on public.enrollments for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "enrollments: teacher reads"
  on public.enrollments for select
  using (public.teaches(profile_id));

-- assignments ---------------------------------------------------------
-- Създаването и редактирането е само на админа: преподавателят избира
-- КОГА да даде нещо, а не КАКВО да има.
drop policy if exists "assignments: read published" on public.assignments;
drop policy if exists "assignments: read for grade" on public.assignments;
drop policy if exists "assignments: teacher all"    on public.assignments;
drop policy if exists "assignments: admin all"      on public.assignments;
drop policy if exists "assignments: read visible"   on public.assignments;

create policy "assignments: read visible"
  on public.assignments for select
  using (public.can_see_assignment(auth.uid(), id));

create policy "assignments: admin all"
  on public.assignments for all
  using (public.is_admin())
  with check (public.is_admin());

-- attempts ------------------------------------------------------------
drop policy if exists "attempts: read own"           on public.attempts;
drop policy if exists "attempts: insert own"         on public.attempts;
drop policy if exists "attempts: teacher reads"      on public.attempts;
drop policy if exists "attempts: teacher grades"     on public.attempts;
drop policy if exists "attempts: teacher deletes"    on public.attempts;
drop policy if exists "attempts: admin all"          on public.attempts;
drop policy if exists "attempts: teacher own students" on public.attempts;

create policy "attempts: read own"
  on public.attempts for select
  using (user_id = auth.uid());

-- Досега условието беше „заданието е публикувано“. Сега е „ученикът
-- изобщо може да види това задание“ — иначе някой би могъл да предаде
-- работа по лист, който не му е даван.
create policy "attempts: insert own"
  on public.attempts for insert
  with check (
    user_id = auth.uid()
    and public.can_see_assignment(auth.uid(), assignment_id)
  );

create policy "attempts: teacher own students"
  on public.attempts for select
  using (public.teaches(user_id));

create policy "attempts: teacher grades"
  on public.attempts for update
  using (public.teaches(user_id))
  with check (public.teaches(user_id));

create policy "attempts: admin all"
  on public.attempts for all
  using (public.is_admin())
  with check (public.is_admin());

-- Нарочно няма изтриване за преподавател: предадена работа е документ.
-- Само админът може да махне опит, през „attempts: admin all“.


-- ---------------------------------------------------------------------
-- 6. Новият потребител вече може да е и преподавател
--    Ролята пак НЕ се чете от метаданните на потребителя — това би
--    позволило на всеки сам да си поиска 'teacher', ако някога включиш
--    публичната регистрация. Преподавател се прави само от Edge
--    функцията admin-users, която първо проверява, че викащият е админ.
-- ---------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  g int;
begin
  begin
    g := nullif(new.raw_user_meta_data->>'grade', '')::int;
  exception when others then
    g := null;
  end;
  if g is not null and (g < -1 or g > 12) then
    g := null;
  end if;

  insert into public.profiles (id, full_name, role,
                               grade_at_entry, entry_school_year, grade_set_at)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    'student',
    g,
    case when g is not null then public.current_school_year() end,
    case when g is not null then now() end
  )
  on conflict (id) do nothing;

  insert into public.enrollments (profile_id, subject_id)
  select new.id, s.id from public.subjects s where s.active and s.auto_enroll
  on conflict (profile_id, subject_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


drop table if exists public._v3_admin;

commit;


-- ---------------------------------------------------------------------
-- 7. След като файлът мине
--
--    Провери, че си админ — това трябва да върне true, докато си влязла:
--      select public.is_admin();
--
--    Виж какво се получи:
--      select p.full_name as ученик, t2.full_name as преподавател, s.name as предмет
--        from public.teaching t
--        join public.profiles p  on p.id  = t.student_id
--        join public.profiles t2 on t2.id = t.teacher_id
--        join public.subjects s  on s.id  = t.subject_id
--       order by 2, 1;
--
--    Ученици без преподавател (тези не виждат нищо):
--      select full_name from public.profiles p
--       where p.role = 'student' and p.active
--         and not exists (select 1 from public.teaching t
--                          where t.student_id = p.id and t.active);
--
--    Преподавател се прави от таблото → Преподаватели → Добавяне.
--    За това трябва Edge функцията да е преразгърната:
--      supabase functions deploy admin-users
-- ---------------------------------------------------------------------


-- ---------------------------------------------------------------------
-- 8. АКО НЕЩО СЕ ОБЪРКА — връщане на старите правила
--
--    Махни минусите отпред и пусни САМО този блок. Той връща достъпа
--    „всеки преподавател вижда всичко“, тоест поведението отпреди този
--    файл. Таблиците teaching и assignment_releases остават, но вече не
--    решават нищо, така че нищо не се губи и файлът може да се пусне
--    отново, след като проблемът е намерен.
-- ---------------------------------------------------------------------
--
-- begin;
-- drop policy if exists "assignments: read visible" on public.assignments;
-- create policy "assignments: read for grade" on public.assignments for select
--   using (public.is_teacher() or (
--     published
--     and public.current_grade(auth.uid()) between -1 and 12
--     and (grades is null or public.current_grade(auth.uid()) = any(grades))
--     and (subject_id is null or exists (
--           select 1 from public.enrollments e
--            where e.profile_id = auth.uid() and e.subject_id = assignments.subject_id and e.active))));
-- create policy "assignments: teacher all" on public.assignments for all
--   using (public.is_teacher()) with check (public.is_teacher());
-- drop policy if exists "attempts: insert own" on public.attempts;
-- create policy "attempts: insert own" on public.attempts for insert
--   with check (user_id = auth.uid() and exists (
--     select 1 from public.assignments a where a.id = assignment_id and a.published));
-- drop policy if exists "attempts: teacher own students" on public.attempts;
-- create policy "attempts: teacher reads" on public.attempts for select
--   using (public.is_teacher());
-- drop policy if exists "attempts: teacher grades" on public.attempts;
-- create policy "attempts: teacher grades" on public.attempts for update
--   using (public.is_teacher()) with check (public.is_teacher());
-- create policy "attempts: teacher deletes" on public.attempts for delete
--   using (public.is_teacher());
-- drop policy if exists "profiles: teacher reads own students" on public.profiles;
-- create policy "profiles: teacher reads" on public.profiles for select
--   using (public.is_teacher());
-- create policy "profiles: teacher writes" on public.profiles for all
--   using (public.is_teacher()) with check (public.is_teacher());
-- commit;
