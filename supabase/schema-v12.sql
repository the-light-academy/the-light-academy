-- =====================================================================
--  The Light Academy — рожденият ден на ученика
--  ---------------------------------------------------------------------
--  ПУСНИ ЦЕЛИЯ ФАЙЛ. Редакторът на Supabase изпълнява само маркираното,
--  ако има маркирано — файл, пуснат на парчета, оставя базата наполовина.
--
--  Какво прави: една нова колона в profiles и една функция, с която
--  детето си записва рождения ден от паспорта. Нищо друго не се пипа.
--
--  ЗАЩО В profiles, А НЕ В ПАСПОРТА (star_cards)
--
--  Паспортът е частен по устройство: политиките му са само „редът е мой“
--  и никой друг не чете. Рожденият ден обаче трябва да се вижда от теб и
--  от преподавателя на детето — иначе няма как да го честитите. Ако той
--  влезеше в star_cards, щеше да се наложи да се отвори за четене цялата
--  карта, тоест и мечтата, и любимата книга, и всичко останало, което
--  детето е писало само за себе си. Затова рожденият ден стои в
--  profiles, където „преподавателят чете своите ученици“ вече важи, а
--  паспортът си остава затворен.
--
--  КОЙ КАКВО МОЖЕ
--
--  Чете: самото дете (profiles: read own), преподавателят му
--  (profiles: teacher reads own students) и админът (profiles: admin
--  all). Никой друг — съученик не вижда чужд профил.
--
--  Пише: детето — САМО през функцията set_my_birthday и САМО в своя ред
--  и САМО тази колона. Няма политика за update на profiles за ученик и
--  тук не се добавя такава: това би значело, че детето може да си пипне
--  и ролята, и класа, и is_admin. Админът пише направо, както досега.
--
--  Датата не може да е в бъдещето и не може да е отпреди 1995 г. Това
--  го пази базата, не браузърът: проверката за „отдавна“ е ограничение,
--  а за „в бъдещето“ — тригер, защото current_date се мени и в check не
--  се допуска.
-- =====================================================================

-- ---------------------------------------------------------------------
--  1. Колоната
-- ---------------------------------------------------------------------
alter table public.profiles
  add column if not exists birthday date;

comment on column public.profiles.birthday is
  'Рожден ден. Детето си го пише само през public.set_my_birthday().';

alter table public.profiles drop constraint if exists profiles_birthday_sane;
alter table public.profiles add  constraint profiles_birthday_sane
  check (birthday is null or birthday >= date '1995-01-01');

-- ---------------------------------------------------------------------
--  2. „Не в бъдещето“
-- ---------------------------------------------------------------------
--  Тригер, а не check: current_date не е immutable и в ограничение не се
--  допуска. Тригерът важи за всеки път — и за функцията отдолу, и за
--  админа, който пише направо в таблицата.
-- ---------------------------------------------------------------------
create or replace function public.profiles_birthday_guard()
returns trigger
language plpgsql
as $$
begin
  if new.birthday is not null and new.birthday > current_date then
    raise exception 'Рожденият ден не може да е в бъдещето: %', new.birthday
      using errcode = '23514';
  end if;
  return new;
end $$;

drop trigger if exists profiles_birthday_guard on public.profiles;
create trigger profiles_birthday_guard
  before insert or update of birthday on public.profiles
  for each row execute function public.profiles_birthday_guard();

-- ---------------------------------------------------------------------
--  3. Функцията, с която детето си записва рождения ден
-- ---------------------------------------------------------------------
--  security definer значи, че тялото тича с правата на собственика на
--  функцията и минава покрай RLS. Затова тя прави точно едно нещо и
--  няма как да направи друго:
--
--  · пипа САМО колоната birthday;
--  · САМО на реда, чието id е auth.uid() — id-то не е параметър и не
--    може да се подаде отвън;
--  · search_path е закован, за да не може името на таблица да бъде
--    подменено от извикващия.
--
--  null изчиства датата — детето има право да си я махне.
-- ---------------------------------------------------------------------
create or replace function public.set_my_birthday(p_birthday date)
returns date
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  me  uuid := auth.uid();
  out date;
begin
  if me is null then
    raise exception 'Няма влязъл потребител.' using errcode = '28000';
  end if;
  if p_birthday is not null then
    if p_birthday > current_date then
      raise exception 'Рожденият ден не може да е в бъдещето.' using errcode = '23514';
    end if;
    if p_birthday < date '1995-01-01' then
      raise exception 'Тази дата е твърде отдавна.' using errcode = '23514';
    end if;
  end if;

  update public.profiles p
     set birthday = p_birthday
   where p.id = me
  returning p.birthday into out;

  if not found then
    raise exception 'Няма такъв профил.' using errcode = 'P0002';
  end if;
  return out;
end $$;

-- В Postgres всяка нова функция получава EXECUTE от PUBLIC. При
-- security definer това значи „всеки може да я извика“ — включително
-- невлезлият anon. Затова правата се отнемат и се дават поименно.
revoke all on function public.set_my_birthday(date) from public, anon;
grant execute on function public.set_my_birthday(date) to authenticated;

-- ---------------------------------------------------------------------
--  4. Проверка — какво се получи
-- ---------------------------------------------------------------------
select
  (select count(*) from information_schema.columns
    where table_schema = 'public' and table_name = 'profiles'
      and column_name = 'birthday')                                as има_колона,
  (select count(*) from pg_constraint
    where conrelid = 'public.profiles'::regclass
      and conname = 'profiles_birthday_sane')                      as ограничение,
  (select count(*) from pg_trigger
    where tgrelid = 'public.profiles'::regclass
      and tgname = 'profiles_birthday_guard')                      as тригер,
  (select count(*) from pg_proc
    where proname = 'set_my_birthday'
      and pronamespace = 'public'::regnamespace)                   as функция,
  (select has_function_privilege('authenticated',
            'public.set_my_birthday(date)', 'execute'))            as учителите_могат,
  (select has_function_privilege('anon',
            'public.set_my_birthday(date)', 'execute'))            as невлезлият_може,
  (select count(*) from public.profiles where birthday is not null) as попълнени;
