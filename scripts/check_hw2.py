#!/usr/bin/env python3
"""Проверява задачите за вторите нива на домашните в 6. клас.

Всеки отговор е написан два пъти: веднъж както детето ще го види (`a`
или верният вариант при избор) и веднъж като сметка (`chk`). Тук
сметката се пресмята наново с точни дроби и трябва да даде същото. Ако
някъде има изтървана запетая, лъсва тук, а не пред ученика.

Проверява се и останалото: че няма две еднакви условия в един лист, че
всяка задача носи обяснение, че верният вариант при избор сочи към
истински отговор и че сглобеният файл е наистина „ниво 2“ — заглавие,
slug и брой задачи.

    python3 scripts/check_hw2.py          # всички седмици
    python3 scripts/check_hw2.py w04      # само тази
"""
import re
import sys
from fractions import Fraction as F
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'scripts'))
from hw2.questions import WEEKS            # noqa: E402

fails = []
passed = 0


def ok(name, cond, extra=''):
    global passed
    if cond:
        passed += 1
    else:
        fails.append(name + (' · ' + str(extra) if extra else ''))


def num(s):
    """„1 5/24“, „29/24“, „4,5“, „−0,3“ → точна дроб."""
    t = str(s).strip().replace('−', '-').replace(' ', ' ')
    m = re.fullmatch(r'(-?)(\d+)\s+(\d+)/(\d+)', t)
    if m:
        v = F(int(m.group(2))) + F(int(m.group(3)), int(m.group(4)))
        return -v if m.group(1) else v
    m = re.fullmatch(r'(-?\d+)/(\d+)', t)
    if m:
        return F(int(m.group(1)), int(m.group(2)))
    m = re.fullmatch(r'-?\d+(?:[.,]\d+)?', t)
    if m:
        return F(t.replace(',', '.'))
    return None


def main():
    want = sys.argv[1:]
    keys = sorted(k for k in WEEKS if not want or k in want)
    unchecked = 0
    total = 0

    for k in keys:
        spec = WEEKS[k]
        qs = spec['qs']
        ok('[%s] поне 12 задачи' % k, len(qs) >= 12, len(qs))
        seen = {}
        for i, q in enumerate(qs, 1):
            total += 1
            where = '[%s] задача %d' % (k, i)
            plain = re.sub(r'<[^>]+>', '', q['q']).strip()
            ok(where + ': условието не се повтаря', plain not in seen,
               'същото като задача %s' % seen.get(plain))
            seen[plain] = i
            ok(where + ': има обяснение', len(q.get('why', '')) > 12)
            ok(where + ': има етикет', bool(q.get('tag')))

            if q['t'] == 'mc':
                ok(where + ': верният вариант съществува',
                   isinstance(q.get('c'), int) and 0 <= q['c'] < len(q['opts']), q.get('c'))
                ok(where + ': поне три варианта', len(q['opts']) >= 3, len(q['opts']))
                ok(where + ': вариантите са различни', len(set(q['opts'])) == len(q['opts']))
            else:
                ok(where + ': отговорът е число', num(q.get('a')) is not None, q.get('a'))

            chk = q.get('chk')
            if chk is None:
                unchecked += 1
                continue
            try:
                val = eval(chk, {'F': F, 'abs': abs, 'min': min, 'max': max, 'sum': sum,
                                 '__builtins__': {}}, {})
            except Exception as e:                       # noqa: BLE001
                fails.append(where + ': сметката не се смята · ' + str(e))
                continue
            if q['t'] == 'mc':
                ok(where + ': сметката сочи верния вариант',
                   str(val) == q['opts'][q['c']],
                   'сметка „%s“, отбелязан „%s“' % (val, q['opts'][q['c']]))
            else:
                a = num(q['a'])
                ok(where + ': отговорът съвпада със сметката',
                   a is not None and F(val) == a,
                   'в листа „%s“, пресметнато „%s“' % (q['a'], val))

        # сглобеният файл
        out = ROOT / spec['out']
        ok('[%s] файлът е сглобен' % k, out.exists(), spec['out'])
        if out.exists():
            html = out.read_text(encoding='utf-8')
            ok('[%s] заглавието казва „ниво 2“' % k, '· ниво 2' in html)
            ok('[%s] slug-ът е новият' % k,
               "saveAttempt('" + spec['slug'] + "'" in html, spec['slug'])
            i = html.find('const QUESTIONS')
            j = html.find('\n];', i)
            ok('[%s] задачите са вътре' % k,
               i > 0 and html[i:j].count('type:') == len(qs),
               html[i:j].count('type:') if i > 0 else 'няма блок')
            base = (ROOT / spec['base']).read_text(encoding='utf-8')
            ok('[%s] основният лист не е пипнат' % k,
               "saveAttempt('" + spec['slug'] + "'" not in base)

    print('седмици: %d · задачи: %d · без сметка: %d' % (len(keys), total, unchecked))
    print('минали проверки: %d' % passed)
    if fails:
        print('ПАДНАЛИ (%d):' % len(fails))
        for f in fails[:40]:
            print(' -', f)
        sys.exit(1)
    print('✓ всеки отговор е пресметнат наново и съвпада')


if __name__ == '__main__':
    main()
