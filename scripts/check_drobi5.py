#!/usr/bin/env python3
"""Проверява урока „Дроби в сладкарницата“ — по друг път.

За всяка задача се доказват четири неща:

  1. ОТГОВОРЪТ. Условието се смята наново с ТОЧНИ дроби (sympy Rational)
     и се сверява с написания отговор.
  2. ВИДЪТ НА ОТГОВОРА. Дробта трябва да е съкратена ДОКРАЙ — написаният
     знаменател се сравнява със знаменателя на съкратената дроб — а
     когато стойността е по-голяма от 1, отговорът трябва да е смесено
     число, а не неправилна дроб.
  3. ЕКРАНЪТ. HTML-ът, който вижда детето, се чете назад по свои правила
     (дробта се връща в A/B, смесеното число в цяло + дроб) и полученият
     израз се сравнява със същата стойност.
  4. ВСИЧКО ОСТАНАЛО: уникални номера, по пет задачи на ниво, решение с
     обяснение на всяка, никъде поле за въвеждане.

    /usr/bin/python3.13 scripts/check_drobi5.py
"""
import re
import sys
from fractions import Fraction
from pathlib import Path

import sympy

KOREN = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from drobi5.zadachi import TABOVE                   # noqa: E402
from grad6.izraz import izobrazi                    # noqa: E402

padnali = []
minali = 0


def ok(ime, uslovie, dop=''):
    global minali
    if uslovie:
        minali += 1
    else:
        padnali.append(ime + (' · ' + str(dop) if dop else ''))


MX = re.compile(r'mx\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)')


def stoinost(mat):
    """Машинният израз → точна дроб. Смесените числа се разгъват първо."""
    t = MX.sub(lambda m: '(%s + Rational(%s,%s))'
               % (m.group(1), m.group(2), m.group(3)), mat)
    t = t.replace('−', '-').replace('·', '*').replace(':', '/')
    #  Всяко голо число става точна дроб, за да няма плаваща запетая.
    izraz = sympy.sympify(t, rational=True, evaluate=True)
    return Fraction(int(sympy.Rational(izraz).p), int(sympy.Rational(izraz).q))


def napisan(s):
    """„1 5/12“, „11/24“, „2“ → (стойност, написан знаменател, смесено ли е)."""
    t = str(s).strip()
    m = re.fullmatch(r'(\d+)\s+(\d+)/(\d+)', t)
    if m:
        c, b, z = int(m.group(1)), int(m.group(2)), int(m.group(3))
        return Fraction(c * z + b, z), z, True
    m = re.fullmatch(r'(\d+)/(\d+)', t)
    if m:
        return Fraction(int(m.group(1)), int(m.group(2))), int(m.group(2)), False
    m = re.fullmatch(r'\d+', t)
    if m:
        return Fraction(int(t)), 1, False
    return None, None, None


# ── екранът се чете назад ────────────────────────────────────────────
SMES = re.compile(
    r'(\d+)<span class="frac smes"><span class="chis">(\d+)</span>'
    r'<span class="znam">(\d+)</span></span>')
FRAC = re.compile(
    r'<span class="frac"><span class="chis">(.*?)</span>'
    r'<span class="znam">(.*?)</span></span>')


def ot_ekrana(h):
    """HTML-ът на екрана → израз. Смесените числа първо, после дробите."""
    h = SMES.sub(lambda m: '((%s) + (%s)/(%s))'
                 % (m.group(1), m.group(2), m.group(3)), h)
    predi = None
    while predi != h:
        predi = h
        h = FRAC.sub(lambda m: '((%s)/(%s))' % (m.group(1), m.group(2)), h)
    h = h.replace('−', '-').replace('·', '*').replace(' : ', '/')
    if '<' in h or '>' in h:
        raise ValueError('остана HTML: ' + h)
    return h


def main():
    vidqni, uslovia, broi = {}, {}, 0
    ok('табовете са два', len(TABOVE) == 2, len(TABOVE))

    for t in TABOVE:
        kude_t = '[%s]' % t['ime']
        ok(kude_t + ' има три нива', len(t['niva']) == 3, len(t['niva']))
        ok(kude_t + ' има идея', len(t.get('ideya', '')) > 40)
        ok(kude_t + ' има правила', len(t.get('pravila', [])) >= 2)

        for nivo in t['niva']:
            kude_n = '%s %s' % (kude_t, nivo['ime'])
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
                   len(z.get('reshenie', '')) > 30, z.get('reshenie', '')[:30])

                try:
                    v = stoinost(z['mat'])
                except Exception as ex:                   # noqa: BLE001
                    padnali.append(kude + ': изразът не се смята · ' + repr(ex))
                    continue

                #  1 · отговорът
                dadeno, znam, smeseno = napisan(z['otgovor'])
                ok(kude + ': отговорът е дроб или смесено число',
                   dadeno is not None, z['otgovor'])
                if dadeno is None:
                    continue
                ok(kude + ': отговорът съвпада със сметката', dadeno == v,
                   'написано „%s“, пресметнато „%s“' % (z['otgovor'], v))

                #  2 · видът на отговора
                ok(kude + ': дробта е съкратена докрай',
                   znam == v.denominator or (v.denominator == 1 and znam == 1)
                   or (smeseno and znam == v.denominator),
                   'написан знаменател %s, съкратен %s' % (znam, v.denominator))
                if v > 1 and v.denominator != 1:
                    ok(kude + ': по-голямо от 1 се пише като смесено число',
                       smeseno, z['otgovor'])
                else:
                    ok(kude + ': не е излишно смесено', not smeseno
                       or v > 1, z['otgovor'])
                ok(kude + ': стойността е положителна', v > 0, v)

                #  3 · екранът
                try:
                    ekran = izobrazi(z['mat'], True)
                    nazad = ot_ekrana(ekran)
                    ok(kude + ': екранът показва същото условие',
                       stoinost(nazad) == v, nazad)
                except Exception as ex:                   # noqa: BLE001
                    padnali.append(kude + ': екранът не се чете · ' + repr(ex))

    #  4 · сглобената страница
    stranica = KOREN / 'artefakti/urok_5_drobi.html'
    ok('страницата е сглобена', stranica.exists(), stranica.name)
    if stranica.exists():
        html = stranica.read_text(encoding='utf-8')
        ok('никъде няма поле за въвеждане',
           '<input' not in html and '<textarea' not in html)
        ok('всички задачи са вътре', html.count('"reshenie": "') == broi,
           html.count('"reshenie": "'))
        ok('има бутон „Покажи решението“', 'Покажи решението' in html)
        ok('заглавието е на мястото си',
           '<title>Дроби в сладкарницата</title>' in html)
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
