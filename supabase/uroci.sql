-- =====================================================================
--  The Light Academy — интерактивните уроци
--  ---------------------------------------------------------------------
--  ПУСНИ ЦЕЛИЯ ФАЙЛ. Пуска се толкова пъти, колкото трябва: вече
--  записаните уроци се обновяват, нови не се дублират.
--
--  ПРЕДИ ТОВА веднъж трябва да е минал supabase/schema-v9.sql — той
--  разрешава вида 'lesson'. Без него тези редове ще спрат с грешка за
--  нарушено ограничение.
--
--  КАК СЕ ДОБАВЯ УРОК
--  1. Файлът на урока влиза в папка uroci/ (виж uroci/README.md).
--  2. Копираш един блок отдолу и сменяш в него четири неща:
--       slug   — кратко име без интервали, уникално: 'urok-4-w05'
--       title  — както ще се чете в календара
--       url    — пътят до файла: 'uroci/urok_4_w05.html'
--                или пълен чужд адрес: 'https://wordwall.net/...'
--       week   — коя седмица е, и grades — за кой клас
--  3. Пускаш файла. Урокът влиза като ЧЕРНОВА.
--
--  max_points е 0 и остава 0 — урокът не се оценява и базата не го
--  приема с други точки (ограничението се казва
--  assignments_lesson_no_points).
--  4. В таблото: „Сложи в библиотеката“, после „Дай на моите“.
--
--  published нарочно липсва в on conflict do update — дали урокът е в
--  библиотеката се решава от таблото, не от този файл. Иначе всяко
--  пускане щеше да връща обратно вече публикуваното.
--
--  sort_order: ползва се схемата от домашните — клас · 100 + седмица
--  (4. клас, седмица 5 → 405). Уроците са с 10 000 отгоре, за да стоят
--  отделно: 10405.
--
--  description е един ред под заглавието — какво ще се случи в часа.
--  Вижда се в календара и в портала. Може да се остави null.
-- =====================================================================

-- Колоната за описанието идва от supabase/schema-v14.sql. Повтаря се и
-- тук (add column IF NOT EXISTS, тоест нищо не разваля), за да няма
-- значение кой от двата файла е пуснат първи.
alter table public.assignments
  add column if not exists description text;

-- ---------------------------------------------------------------------
-- ОБРАЗЕЦ — копирай блока и смени четирите неща.
-- Заради `where false` този ред НЕ влиза в базата; за истински урок
-- махни последния ред с where и напиши своето.
-- ---------------------------------------------------------------------
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
select
  'urok-4-w05',                               -- slug
  'Урок — Деление с едноцифрено число',       -- title
  'lesson',
  'uroci/urok_4_w05.html',                    -- url
  'Делим на части, докато не остане нищо',    -- description: един ред отдолу, може и null
  0,                                          -- max_points: урокът НЕ се оценява, винаги 0
  false,
  10405,                                      -- sort_order: 10000 + клас·100 + седмица
  5,                                          -- week
  (select id from public.subjects where slug = 'matematika'),
  '{4}'                                       -- grades
where false                                   -- ← махни този ред за истински урок
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;


-- ---------------------------------------------------------------------
-- Оттук надолу се редят истинските уроци.
-- ---------------------------------------------------------------------

-- 7. клас, седмица 2 — три учебни часа: преговор на 6. клас (рационални
-- числа и степени; уравнения, пропорции, проценти) и първата нова тема
-- „числена стойност на израз и едночлени“.
-- Страницата е ЗА ПРЕПОДАВАТЕЛЯ: вижда се планът по минути, отговорите
-- на всички задачи и бележките за работата с децата.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-7-w02',
   'Урок 1 — От числата към буквите',
   'lesson',
   'uroci/urok_7_w02.html',
   'Три часа преговор и първата нова тема',
   0,
   false,
   10702,
   2,
   (select id from public.subjects where slug = 'matematika'),
   '{7}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва: решава се от таблото.



