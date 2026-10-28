#!/usr/bin/env python3
"""Проверява урока „Храмът на трите печата“ (7. клас) — по друг път.

Генераторът смята, като прилага формулите. Тук нищо не се прилага:
всеки отговор се ЧЕТЕ НАЗАД от низовете, които ученикът ще види, и се
сравнява с условието числено — в случайни точки. Два многочлена, които
съвпадат в дванадесет случайни точки от диапазон с 400 стойности, са
един и същ многочлен.

Проверява се и останалото:
  · парчетата на картината, събрани, дават формулата;
  · никоя примамка не е равна на парче или на верен член;
  · всяка стъпка от сметката наум е вярна сама по себе си
    (101² = (100 + 1)² = 100² + 2 · 100 · 1 + 1² = 10000 + 200 + 1 = 10201);
  · при разпознаването верният отговор е равен на израза, а другите три
    не са — и там, където отговорът е „не е“, дискриминантата го
    потвърждава;
  · вярно/грешно при СТРАЖИТЕ — преценено наново;
  · цифрите на кода идват от самите отговори.

    python3 scripts/check_hram.py
"""
import json
import random
import re
import subprocess
import sys
from pathlib import Path

from sympy import Add, Rational, Symbol, expand, symbols

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'scripts'))
from urok7.algebra import parse  # noqa: E402

TOCHKI = 12
RND = random.Random(11)
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
        t = {s: Rational(RND.randint(-200, 200)) for s in simvoli}
        if Rational(e1.subs(t)) != Rational(e2.subs(t)):
            return False
    return True


def sbor(chlenove):
    return Add(*[parse(c) for c in chlenove])


