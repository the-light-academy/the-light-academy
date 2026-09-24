-- =====================================================================
--  The Light Academy — записване на индивидуални уроци
--  ---------------------------------------------------------------------
--  ПУСНИ ЦЕЛИЯ ФАЙЛ. Редакторът на Supabase изпълнява само маркираното,
--  ако има маркирано — файл, пуснат на парчета, оставя базата наполовина.
--
--  Какво прави: дава на преподавателите къде да кажат кога са свободни,
--  и на родителите начин да си вземат час, без да звънят. Нищо
--  съществуващо не се пипа — трите таблици са нови и празни, докато
--  първият преподавател не въведе първия си прозорец. Дотогава за
--  учениците не се променя абсолютно нищо.
--
--  ДВЕ РЕШЕНИЯ, КОИТО СИ ЗАСЛУЖАВА ДА СЕ ЗНАЯТ
--
--  1. Няма нова Edge Function. Непознатият посетител (ролята `anon`)
--     днес вижда само `assignments` и три функции за дати — тоест
--     публичната страница не може да чете базата направо. Обичайният
--     отговор е Edge Function, но заемането на час трябва да е атомарно
--     (двама родители, същият час, същата секунда), а това се решава
--     ТУК, вътре в базата. Затова вместо сървър отвън има две
--     SECURITY DEFINER функции, дадени на `anon`: те отдават точно
--     толкова, колкото им е казано, и нищо повече.
--
--  2. Двойно записване не се пази с проверка в страницата, а с
--     ограничение в базата (виж `lessons_no_overlap`). Проверка в
--     страницата винаги има процеп между „свободно ли е?“ и „запиши“.
--     Ограничението няма.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 0. Настройки, които се сменят с един ред
-- ---------------------------------------------------------------------
create table if not exists public.booking_settings (
  id              boolean primary key default true check (id),
  horizon_days    int  not null default 30,   -- колко напред се вижда
  lead_hours      int  not null default 12,   -- най-рано колко часа преди
  hold_days       int  not null default 7,    -- след колко дни пада незатвърден час
  max_per_phone   int  not null default 3,    -- заявки от един телефон за 24 ч.
  slot_minutes    int  not null default 60
);
insert into public.booking_settings (id) values (true) on conflict (id) do nothing;

comment on column public.booking_settings.hold_days is
  'Предпазител, не работен похват. Страницата е публична и запазва часа
   веднага; без срок един злонамерен посетител може да заключи целия
   календар завинаги. Ани потвърждава далеч преди тези дни да минат.';


-- ---------------------------------------------------------------------
-- 1. Кога е свободен преподавателят
--    Повтарящи се седмични прозорци, в МЕСТНО софийско време. Пазят се
--    като ден-от-седмицата + час, а не като дати, защото „вторник от
--    18:00“ е това, което човекът мисли — и защото така 18:00 си остава
--    18:00 и след разместването на часовника.
-- ---------------------------------------------------------------------
create table if not exists public.teacher_availability (
  id          uuid primary key default gen_random_uuid(),
  teacher_id  uuid not null references public.profiles(id) on delete cascade,
  -- null = всеки предмет, който този преподавател води
  subject_id  uuid references public.subjects(id) on delete cascade,
  weekday     smallint not null check (weekday between 1 and 7),  -- ISO: 1 = понеделник
  starts_at   time not null,
  ends_at     time not null,
  valid_from  date not null default current_date,
  valid_to    date,
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  check (ends_at > starts_at)
);
create index if not exists teacher_availability_by_teacher
  on public.teacher_availability (teacher_id, weekday) where active;


-- ---------------------------------------------------------------------
-- 2. Изключенията: отпуска, празник, „този вторник не мога“
-- ---------------------------------------------------------------------
create table if not exists public.availability_blocks (
  id          uuid primary key default gen_random_uuid(),
  teacher_id  uuid not null references public.profiles(id) on delete cascade,
  starts_at   timestamptz not null,
  ends_at     timestamptz not null,
  note        text,
  created_at  timestamptz not null default now(),
  check (ends_at > starts_at)
);
create index if not exists availability_blocks_by_teacher
  on public.availability_blocks (teacher_id, starts_at);


