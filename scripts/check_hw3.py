#!/usr/bin/env python3
"""Проверява задачите от „ниво В група“ за 6. клас.

Състезателната задача е опасна по друг начин от учебната: решението ѝ
обикновено е кратко и затова лесно се заблуждава. Тук всеки отговор се
пресмята ВТОРИ ПЪТ и по възможност ПО ДРУГ ПЪТ — не по идеята от
решението, а с изчерпване: обхождат се всички възможности и се брои
колко от тях стават. Ако задачата пита „най-малкото число, което…“,
проверката пробва числата едно по едно, вместо да повтаря сметката.

Затова в полето chk може да стои цял израз с цикъл:

    min(n for n in range(1, 10000) if n % 7 == 3 and n % 11 == 5)

На разположение са: range, len, sum, mnoj (произведение), min, max, abs,
sorted, set, list, all, any, int, str, F (точна дроб), nod, nok, delitели,
prost и cifri.

Проверява се и останалото: че листът е с десет задачи, че няма две
еднакви условия, че всяка задача носи обяснение и етикет, че сглобеният
файл наистина е „ниво В група“ и че основният лист не е пипнат.

    python3 scripts/check_hw3.py          # всички теми
    python3 scripts/check_hw3.py w04      # само тази
"""
import math
import re
import sys
from fractions import Fraction as F
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'scripts'))
from hw3.zadachi import TEMI            # noqa: E402

fails = []
passed = 0


def ok(name, cond, extra=''):
    global passed
    if cond:
        passed += 1
    else:
        fails.append(name + (' · ' + str(extra) if extra else ''))


def nod(*a):
    return math.gcd(*[int(x) for x in a])


def nok(*a):
    r = 1
    for x in a:
        r = r * int(x) // math.gcd(r, int(x))
    return r


def delitели(n):
    n = int(n)
    return sorted(d for d in range(1, n + 1) if n % d == 0)


def prost(n):
    n = int(n)
    if n < 2:
        return False
    return all(n % d for d in range(2, int(n ** .5) + 1))


def mnoj(it):
    """Произведение на редица — като sum, но с умножение."""
    r = F(1)
    for x in it:
        r *= F(x)
    return r


def cifri(n):
    return [int(c) for c in str(abs(int(n)))]


SREDA = {'F': F, 'range': range, 'len': len, 'sum': sum, 'min': min, 'max': max,
         'abs': abs, 'sorted': sorted, 'set': set, 'list': list, 'all': all,
         'any': any, 'int': int, 'str': str, 'round': round, 'pow': pow,
         'divmod': divmod, 'enumerate': enumerate, 'zip': zip, 'reversed': reversed,
         'mnoj': mnoj, 'nod': nod, 'nok': nok, 'delitели': delitели, 'prost': prost, 'cifri': cifri}


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
    if re.fullmatch(r'-?\d+(?:[.,]\d+)?', t):
        return F(t.replace(',', '.'))
    return None


def main():
    want = sys.argv[1:]
    keys = sorted(k for k in TEMI if not want or k in want)
    total = unchecked = 0

    for k in keys:
        spec = TEMI[k]
        qs = spec['qs']
        ok('[%s] десет задачи' % k, len(qs) == 10, len(qs))
        seen = {}
        for i, q in enumerate(qs, 1):
            total += 1
            where = '[%s] задача %d' % (k, i)
            plain = re.sub(r'<[^>]+>', '', q['q']).strip()
            ok(where + ': условието не се повтаря', plain not in seen,
               'същото като задача %s' % seen.get(plain))
            seen[plain] = i
            ok(where + ': има обяснение', len(q.get('why', '')) > 20)
            ok(where + ': има етикет', bool(q.get('tag')))
            ok(where + ': условието не е празно', len(plain) > 25, plain[:40])

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
                val = eval(chk, dict(SREDA, __builtins__={}), {})     # noqa: S307
            except Exception as e:                                    # noqa: BLE001
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

        out = ROOT / spec['out']
        ok('[%s] файлът е сглобен' % k, out.exists(), spec['out'])
        if out.exists():
            html = out.read_text(encoding='utf-8')
            ok('[%s] заглавието казва „ниво В група“' % k, '· ниво В група' in html)
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

    print('теми: %d · задачи: %d · без сметка: %d' % (len(keys), total, unchecked))
    print('минали проверки: %d' % passed)
    if fails:
        print('ПАДНАЛИ (%d):' % len(fails))
        for f in fails[:40]:
            print(' -', f)
        sys.exit(1)
    print('✓ всеки отговор е пресметнат наново')


if __name__ == '__main__':
    main()
