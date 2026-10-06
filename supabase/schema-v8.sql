-- =====================================================================
--  The Light Academy — раздели вътре в един предмет
--  ---------------------------------------------------------------------
--  ПУСНИ ЦЕЛИЯ ФАЙЛ. Редакторът на Supabase изпълнява само маркираното,
--  ако има маркирано — файл, пуснат на парчета, оставя базата наполовина.
--
--  Какво прави: две нови колони в таблица assignments и нищо друго. Без
--  нова таблица, без нова политика, без промяна по съществуващите. Вече
--  качените задания остават точно както са — двете колони са празни за
--  тях и празното значи „не е в раздел“.
--
--  ЗАЩО ДВЕ КОЛОНИ, А НЕ ТАБЛИЦА С РАЗДЕЛИ
--
--  Самите раздели („Подготовка за олимпиада“ → „Общински кръг“) са
--  учебна структура, не данни: те не се менят от ден на ден и не ги
--  въвежда никой през екран. Затова живеят в кода, в assets/tracks.js,
--  точно както програмата по седмици живее в teacher.html. Базата пази
--  само КОЕ задание в кой раздел е.
--
--  Следствието е важно: раздел съществува и когато е празен. Таблото
--  показва и трите кръга от първия ден, за да се види къде какво да се
--  сложи — ако разделите идваха от самите задания, празният кръг просто
--  нямаше да го има.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
--  Двете колони
-- ---------------------------------------------------------------------
--  track   — голямата тема вътре в предмета: 'olimpiada'
--  section — подтемата в нея: 'obshtinski', 'oblasten', 'nacionalen'
--
--  Пазят се кратки имена, не надписи. Надписът се чете от tracks.js и се
--  сменя там; ако в базата стоеше „Общински кръг“, всяка редакция на
--  надписа щеше да иска и промяна по данните.
-- ---------------------------------------------------------------------
alter table public.assignments add column if not exists track   text;
alter table public.assignments add column if not exists section text;

-- Формата, същата като навсякъде другаде: малки букви, цифри, долна
-- черта. Браузърът и без това подава само познати имена, но ограничението
-- е в базата, защото там е единственото място, което никой не заобикаля.
alter table public.assignments drop constraint if exists assignments_track_shape;
alter table public.assignments add  constraint assignments_track_shape
  check (track is null or track ~ '^[a-z][a-z0-9_]{0,31}$');

alter table public.assignments drop constraint if exists assignments_section_shape;
alter table public.assignments add  constraint assignments_section_shape
  check (section is null or section ~ '^[a-z][a-z0-9_]{0,31}$');

-- Подтема без тема е безсмислица: „Общински кръг“ на нищо. Ограничението
-- не позволява да се получи при недоглеждане.
alter table public.assignments drop constraint if exists assignments_section_needs_track;
alter table public.assignments add  constraint assignments_section_needs_track
  check (section is null or track is not null);

commit;

-- ---------------------------------------------------------------------
-- Ако трябва да се махне (разделите изчезват, самите задания остават):
--   alter table public.assignments drop column if exists section;
--   alter table public.assignments drop column if exists track;
-- ---------------------------------------------------------------------

-- Потвърждение, че е минало.
select 'Готово' as статус,
       (select count(*) from information_schema.columns
         where table_schema = 'public' and table_name = 'assignments'
           and column_name in ('track', 'section'))               as нови_колони,
       (select count(*) from pg_constraint
         where conrelid = 'public.assignments'::regclass
           and conname like 'assignments_%section%' or conname like 'assignments_track%')
                                                                   as ограничения,
       (select count(*) from public.assignments where track is not null)
                                                                   as вече_в_раздел;
