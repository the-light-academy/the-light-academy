-- =====================================================================
--  The Light Academy — въпросите от родителите
--  ---------------------------------------------------------------------
--  ПУСНИ ЦЕЛИЯ ФАЙЛ. Редакторът на Supabase изпълнява само маркираното,
--  ако има маркирано — файл, пуснат на парчета, оставя базата наполовина.
--
--  В дъното на сайта вече има форма „Имате въпрос? Пишете ни“. Тук е
--  другата ѝ половина: мястото, където пристига написаното, и правилата
--  кой може да пише и кой да чете.
--
--  Кой какво може:
--
--    · Родителят (не е влязъл никъде) МОЖЕ само да ДОБАВИ въпрос.
--      Не може да чете — нито своя, нито чужд. Затова на anon се дава
--      само insert; select изобщо не му е разрешен, независимо от
--      политиките.
--    · Администраторът чете въпросите, отмята ги като обработени и си
--      пише бележка. Преподавателите НЕ ги виждат: това са запитвания
--      към академията, не работа по конкретно дете.
--
--  Срещу спам, без да се пита родителят за нищо излишно:
--
--    · Всяко поле си има таван на дължината, а въпросът — и под.
--    · Иска се поне един начин за връзка: имейл или телефон.
--    · Пазач върху скоростта: не повече от 10 въпроса за минута и 100
--      за час от цялата страница. Това не пречи на жив човек, но спира
--      машина, която удря в кръг.
--    · Формата носи и скрито поле-примамка; то се проверява в браузъра
--      и никога не стига дотук.
--
--  След като мине файлът, въпросите се четат в таблото, раздел
--  „Въпроси“ (вижда се само от администратор).
-- =====================================================================

create table if not exists public.parent_questions (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  ime         text not null,
  imeyl       text,
  telefon     text,
  vupros      text not null,
  handled     boolean not null default false,
  handled_at  timestamptz,
  handled_by  uuid references public.profiles(id) on delete set null,
  belejka     text,

  constraint parent_questions_ime_len
    check (char_length(btrim(ime)) between 2 and 120),
  constraint parent_questions_vupros_len
    check (char_length(btrim(vupros)) between 10 and 4000),
  constraint parent_questions_imeyl_len
    check (imeyl is null or char_length(imeyl) <= 200),
  constraint parent_questions_telefon_len
    check (telefon is null or char_length(telefon) <= 60),
  constraint parent_questions_belejka_len
    check (belejka is null or char_length(belejka) <= 4000),

  --  Без начин за връзка въпросът няма смисъл — няма как да се отговори.
  constraint parent_questions_vruzka check (
    coalesce(btrim(imeyl), '') <> '' or coalesce(btrim(telefon), '') <> ''),

  --  Отметнато, но без кога — това е полуотметнато и не се пази.
  constraint parent_questions_handled_kodga check (
    (handled and handled_at is not null) or
    (not handled and handled_at is null and handled_by is null))
);

create index if not exists parent_questions_nov_idx
  on public.parent_questions (created_at desc) where not handled;
create index if not exists parent_questions_vsi_idx
  on public.parent_questions (created_at desc);

alter table public.parent_questions enable row level security;

-- ---------------------------------------------------------------------
--  ПРАВА ВЪРХУ ТАБЛИЦАТА
--  От 30 октомври 2026 г. Supabase спира да дава автоматично права на
--  Data API върху НОВИ таблици в public. Затова таблицата си носи
--  правата в същия файл, който я създава.
--
--  anon          — САМО insert. Това е единственото място в платформата,
--                  където невлязъл човек пише в базата, и той не може
--                  да прочете обратно нищо, дори своето.
--  authenticated — през политиките; реално чете само администраторът.
--  service_role  — за Edge функциите; ключът им заобикаля RLS, но БЕЗ
--                  право върху таблицата пак не минава.
-- ---------------------------------------------------------------------
revoke all on table public.parent_questions from anon;
grant insert on table public.parent_questions to anon;
grant select, insert, update, delete on table public.parent_questions to authenticated;
grant select, insert, update, delete on table public.parent_questions to service_role;

drop policy if exists "parent questions: anyone asks" on public.parent_questions;
drop policy if exists "parent questions: admin reads" on public.parent_questions;
drop policy if exists "parent questions: admin writes" on public.parent_questions;

-- Пита всеки — но само пита. Полетата за обработката трябва да дойдат
-- празни: инак някой би могъл да вкара въпрос, вече отметнат като
-- приключен, и той никога да не се види.
create policy "parent questions: anyone asks" on public.parent_questions
  for insert to anon, authenticated
  with check (handled = false and handled_at is null
              and handled_by is null and belejka is null);

create policy "parent questions: admin reads" on public.parent_questions
  for select to authenticated
  using (public.is_admin());

create policy "parent questions: admin writes" on public.parent_questions
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- ---------------------------------------------------------------------
--  Пазач върху скоростта
--  Таблицата е единственото отворено за писане място. Без таван една
--  машина би могла да я напълни за минути. Числата са нарочно високи:
--  жив родител никога не стига до тях.
-- ---------------------------------------------------------------------
create or replace function public.parent_questions_guard()
returns trigger language plpgsql security definer
set search_path = public, pg_temp as $$
declare
  za_minuta int;
  za_chas   int;
begin
  select count(*) into za_minuta from public.parent_questions
   where created_at > now() - interval '1 minute';
  if za_minuta >= 10 then
    raise exception 'Твърде много въпроси наведнъж. Опитайте пак след минута.'
      using errcode = '53400';
  end if;

  select count(*) into za_chas from public.parent_questions
   where created_at > now() - interval '1 hour';
  if za_chas >= 100 then
    raise exception 'Твърде много въпроси за кратко. Опитайте пак по-късно.'
      using errcode = '53400';
  end if;

  --  Каквото дойде отвън, се подрязва тук: полетата се записват без
  --  празнините отпред и отзад, а празният низ става null.
  new.ime     := btrim(new.ime);
  new.imeyl   := nullif(btrim(coalesce(new.imeyl, '')), '');
  new.telefon := nullif(btrim(coalesce(new.telefon, '')), '');
  new.vupros  := btrim(new.vupros);
  return new;
end $$;

revoke all on function public.parent_questions_guard() from public;

drop trigger if exists parent_questions_guard_tr on public.parent_questions;
create trigger parent_questions_guard_tr
  before insert on public.parent_questions
  for each row execute function public.parent_questions_guard();

-- Проверка: таблицата е вътре и anon може само да пише.
select
  (select count(*) from public.parent_questions)                 as vuprosi,
  has_table_privilege('anon', 'public.parent_questions', 'insert') as anon_pishe,
  has_table_privilege('anon', 'public.parent_questions', 'select') as anon_chete;
