-- =====================================================================
-- The Light Academy — LightSpace, класове и предмети (схема v2)
--
-- Пуска се ВЕДНЪЖ в Supabase: SQL Editor -> New query -> Run.
-- Може да се пуска повторно без вреда — всяка команда е идемпотентна.
--
-- Файлът има два блока:
--   БЛОК 1 — самата схема (нови таблици, колони, функции, политики)
--   БЛОК 2 — пренасяне на данните, които вече са в базата
--
-- Ако искаш, пусни ги един по един, за да видиш резултата на всеки.
--
-- ЗАЩО Е НАПРАВЕНО ТАКА (накратко):
--   Не пазим "клас", защото класът се мени всяка година и щеше да иска
--   ръчна миграция всеки септември. Пазим кога и в кой клас е записан
--   ученикът; текущият клас се пресмята. Никакъв годишен ритуал.
--
--   текущ клас = grade_at_entry + (текуща учебна година - entry_school_year)
--
--   Учебната година се сменя на 1 септември. 2026 значи учебна 2026/27.
-- =====================================================================


-- #####################################################################
-- #  БЛОК 1 — СХЕМА
-- #####################################################################

-- ---------------------------------------------------------------------
-- 1.1 Учебна година — функциите, върху които стъпва всичко
-- ---------------------------------------------------------------------

-- Коя учебна година е даден момент. 1 септември е границата.
-- Часовата зона е фиксирана на София, за да не зависи отговорът от
-- настройките на сървъра.
create or replace function public.school_year_of(at timestamptz)
returns int
language sql
stable
as $$
  select case
           when extract(month from (at at time zone 'Europe/Sofia')) >= 9
             then extract(year from (at at time zone 'Europe/Sofia'))::int
             else extract(year from (at at time zone 'Europe/Sofia'))::int - 1
         end;
$$;

create or replace function public.current_school_year()
returns int
language sql
stable
as $$
  select public.school_year_of(now());
$$;

-- Как се изписва клас пред хора. -1 и 0 никога не се показват като числа.
create or replace function public.grade_label(g int)
returns text
language sql
immutable
as $$
  select case
           when g is null then 'Без клас'
           when g = -1    then 'Предучилищна (5 г.)'
           when g = 0     then 'Предучилищна (6 г.)'
           when g between 1 and 12 then g::text || '. клас'
           else 'Завършил'
         end;
$$;

grant execute on function public.school_year_of(timestamptz) to anon, authenticated;
grant execute on function public.current_school_year()       to anon, authenticated;
grant execute on function public.grade_label(int)            to anon, authenticated;


-- ---------------------------------------------------------------------
-- 1.2 Предмети
--     Сега се създава само Математика. Театър, български, испански и
--     английски могат да се добавят по всяко време с един insert —
--     базата вече ги позволява, но нищо не се създава само.
-- ---------------------------------------------------------------------

create table if not exists public.subjects (
  id           uuid primary key default gen_random_uuid(),
  slug         text unique not null,
  name         text not null,
  active       boolean not null default true,
  -- когато е true, всеки нов ученик се записва автоматично в този предмет
  auto_enroll  boolean not null default false,
  sort_order   int not null default 0,
  created_at   timestamptz not null default now()
);

alter table public.subjects add column if not exists auto_enroll boolean not null default false;

insert into public.subjects (slug, name, active, auto_enroll, sort_order)
values ('matematika', 'Математика', true, true, 10)
on conflict (slug) do nothing;

-- Когато решиш да добавиш нов предмет, това е целият ред:
--   insert into public.subjects (slug, name, sort_order)
--   values ('teatar-en', 'Театър на английски', 20);


-- ---------------------------------------------------------------------
-- 1.3 Записвания — кой ученик какъв предмет учи
-- ---------------------------------------------------------------------

create table if not exists public.enrollments (
  id          uuid primary key default gen_random_uuid(),
  profile_id  uuid not null references public.profiles(id) on delete cascade,
  subject_id  uuid not null references public.subjects(id) on delete cascade,
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  unique (profile_id, subject_id)
);

create index if not exists enrollments_profile_idx on public.enrollments(profile_id);
create index if not exists enrollments_subject_idx on public.enrollments(subject_id);


