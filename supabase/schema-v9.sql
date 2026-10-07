-- =====================================================================
--  The Light Academy — интерактивни уроци в календара
--  ---------------------------------------------------------------------
--  Какво прави: разрешава трети вид задание — 'lesson' — и го пази да не
--  влиза в статистиката. Нова таблица няма, нова политика няма, вече
--  качените домашни и изпити не се пипат.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА. Всяка стъпка е написана така,
--  че да минава и на празно, и върху наполовина свършена работа: първо
--  маха старото (ако го има), после слага новото. Няма begin/commit —
--  ако редакторът спре по средата, просто пусни файла пак.
--
--  Стъпките са три и са самостоятелни. Ако редакторът се спъне в целия
--  файл, маркирай и пусни стъпка 1, после стъпка 2, после стъпка 3.
--
--  ЗАЩО В СЪЩАТА ТАБЛИЦА, А НЕ НОВА
--
--  Урокът минава по абсолютно същия път като домашното: качва се като
--  страница, закача се за седмица, влиза в библиотеката, преподавателят
--  го дава на своите ученици. Тези четири неща вече ги има в
--  assignments — заедно с правилата кой какво вижда. Отделна таблица
--  щеше да значи същите четири неща, написани втори път, и втори набор
--  политики, който да се разминава с първия.
--
--  Разликата е една: урокът не се оценява. Няма точки, няма опити, няма
--  процент. Затова са и двете пазилки по-долу.
-- =====================================================================


-- =====================================================================
--  СТЪПКА 1 — третият вид
-- ---------------------------------------------------------------------
--  Старото ограничение е кръстено от Postgres, когато таблицата е
--  създадена: assignments_kind_check. Маха се по име, а не с търсене из
--  системните таблици — така стъпката е четири обикновени реда, без
--  do-блок, който някои редактори не преглъщат.
--
--  Ако накрая справката покаже друго ограничение върху kind, прати ми
--  я: значи ограничението е с име, което не съм познал.
-- =====================================================================

alter table public.assignments drop constraint if exists assignments_kind_check;
alter table public.assignments drop constraint if exists assignments_kind_valid;

alter table public.assignments add constraint assignments_kind_valid
  check (kind in ('exam', 'homework', 'lesson'));


-- =====================================================================
--  СТЪПКА 2 — урокът няма точки
-- ---------------------------------------------------------------------
--  max_points по подразбиране е 100. Ако урок влезе със 100 точки, в
--  портала детето ще види „0 от 100“ и ще реши, че е изостанало с нещо,
--  което изобщо не се оценява.
--
--  Затова в реда на урока max_points се пише изрично 0 — образецът в
--  supabase/uroci.sql го прави — а ограничението отдолу не позволява да
--  се забрави. Ако го забравиш, базата ще откаже реда с името на
--  ограничението, което само си казва какво иска.
-- =====================================================================

-- Ако по-ранна версия на този файл е сложила тригер за същото — пада.
drop trigger if exists assignments_lesson_points on public.assignments;
drop function if exists public.lesson_has_no_points();

-- Вече качените уроци (ако файлът се пуска втори път) се оправят наведнъж.
update public.assignments set max_points = 0
  where kind = 'lesson' and max_points is distinct from 0;

alter table public.assignments drop constraint if exists assignments_lesson_no_points;

alter table public.assignments add constraint assignments_lesson_no_points
  check (kind <> 'lesson' or max_points = 0);


-- =====================================================================
--  СТЪПКА 3 — на урок не се пише опит
-- ---------------------------------------------------------------------
--  Пръстенът в портала е „колко от отвореното ти е зад гърба“. Опит
--  върху урок би го изкривил, а и няма откъде да дойде: страницата на
--  урока не предава нищо. Остава само ръчно сложен ред — и точно него
--  спира това.
--
--  Тук трябва функция, защото ограничение (check) не може да поглежда в
--  друга таблица. Функцията е същата по устройство като touch_star_card
--  от schema-v7.sql.
-- =====================================================================

create or replace function public.no_attempt_on_lesson()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if exists (select 1 from public.assignments a
              where a.id = new.assignment_id and a.kind = 'lesson') then
    raise exception 'На интерактивен урок не се пише опит — урокът не се оценява.'
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

revoke all on function public.no_attempt_on_lesson() from public, anon;

drop trigger if exists attempts_not_on_lesson on public.attempts;

create trigger attempts_not_on_lesson
  before insert or update of assignment_id on public.attempts
  for each row execute function public.no_attempt_on_lesson();


-- =====================================================================
--  Потвърждение, че е минало. Трите числа трябва да са 1, 1 и 1,
--  а последната колона да е празна.
-- =====================================================================

select
  (select count(*) from pg_constraint
    where conrelid = 'public.assignments'::regclass
      and conname = 'assignments_kind_valid')                     as вид,
  (select count(*) from pg_constraint
    where conrelid = 'public.assignments'::regclass
      and conname = 'assignments_lesson_no_points')               as точки,
  (select count(*) from pg_trigger
    where tgrelid = 'public.attempts'::regclass
      and tgname = 'attempts_not_on_lesson')                      as опити,
  (select count(*) from public.assignments where kind = 'lesson') as качени_уроци,
  (select string_agg(conname, ', ') from pg_constraint
    where conrelid = 'public.assignments'::regclass
      and contype = 'c'
      and conname not in ('assignments_kind_valid', 'assignments_lesson_no_points')
      and pg_get_constraintdef(oid) like '%kind%')                as чуждо_ограничение;


-- ---------------------------------------------------------------------
-- Ако трябва да се върне назад (уроците остават в таблицата, но вече
-- няма да минават):
--   drop trigger if exists attempts_not_on_lesson on public.attempts;
--   drop function if exists public.no_attempt_on_lesson();
--   delete from public.assignments where kind = 'lesson';
--   alter table public.assignments drop constraint assignments_lesson_no_points;
--   alter table public.assignments drop constraint assignments_kind_valid;
--   alter table public.assignments add  constraint assignments_kind_check
--     check (kind in ('exam', 'homework'));
-- ---------------------------------------------------------------------