-- ---------------------------------------------------------------------
-- 3. Часовете — и заявените, и потвърдените, в една таблица
--    Една таблица, а не „заявки“ и „часове“ поотделно: заетостта на
--    преподавателя е едно и също нещо, независимо дали часът е още
--    запазен или вече потвърден, а едно ограничение върху една таблица
--    е единственият начин двете да не се разминат.
-- ---------------------------------------------------------------------
create table if not exists public.lessons (
  id          uuid primary key default gen_random_uuid(),
  teacher_id  uuid not null references public.profiles(id) on delete restrict,
  subject_id  uuid not null references public.subjects(id) on delete restrict,
  starts_at   timestamptz not null,
  ends_at     timestamptz not null,
  status      text not null default 'held'
              check (status in ('held','confirmed','declined','cancelled')),
  -- за седмично повторение по-късно: тогава серия уроци носят един и същ
  -- series_id. Колоната стои от първия ден, за да е добавяне на редове,
  -- а не промяна на схемата.
  series_id   uuid,
  -- ако семейството вече е наше, часът се връзва за ученика
  student_id  uuid references public.profiles(id) on delete set null,
  parent_name  text, parent_phone text, parent_email text,
  child_name   text, child_grade int, note text,
  hold_expires_at timestamptz,
  created_at  timestamptz not null default now(),
  decided_at  timestamptz,
  decided_by  uuid references public.profiles(id) on delete set null,
  check (ends_at > starts_at)
);
create index if not exists lessons_by_teacher on public.lessons (teacher_id, starts_at);
create index if not exists lessons_by_status  on public.lessons (status, starts_at);

-- СЪРЦЕТО НА ЦЯЛАТА РАБОТА.
-- Не уникален индекс по (teacher_id, starts_at): той стига само докато
-- всички уроци са по 60 минути и започват на кръгъл час. Изключващото
-- ограничение е вярно независимо от това — включително ако един ден
-- часовете станат по 90 минути или прозорците тръгнат от 17:30.
create extension if not exists btree_gist;
do $$ begin
  alter table public.lessons add constraint lessons_no_overlap
    exclude using gist (teacher_id with =, tstzrange(starts_at, ends_at) with &&)
    where (status in ('held','confirmed'));
exception when duplicate_table then null; when duplicate_object then null;
end $$;

commit;


-- =====================================================================
--  4. Свободните часове — единственото, което непознат посетител вижда
-- =====================================================================
begin;

