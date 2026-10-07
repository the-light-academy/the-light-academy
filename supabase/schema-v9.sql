-- =====================================================================
--  The Light Academy — интерактивни уроци в календара
--  ---------------------------------------------------------------------
--  ПУСНИ ЦЕЛИЯ ФАЙЛ. Редакторът на Supabase изпълнява само маркираното,
--  ако има маркирано — файл, пуснат на парчета, оставя базата наполовина.
--
--  Какво прави: разрешава трети вид задание — 'lesson' — и го пази да не
--  влиза в статистиката. Нова таблица няма, нова политика няма, вече
--  качените домашни и изпити не се пипат.
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
--  процент. Затова тук стоят и двете пазилки отдолу.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
--  1. Третият вид
-- ---------------------------------------------------------------------
--  Старото ограничение е безименно (Postgres го е кръстил сам, когато
--  таблицата е създадена с `check (kind in (...))` вътре в реда). Затова
--  се търси по съдържание, а не по име: всяко ограничение върху
--  assignments, което споменава kind, пада, и на негово място идва едно
--  с име, което после се познава.
-- ---------------------------------------------------------------------
do $$
declare c record;
begin
  for c in
    select conname
    from pg_constraint
    where conrelid = 'public.assignments'::regclass
      and contype = 'c'
      and pg_get_constraintdef(oid) ilike '%kind%'
  loop
    execute format('alter table public.assignments drop constraint %I', c.conname);
  end loop;
end $$;

alter table public.assignments add constraint assignments_kind_valid
  check (kind in ('exam', 'homework', 'lesson'));


-- ---------------------------------------------------------------------
--  2. Урокът няма точки
-- ---------------------------------------------------------------------
--  max_points по подразбиране е 100. Ако урок влезе със 100 точки, в
--  портала детето ще види „0 от 100“ и ще реши, че е изостанало с нещо,
--  което изобщо не се оценява.
--
--  Нарочно е тригер, а не check: check-ът би отказал реда и би върнал
--  грешка върху съвсем редовен insert, в който просто не е писано
--  max_points. Тригерът мълчаливо слага нулата и всичко минава.
-- ---------------------------------------------------------------------
create or replace function public.lesson_has_no_points()
returns trigger
language plpgsql
as $$
begin
  if new.kind = 'lesson' then
    new.max_points := 0;
  end if;
  return new;
end;
$$;

revoke all on function public.lesson_has_no_points() from public, anon;

drop trigger if exists assignments_lesson_points on public.assignments;
create trigger assignments_lesson_points
  before insert or update on public.assignments
  for each row execute function public.lesson_has_no_points();

-- Вече качените уроци (ако файлът се пуска втори път) се оправят наведнъж.
update public.assignments set max_points = 0
  where kind = 'lesson' and max_points <> 0;


-- ---------------------------------------------------------------------
--  3. На урок не се пише опит
-- ---------------------------------------------------------------------
--  Пръстенът в портала е „колко от отвореното ти е зад гърба“. Опит
--  върху урок би го изкривил, а и няма откъде да дойде: страницата на
--  урока не предава нищо. Остава само ръчно сложен ред — и точно него
--  спира това.
--
--  Check не може да се ползва: трябва да се погледне в друга таблица, а
--  в check подзаявки не се допускат.
-- ---------------------------------------------------------------------
create or replace function public.no_attempt_on_lesson()
returns trigger
language plpgsql
security definer set search_path = public
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

commit;

-- ---------------------------------------------------------------------
-- Ако трябва да се върне назад (уроците остават в таблицата, но вече
-- няма да минават):
--   drop trigger if exists attempts_not_on_lesson on public.attempts;
--   drop trigger if exists assignments_lesson_points on public.assignments;
--   drop function if exists public.no_attempt_on_lesson();
--   drop function if exists public.lesson_has_no_points();
--   delete from public.assignments where kind = 'lesson';
--   alter table public.assignments drop constraint assignments_kind_valid;
--   alter table public.assignments add  constraint assignments_kind_valid
--     check (kind in ('exam', 'homework'));
-- ---------------------------------------------------------------------

-- Потвърждение, че е минало.
select 'Готово' as статус,
       (select count(*) from pg_constraint
         where conrelid = 'public.assignments'::regclass
           and conname = 'assignments_kind_valid')                as ограничение,
       (select count(*) from pg_trigger
         where tgrelid = 'public.assignments'::regclass
           and tgname = 'assignments_lesson_points')              as тригер_точки,
       (select count(*) from pg_trigger
         where tgrelid = 'public.attempts'::regclass
           and tgname = 'attempts_not_on_lesson')                 as тригер_опити,
       (select count(*) from public.assignments where kind = 'lesson')
                                                                  as качени_уроци;
