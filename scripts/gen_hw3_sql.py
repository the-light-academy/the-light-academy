#!/usr/bin/env python3
"""Пише supabase/domashni-nivo-v.sql — редовете за „ниво В група“ в 6. клас.

Всеки състезателен лист трябва да има ред в таблица assignments, иначе
няма къде да влезе резултатът. Данните не се измислят: седмицата, подредбата и
темата се взимат от реда на основния лист в supabase/assignments.sql, за
да стоят двата листа един до друг в таблото и в календара.

    python3 scripts/gen_hw3_sql.py
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'scripts'))
from hw3.zadachi import TEMI as WEEKS      # noqa: E402

SQL = (ROOT / 'supabase' / 'assignments.sql').read_text(encoding='utf-8')

# Всички редове от assignments.sql: slug → (title, sort_order, week, grades)
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
    """Подзаглавието на листа → един ред за описание в базата."""
    head = sub.split(':')[0].strip().rstrip('.')
    return head[0].upper() + head[1:]


def main() -> None:
    out = ["""-- =====================================================================
--  Третото ниво на домашните в 6. клас — „ниво В група“
--  ---------------------------------------------------------------------
--  Към всяка тема от 6. клас има и трети лист — „ниво В група“: десет
--  състезателни задачи от вида, който се дава на Иван Салабашев,
--  Европейско кенгуру и на общинските кръгове. Страниците се сглобяват
--  от scripts/build_hw3.py, а задачите стоят в scripts/hw3/zadachi.py.
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
--  Файлът е написан от scripts/gen_hw3_sql.py — не го редактирай на ръка.
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
-- 6. клас, седмица %(week)d — ТРЕТИ лист за същата тема: ниво В група.
-- %(note)s
-- sort_order е същият като на %(baseslug)s: трите листа за темата стоят
-- в една седмица и се подреждат по име.
insert into public.assignments
  (slug, title, kind, url, description, max_points, published, sort_order,
   week, subject_id, grades)
values
  ('%(slug)s',
   'Домашно — %(tema)s · ниво В група',
   'homework',
   '%(url)s',
   '%(desc)s',
   %(points)d,
   false,
   %(sort)d,
   %(week)d,
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
  -- published нарочно липсва тук: то се управлява от таблото.
""" % {
            'week': base['week'], 'baseslug': base['slug'],
            'note': short(spec['sub']) + '.',
            'slug': spec['slug'], 'tema': tema, 'url': spec['out'],
            'desc': short(spec['sub']).replace("'", "''"),
            'points': len(spec['qs']), 'sort': base['sort'],
        })

    out.append("""

-- Какво има в базата сега ----------------------------------------------
--  По един ред на лист: основният, ниво 2 и ниво В група един под друг.
select a.week                                as sedmica,
       a.title                               as list,
       a.max_points                          as tochki,
       case when a.published then 'да' else 'не' end as v_biblioteka
  from public.assignments a
 where a.kind = 'homework'
   and a.grades @> '{6}'
 order by a.week, a.title;
""")

    if missing:
        sys.exit('няма ред в assignments.sql за: ' + ', '.join(missing))
    path = ROOT / 'supabase' / 'domashni-nivo-v.sql'
    path.write_text('\n'.join(out) + '\n', encoding='utf-8')
    print('%s · %d реда' % (path.name, len(WEEKS)))


if __name__ == '__main__':
    main()