-- ---------------------------------------------------------------------
-- 1.4 profiles — кога и в кой клас е записан ученикът
-- ---------------------------------------------------------------------

alter table public.profiles add column if not exists grade_at_entry    int;
alter table public.profiles add column if not exists entry_school_year int;
alter table public.profiles add column if not exists grade_set_at      timestamptz;

do $$
begin
  alter table public.profiles
    add constraint profiles_grade_range
    check (grade_at_entry is null or grade_at_entry between -1 and 12);
exception when duplicate_object then null;
end $$;

do $$
begin
  alter table public.profiles
    add constraint profiles_grade_pair
    check ((grade_at_entry is null) = (entry_school_year is null));
exception when duplicate_object then null;
end $$;

-- Сега, когато колоните ги има, можем да пресметнем класа.
-- Текущият клас на един ученик. null = още няма зададен клас.
-- SECURITY DEFINER, защото се вика вътре в политиките върху assignments
-- и трябва да може да прочете profiles независимо от политиките там.
create or replace function public.current_grade(uid uuid)
returns int
language sql
stable
security definer set search_path = public
as $$
  select p.grade_at_entry + (public.current_school_year() - p.entry_school_year)
  from public.profiles p
  where p.id = uid;
$$;

grant execute on function public.current_grade(uuid) to authenticated;


-- ---------------------------------------------------------------------
-- 1.5 assignments — за кой предмет и за кои класове е заданието
--     grades = null  ->  за всички класове
--     grades = '{7}' ->  само за 7. клас
--     grades = '{6,7}' -> за 6. и за 7. клас
-- ---------------------------------------------------------------------

alter table public.assignments add column if not exists subject_id uuid
  references public.subjects(id) on delete set null;
alter table public.assignments add column if not exists grades int[];

do $$
begin
  alter table public.assignments
    add constraint assignments_grades_valid
    check (
      grades is null
      or (array_length(grades, 1) >= 1
          and grades <@ array[-1,0,1,2,3,4,5,6,7,8,9,10,11,12]::int[])
    );
exception when duplicate_object then null;
end $$;

create index if not exists assignments_grades_idx  on public.assignments using gin (grades);
create index if not exists assignments_subject_idx on public.assignments(subject_id);


-- ---------------------------------------------------------------------
-- 1.6 Бутонът "Задай клас"
--     Пренаписва "записан в X клас през Y година" и от следващия
--     1 септември автоматичното израстване продължава оттам.
--     Върши работа и за повтарящ година ученик: просто му задаваш
--     същия клас наново.
--     ВНИМАНИЕ: презаписва оригиналния запис. grade_set_at пази кога.
-- ---------------------------------------------------------------------

create or replace function public.set_student_grade(student uuid, new_grade int)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  if not public.is_teacher() then
    raise exception 'Само преподавател може да задава клас.';
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


-- ---------------------------------------------------------------------
-- 1.7 Нов ученик — профилът поема класа и записването в предмет
--     Ролята вече е твърдо 'student'. Досега се вземаше от метаданните
--     на потребителя, което значи, че ако някога включиш публичната
--     регистрация, всеки може да си поиска role='teacher'. Преподавател
--     се прави само с ръчен update, както и досега.
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

  -- записване в предметите, отбелязани с auto_enroll
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


-- ---------------------------------------------------------------------
-- 1.8 Права и политики за новите таблици
-- ---------------------------------------------------------------------

alter table public.subjects    enable row level security;
alter table public.enrollments enable row level security;

grant select, insert, update, delete on public.subjects    to authenticated;
grant select, insert, update, delete on public.enrollments to authenticated;

drop policy if exists "subjects: read active"  on public.subjects;
drop policy if exists "subjects: teacher all"  on public.subjects;

create policy "subjects: read active"
  on public.subjects for select
  using (active or public.is_teacher());

create policy "subjects: teacher all"
  on public.subjects for all
  using (public.is_teacher())
  with check (public.is_teacher());

drop policy if exists "enrollments: read own"     on public.enrollments;
drop policy if exists "enrollments: teacher all"  on public.enrollments;

create policy "enrollments: read own"
  on public.enrollments for select
  using (profile_id = auth.uid());