-- Разгъва седмичните прозорци върху истински дати и маха заетото.
--
-- ЧАСОВАТА ЗОНА Е ЦЯЛАТА ТРУДНОСТ. Часовете се събират в МЕСТНО време и
-- чак накрая се превръщат в timestamptz:
--     ((ден + начало + n часа) at time zone 'Europe/Sofia')
-- Обратният ред — първо в timestamptz, после добавяне на часове — мести
-- урока с един час всеки път, когато часовникът се размества (25 октомври
-- 2026). Това е най-тихата възможна грешка в такава система и затова е
-- първото, което тестът проверява.
create or replace function public.free_slots(
  p_subject uuid,
  p_from    date default current_date,
  p_to      date default null
)
returns table (
  teacher_id   uuid,
  teacher_name text,
  starts_at    timestamptz,
  ends_at      timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  with cfg as (select * from public.booking_settings where id),
  bounds as (
    select p_from as d_from,
           coalesce(p_to, current_date + (select horizon_days from cfg)) as d_to,
           (select lead_hours   from cfg) as lead_hours,
           (select slot_minutes from cfg) as slot_minutes
  ),
  days as (
    select d::date as day
      from bounds b, generate_series(b.d_from, b.d_to, interval '1 day') d
  ),
  -- прозорците, приложени върху всеки ден от обхвата
  windows as (
    select a.teacher_id, p.full_name, d.day, a.starts_at as w_start, a.ends_at as w_end
      from public.teacher_availability a
      join public.profiles p on p.id = a.teacher_id
      join days d on extract(isodow from d.day)::int = a.weekday
     where a.active
       and p.role = 'teacher' and p.active
       and d.day >= a.valid_from
       and (a.valid_to is null or d.day <= a.valid_to)
       -- null = прозорецът важи за всеки предмет; иначе точно този
       and (a.subject_id is null or a.subject_id = p_subject)
  ),
  slots as (
    select w.teacher_id, w.full_name,
           ((w.day + w.w_start + make_interval(mins => n * b.slot_minutes))
              at time zone 'Europe/Sofia') as s_start,
           ((w.day + w.w_start + make_interval(mins => (n + 1) * b.slot_minutes))
              at time zone 'Europe/Sofia') as s_end
      from windows w, bounds b,
           lateral generate_series(
             0,
             greatest(0, (extract(epoch from (w.w_end - w.w_start)) / 60
                          / b.slot_minutes)::int - 1)
           ) as n
  )
  select distinct s.teacher_id, s.full_name, s.s_start, s.s_end
    from slots s, bounds b
   where s.s_start > now() + make_interval(hours => b.lead_hours)
     -- вече зает час: и запазеният брои за зает, иначе двама родители
     -- виждат един и същ час, докато първият чака потвърждение
     and not exists (
           select 1 from public.lessons l
            where l.teacher_id = s.teacher_id
              and l.status in ('held','confirmed')
              and tstzrange(l.starts_at, l.ends_at) && tstzrange(s.s_start, s.s_end))
     -- отпуска, празник, „този вторник не мога“
     and not exists (
           select 1 from public.availability_blocks x
            where x.teacher_id = s.teacher_id
              and tstzrange(x.starts_at, x.ends_at) && tstzrange(s.s_start, s.s_end))
   order by s.s_start, s.full_name;
$$;


-- Предметите, за които ИМА какво да се запази. Трябва, защото `anon` не
-- чете `subjects` — а страницата трябва да покаже от какво да се избира.
-- Нарочно не е `grant select on subjects to anon`: така излизат само
-- предметите, за които някой преподавател наистина е отворил часове, и
-- родителят не избира нещо, зад което няма нищо.
create or replace function public.bookable_subjects()
returns table (id uuid, name text, slug text)
language sql
stable
security definer
set search_path = public
as $$
  select distinct s.id, s.name, s.slug
    from public.subjects s
   where s.active
     and exists (
       select 1
         from public.teacher_availability a
         join public.profiles p on p.id = a.teacher_id
        where a.active and p.role = 'teacher' and p.active
          and (a.valid_to is null or a.valid_to >= current_date)
          and (a.subject_id is null or a.subject_id = s.id))
   order by s.name;
$$;


-- Заема час. Единственият начин, по който непознат посетител пише в базата.
create or replace function public.request_lesson(
  p_teacher      uuid,
  p_subject      uuid,
  p_starts       timestamptz,
  p_parent_name  text,
  p_parent_phone text,
  p_parent_email text,
  p_child_name   text,
  p_child_grade  int  default null,
  p_note         text default null
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
  v_end timestamptz;
  v_recent int;
  cfg public.booking_settings;
begin
  select * into cfg from public.booking_settings where id;

  -- --- какво е въведено -------------------------------------------------
  if coalesce(trim(p_parent_name), '') = '' or length(p_parent_name) > 120 then
    raise exception 'Въведете име на родителя.' using errcode = '22023';
  end if;
  if coalesce(trim(p_parent_phone), '') = '' or length(p_parent_phone) > 40 then
    raise exception 'Въведете телефон.' using errcode = '22023';
  end if;
  if coalesce(trim(p_child_name), '') = '' or length(p_child_name) > 120 then
    raise exception 'Въведете име на детето.' using errcode = '22023';
  end if;
  if p_parent_email is not null and p_parent_email !~ '^[^\s@]+@[^\s@.]+(\.[^\s@.]+)+$' then
    raise exception 'Имейлът не изглежда редовен.' using errcode = '22023';
  end if;
  if p_child_grade is not null and (p_child_grade < -1 or p_child_grade > 12) then
    raise exception 'Класът е извън обхвата.' using errcode = '22023';
  end if;
  if length(coalesce(p_note, '')) > 1000 then
    raise exception 'Съобщението е твърде дълго.' using errcode = '22023';
  end if;

  -- --- часът трябва да е измежду свободните, а не какъвто и да е -------
  -- Без това всеки може да си впише 3 ч. през нощта: функцията е публична
  -- и получава каквото ѝ подадат.
  if not exists (
       select 1 from public.free_slots(p_subject, current_date,
                                       current_date + cfg.horizon_days) f
        where f.teacher_id = p_teacher and f.starts_at = p_starts) then
    raise exception 'Този час вече не е свободен. Изберете друг.' using errcode = '22023';
  end if;

  -- --- срещу заливане ---------------------------------------------------
  select count(*) into v_recent
    from public.lessons
   where parent_phone = p_parent_phone
     and created_at > now() - interval '24 hours'
     and status in ('held','confirmed');
  if v_recent >= cfg.max_per_phone then
    raise exception 'От този телефон вече има % заявки за днес. Обадете се на 0885501283.',
      v_recent using errcode = '22023';
  end if;

  v_end := p_starts + make_interval(mins => cfg.slot_minutes);

  insert into public.lessons (
    teacher_id, subject_id, starts_at, ends_at, status,
    parent_name, parent_phone, parent_email, child_name, child_grade, note,
    hold_expires_at
  ) values (
    p_teacher, p_subject, p_starts, v_end, 'held',
    trim(p_parent_name), trim(p_parent_phone), nullif(trim(p_parent_email), ''),
    trim(p_child_name), p_child_grade, nullif(trim(p_note), ''),
    now() + make_interval(days => cfg.hold_days)
  ) returning id into v_id;

  return v_id;
exception
  -- Двама родители, същият час, същата секунда. Ограничението решава кой
  -- печели; тук само се превежда на човешки.
  when exclusion_violation then
    raise exception 'Този час току-що беше зает. Изберете друг.' using errcode = '22023';
end $$;

commit;


-- =====================================================================
--  5. Кой какво вижда
-- =====================================================================
begin;

-- Решава заявка. Отделна функция, а не гола update-политика, защото освен
-- статуса трябва да се запише И кой кога е решил — иначе след месец няма
-- как да се разбере кой е отказал часа на едно дете.
create or replace function public.decide_lesson(p_id uuid, p_status text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare v public.lessons;
begin
  if p_status not in ('confirmed','declined','cancelled') then
    raise exception 'Непознато решение: %', p_status using errcode = '22023';
  end if;
  select * into v from public.lessons where id = p_id;
  if v.id is null then
    raise exception 'Този час не е намерен.' using errcode = '22023';
  end if;
  -- своя час решава преподавателят; всеки — админът
  if not (public.is_admin() or v.teacher_id = auth.uid()) then
    raise exception 'Този час не е ваш.' using errcode = '42501';
  end if;
  update public.lessons
     set status = p_status,
         hold_expires_at = null,
         decided_at = now(),
         decided_by = auth.uid()
   where id = p_id;
end $$;

-- Пуска запазените часове, които никой не е затворил. Предпазител срещу
-- заливане, не работен похват — виж коментара при booking_settings.
create or replace function public.release_expired_holds()
returns int
language sql
security definer
set search_path = public
as $$
  with gone as (
    update public.lessons
       set status = 'cancelled', decided_at = now()
     where status = 'held'
       and hold_expires_at is not null
       and hold_expires_at < now()
    returning 1
  ) select count(*)::int from gone;
$$;

alter table public.teacher_availability enable row level security;
alter table public.availability_blocks  enable row level security;
alter table public.lessons              enable row level security;

grant select, insert, update, delete on public.teacher_availability to authenticated;
grant select, insert, update, delete on public.availability_blocks  to authenticated;
grant select, insert, update, delete on public.lessons              to authenticated;
grant select on public.booking_settings to authenticated;

-- Непознатият посетител НЕ получава достъп до нито една от таблиците —
-- само до двете функции, които отдават точно толкова, колкото трябва.
grant execute on function public.bookable_subjects()                     to anon, authenticated;
grant execute on function public.free_slots(uuid, date, date)           to anon, authenticated;
grant execute on function public.request_lesson(uuid, uuid, timestamptz,
                                                text, text, text, text, int, text)
                                                                         to anon, authenticated;
grant execute on function public.decide_lesson(uuid, text)               to authenticated;
grant execute on function public.release_expired_holds()                 to authenticated;

drop policy if exists "avail: admin all"      on public.teacher_availability;
drop policy if exists "avail: own"            on public.teacher_availability;
drop policy if exists "blocks: admin all"     on public.availability_blocks;
drop policy if exists "blocks: own"           on public.availability_blocks;
drop policy if exists "lessons: admin all"    on public.lessons;
drop policy if exists "lessons: teacher own"  on public.lessons;
drop policy if exists "lessons: student own"  on public.lessons;

create policy "avail: admin all" on public.teacher_availability for all
  using (public.is_admin()) with check (public.is_admin());
create policy "avail: own" on public.teacher_availability for all
  using (teacher_id = auth.uid()) with check (teacher_id = auth.uid());

create policy "blocks: admin all" on public.availability_blocks for all
  using (public.is_admin()) with check (public.is_admin());
create policy "blocks: own" on public.availability_blocks for all
  using (teacher_id = auth.uid()) with check (teacher_id = auth.uid());

create policy "lessons: admin all" on public.lessons for all
  using (public.is_admin()) with check (public.is_admin());
-- Преподавателят чете своите часове. Решаването минава през
-- decide_lesson(), затова тук няма update-политика: иначе би могъл да
-- пренапише телефона на родителя или да си вземе чужд час.
create policy "lessons: teacher own" on public.lessons for select
  using (teacher_id = auth.uid());
create policy "lessons: student own" on public.lessons for select
  using (student_id = auth.uid());

commit;

-- ---------------------------------------------------------------------
-- Ако трябва да се махне всичко (внимание: трие и заявките):
--   drop function if exists public.release_expired_holds();
--   drop function if exists public.decide_lesson(uuid, text);
--   drop function if exists public.request_lesson(uuid, uuid, timestamptz,
--                             text, text, text, text, int, text);
--   drop function if exists public.free_slots(uuid, date, date);
--   drop table if exists public.lessons;
--   drop table if exists public.availability_blocks;
--   drop table if exists public.teacher_availability;
--   drop table if exists public.booking_settings;
-- ---------------------------------------------------------------------

-- Потвърждение, че е минало. Не raise notice: SQL Editor-ът на Supabase
-- показва само таблици с резултат.
select 'Готово' as статус,
       (select count(*) from public.teacher_availability) as прозорци,
       (select count(*) from public.lessons)              as часове,
       (select horizon_days from public.booking_settings where id) as дни_напред;
