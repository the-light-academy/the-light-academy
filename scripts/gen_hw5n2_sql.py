#!/usr/bin/env python3
"""Пише supabase/domashni-5-nivo2.sql — редовете за вторите нива в 5. клас.

Всеки нов лист трябва да има ред в таблица assignments, иначе няма къде
да влезе резултатът. Данните не се измислят: седмицата, подредбата и
темата се взимат от реда на основния лист в supabase/assignments.sql, за
да стоят двата листа един до друг в таблото и в календара.

    python3 scripts/gen_hw5n2_sql.py
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'scripts'))
from hw5n2.zadachi import WEEKS            # noqa: E402

SQL = (ROOT / 'supabase' / 'assignments.sql').read_text(encoding='utf-8')

# Всички редове за домашни от assignments.sql: url → основните данни.
ROWS = {}
for m in re.finditer(
        r"\(\s*'([a-z0-9-]+)',\s*\n\s*'([^']*)',\s*\n\s*'homework',\s*\n"
        r"\s*'([^']*)',\s*\n(?:\s*'[^']*',\s*\n)?"
        r"\s*(\d+),\s*\n\s*(?:true|false),\s*\n\s*(\d+),\s*\n\s*(\d+),",
        SQL):
    slug, title, url, pts, sort, week = m.groups()
    ROWS[url] = {'slug': slug, 'title': title, 'points': int(pts),
                 'sort': int(sort), 'week': int(week)}


def short(sub: str) -> str:
    """Подзаглавието на листа → един ред за описание в базата.

    Взима се първото изречение: то казва какво има в листа. Редът след
    него е указание към ученика („дробите се пишат с черта“) и в базата
    няма работа.
    """
    head = sub.split('. ')[0].strip().rstrip('.')
    return head[0].upper() + head[1:]


def main() -> None:
    out = ["""-- =====================================================================
--  Вторите нива на домашните в 5. клас — редовете в базата
--  ---------------------------------------------------------------------
--  Към всяко домашно за 5. клас има втори лист „ниво 2“: същата тема,
--  същият вид оценяване, но 10 по-трудни задачи. Страниците се сглобяват
--  от scripts/build_hw5n2.py, а задачите стоят в scripts/hw5n2/.
--
--  Този файл е другата половина: без ред в assignments резултатът няма
--  къде да се запише. Седмицата и подредбата са същите като на основния
--  лист, за да стоят двата един до друг в таблото и в календара.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА — нищо не се трие и не се
--  дублира. published нарочно не се пипа при повторно пускане: кога
--  листът отива при учениците се решава от таблото („Сложи в
--  библиотеката“, после „Дай на моите“).
--
--  Седмица 9 има вече втори лист (hw5-w09b), затова новият ѝ лист е
--  hw5-w09c — третият за тази седмица.
--
--  Файлът е написан от scripts/gen_hw5n2_sql.py — не го редактирай на ръка.
--
--  ПРЕДИ ТОВА трябва веднъж да са минали:
--    · supabase/subjects.sql
--    · supabase/assignments.sql   (основните листове)
-- =====================================================================
"""]
    missing = []
    for k in sorted(WEEKS):
        spec = WEEKS[k]
        base = ROWS.get(spec['base'])
        if not base:
            missing.append(spec['base'])
            continue
        tema = base['title'].split('—', 1)[1].strip()
        out.append("""
-- 5. клас, седмица %(week)d — ВТОРИ лист за същата седмица, ниво 2.
-- %(note)s
-- sort_order е същият като на %(baseslug)s: двата листа стоят в една
-- седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('%(slug)s',
   'Домашно — %(tema)s · ниво 2',
   'homework',
   '%(url)s',
   '%(desc)s',
   %(points)d,
   false,
   %(sort)d,
   %(week)d,
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
  -- published нарочно липсва тук: то се управлява от таблото.
""" % {
            'week': base['week'], 'baseslug': base['slug'],
            'note': short(spec['sub']) + '.',
            'slug': spec['slug'], 'tema': tema, 'url': spec['out'],
            'desc': short(spec['sub']).replace("'", "''"),
            'points': len(spec['qs']), 'sort': base['sort'],
        })

    slugs = [WEEKS[k]['slug'] for k in sorted(WEEKS)]
    redove = []
    for i in range(0, len(slugs), 4):
        redove.append(', '.join("'%s'" % s for s in slugs[i:i + 4]))
    out.append("""

-- Какво има в базата сега ----------------------------------------------
--  Един ред на лист: заглавието, точките и дали е в библиотеката.
select a.week                                as sedmica,
       a.title                               as list,
       a.max_points                          as tochki,
       case when a.published then 'да' else 'не' end as v_biblioteka
  from public.assignments a
 where a.slug in (%s)
 order by a.week, a.title;
""" % (',\n                  '.join(redove),))

    if missing:
        sys.exit('няма основен ред за: ' + ', '.join(missing))

    path = ROOT / 'supabase' / 'domashni-5-nivo2.sql'
    path.write_text(''.join(out), encoding='utf-8')
    print('%s · %d реда' % (path.relative_to(ROOT), len(slugs)))


if __name__ == '__main__':
    main()
