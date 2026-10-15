-- =====================================================================
--  The Light Academy — обратна връзка за родителя
--  ---------------------------------------------------------------------
--  ПУСНИ ЦЕЛИЯ ФАЙЛ. Редакторът на Supabase изпълнява само маркираното,
--  ако има маркирано — файл, пуснат на парчета, оставя базата наполовина.
--
--  Какво прави: една нова таблица feedback_reports. В нея стои всичко,
--  което пишеш за едно дете за един период — и числата, с които е било
--  написано. Нищо друго не се пипа.
--
--  ЗАЩО СЕ ПАЗИ, А НЕ СЕ ПРАВИ ВСЕКИ ПЪТ НАНОВО
--
--  Отчетът е документ, изпратен на родителя. След месец трябва да се
--  вижда ТОЧНО какво е било написано и с какви числа — иначе „миналия
--  път казахме, че е 72%“ няма как да се провери. Затова числата се
--  записват в stats като снимка в мига на писането: нови домашни после
--  не местят стар отчет.
--
--  Другото е по-просто: започваш отчет днес, дописваш го утре. Чернова,
--  която живее само в браузъра, се губи при презареждане.
--
--  КОЙ КАКВО МОЖЕ
--
--  Чете: авторът, всеки преподавател на това дете и админът. Нарочно и
--  другият преподавател на същото дете — в академия с трима души
--  „какво писахме на родителя на Иван“ трябва да се види, преди да се
--  напише следващото.
--
--  Пише: преподавателят — само отчети за СВОИ ученици и само на свое
--  име. Поправя и трие само своите (админът — всичко).
--
--  ДЕТЕТО НЕ ЧЕТЕ ТОВА.
--
--  Няма политика за ученик и тук не се добавя такава. Обратната връзка
--  е разговор между преподавателя и родителя: в нея стоят неща, които
--  се казват за дете, а не на дете („разсейва се“, „трудно сяда сам“).
--  Ако някой ден трябва и детето да вижда нещо, то ще е друго поле,
--  нарочно написано за него, не това.
--
--  СТРАНИЦАТА РАБОТИ И БЕЗ ТОЗИ ФАЙЛ
--
--  Таблото хваща „няма такава таблица“ (42P01) и показва жълта бележка
--  „пусни supabase/schema-v15.sql“ вместо да се счупи.
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
--  1. Таблицата
-- ---------------------------------------------------------------------
create table if not exists public.feedback_reports (
  id          uuid primary key default gen_random_uuid(),
  student_id  uuid not null references public.profiles(id) on delete cascade,
  teacher_id  uuid not null references public.profiles(id) on delete cascade,

  -- Периодът, за който е отчетът. Двете дати се виждат в документа.
  period_from date not null,
  period_to   date not null,

  -- Текстът. Всяко поле е отделен раздел в документа; празните се
  -- прескачат при печат, за да не остават заглавия без съдържание.
  summary     text not null default '',  -- Накратко
  improved    text not null default '',  -- Какво се подобри
  focus       text not null default '',  -- Върху какво наблягаме
  noticed     text not null default '',  -- Какво забелязвам
  next_steps  text not null default '',  -- Какво предстои и какво може вкъщи

  -- Снимка на числата в мига на писането: предадени работи, среден
  -- резултат, разликата спрямо предходния период, темите. Таблото ги
  -- смята и ги записва тук — не се пресмятат наново при отваряне.
  stats       jsonb not null default '{}'::jsonb,

  -- 'draft' се пише още, 'sent' е изпратен на родителя. Отбелязва се на
  -- ръка: платформата не праща писма, PDF-ът се сваля и се изпраща.
  status      text not null default 'draft'
              check (status in ('draft','sent')),
  sent_at     timestamptz,

  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),

  constraint feedback_period_sane check (period_to >= period_from),
  -- Период в бъдещето е грешка при писане, не отчет.
  constraint feedback_period_not_future check (period_to <= current_date + 1),
  constraint feedback_sent_has_date
    check ((status = 'sent') = (sent_at is not null))
);

create index if not exists feedback_reports_student_idx
  on public.feedback_reports (student_id, period_to desc);

comment on table public.feedback_reports is
  'Обратна връзка за родителя: какво пишем за едно дете за един период, и с какви числа.';

-- updated_at го пише базата, не страницата.
create or replace function public.touch_feedback_report()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists feedback_reports_touch on public.feedback_reports;
create trigger feedback_reports_touch
  before insert or update on public.feedback_reports
  for each row execute function public.touch_feedback_report();

-- ---------------------------------------------------------------------
--  2. Кой какво може
-- ---------------------------------------------------------------------
alter table public.feedback_reports enable row level security;

drop policy if exists "feedback: read" on public.feedback_reports;
create policy "feedback: read" on public.feedback_reports
  for select using (
    public.is_admin()
    or teacher_id = auth.uid()
    or public.teaches(student_id)
  );

-- Пише се само на свое име и само за свой ученик. Двете заедно: иначе
-- преподавател би могъл да напише отчет за чуждо дете или да подпише
-- чужд отчет със свое име.
drop policy if exists "feedback: write own" on public.feedback_reports;
create policy "feedback: write own" on public.feedback_reports
  for insert with check (
    teacher_id = auth.uid()
    and (public.is_admin() or public.teaches(student_id))
  );

drop policy if exists "feedback: edit own" on public.feedback_reports;
create policy "feedback: edit own" on public.feedback_reports
  for update using (public.is_admin() or teacher_id = auth.uid())
          with check (public.is_admin() or teacher_id = auth.uid());

drop policy if exists "feedback: delete own" on public.feedback_reports;
create policy "feedback: delete own" on public.feedback_reports
  for delete using (public.is_admin() or teacher_id = auth.uid());

-- Правата на самата таблица. Политиките решават КОИ редове, но без
-- grant ролята няма достъп изобщо — и всичко отгоре пада с „permission
-- denied“, преди политиката да е казала дума. anon нарочно липсва:
-- невлязъл човек няма работа с обратната връзка за дете.
grant select, insert, update, delete on table public.feedback_reports to authenticated;

-- ---------------------------------------------------------------------
--  3. Проверка — какво се получи
-- ---------------------------------------------------------------------
select
  (select count(*) from information_schema.tables
    where table_schema = 'public' and table_name = 'feedback_reports')   as има_таблица,
  (select count(*) from pg_policies
    where schemaname = 'public' and tablename = 'feedback_reports')      as политики,
  (select relrowsecurity from pg_class
    where oid = 'public.feedback_reports'::regclass)                     as защитата_е_вдигната,
  (select count(*) from pg_trigger
    where tgrelid = 'public.feedback_reports'::regclass
      and tgname = 'feedback_reports_touch')                             as тригер,
  (select has_table_privilege('authenticated', 'public.feedback_reports', 'select'))
                                                                         as влезлите_имат_достъп,
  (select has_table_privilege('anon', 'public.feedback_reports', 'select'))
                                                                         as невлезлият_има,
  (select count(*) from public.feedback_reports)                         as написани_отчети;
