#!/usr/bin/env python3
"""Проверява урока „Изход от Матрицата“ (7. клас) — по друг път.

Генераторът смята отговорите, като разкрива скобите. Тук нищо не се
разкрива: всеки отговор се ЧЕТЕ НАЗАД от самия екран (низовете, които
ученикът ще види) и се сравнява с условието числено — като се заместват
случайни числа на мястото на буквите. Два многочлена, които съвпадат в
дванадесет случайни точки от диапазон с 400 стойности, са един и същ
многочлен; вероятността да се разминат е по-малка от едно на 10¹⁵.

Проверява се и останалото:
  · всеки член от отговора стои точно веднъж сред чиповете;
  · никоя примамка не е равна на верен член (не по изписване, а по
    стойност — иначе ученик с верен отговор би минал за сгрешил);
  · сборът на квадратчетата в решетката дава произведението;
  · коренът на всяко уравнение, върнат в самото уравнение, го изпълнява;
  · вярно/грешно в ГЛИТЧ — преценено наново, числено;
  · цифрите на кода идват от отговорите, а не отнякъде другаде.

    python3 scripts/check_urok7.py
"""
import json
import random
import re
import subprocess
import sys
from pathlib import Path

from sympy import Add, Integer, Rational, expand, symbols

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'scripts'))
from urok7.algebra import parse  # noqa: E402

A, B = symbols('a b')
X, Y = symbols('x y')
ZAMIANA = {X: A + B, Y: A - B}
TOCHKI = 12
RND = random.Random(7)

fails = []
minali = 0


def ok(ime, uslovie, dopulnenie=''):
    global minali
    if uslovie:
        minali += 1
    else:
        fails.append(ime + (' · ' + str(dopulnenie) if dopulnenie else ''))


def sluchaina_tochka(simvoli):
    return {s: Rational(RND.randint(-200, 200)) for s in simvoli}


def ravni(e1, e2):
    """Два израза, сравнени в случайни точки — без разкриване на скоби."""
    simvoli = sorted(set(e1.free_symbols) | set(e2.free_symbols), key=str)
    if not simvoli:
        return expand(e1 - e2) == 0
    for _ in range(TOCHKI):
        t = sluchaina_tochka(simvoli)
        if Rational(e1.subs(t)) != Rational(e2.subs(t)):
            return False
    return True


def sbor(chlenove):
    return Add(*[parse(c) for c in chlenove])