-- 6. клас, седмица 8 — „Подводница „Знак““: обобщение на седмици 4–8.
-- Пет спирки надолу и обратно нагоре — знак и модул, събиране,
-- изваждане, умножение и накрая всичко в един израз. Дълбокомерът е
-- числовата ос, изправена вертикално: нулата е повърхността, минусът е
-- надолу, а модулът е дълбочината. Във всяка спирка има по една игра
-- (четене на показание, потапяне по оста, „кой е по-дълбоко“, знакът
-- на произведението) и накрая люк с шифър от собствените им отговори.
-- Деление НЯМА — то идва в седмица 9.
-- Страницата е ЗА ЧАСА: не иска вход, нищо не предава и никъде няма
-- поле за въвеждане на отговор — отговорът се показва с бутон.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-6-w08',
   'Урок — Подводница „Знак“',
   'lesson',
   'uroci/urok_6_w08.html',
   'Обобщение на седмици 4–8 в пет спирки: знак и модул, събиране, изваждане, умножение и всичко заедно. Дълбокомерът е числовата ос изправена, има по една игра на спирка и люк с шифър накрая. 45 задачи, отговорите се показват с бутон.',
   0,
   false,
   10608,
   8,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;


-- 6. клас, седмица 10 — „Гран при Каталуня“: същата писта и същият
-- двигател като „Рационално Гран при“, но върху УМНОЖЕНИЕ и ДЕЛЕНИЕ на
-- рационални числа. Седем теми на по четири нива — знакът при · и :,
-- десетични, дроби, деление чрез обратно число, степени на отрицателни
-- числа, изрази с няколко действия и свойствата. Задачите се раждат на
-- място, затова две гонки не са еднакви. Три части и накрая таблица по
-- теми за преподавателя.
-- Страницата е ЗА ЧАСА: не иска вход и нищо не предава — урокът не се
-- оценява. Пази напредъка си отделно от урока за седмица 6.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-6-w10',
   'Урок — Гран при Каталуня',
   'lesson',
   'uroci/urok_6_w10.html',
   'Състезание на писта: умножение и деление на рационални числа в три части, с таблица по теми за учителя.',
   0,
   false,
   10610,
   10,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;


-- 6. клас, седмица 6 — „Рационално Гран при“: състезание на писта за
-- Формула 1. От 2 до 8 деца играят на една клавиатура, всяко с по два
-- клавиша; колата върви напред толкова, колкото е отговорило вярно на
-- въпроси за рационални числа — отрицателни числа, числова ос, модул,
-- сравняване, събиране с еднакви и с различни знаци, свойства.
-- Три части (Състезание, Реванш, „Брад Пит във Формула 1“) и накрая
-- таблица по теми за преподавателя: къде са грешките.
-- Страницата е ЗА ЧАСА: не иска вход и нищо не предава — урокът не се
-- оценява.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-6-w06',
   'Урок — Рационално Гран при',
   'lesson',
   'uroci/urok_6_w06.html',
   'Състезание на писта за Формула 1',
   0,
   false,
   10606,
   6,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва: решава се от таблото.

-- 4. клас, седмица 1 — „Горски задачи“: генератор на текстови задачи с
-- числата до 1000. Събиране, изваждане, „с колко повече“, „пъти повече“,
-- разделяне поравно и двустъпкови. Всяка задача има подсказка, кубчета и
-- решение, а задачите не свършват — става и за загряване в друга седмица.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-4-w01',
   'Урок — Горски задачи',
   'lesson',
   'uroci/urok_4_w01.html',
   'Безкрайни текстови задачи с числата до 1000',
   0,
   false,
   10401,
   1,
   (select id from public.subjects where slug = 'matematika'),
   '{4}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва: решава се от таблото.

-- 4. клас, седмица 2 — „Космическа мисия“: пет планети по четири задачи.
-- Луната (разряди), Марс (ред на действията), Юпитер (неизвестното число),
-- Сатурн (мерки и време), Нептун (съставни задачи). Между планетите има
-- паузи с движение, а на всяка — бележка за преподавателя.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-4-w02',
   'Урок — Космическа мисия',
   'lesson',
   'uroci/urok_4_w02.html',
   'Пет планети, пет теми и паузи с движение',
   0,
   false,
   10402,
   2,
   (select id from public.subjects where slug = 'matematika'),
   '{4}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва: решава се от таблото.