create policy "enrollments: teacher all"
  on public.enrollments for all
  using (public.is_teacher())
  with check (public.is_teacher());


-- ---------------------------------------------------------------------
-- 1.9 Новото правило кой вижда кое задание
--
--     Ученикът вижда задание само ако:
--       * е публикувано, И
--       * има зададен клас между предучилищна и 12., И
--       * заданието е за неговия клас (или е за всички класове), И
--       * е записан в предмета на заданието (или заданието е без предмет)
--
--     Оттук идва и "след 12. клас сам става неактивен": на такъв ученик
--     пресметнатият клас става 13 и нито едно задание не му отговаря.
--     Ръчното изключване през `active` си остава както е.
--
--     ВАЖНО: ученик без зададен клас не вижда НИЩО. Затова БЛОК 2
--     по-долу задава клас на всички, които вече съществуват.
-- ---------------------------------------------------------------------

drop policy if exists "assignments: read published"  on public.assignments;
drop policy if exists "assignments: read for grade"  on public.assignments;

create policy "assignments: read for grade"
  on public.assignments for select
  using (
    public.is_teacher()
    or (
      published
      and public.current_grade(auth.uid()) between -1 and 12
      and (grades is null or public.current_grade(auth.uid()) = any(grades))
      and (
        subject_id is null
        or exists (
          select 1 from public.enrollments e
          where e.profile_id = auth.uid()
            and e.subject_id = assignments.subject_id
            and e.active
        )
      )
    )
  );

-- Заданията вече не се четат от нерегистрирани. Досега `anon` имаше
-- select върху цялата таблица, тоест всеки можеше да изчете списъка със
-- заданията и адресите им, без да влиза. Нищо в сайта не разчита на това.
revoke select on public.assignments from anon;


-- #####################################################################
-- #  БЛОК 2 — ПРЕНАСЯНЕ НА СЪЩЕСТВУВАЩИТЕ ДАННИ
-- #
-- #  Този блок ПИПА данни. Прочети го, преди да го пуснеш.
-- #####################################################################

-- 2.1 Всички досегашни ученици са в курса за НВО, тоест 7. клас.
--     Ако някой от тях е в друг клас, оправи го после с бутона
--     "Задай клас" в таблото — или смени числото тук, преди да пуснеш.
update public.profiles
   set grade_at_entry    = 7,
       entry_school_year = public.current_school_year(),
       grade_set_at      = now()
 where role = 'student'
   and grade_at_entry is null;

-- 2.2 Всички досегашни ученици учат математика.
insert into public.enrollments (profile_id, subject_id)
select p.id, s.id
  from public.profiles p
  cross join public.subjects s
 where p.role = 'student' and s.slug = 'matematika'
on conflict (profile_id, subject_id) do nothing;

-- 2.3 Всички досегашни задания са по математика и са за 7. клас.
update public.assignments a
   set subject_id = (select id from public.subjects where slug = 'matematika'),
       grades     = '{7}'
 where a.subject_id is null
   and a.grades is null;

-- 2.4 Старата колона `grade` в profiles отпада. Беше текст, никога не е
--     била четена и никога записвана от нищо в сайта — новите три
--     колони я заместват.
alter table public.profiles drop column if exists grade;


-- #####################################################################
-- #  ПРОВЕРКА — пусни това след горното и виж дали изглежда наред
-- #####################################################################

-- Коя учебна година сме според базата (днес трябва да е 2026):
--   select public.current_school_year();
--
-- Учениците и класът им:
--   select p.full_name,
--          public.grade_label(p.grade_at_entry) as "записан в",
--          p.entry_school_year                  as "през година",
--          public.grade_label(
--            p.grade_at_entry + (public.current_school_year() - p.entry_school_year)
--          ) as "сега"
--     from public.profiles p
--    where p.role = 'student'
--    order by p.full_name;
--
-- Ученик без зададен клас (такъв не вижда нито едно задание):
--   select id, full_name from public.profiles
--    where role = 'student' and grade_at_entry is null;
--
-- Заданията и за кого са:
--   select a.slug, a.title, s.name as предмет, a.grades, a.published
--     from public.assignments a
--     left join public.subjects s on s.id = a.subject_id
--    order by a.sort_order;
