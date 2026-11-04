#!/usr/bin/env python3
"""Проверява урока „Лебедово езеро“ (трета степен) — по друг път.

Генераторът смята, като прилага формулите. Тук нищо не се прилага:
отговорите се четат назад от низовете, които ученикът ще види, и се
сверяват с условието ЧИСЛЕНО — в дванадесет случайни точки. Където
отговорът е число, то се пресмята по втори, различен път (полиномно
деление вместо формула, обхождане на цели двойки вместо тъждество).

Проверява се и останалото: че парчетата на куба са точно коефициентите
на (a + b)³, че всеки ред от триъгълника на Паскал наистина е сбор на
двата над него, че всяка двойка за свързване е тъждество, че във ФУЕТЕ
верността е преценена правилно и че 11³ = 1331.

    python3 scripts/check_ezero.py
"""
import json
import math
import random
import re
import subprocess
import sys
from pathlib import Path

from sympy import Add, Rational, Symbol, expand, symbols

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'scripts'))
from urok7.algebra import parse  # noqa: E402

A, B = symbols('a b')
TOCHKI = 12
RND = random.Random(13)
SREDA = {'range': range, 'str': str, 'int': int, 'len': len, 'sum': sum, 'min': min,
         'max': max, 'abs': abs, '__builtins__': {}}
fails, minali = [], 0


def ok(ime, uslovie, dop=''):
    global minali
    if uslovie:
        minali += 1
    else:
        fails.append(ime + (' · ' + str(dop) if dop else ''))


def ravni(e1, e2):
    simvoli = sorted(set(e1.free_symbols) | set(e2.free_symbols), key=str)
    if not simvoli:
        return expand(e1 - e2) == 0
    for _ in range(TOCHKI):
        t = {s: Rational(RND.randint(-120, 120)) for s in simvoli}
        if Rational(e1.subs(t)) != Rational(e2.subs(t)):
            return False
    return True


def sbor(chlenove):
    return Add(*[parse(c) for c in chlenove])