-- 4. клас, седмица 18 — „Математическо приключение“: 25 задачи в шест
-- раздела (числа и действия, умножение и деление, ред на действията, мерни
-- единици и време, геометрия, предизвикателства). За обобщението на срока.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-4-w18',
   'Урок — Математическо приключение',
   'lesson',
   'uroci/urok_4_w18.html',
   '25 задачи от целия първи срок, от лесни към трудни',
   0,
   false,
   10418,
   18,
   (select id from public.subjects where slug = 'matematika'),
   '{4}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва: решава се от таблото.

-- 5. клас, седмица 3 — „Да поправим грешките“: сгрешените задачи от
-- входното ниво, а след всяка поправена идва подобна задача. Прави се в
-- часа за анализ на входното ниво.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-5-w03',
   'Урок — Да поправим грешките',
   'lesson',
   'uroci/urok_5_w03.html',
   'Сгрешените задачи от входното ниво, една по една',
   0,
   false,
   10503,
   3,
   (select id from public.subjects where slug = 'matematika'),
   '{5}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва: решава се от таблото.

-- 5. клас, седмица 9 — „НОД, НОК и пицата“: машината за делители и
-- плочките в банята (НОД), жабката и зайчето по оста (НОК), нарязаната
-- пица (обикновената дроб) и три задачи за мислене. Покрива и седмица 8,
-- и отваря темата на седмица 10.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-5-w09',
   'Урок — НОД, НОК и пицата',
   'lesson',
   'uroci/urok_5_w09.html',
   'Плочки, жабка и зайче, и една нарязана пица',
   0,
   false,
   10509,
   9,
   (select id from public.subjects where slug = 'matematika'),
   '{5}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва: решава се от таблото.

-- 5. клас, седмица 33 — „Архитектът на Мишо“: 14 задачи в четири нива —
-- десетични дроби, части от число, мерни единици, периметър и лице, НОД и
-- НОК, проценти и движение. За годишния преговор. Задачите са кръстени на
-- Мишо и Боян — имената са в текста на страницата.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-5-w33',
   'Урок — Архитектът на Мишо',
   'lesson',
   'uroci/urok_5_w33.html',
   'Къща се строи с дроби, проценти, мерки и лице',
   0,
   false,
   10533,
   33,
   (select id from public.subjects where slug = 'matematika'),
   '{5}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва: решава се от таблото.

-- 6. клас, седмица 5 — „Отборът по оста“: план за ТРИ учебни часа по 45
-- минути за двама ученици, които работят като отбор. 28 задачи и 5 игри.
-- Час 1 е ос, модул и сравняване (седмици 4–5), час 2 е събирането
-- (седмица 6), час 3 — свойствата и поглед към изваждането (седмица 7).
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-6-w05',
   'Урок — Отборът по оста',
   'lesson',
   'uroci/urok_6_w05.html',
   'Три учебни часа по числовата ос — двама като отбор',
   0,
   false,
   10605,
   5,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва: решава се от таблото.

-- 6. клас, седмица 23 — „Вероятности и уравнения“: осем задачи за
-- вероятност с нарисувани зарове, монети и топки, и осем двустъпкови
-- уравнения, всяко с везна до себе си. Вероятността се приема само като
-- съкратена докрай дроб.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-6-w23',
   'Урок — Вероятности и уравнения',
   'lesson',
   'uroci/urok_6_w23.html',
   'Зарове, топки и везна',
   0,
   false,
   10623,
   23,
   (select id from public.subjects where slug = 'matematika'),
   '{6}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва: решава се от таблото.


