-- =====================================================================
--  The Light Academy — Английски като предмет, кой какво преподава,
--  и общ поглед върху часовете
--  ---------------------------------------------------------------------
--  ПУСНИ ЦЕЛИЯ ФАЙЛ. Редакторът на Supabase изпълнява само маркираното,
--  ако има маркирано — файл, пуснат на парчета, оставя базата наполовина.
--
--  Три неща:
--
--  1. Нов предмет „Английски“. Никой не се записва в него автоматично —
--     записваш го от таблото, ученик по ученик.
--
--  2. Нова таблица teacher_subjects: кой преподавател по какво
--     преподава. Досега това се подразбираше от teaching — таблицата
--     „кой кого учи по какво“. Но тя иска УЧЕНИК, а часовете в
--     календара се пишат на свободно име на дете, което още не е в
--     платформата. Затова „Валя преподава английски“ нямаше къде да се
--     запише, докато Валя няма записан ученик по английски. Сега има.
--
--  3. Часовете стават общи за четене: всеки преподавател вижда и
--     часовете на другите. Писането не се пипа — всеки си пише, поправя
--     и трие САМО своите часове, точно както досега.
-- =====================================================================

-- ---------------------------------------------------------------------
--  1. Предметът
-- ---------------------------------------------------------------------
insert into public.subjects (slug, name, active, auto_enroll, sort_order)
values ('angliiski', 'Английски', true, false, 30)
on conflict (slug) do update set name = excluded.name, active = true;

-- ---------------------------------------------------------------------
--  2. Кой какво преподава
-- ---------------------------------------------------------------------
create table if not exists public.teacher_subjects (
  teacher_id  uuid not null references public.profiles(id) on delete cascade,
  subject_id  uuid not null references public.subjects(id) on delete cascade,
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  primary key (teacher_id, subject_id)
);

create index if not exists teacher_subjects_teacher_idx
  on public.teacher_subjects(teacher_id) where active;

alter table public.teacher_subjects enable row level security;
-- ---------------------------------------------------------------------
--  ПРАВА ВЪРХУ ТАБЛИЦИТЕ
--  От 30 октомври 2026 г. Supabase спира да дава автоматично права на
--  Data API върху НОВИ таблици в public. Затова всяка таблица си носи
--  правата в същия файл, който я създава — инак при нов проект, при
--  клон за преглед или при „supabase db reset“ страницата получава
--  „permission denied“.
--
--  authenticated — работи през политиките (RLS решава кой какво вижда).
--  service_role  — за Edge функцията admin-users: ключът ѝ заобикаля
--                  RLS, но БЕЗ право върху таблицата пак не минава.
--  anon          — нарочно нищо: в тази платформа всичко е зад вход.
-- ---------------------------------------------------------------------
revoke all on table public.teacher_subjects from anon;
grant select, insert, update, delete on table public.teacher_subjects to authenticated;
grant select, insert, update, delete on table public.teacher_subjects to service_role;

drop policy if exists "teacher subjects: teachers read" on public.teacher_subjects;
drop policy if exists "teacher subjects: admin writes" on public.teacher_subjects;

-- Четат всички преподаватели: списъкът е работен, не личен — по него се
-- знае кой може да запише час по кой предмет. Учениците не го четат.
create policy "teacher subjects: teachers read" on public.teacher_subjects
  for select to authenticated
  using (public.is_teacher());

-- Пише само администраторът. Иначе всеки би могъл да си припише предмет.
create policy "teacher subjects: admin writes" on public.teacher_subjects
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Пренасяне на вече известното: каквото всеки преподава на учениците си,
-- влиза и тук. Без това таблицата тръгва празна и на всеки преподавател
-- биха му се предложили всички предмети.
insert into public.teacher_subjects (teacher_id, subject_id)
select distinct t.teacher_id, t.subject_id
  from public.teaching t
 where t.active
on conflict do nothing;

-- И новото: Валя преподава английски.
-- Търси се по име, защото id-тата са различни във всяка база. Ако такъв
-- преподавател няма, тук не се вписва нищо и файлът НЕ спира — долният
-- select казва какво се е получило, вместо да се чупи по средата.
insert into public.teacher_subjects (teacher_id, subject_id)
select p.id, s.id
  from public.profiles p
  cross join public.subjects s
 where p.role = 'teacher' and p.active
   and p.full_name ilike '%Валя%'
   and s.slug = 'angliiski'
on conflict (teacher_id, subject_id) do update set active = true;

-- ---------------------------------------------------------------------
--  3. Часовете се виждат от всички преподаватели
-- ---------------------------------------------------------------------
--  Досега политиката за четене беше „редът е мой“. Оттук нататък всеки
--  преподавател вижда целия календар — за да се знае кой кога е зает и
--  да не се уговарят два часа в една стая.
--
--  Пипа се САМО четенето. „lessons: add own“, „edit own“ и „drop own“
--  остават както са в schema-v11.sql: чужд час се вижда, но не се пипа.
--  Ученик не чете нищо тук — няма политика за него.
-- ---------------------------------------------------------------------
drop policy if exists "lessons: read own" on public.lessons;
drop policy if exists "lessons: read all" on public.lessons;

create policy "lessons: read all" on public.lessons
  for select to authenticated
  using (public.is_teacher());

-- ---------------------------------------------------------------------
--  3б. Имената на преподавателите
-- ---------------------------------------------------------------------
--  Общият календар не стига сам: преподавател не чете чужд профил —
--  политиките по profiles са „моят ред“ и „моите ученици“. Без име
--  чуждият час излиза като „преподавател“, което не казва нищо.
--
--  Вместо да се отваря цялата таблица profiles за колеги (а в нея вече
--  има и рождени дни), тук стои функция, която връща САМО онова, което
--  календарът показва: id и име на активните преподаватели. Ученик,
--  който я извика, не получава нищо — пази го условието вътре.
-- ---------------------------------------------------------------------
create or replace function public.teacher_names()
returns table (id uuid, full_name text)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select p.id, p.full_name
    from public.profiles p
   where p.role = 'teacher' and p.active
     and public.is_teacher()
$$;

revoke all on function public.teacher_names() from public, anon;
grant execute on function public.teacher_names() to authenticated;

-- ---------------------------------------------------------------------
--  4. Проверка — какво се получи
-- ---------------------------------------------------------------------
select
  (select count(*) from public.subjects where slug = 'angliiski')        as има_английски,
  (select count(*) from public.teacher_subjects)                         as реда_кой_какво_преподава,
  (select string_agg(p.full_name, ', ' order by p.full_name)
     from public.teacher_subjects ts
     join public.profiles p on p.id = ts.teacher_id
     join public.subjects s on s.id = ts.subject_id
    where s.slug = 'angliiski' and ts.active)                            as английски_се_води_от,
  (select count(*) from pg_policy
    where polrelid = 'public.lessons'::regclass
      and polname = 'lessons: read all')                                 as общ_поглед_върху_часовете,
  (select count(*) from pg_policy
    where polrelid = 'public.lessons'::regclass)                         as правила_за_часовете,
  (select count(*) from pg_proc
    where proname = 'teacher_names'
      and pronamespace = 'public'::regnamespace)                         as функция_с_имената,
  case when exists (select 1 from public.teacher_subjects ts
                      join public.subjects s on s.id = ts.subject_id
                     where s.slug = 'angliiski' and ts.active)
       then 'готово'
       else 'Английският остана без преподавател: няма активен профил с име „Валя“. '
            'Добави я от таблото → Преподаватели и пусни файла пак.'
  end                                                                    as бележка;