def main():
    data = json.loads(subprocess.check_output(
        [sys.executable, str(ROOT / 'scripts' / 'build_hram.py'), '--json'], text=True))

    vidqni, broi = set(), 0
    for z in data['zali']:
        kod = z['kod']
        ok('[%s] нужните не надхвърлят задачите' % kod, 0 < z['nujni'] <= len(z['zadachi']))
        for q in z['zadachi']:
            broi += 1
            ime = '[%s] %s' % (kod, q['izraz'])
            ok(ime + ': id-то е ново', q['id'] not in vidqni, q['id'])
            vidqni.add(q['id'])
            ok(ime + ': има обяснение',
               q['zashto'] and all(len(r.strip()) >= 2 for r in q['zashto']))

            if q['vid'] == 'izbor':
                cel = parse(q['izraz'])
                if q.get('kontrol') == 'ne_e_kvadrat':
                    x = sorted(cel.free_symbols, key=str)[0]
                    p = expand(cel).as_poly(x)
                    a2, a1, a0 = (p.coeff_monomial(x**2), p.coeff_monomial(x),
                                  p.coeff_monomial(1))
                    ok(ime + ': наистина не е пълен квадрат', a1**2 - 4*a2*a0 != 0,
                       'b² − 4ac = %s' % (a1**2 - 4*a2*a0))
                else:
                    ok(ime + ': отбелязаният отговор е верен',
                       ravni(parse(q['veren']), cel), q['veren'])
                for dr in q['izbori']:
                    if dr == q['veren']:
                        continue
                    ok(ime + ': „%s“ не е верен' % dr, not ravni(parse(dr), cel))
                ok(ime + ': има поне три избора', len(q['izbori']) >= 3)
                continue

            if q['vid'] in ('chislo', 'naum'):
                stoinost = Rational(int(q['p']), int(q['q']))
                if q['vid'] == 'chislo':
                    lqvo, dqsno = q['izraz'].split('=')
                    L, R = parse(lqvo), parse(dqsno)
                    v = sorted(L.free_symbols, key=str)[0]
                    ok(ime + ': коренът изпълнява уравнението',
                       Rational(L.subs(v, stoinost)) == Rational(R))
                else:
                    ok(ime + ': числото е стойността на израза',
                       ravni(parse(q['izraz']), Rational(stoinost)), q['koren'])
                    ok(ime + ': разбиването е същото число',
                       ravni(parse(q['razbivane']), parse(q['izraz'])), q['razbivane'])
                    for red in q['zashto'][1:-1]:
                        try:
                            stupka = parse(red)
                        except Exception:                           # noqa: BLE001
                            continue
                        ok(ime + ': стъпката „%s“ е вярна' % red,
                           ravni(stupka, parse(q['izraz'])))
                    posleden = q['zashto'][-1].lstrip('= ')
                    ok(ime + ': последният ред е отговорът',
                       ravni(parse(posleden), Rational(stoinost)), posleden)
                ok(ime + ': изписаният корен е същото число',
                   parse(q['koren'].replace('−', '-')) == stoinost, q['koren'])
                continue

            # chipove и mozaika
            e = parse(q['izraz'])
            ok(ime + ': сглобеният отговор съвпада с условието',
               ravni(sbor(q['otgovor']), e), ' + '.join(q['otgovor']))
            ok(ime + ': няма повторен член', len(set(q['otgovor'])) == len(q['otgovor']))
            for t in q['otgovor']:
                ok(ime + ': „%s“ стои сред чиповете' % t, q['chipove'].count(t) == 1)
            prim = [c for c in q['chipove'] if c not in q['otgovor']]
            ok(ime + ': има поне три примамки', len(prim) >= 3, len(prim))
            ok(ime + ': примамките са различни', len(set(prim)) == len(prim))
            for p in prim:
                ok(ime + ': примамката „%s“ не е верен член' % p,
                   all(not ravni(parse(p), parse(t)) for t in q['otgovor']))

        # картината
        m = z['mozaika']
        if m:
            cqlo = parse(z['zadachi'][0]['izraz'])
            parcheta = sbor(m['slotove']) + (parse(m['nachalo']) if m.get('nachalo') else 0)
            ok('[%s] парчетата дават формулата' % kod, ravni(parcheta, cqlo),
               ' + '.join(m['slotove']))
            ochakvani = {'sbor': 4, 'razlika': 3, 'ogledalo': 2}[m['vid']]
            ok('[%s] парчетата са колкото местата в чертежа' % kod,
               len(m['slotove']) == ochakvani, len(m['slotove']))
            for p in m['primamki']:
                ok('[%s] примамката „%s“ не е парче' % (kod, p),
                   all(not ravni(parse(p), parse(s)) for s in m['slotove']))
            lqvo, dqsno = m['izvod'].split('=')[0], m['izvod'].split('=')[-1]
            ok('[%s] изводът под картината е верен' % kod,
               ravni(parse(lqvo), parse(dqsno)), m['izvod'])

        # печатът
        p = z['pechat']
        ok('[%s] печатът е една цифра' % kod, re.fullmatch(r'\d', p['cifra']), p['cifra'])
        ochakvano = None
        cel = next((q for q in z['zadachi'] if q['id'] == p['na']), None)
        ok('[%s] печатът сочи задача от залата' % kod, cel is not None, p['na'])
        if cel and cel.get('otgovor'):
            otg = expand(sbor(cel['otgovor']))
            if p['kontrol'] == 'koef':
                ochakvano = abs(int(otg.coeff(Symbol('x'), 1)))
            elif p['kontrol'] == 'svoboden':
                ochakvano = abs(int(otg.subs({s: 0 for s in otg.free_symbols})))
            elif p['kontrol'] == 'stepen':
                ochakvano = max(int(sum(t.as_poly(s).degree() for s in otg.free_symbols))
                                for t in Add.make_args(otg))
        elif cel and cel.get('koren'):
            ochakvano = abs(int(Rational(cel['koren'].replace('−', '-'))))
        ok('[%s] цифрата на печата идва от отговора' % kod,
           ochakvano is not None and str(ochakvano) == p['cifra'],
           '%s срещу %s' % (ochakvano, p['cifra']))

    ok('кодът е четири цифри', re.fullmatch(r'\d{4}', data['kod']), data['kod'])
    ok('кодът е от печатите',
       data['kod'] == ''.join(z['pechat']['cifra'] for z in data['zali']))

    redove = 0
    for g in data['straji']:
        vqrni = 0
        for r in g['redove']:
            redove += 1
            lqvo, dqsno = r['red'].split('=')
            istina = ravni(parse(lqvo), parse(dqsno))
            ok('[стражи %s] „%s“' % (g['kod'], r['red']), istina == r['vqrno'],
               'пише %s, а е %s' % (r['vqrno'], istina))
            vqrni += 1 if istina else 0
        ok('[стражи %s] има и верни, и грешни' % g['kod'], 0 < vqrni < len(g['redove']), vqrni)

    istini = []
    for p in data['pechati']:
        lqvo, dqsno = p['red'].split('=')
        istini.append(ravni(parse(lqvo), parse(dqsno)))
        ok('[изход %s] отбелязването е вярно' % p['etiket'], istini[-1] == p['vqrno'])
    ok('на изхода верен е точно един печат', sum(istini) == 1, istini)

    html = (ROOT / 'uroci' / 'urok_7_hram.html').read_text(encoding='utf-8')
    red = html[html.index('/* ДАННИ:НАЧАЛО'):].split('\n')
    ok('маркерът затваря коментара си', red[0].rstrip().endswith('*/'), red[0])
    ok('данните започват веднага след маркера', red[1].startswith('const HRAM = {'))
    ok('страницата носи кода', '"kod": "%s"' % data['kod'] in html)
    ok('страницата е една, без външни файлове',
       not re.search(r'<script[^>]+src=', html) and not re.search(r'<img', html))
    ok('кодът не стои изписан наготово', html.count('>' + data['kod'] + '<') == 0)
    ok('фонът не се движи',
       'requestAnimationFrame' not in html and '<canvas' not in html)

    print('задачи: %d · стражи: %d · проверки: %d' % (broi, redove, minali))
    if fails:
        print('ПАДНАЛИ (%d):' % len(fails))
        for f in fails[:40]:
            print(' -', f)
        sys.exit(1)
    print('✓ всеки отговор е сверен числено с условието')


if __name__ == '__main__':
    main()