-- 7. клас, седмица 7 — „Разходка из Париж“: трите формули за съкратено
-- умножение, по една на спирка. На всяка спирка формулата първо се
-- ВИЖДА: квадратът (a + b)² се разглобява на четири парчета с бутон,
-- (a − b)² е същият квадрат с две отрязани ивици, а a² − b² се
-- пренарежда в правоъгълник. После девет задачи от лесни към трудни и
-- игра: асансьорът на кулата, фалшификатите в Лувъра, мостовете на Сена
-- и уличният художник на Монмартър. Четвъртата спирка завършва с
-- творческо ателие — три задачи с хартия и цветни моливи.
-- Страницата е ЗА ЧАСА: не иска вход, нищо не предава и никъде няма
-- поле за въвеждане на отговор — отговорът се показва с бутон.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-7-w07',
   'Урок — Разходка из Париж',
   'lesson',
   'uroci/urok_7_w07.html',
   'Четири спирки в Париж и трите формули за съкратено умножение: (a + b)², (a − b)² и (a − b)(a + b). Всяка формула първо се вижда на картинка, после се смята, а накрая се играе. Накрая — творческо ателие на Монмартър.',
   0,
   false,
   10707,
   7,
   (select id from public.subjects where slug = 'matematika'),
   '{7}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;


-- 7. клас, седмица 6 — „Лего сейфът“: умножение на многочлен с едночлен
-- и на многочлен с многочлен, за ДВАМА на един екран. Дванайсет задачи
-- от лесни към трудни; първите три минават през лего плоча, на която
-- произведението се вижда като площ, разделена на парчета. По средата
-- има пауза — игра на бързина с две клавиша (F и J), без математика.
-- Накрая escape ключалка: четирите цифри на кода излизат от техните
-- собствени отговори, а при грешка сейфът казва само КОЛКО цифри са на
-- вярно място.
-- Страницата е ЗА ЧАСА: не иска вход и нищо не предава — урокът не се
-- оценява.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-7-w06',
   'Урок — Лего сейфът',
   'lesson',
   'uroci/urok_7_w06.html',
   'Три раздела за дъската: многочлен · многочлен, рационални числа ±, формули за съкратено умножение. С лего плочи, числова ос, пудели и сейф с четири ключалки — отговорите се показват с бутон, нищо не се въвежда.',
   0,
   false,
   10706,
   6,
   (select id from public.subjects where slug = 'matematika'),
   '{7}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва: решава се от таблото.
-- 7. клас, седмица 7 — „Изход от Матрицата“: умножение на многочлен с
-- многочлен като стая за бягство за ДВАМА. Пет сектора с 35 задачи
-- (436–448 от сборника плюс пет за загрявка) и три начина да се
-- отговори: РЕШЕТКА — всяко квадратче е едно произведение, после се
-- привежда; ЧИПОВЕ — отговорът се сглобява от членове, а сред тях стоят
-- и членовете ОТПРЕДИ привеждането, тоест най-честата грешка; ЧИСЛО —
-- уравненията, в които x² се унищожава (пет от тях с дробен корен).
-- Между секторите е ГЛИТЧ: бърза игра „вярно или грешно“ на два чифта
-- клавиша (A/Z и K/M), с общи точки за отбора и бутон СЪВЕТ, който
-- спира лентата, за да се посъветват. Всеки отворен сектор дава по един
-- фрагмент от кода; петте фрагмента отварят вратата — и вечерята.
-- Страницата е ЗА ЧАСА: не иска вход и нищо не предава — урокът не се
-- оценява. Докъде са стигнали двамата се пази в самия браузър.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('urok-7-matrica',
   'Урок — Изход от Матрицата',
   'lesson',
   'uroci/urok_7_matrica.html',
   'Стая за бягство за двама: 35 задачи за умножение на многочлен с многочлен в пет сектора, бърза игра „вярно или грешно“ между тях и код от пет цифри за изхода. Подготовка за НВО.',
   0,
   false,
   10707,
   7,
   (select id from public.subjects where slug = 'matematika'),
   '{7}')
on conflict (slug) do update set
  title       = excluded.title,
  kind        = excluded.kind,
  url         = excluded.url,
  description = excluded.description,
  max_points  = excluded.max_points,
  sort_order  = excluded.sort_order,
  week        = excluded.week,
  subject_id  = excluded.subject_id,
  grades      = excluded.grades;
  -- published нарочно липсва: решава се от таблото.


-- Какво има до момента:
select kind as вид,
       count(*) as брой,
       count(*) filter (where published) as в_библиотеката
  from public.assignments
 group by kind
 order by kind;
