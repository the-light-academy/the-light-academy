#!/usr/bin/env python3
"""Проверява урока „Градът на степените“ — по друг път.

Три неща се доказват за всяка задача:

  1. ОТГОВОРЪТ. Условието се смята наново със sympy и се сверява с
     написания отговор. При изразите отговорът често е от две части
     („2⁷ = 128“) — и ДВЕТЕ трябва да дават същото число. Уравненията се
     решават наново, а „всяко число“ и „няма решение“ се доказват.

  2. ЕКРАНЪТ. HTML-ът, който вижда детето, се ЧЕТЕ НАЗАД по свои
     правила — дробта се връща в A/B, <sup> в степен — и полученият
     израз се сравнява със същия символен израз. Така условието на
     екрана не може да се разминава с условието, което се решава.

  3. ВСИЧКО ОСТАНАЛО: уникални номера, по пет задачи на ниво, решение с
     обяснение на всяка, никъде поле за въвеждане.

    /usr/bin/python3.13 scripts/check_grad6.py
"""
import re
import sys
from pathlib import Path

import sympy
from sympy.parsing.sympy_parser import (convert_xor,
                                        implicit_multiplication_application,
                                        parse_expr, split_symbols,
                                        standard_transformations)

KOREN = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from grad6.zadachi import ETAPI                     # noqa: E402
from grad6.izraz import izobrazi                    # noqa: E402

T = standard_transformations + (convert_xor, split_symbols,
                                implicit_multiplication_application)
GORNI = {'⁰': '0', '¹': '1', '²': '2', '³': '3', '⁴': '4', '⁵': '5',
         '⁶': '6', '⁷': '7', '⁸': '8', '⁹': '9', 'ⁿ': 'n'}

padnali = []
minali = 0


def ok(ime, uslovie, dop=''):
    global minali
    if uslovie:
        minali += 1
    else:
        padnali.append(ime + (' · ' + str(dop) if dop else ''))


def sp(s):
    """Низ → точен израз на sympy."""
    t = (str(s).replace('−', '-').replace('–', '-').replace('·', '*')
         .replace('×', '*').replace(':', '/'))
    t = re.sub(r'[⁰¹²³⁴⁵⁶⁷⁸⁹ⁿ]+',
               lambda m: '^(' + ''.join(GORNI[c] for c in m.group(0)) + ')', t)
    t = re.sub(r'(?<=\d),(?=\d)', '.', t)
    return sympy.nsimplify(parse_expr(t, transformations=T), rational=True)


# ── екранът се чете назад ────────────────────────────────────────────
FRAC = re.compile(
    r'<span class="frac"><span class="chis">(.*?)</span>'
    r'<span class="znam">(.*?)</span></span>')


def ot_ekrana(h):
    """HTML-ът, който вижда детето → израз. Отвътре навън."""
    predi = None
    while predi != h:
        predi = h
        h = FRAC.sub(lambda m: '((%s)/(%s))' % (m.group(1), m.group(2)), h)
    h = re.sub(r'<sup>(.*?)</sup>', lambda m: '^(%s)' % m.group(1), h)
    h = re.sub(r'</?i>', '', h)
    if '<' in h or '>' in h:
        raise ValueError('остана HTML: ' + h)
    return h


def chislo(s):
    t = str(s).strip()
    if not t:
        return None
    try:
        return sp(t)
    except Exception:                                    # noqa: BLE001
        return None


# ── проверките по видове ─────────────────────────────────────────────
def proveri_izraz(kude, z):
    stoinost = sympy.expand(sp(z['mat']))
    chasti = [c.strip() for c in z['otgovor'].split('=')]
    ok(kude + ': отговорът има поне една част', len(chasti) >= 1)
    for c in chasti:
        e = chislo(c)
        ok('%s: „%s“ е израз' % (kude, c), e is not None)
        if e is not None:
            ok('%s: „%s“ дава същото' % (kude, c),
               sympy.simplify(sympy.expand(e) - stoinost) == 0,
               'пресметнато „%s“' % stoinost)
    #  Първата част трябва да е СТЕПЕН или едночлен, а не само число —
    #  иначе задачата „запиши като степен“ си няма отговор.
    if len(chasti) == 2:
        ok(kude + ': първата част е записана като степен',
           '^' in sp(chasti[0]).__repr__() or sp(chasti[0]).is_Pow
           or any(c in chasti[0] for c in GORNI),
           chasti[0])


def proveri_pokazatel(kude, z):
    n = sympy.Symbol('n')
    l, d = z['mat'].split('=')
    #  Основите са равни, значи показателите също: сравняваме логаритмите
    #  по основата, за да не вдигаме огромни числа.
    reshenia = sympy.solve(sympy.Eq(sp(l), sp(d)), n)
    ok(kude + ': има точно един показател', len(reshenia) == 1, reshenia)
    m = re.fullmatch(r'n\s*=\s*(.+)', z['otgovor'].strip())
    ok(kude + ': отговорът е записан като n = …', bool(m), z['otgovor'])
    if m and len(reshenia) == 1:
        ok(kude + ': показателят съвпада', chislo(m.group(1)) == reshenia[0],
           'решено „%s“' % reshenia[0])


