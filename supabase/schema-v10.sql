-- =====================================================================
--  The Light Academy — часовете на преподавателите
--  ---------------------------------------------------------------------
--  Какво прави: една нова таблица — public.lessons — и правилата кой
--  какво вижда в нея. Нищо друго не се пипа.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА. Всяка стъпка минава и на
--  празно, и върху наполовина свършена работа. Няма begin/commit — ако
--  редакторът спре по средата, просто пусни файла пак.
--
--  КАКВО Е ЕДИН ЧАС ТУК
--  Преподавателят си записва урок: кое дете, по кой предмет, кога и
--  колко дълго. Това е всичко. Няма заявки, няма потвърждаване, няма
--  родители — часът съществува в мига, в който го запише.
--
--  ЗАЩО ЕДНА ТАБЛИЦА, А НЕ „ЗАЯВКИ“ И „ЧАСОВЕ“
--  Заетостта на преподавателя е едно и също нещо, както и да е влязъл
--  часът в нея. Ако утре се появи и запазване от родител, то добавя
--  колони в тази таблица, а не втора таблица до нея — инак двете се
--  разминават още първата седмица.
-- =====================================================================


-- =====================================================================
--  СТЪПКА 1 — таблицата
-- =====================================================================

create extension if not exists btree_gist;

create table if not exists public.lessons (
  id          uuid primary key default gen_random_uuid(),

  teacher_id  uuid not null references public.profiles(id) on delete restrict,
  subject_id  uuid not null references public.subjects(id) on delete restrict,

  -- Името се пише на ръка. Детето може и да не е в платформата — часът
  -- се записва и за дете, което тепърва идва.
  child_name  text not null,

  starts_at   timestamptz not null,
  ends_at     timestamptz not null,

  note        text,

  -- Повтарящите се часове са отделни редове с един и същ series_id.
  -- Така един час от поредицата се мести или трие сам, без да влачи
  -- останалите — а „изтрий всички до края“ пак е една заявка.
  series_id   uuid,

  created_at  timestamptz not null default now(),
  created_by  uuid not null references public.profiles(id) on delete restrict,

  constraint lessons_child_name_ok
    check (length(btrim(child_name)) between 1 and 80),
  constraint lessons_note_ok
    check (note is null or length(note) <= 500),
  constraint lessons_time_ok
    check (ends_at > starts_at and ends_at <= starts_at + interval '8 hours')
);

create index if not exists lessons_by_teacher on public.lessons (teacher_id, starts_at);
create index if not exists lessons_by_start   on public.lessons (starts_at);
create index if not exists lessons_by_series  on public.lessons (series_id) where series_id is not null;


-- ---------------------------------------------------------------------
--  Два часа на един преподавател по едно и също време не минават
-- ---------------------------------------------------------------------
--  Не уникален индекс по (teacher_id, starts_at): той стига само докато
--  всички часове са по 60 минути и тръгват на кръгъл час. Изключващото
--  ограничение е вярно и когато часът е 90 минути или започва в 17:30.
-- ---------------------------------------------------------------------
alter table public.lessons drop constraint if exists lessons_no_overlap;
alter table public.lessons add  constraint lessons_no_overlap
  exclude using gist (teacher_id with =, tstzrange(starts_at, ends_at) with &&);


-- =====================================================================
--  СТЪПКА 2 — кой какво вижда
-- ---------------------------------------------------------------------
--  Преподавателят: само своите часове, и пише само от свое име.
--  Админът: всичко.
--  Ученик или родител: нищо. Имената на децата стоят тук и не напускат
--  кръга на преподавателите.
-- =====================================================================

alter table public.lessons enable row level security;

drop policy if exists "lessons: own"       on public.lessons;
drop policy if exists "lessons: admin all" on public.lessons;

create policy "lessons: own" on public.lessons
  for all to authenticated
  using (teacher_id = auth.uid())
  with check (teacher_id = auth.uid() and created_by = auth.uid());

create policy "lessons: admin all" on public.lessons
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- anon няма работа тук: часовете се виждат само след вход.
revoke all on table public.lessons from anon;
grant select, insert, update, delete on table public.lessons to authenticated;


-- =====================================================================
--  Потвърждение, че е минало. Трите числа трябва да са 1, 1 и 2.
-- =====================================================================

--  Ако „колони“ не е 10, значи в базата вече е имало таблица lessons от
--  друг опит и създаването е било прескочено. Тогава ми кажи — не бива
--  да се налучква кое липсва.
select
  (select count(*) from information_schema.tables
    where table_schema = 'public' and table_name = 'lessons')          as таблица,
  (select count(*) from information_schema.columns
    where table_schema = 'public' and table_name = 'lessons'
      and column_name in ('id','teacher_id','subject_id','child_name','starts_at',
                          'ends_at','note','series_id','created_at','created_by'))
                                                                       as колони,
  (select count(*) from pg_constraint
    where conrelid = 'public.lessons'::regclass
      and conname = 'lessons_no_overlap')                              as без_застъпване,
  (select count(*) from pg_policy
    where polrelid = 'public.lessons'::regclass)                       as правила,
  (select count(*) from public.lessons)                                as записани_часове;


-- ---------------------------------------------------------------------
-- Ако трябва да се махне (всички записани часове изчезват):
--   drop table if exists public.lessons;
-- ---------------------------------------------------------------------
