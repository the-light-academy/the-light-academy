#!/usr/bin/env python3
"""Пише supabase/domashni-angliyski-5-u1.sql — редовете в базата.

Петте листа нямат къде да запишат резултата, докато ги няма в таблица
assignments. Този файл ги вкарва, закачени за предмета „Английски“, за
5. клас и за Unit 1 от учебника (track ep1_unit1).

    /usr/bin/python3.13 scripts/gen_english5_sql.py
"""
import pathlib
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from english.build import za_ocenka, broi_redove   # noqa: E402
import build_english5 as B                          # noqa: E402

IZHOD = KOREN / 'supabase/domashni-angliyski-5-u1.sql'

#  Коя част от юнита е всеки лист (частите стоят в assets/tracks.js).
CHASTI = {
    'en5-u1-story': ('reading',
                     'Разказът „The Lost Backpack“ с двайсет празни места и '
                     'седем въпроса с цели изречения'),
    'en5-u1-order': ('language_focus',
                     'Подреждане на разбъркани думи: have got, this/that/these/those, '
                     'there is/are, въпросителни думи'),
    'en5-u1-detective': ('review',
                         'Намери сгрешената дума — трийсет изречения от лесни към '
                         'коварни'),
    'en5-u1-grammar': ('language_focus',
                       'Въпросителни думи, and/or/but, there is/there are, '
                       'отрицания и some/any'),
    'en5-u1-words': ('vocabulary',
                     'Познай думата по описанието: места в града, предмети, '
                     'държави и прилагателни'),
}

GLAVA = """-- =====================================================================
--  Английски, 5. клас, Unit 1 — петте листа от домашното за 12 ноември
--  ---------------------------------------------------------------------
--  Домашното е едно, но е голямо: 138 задачи за автоматична проверка и
--  7 въпроса с цели изречения. Разделено е на пет листа по теми, всеки
--  с най-много десет упражнения, за да не е безкрайно на един екран.
--
--  Мястото им в платформата: предмет „Английски“, 5. клас, Unit 1 от
--  English Plus 1 — всеки лист в своята част на юнита (Reading,
--  Language focus, Review, Vocabulary). БЕЗ седмица: английският върви
--  по юнити, не по седмици.
--
--  Страниците се сглобяват от scripts/build_english5.py, задачите стоят
--  в scripts/english5/, а scripts/check_english5.py ги сверява наново с
--  правилата на юнита.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА — нищо не се трие и не се
--  дублира. published нарочно не се пипа при повторно пускане: кога
--  един лист отива при учениците се решава от таблото („Сложи в
--  библиотеката“, после „Дай на моите“).
--
--  Файлът е написан от scripts/gen_english5_sql.py — не го редактирай
--  на ръка.
--
--  ПРЕДИ ТОВА трябва веднъж да са минали:
--    · supabase/schema.sql и надстройките след него
--    · supabase/schema-v8.sql   (колоните track и section)
--    · supabase/schema-v13.sql  (оттам идва предметът „Английски“)
-- =====================================================================

do $do$
declare
  predmet uuid;
  imeto   text;
begin
  select id, name into predmet, imeto
    from public.subjects
   where slug = 'angliiski';

  if predmet is null then
    select id, name into predmet, imeto
      from public.subjects
     where coalesce(active, true)
       and (name ilike '%нглийск%' or name ilike '%english%')
     order by length(name), name
     limit 1;
  end if;

  if predmet is null then
    raise exception using
      message = 'Няма предмет „Английски“ в public.subjects.',
      hint    = 'Пусни първо supabase/schema-v13.sql или създай предмета от таблото.';
  end if;

  raise notice 'Петте листа се закачат за предмет „%“, Unit 1.', imeto;
"""

RED = """
  --  {ime}
  --  {opisanie}
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('{slug}',
     '{titul}',
     'homework',
     '{fail}',
     '{opisanie}',
     {tochki},
     false,
     {red},
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{{5}}',
     'ep1_unit1',
     '{chast}')
  on conflict (slug) do update set
    title       = excluded.title,
    kind        = excluded.kind,
    url         = excluded.url,
    description = excluded.description,
    max_points  = excluded.max_points,
    sort_order  = excluded.sort_order,
    week        = excluded.week,
    subject_id  = excluded.subject_id,
    grades      = excluded.grades,
    track       = excluded.track,
    section     = excluded.section;
    -- published нарочно липсва тук: то се управлява от таблото.
"""

KRAI = """end
$do$;


-- ---------------------------------------------------------------------
--  Справка: петте листа, в коя част на юнита са и вижда ли ги някой.
-- ---------------------------------------------------------------------
select
  a.sort_order                             as red,
  a.slug,
  a.title,
  s.name                                   as predmet,
  a.grades                                 as klasove,
  a.track || ' / ' || a.section            as chast,
  a.max_points                             as tochki,
  case when a.published then 'вижда се от учениците'
       else 'още не се вижда — пусни го от таблото' end as sustoqnie
from public.assignments a
left join public.subjects s on s.id = a.subject_id
where a.slug like 'en5-u1-%'
order by a.sort_order;
"""


def ap(t: str) -> str:
    """Апострофът в SQL се удвоява."""
    return t.replace("'", "''")


def main() -> None:
    parchета = [GLAVA]
    for n, (danni, pat) in enumerate(B.vsichki()):
        chast, opisanie = CHASTI[danni['slug']]
        avto = sum(za_ocenka(u) for u in danni['upr'])
        ruch = sum(broi_redove(u) for u in danni['upr'] if u['vid'] == 'svoboden')
        titul = danni['title'].replace('Домашно — ', 'Домашно — Unit 1 · ') \
                              .replace(' — 5. клас', '')
        parchета.append(RED.format(
            ime=titul,
            slug=danni['slug'],
            titul=ap(titul),
            fail=pat.name,
            opisanie=ap(opisanie),
            tochki=avto + ruch,
            red=5110 + n,
            chast=chast,
        ))
    parchета.append(KRAI)
    IZHOD.write_text(''.join(parchета), encoding='utf-8')
    print(IZHOD.name, '·', len(B.vsichki()), 'реда ·', len(''.join(parchета)), 'знака')


if __name__ == '__main__':
    main()