def main():
    data = json.loads(subprocess.check_output(
        [sys.executable, str(ROOT / 'scripts' / 'build_urok7.py'), '--json'],
        text=True))

    vidqni_id, vidqni_izraz = set(), set()
    broi_zadachi = 0

    for s in data['sektori']:
        kod = s['kod']
        ok('[%s] нужните са по-малко от задачите' % kod,
           0 < s['nujni'] <= len(s['zadachi']), s['nujni'])
        for z in s['zadachi']:
            broi_zadachi += 1
            ime = '[%s] %s' % (kod, z.get('knige') or z['id'])
            ok(ime + ': id-то е ново', z['id'] not in vidqni_id)
            vidqni_id.add(z['id'])
            ok(ime + ': условието не се повтаря', z['izraz'] not in vidqni_izraz)
            vidqni_izraz.add(z['izraz'])

            if z['vid'] == 'chislo':
                lqvo, dqsno = z['izraz'].split('=')
                L, R = parse(lqvo), parse(dqsno)
                v = sorted(L.free_symbols, key=str)[0]
                ok(ime + ': буквата е същата', str(v) == z['promenliva'])
                koren = Rational(int(z['p']), int(z['q']))
                ok(ime + ': коренът изпълнява уравнението',
                   Rational(L.subs(v, koren)) == Rational(R),
                   'при %s = %s лявата страна е %s' % (v, koren, L.subs(v, koren)))
                ok(ime + ': изписаният корен е същото число',
                   parse(z['koren'].replace('−', '-')) == koren, z['koren'])
                ok(ime + ': дробта е отбелязана', z['drob'] == (koren.q != 1))
                continue

            e = parse(z['izraz'])
            if z['vid'] == 'zamiana':
                e = e.subs(ZAMIANA)
                ok(ime + ': показаната замяна е същата',
                   ravni(parse(z['zamiana']), e), z['zamiana'])
            ok(ime + ': сглобеният отговор съвпада с условието',
               ravni(sbor(z['otgovor']), e), ' + '.join(z['otgovor']))
            ok(ime + ': отговорът е поне два члена', len(z['otgovor']) >= 2)
            ok(ime + ': няма повторен член в отговора',
               len(set(z['otgovor'])) == len(z['otgovor']))

            # чиповете
            for t in z['otgovor']:
                ok(ime + ': „%s“ стои сред чиповете' % t, z['chipove'].count(t) == 1)
            primamki = [c for c in z['chipove'] if c not in z['otgovor']]
            ok(ime + ': има поне три примамки', len(primamki) >= 3, len(primamki))
            ok(ime + ': примамките са различни', len(set(primamki)) == len(primamki))
            for p in primamki:
                pe = parse(p)
                ok(ime + ': примамката „%s“ не е верен член' % p,
                   all(not ravni(pe, parse(t)) for t in z['otgovor']))

            if z['vid'] == 'mreja':
                m = z['mreja']
                levi, desni = sbor(m['redove']), sbor(m['koloni'])
                ok(ime + ': решетката пази условието', ravni(levi * desni, e))
                kletki = []
                for ri, red in enumerate(m['kletki']):
                    ok(ime + ': редът има колкото колони', len(red) == len(m['koloni']))
                    for ki, kl in enumerate(red):
                        veren = parse(m['redove'][ri]) * parse(m['koloni'][ki])
                        ok(ime + ': квадратче %d·%d е произведението' % (ri + 1, ki + 1),
                           ravni(parse(kl['t']), veren), kl['t'])
                        ok(ime + ': квадратче %d·%d има два избора повече' % (ri + 1, ki + 1),
                           len(kl['p']) == 2, kl['p'])
                        for p in kl['p']:
                            ok(ime + ': грешният избор „%s“ не е верният' % p,
                               not ravni(parse(p), veren))
                        kletki.append(parse(kl['t']))
                ok(ime + ': сборът на квадратчетата дава отговора',
                   ravni(Add(*kletki), sbor(z['otgovor'])))

            ok(ime + ': има обяснение', len(z['zashto']) >= 1 and
               all(len(r) > 3 for r in z['zashto']))

        # фрагментът
        f = s['fragment']
        ok('[%s] фрагментът е една цифра' % kod, re.fullmatch(r'\d', f['cifra']), f['cifra'])
        zad = {z['id']: z for z in s['zadachi']}
        vupros = f['vupros']
        if 'члена' in vupros:
            cel = [z for z in s['zadachi'] if z['vid'] != 'chislo' and
                   (z.get('knige') or '') in vupros]
            ok('[%s] фрагментът брои членовете на задачата от въпроса' % kod, len(cel) == 1, vupros)
            if len(cel) == 1:
                ok('[%s] цифрата е броят на членовете' % kod,
                   int(f['cifra']) == len(cel[0]['otgovor']), len(cel[0]['otgovor']))
        del zad

    ok('кодът е пет цифри', re.fullmatch(r'\d{5}', data['kod']), data['kod'])
    ok('кодът е от фрагментите',
       data['kod'] == ''.join(s['fragment']['cifra'] for s in data['sektori']))

    # ГЛИТЧ: верността се преценява наново
    broi_redove = 0
    for g in data['glitch']:
        vqrni = 0
        for r in g['redove']:
            broi_redove += 1
            lqvo, dqsno = r['red'].split('=')
            istina = ravni(parse(lqvo), parse(dqsno))
            ok('[глитч %s] „%s“' % (g['kod'], r['red']), istina == r['vqrno'],
               'пише %s, а е %s' % (r['vqrno'], istina))
            vqrni += 1 if istina else 0
            if not istina:
                ok('[глитч %s] обяснението сочи вярното' % g['kod'],
                   r['zashto'].startswith('Грешно'), r['zashto'])
        ok('[глитч %s] има и верни, и грешни' % g['kod'], 0 < vqrni < len(g['redove']), vqrni)

    # вратите
    istini = []
    for v in data['vrati']:
        lqvo, dqsno = v['red'].split('=')
        istini.append(ravni(parse(lqvo), parse(dqsno)))
        ok('[врата %s] отбелязването е вярно' % v['etiket'], istini[-1] == v['vqrno'])
    ok('вратите: вярна е точно една', sum(istini) == 1, istini)

    # страницата
    html = (ROOT / 'uroci' / 'urok_7_matrica.html').read_text(encoding='utf-8')
    ok('страницата носи данните', '"kod": "%s"' % data['kod'] in html.replace("'", '"'))
    red_nachalo = html[html.index('/* ДАННИ:НАЧАЛО'):].split('\n')[0]
    ok('маркерът затваря коментара си', red_nachalo.rstrip().endswith('*/'), red_nachalo)
    ok('данните започват веднага след маркера',
       html[html.index('/* ДАННИ:НАЧАЛО'):].split('\n')[1].startswith('const MISIA = {'))
    ok('страницата няма празен MISIA', 'const MISIA = {}' not in html)
    ok('страницата е една, без външни файлове',
       not re.search(r'<script[^>]+src=', html) and not re.search(r'<img', html))
    for cifra in data['kod']:
        pass
    ok('кодът не стои изписан наготово в текста',
       html.count('>' + data['kod'] + '<') == 0)

    print('задачи: %d · глитч реда: %d · проверки: %d' % (broi_zadachi, broi_redove, minali))
    if fails:
        print('ПАДНАЛИ (%d):' % len(fails))
        for f in fails[:40]:
            print(' -', f)
        sys.exit(1)
    print('✓ всеки отговор е сверен числено с условието')


if __name__ == '__main__':
    main()
