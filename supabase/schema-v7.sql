-- =====================================================================
--  The Light Academy — космическият паспорт на ученика (разделът „Профил“)
--  ---------------------------------------------------------------------
--  Таблицата се казва star_cards, а надписът на екрана е „Моят космически
--  паспорт“. Името на таблицата е вътрешно и НЕ се преименува заради
--  надпис: това би значело ново пускане на файл срещу нула полза. Ако
--  вече си пуснала този файл веднъж, няма нужда да го пускаш пак —
--  променени са само обясненията в него.
--
--  ПУСНИ ЦЕЛИЯ ФАЙЛ. Редакторът на Supabase изпълнява само маркираното,
--  ако има маркирано — файл, пуснат на парчета, оставя базата наполовина.
--
--  Какво прави: една нова таблица с по един ред на дете — избраният
--  аватар, избраните теми и кратките отговори към тях („любим отбор“,
--  „любима книга“). Нищо съществуващо не се пипа: без промени по
--  profiles, без промени по политиките на другите таблици.
--
--  КОЙ ВИЖДА КАКВО
--
--  Само детето — своя ред. Нито съученик, нито преподавател, нито
--  администратор минава през политиките отдолу. Това е нарочно: тук
--  детето пише за себе си, а не за училището, и единственото, което
--  прави мястото безопасно, е че никой друг не чете.
--
--  Ако някой ден трябва преподавателят да вижда картите на своите
--  ученици, на дъното на файла стои готовият блок — коментиран, с
--  обяснение какво се променя. Не го пускай, без да си решила, че
--  искаш точно това.
--
--  КАКВО СЕ ПАЗИ И КАКВО НЕ
--
--  Пазят се само кратки идентификатори („football“, „astronaut“) и
--  кратки отговори до 80 знака. Няма снимки, няма качени файлове, няма
--  свободен текст без таван. Аватарите са рисунки в кода на страницата
--  (assets/starcard.js), не файлове в базата — затова тук стои само
--  името на избрания.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
--  Двете проверки на формата
-- ---------------------------------------------------------------------
--  Защо са функции, а не направо в check: ограничението не може да
--  съдържа подзаявка, а за да се провери ВСЕКИ елемент на един масив,
--  трябва точно подзаявка. Вътре в функция това е позволено — тя гледа
--  само стойността, която ѝ подават, и не чете нито една таблица.
--
--  Какво пазят: детето да не може да напише в собствения си ред нито
--  гигантски текст, нито каквото и да е, което страницата после ще
--  показва обратно. Списъкът на темите живее в assets/starcard.js —
--  базата не знае имената им и не бива да ги знае, инак всяка нова тема
--  би искала промяна по базата. Тук се пази ФОРМАТА: кратко име от
--  малки букви, цифри и долна черта.
--
--  Правата НЕ се отнемат от тези две. Ограничението check ги вика при
--  всеки запис от името на влезлия, а те не издават нищо — предикат
--  върху подадената стойност и нищо повече.
-- ---------------------------------------------------------------------
create or replace function public.card_ids_ok(v jsonb)
returns boolean
language sql
immutable
as $$
  select jsonb_typeof(v) = 'array'
     and jsonb_array_length(v) <= 60
     and (select count(*) = 0
            from jsonb_array_elements(v) e
           where jsonb_typeof(e) <> 'string'
              or (e #>> '{}') !~ '^[a-z][a-z0-9_]{0,31}$');
$$;

create or replace function public.card_answers_ok(v jsonb)
returns boolean
language sql
immutable
as $$
  select jsonb_typeof(v) = 'object'
     and length(v::text) <= 4000
     and (select count(*) = 0
            from jsonb_each(v) kv
           where kv.key !~ '^[a-z][a-z0-9_]{0,47}$'
              or jsonb_typeof(kv.value) <> 'string'
              or length(kv.value #>> '{}') > 80);
$$;

-- ---------------------------------------------------------------------
--  Таблицата
-- ---------------------------------------------------------------------
--  Един ред на дете — затова user_id е първичният ключ, а не отделно
--  id. Така „запази картата“ е един upsert и няма как да се появят две
--  карти на едно дете.
-- ---------------------------------------------------------------------
create table if not exists public.star_cards (
  user_id    uuid primary key references public.profiles(id) on delete cascade,
  -- Името на избраната рисунка, например „astronaut“. null значи „още
  -- не е избрал“ — и това е различно от „избрал е и после е махнал“
  -- само по това, че страницата показва подсказка.
  avatar     text,
  -- Избраните теми, по имена: ["football","space","reading"]
  interests  jsonb not null default '[]'::jsonb,
  -- Отговорите към темите: {"football_team":"Левски","book":"Матилда"}
  answers    jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),

  constraint star_cards_avatar_shape
    check (avatar is null or avatar ~ '^[a-z][a-z0-9_]{0,23}$'),
  constraint star_cards_interests_shape check (public.card_ids_ok(interests)),
  constraint star_cards_answers_shape   check (public.card_answers_ok(answers))
);

-- updated_at да не зависи от това дали страницата се е сетила да го
-- прати. Пише го базата, при всеки запис.
create or replace function public.touch_star_card()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists star_cards_touch on public.star_cards;
create trigger star_cards_touch
  before insert or update on public.star_cards
  for each row execute function public.touch_star_card();

-- ---------------------------------------------------------------------
--  Правата
-- ---------------------------------------------------------------------
--  Три неща, и трите са нужни:
--
--  1. RLS включен — без него политиките отдолу са украса.
--  2. Политики само за влезлия собственик.
--  3. Отнети права на `anon`. Supabase по подразбиране дава на `anon`
--     и `authenticated` права върху всичко в схемата public. RLS и
--     така би спрял невлезлия (няма политика за него), но ключалката е
--     безплатна и стои тук, за да не зависи от подразбирането.
-- ---------------------------------------------------------------------
alter table public.star_cards enable row level security;

revoke all on table public.star_cards from anon;
grant select, insert, update, delete on table public.star_cards to authenticated;

drop policy if exists "star card: виждам своята"   on public.star_cards;
drop policy if exists "star card: създавам своята" on public.star_cards;
drop policy if exists "star card: променям своята" on public.star_cards;
drop policy if exists "star card: трия своята"     on public.star_cards;

-- Нито едно условие не е „или“ с нещо друго. Няма роля, няма изключение
-- за администратор, няма преподавател: редът е твой или не съществува
-- за теб.
create policy "star card: виждам своята" on public.star_cards
  for select to authenticated
  using (user_id = auth.uid());

create policy "star card: създавам своята" on public.star_cards
  for insert to authenticated
  with check (user_id = auth.uid());

-- И using, и with check. Само using би позволил на детето да ВЗЕМЕ
-- своя ред и да го препише на чуждо user_id.
create policy "star card: променям своята" on public.star_cards
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "star card: трия своята" on public.star_cards
  for delete to authenticated
  using (user_id = auth.uid());

commit;

-- ---------------------------------------------------------------------
-- Ако трябва да се махне (разделът „Профил“ спира да пази избраното;
-- страницата продължава да се отваря, само че празна):
--   drop table if exists public.star_cards;
--   drop function if exists public.touch_star_card();
--   drop function if exists public.card_ids_ok(jsonb);
--   drop function if exists public.card_answers_ok(jsonb);
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- АКО ПОИСКАШ ПРЕПОДАВАТЕЛЯТ ДА ВИЖДА КАРТИТЕ НА СВОИТЕ УЧЕНИЦИ
-- ---------------------------------------------------------------------
-- Това е решение, не настройка: оттам нататък написаното от детето се
-- чете и от друг човек. Ако го искаш, пусни САМО този блок — само за
-- четене, само за своите ученици, и само докато връзката е действаща.
--
--   create policy "star card: преподавателят вижда своите" on public.star_cards
--     for select to authenticated
--     using (exists (
--       select 1 from public.teaching t
--        where t.student_id = star_cards.user_id
--          and t.teacher_id = auth.uid()
--          and t.active
--     ));
--
-- Ако го пуснеш, кажи го на децата. Място, за което са мислили, че е
-- само тяхно, не бива да се отваря тихо.
-- ---------------------------------------------------------------------

-- Потвърждение, че е минало. Не raise notice: SQL Editor-ът на Supabase
-- показва само таблици с резултат.
select 'Готово' as статус,
       (select count(*) from pg_tables
         where schemaname = 'public' and tablename = 'star_cards') as таблицата,
       (select relrowsecurity from pg_class where oid = 'public.star_cards'::regclass)
         as rls_включен,
       (select count(*) from pg_policies
         where schemaname = 'public' and tablename = 'star_cards') as политики,
       has_table_privilege('anon', 'public.star_cards', 'select') as невлезлите_могат;