def proveri_uravnenie(kude, z):
    x = sympy.Symbol('x')
    l, d = z['mat'].split('=')
    raznica = sympy.simplify(sympy.expand(sp(l) - sp(d)))
    otg = z['otgovor'].strip()
    if otg == 'всяко число':
        ok(kude + ': наистина е вярно за всяко x', raznica == 0, raznica)
    elif otg == 'няма решение':
        ok(kude + ': наистина няма решение',
           raznica != 0 and not raznica.has(x), raznica)
    else:
        koreni = sympy.solve(sympy.Eq(sp(l), sp(d)), x)
        ok(kude + ': има точно един корен', len(koreni) == 1, koreni)
        m = re.fullmatch(r'x\s*=\s*(.+)', otg)
        ok(kude + ': отговорът е записан като x = …', bool(m), otg)
        if m and len(koreni) == 1:
            ok(kude + ': коренът съвпада', chislo(m.group(1)) == koreni[0],
               'в листа „%s“, решено „%s“' % (otg, koreni[0]))


PROVERKI = {'izraz': proveri_izraz, 'pokazatel': proveri_pokazatel,
            'uravnenie': proveri_uravnenie}


def main():
    vidqni, uslovia, broi = {}, {}, 0
    ok('етапите са три', len(ETAPI) == 3, len(ETAPI))

    for e in ETAPI:
        kude_e = '[%s]' % e['ime']
        ok(kude_e + ' има три нива', len(e['niva']) == 3, len(e['niva']))
        ok(kude_e + ' има идея', len(e.get('ideya', '')) > 30)
        ok(kude_e + ' има правила', len(e.get('pravila', [])) >= 2)
        drobi = (e['kod'] == 'e3')

        for nivo in e['niva']:
            kude_n = '%s %s' % (kude_e, nivo['ime'])
            ok(kude_n + ': пет задачи', len(nivo['zadachi']) == 5,
               len(nivo['zadachi']))
            for z in nivo['zadachi']:
                broi += 1
                kude = '%s · %s' % (kude_n, z['id'])
                ok(kude + ': номерът не се повтаря', z['id'] not in vidqni,
                   vidqni.get(z['id']))
                vidqni[z['id']] = kude
                ok(kude + ': условието не се повтаря', z['mat'] not in uslovia,
                   uslovia.get(z['mat']))
                uslovia[z['mat']] = kude
                ok(kude + ': има решение с обяснение',
                   len(z.get('reshenie', '')) > 25, z.get('reshenie', '')[:25])
                ok(kude + ': има отговор', bool(z.get('otgovor', '').strip()))

                #  1 · екранът се чете назад и трябва да е същият израз
                try:
                    ekran = izobrazi(z['mat'], drobi)
                    nazad = ot_ekrana(ekran)
                    if '=' in z['mat']:
                        a1, a2 = z['mat'].split('=')
                        b1, b2 = nazad.split('=')
                        edno = sympy.simplify(sp(a1) - sp(b1)) == 0
                        dve = sympy.simplify(sp(a2) - sp(b2)) == 0
                        ok(kude + ': екранът показва същото условие',
                           edno and dve, nazad)
                    else:
                        ok(kude + ': екранът показва същото условие',
                           sympy.simplify(sp(z['mat']) - sp(nazad)) == 0, nazad)
                except Exception as ex:                   # noqa: BLE001
                    padnali.append(kude + ': екранът не се чете · ' + repr(ex))

                #  2 · отговорът, пресметнат наново
                f = PROVERKI.get(z['vid'])
                ok(kude + ': познат вид', f is not None, z['vid'])
                if f is None:
                    continue
                try:
                    f(kude, z)
                except Exception as ex:                   # noqa: BLE001
                    padnali.append(kude + ': сметката не тръгва · ' + repr(ex))

    #  3 · сглобената страница
    stranica = KOREN / 'artefakti/urok_6_grad_stepeni.html'
    ok('страницата е сглобена', stranica.exists(), stranica.name)
    if stranica.exists():
        html = stranica.read_text(encoding='utf-8')
        ok('никъде няма поле за въвеждане',
           '<input' not in html and '<textarea' not in html)
        #  Броят се ключовете в данните, а не името на css класа.
        ok('всички задачи са вътре', html.count('"reshenie": "') == broi,
           html.count('"reshenie": "'))
        ok('има бутон „Покажи решението“', 'Покажи решението' in html)
        ok('заглавието е на мястото си', '<title>Градът на степените</title>' in html)
        ok('няма останали заготовки', not re.search(r'__[A-Z][A-Z_]*__', html))
        ok('страницата не носи своя <body>',
           '<body' not in html and '<html' not in html)
        ok('цветовете са определени и за тъмна тема',
           'prefers-color-scheme: dark' in html
           and ':root[data-theme="dark"]' in html)
        ok('страничният отстъп пази системната лента',
           'max(16px, env(safe-area-inset-left' in html
           and 'max(16px, env(safe-area-inset-right' in html)

    print('задачи: %d · проверки: %d' % (broi, minali))
    if padnali:
        print('ПАДНАЛИ (%d):' % len(padnali))
        for x in padnali[:30]:
            print(' -', x)
        sys.exit(1)
    print('✓ всеки отговор е пресметнат наново и екранът съвпада с него')


if __name__ == '__main__':
    main()