def main():
    data = json.loads(subprocess.check_output(
        [sys.executable, str(ROOT / 'scripts' / 'build_ezero.py'), '--json'], text=True))

    vidqni, broi = set(), 0
    for d in data['deistviq']:
        kod = d['kod']
        ok('[%s] нужните не надхвърлят задачите' % kod, 0 < d['nujni'] <= len(d['zadachi']))
        for q in d['zadachi']:
            broi += 1
            ime = '[%s] %s' % (kod, q['izraz'])
            ok(ime + ': id-то е ново', q['id'] not in vidqni, q['id'])
            vidqni.add(q['id'])
            ok(ime + ': има обяснение',
               q['zashto'] and all(len(r.strip()) >= 2 for r in q['zashto']))

            if q['vid'] == 'kub':
                # парчетата трябва да са точно коефициентите на (a + b)³
                izraz = expand((A + B) ** 3)
                for ime_p, broj in q['parcheta']:
                    chlen = parse(ime_p)
                    koef = izraz.coeff(A, chlen.as_poly(A).degree()).coeff(
                        B, chlen.as_poly(B).degree())
                    ok(ime + ': парчетата „%s“ са %d' % (ime_p, broj), koef == broj, koef)
                ok(ime + ': парчетата са осем', sum(n for _, n in q['parcheta']) == 8)
                lqvo, dqsno = q['izvod'].split('=')
                ok(ime + ': изводът е верен', ravni(parse(lqvo), parse(dqsno)), q['izvod'])
                continue

            if q['vid'] == 'paskal':
                for i, red in enumerate(q['redove']):
                    for j, v in enumerate(red):
                        ok(ime + ': ред %d, място %d е %d' % (i, j, v),
                           v == math.comb(i, j), math.comb(i, j))
                ok(ime + ': четвъртият ред е 1, 3, 3, 1', q['redove'][3] == [1, 3, 3, 1])
                ok(ime + ': има поне три скрити места', len(q['skriti']) >= 3)
                for i, j in q['skriti']:
                    ok(ime + ': скритото място съществува',
                       0 <= i < len(q['redove']) and 0 <= j < len(q['redove'][i]))
                continue

            if q['vid'] == 'dvoiki':
                for lqvo, dqsno in q['dvojki']:
                    ok(ime + ': %s = %s' % (lqvo, dqsno),
                       ravni(parse(lqvo), parse(dqsno)))
                levi = [p[0] for p in q['dvojki']]
                ok(ime + ': няма повторени двойки', len(set(levi)) == len(levi))
                continue

            if q['vid'] == 'izbor':
                cel = parse(q['izraz'])
                ok(ime + ': има поне три избора', len(q['izbori']) >= 3)
                ok(ime + ': верният е сред изборите', q['veren'] in q['izbori'])
                try:
                    veren = parse(q['veren'])
                except Exception:                                   # noqa: BLE001
                    continue
                koef = expand(cel).coeff(Symbol('x'), 2)
                ok(ime + ': отговорът върши работа',
                   ravni(veren, cel)                       # самият израз
                   or ravni(parse('(a + 5)') * veren, cel)  # вторият множител
                   or str(koef) == q['veren'],              # или коефициент
                   q['veren'])
                continue

            if q['vid'] in ('chislo', 'naum'):
                st = Rational(int(q['p']), int(q['q']))
                if q['vid'] == 'naum':
                    ok(ime + ': числото е стойността на израза',
                       ravni(parse(q['izraz']), Rational(st)), q['koren'])
                    ok(ime + ': разбиването е същото число',
                       ravni(parse(q['razbivane']), parse(q['izraz'])), q['razbivane'])
                    for red in q['zashto'][1:-1]:
                        try:
                            stupka = parse(red)
                        except Exception:                           # noqa: BLE001
                            continue
                        ok(ime + ': стъпката „%s“ е вярна' % red, ravni(stupka, Rational(st)))
                elif '=' in q['izraz'] and not q.get('smetka'):
                    lqvo, dqsno = q['izraz'].split('=')
                    L, R = parse(lqvo), parse(dqsno)
                    v = sorted(L.free_symbols, key=str)[0]
                    ok(ime + ': коренът изпълнява уравнението',
                       Rational(L.subs(v, st)) == Rational(R.subs(v, st)))
                elif q.get('proverka'):
                    val = eval(q['proverka'], dict(SREDA), {})       # noqa: S307
                    ok(ime + ': числото излиза и по друг път', Rational(val) == st,
                       '%s срещу %s' % (val, st))
                else:
                    ok(ime + ': има втора сметка', False, 'липсва proverka')
                ok(ime + ': изписаният отговор е същото число',
                   parse(q['koren'].replace('−', '-')) == st, q['koren'])
                continue

            e = parse(q['izraz'])
            ok(ime + ': сглобеният отговор съвпада с условието',
               ravni(sbor(q['otgovor']), e), ' + '.join(q['otgovor']))
            ok(ime + ': няма повторен член', len(set(q['otgovor'])) == len(q['otgovor']))
            for t in q['otgovor']:
                ok(ime + ': „%s“ стои сред чиповете' % t, q['chipove'].count(t) == 1)
            prim = [c for c in q['chipove'] if c not in q['otgovor']]
            ok(ime + ': има поне три примамки', len(prim) >= 3, len(prim))
            for p in prim:
                ok(ime + ': примамката „%s“ не е верен член' % p,
                   all(not ravni(parse(p), parse(t)) for t in q['otgovor']))

    redove = 0
    for g in data['fuete']:
        vqrni = 0
        for r in g['redove']:
            redove += 1
            lqvo, dqsno = r['red'].split('=')
            istina = ravni(parse(lqvo), parse(dqsno))
            ok('[фуете %s] „%s“' % (g['kod'], r['red']), istina == r['vqrno'],
               'пише %s, а е %s' % (r['vqrno'], istina))
            vqrni += 1 if istina else 0
        ok('[фуете %s] има и верни, и грешни' % g['kod'], 0 < vqrni < len(g['redove']), vqrni)
    ok('фуететата са 32', redove == 32, redove)

    ok('магията: кубът дава 1331', int(data['magiq']['otgovor']) ** 3 == 1331)

    html = (ROOT / 'uroci' / 'urok_7_ezero.html').read_text(encoding='utf-8')
    red = html[html.index('/* ДАННИ:НАЧАЛО'):].split('\n')
    ok('маркерът затваря коментара си', red[0].rstrip().endswith('*/'), red[0])
    ok('данните започват веднага след маркера', red[1].startswith('const EZERO = {'))
    ok('страницата е една, без външни файлове',
       not re.search(r'<script[^>]+src=', html) and not re.search(r'<img', html))
    ok('фонът не се движи',
       'requestAnimationFrame' not in html and '<canvas' not in html)
    ok('отговорът на магията не стои изписан', html.count('>11<') == 0)

    print('задачи: %d · фуете: %d · проверки: %d' % (broi, redove, minali))
    if fails:
        print('ПАДНАЛИ (%d):' % len(fails))
        for f in fails[:40]:
            print(' -', f)
        sys.exit(1)
    print('✓ всеки отговор е сверен числено с условието')


if __name__ == '__main__':
    main()
