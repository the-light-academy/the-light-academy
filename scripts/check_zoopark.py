#!/usr/bin/env python3
"""Проверява урока за 7. клас — формулите и разлагането на множители.

Нищо не се вярва на доверие. Проверката чете СЪЩИЯ низ, който детето
вижда на екрана, вади математиката от него и я смята наново със sympy:

  · „Развийте …“      — развива се наново и се сверява с отговора;
    иска се и отговорът да е наистина развит, без неразкрити скоби.
  · „Разложете …“     — отговорът се развива и трябва да съвпадне с
    условието; освен това всеки написан множител се разлага поотделно и
    ако някой може да се разложи още, задачата пада. Така „докрай“ не е
    пожелание, а проверено твърдение.
  · „Решете уравнението …“ — уравнението се решава наново; „няма
    решение“ и „всяко число“ също се доказват.
  · „Пресметнете …“   — числото се пресмята с точни дроби.
  · условията с a + b и a · b — системата се решава и търсеният израз се
    пресмята за всяко решение.
  · най-малка стойност — през производната, а не през формулата от
    решението.

    /usr/bin/python3.13 scripts/check_zoopark.py
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

from zoopark import formuli, razlagane            # noqa: E402

T = standard_transformations + (convert_xor, split_symbols,
                                implicit_multiplication_application)

GORNI = {'⁰': '0', '¹': '1', '²': '2', '³': '3', '⁴': '4',
         '⁵': '5', '⁶': '6', '⁷': '7', '⁸': '8', '⁹': '9'}

padnali = []
minali = 0


def ok(ime, uslovie, dop=''):
    global minali
    if uslovie:
        minali += 1
    else:
        padnali.append(ime + (' · ' + str(dop) if dop else ''))


def chist(s: str) -> str:
    """Низът от екрана → низ, който sympy разбира.

    Горните индекси се събират на групи: „2²⁵“ става 2^25, а не 2^2·5.
    Интервалите между групи по три цифри („10 609“) са разделител за
    хиляди и отпадат. Двоеточието тук е деление — то остава само когато
    вече сме отрязали глагола отпред.
    """
    t = (str(s).replace('−', '-').replace('–', '-').replace('—', '-')
         .replace('·', '*').replace('×', '*')
         .replace(' ', ' ').replace(' ', ' '))
    t = re.sub(r'[⁰¹²³⁴⁵⁶⁷⁸⁹]+',
               lambda m: '^' + ''.join(GORNI[c] for c in m.group(0)), t)
    t = re.sub(r'(?<=\d) (?=\d{3}(\D|$))', '', t)      # 10 609 → 10609
    t = re.sub(r'(?<=\d),(?=\d)', '.', t)              # 1,5 → 1.5
    t = t.replace(':', '/').replace(' ', '')
    return t


def sp(s):
    """Израз от екрана → точен израз на sympy (без плаваща запетая)."""
    e = parse_expr(chist(s), transformations=T, evaluate=True)
    return sympy.nsimplify(e, rational=True)


def matematika(izraz: str) -> str:
    """Отрязва глагола пред първото двоеточие: остава само изразът."""
    return izraz.split(':', 1)[1] if ':' in izraz else izraz


def mnojiteli(s: str):
    """Множителите, КАКТО СА НАПИСАНИ на екрана: (низ, степен).

    Не минава през sympy, защото sympy сам разваля написаното: щом види
    5·(x − 2), веднага го разпределя на 5x − 10 и проверката „разложено
    ли е докрай“ би паднала върху собствената си стъпка. Затова низът се
    разрязва на ръка: всяка скоба със степента си е един множител, а
    всичко между скобите — едночлен.
    """
    t = chist(s)
    out, i = [], 0
    while i < len(t):
        if t[i] == '(':
            dulbochina, j = 0, i
            while j < len(t):
                if t[j] == '(':
                    dulbochina += 1
                elif t[j] == ')':
                    dulbochina -= 1
                    if dulbochina == 0:
                        break
                j += 1
            if dulbochina != 0:
                raise ValueError('незатворена скоба в „%s“' % s)
            grupa, i = t[i:j + 1], j + 1
            step = 1
            m = re.match(r'\^(\d+)', t[i:])
            if m:
                step, i = int(m.group(1)), i + m.end()
            out.append((grupa, step))
        else:
            j = i
            while j < len(t) and t[j] != '(':
                j += 1
            parche = t[i:j].strip('*')
            i = j
            if parche and parche not in ('-', '+'):
                out.append((parche, 1))
    return out


def razlojen_dokraj(s: str):
    """Вярно ли е, че отговорът, както е написан, е разложен докрай.

    Всеки написан множител се разлага поотделно. Ако sympy извади от
    него още нещо, написаното не е докрай. Числата се прескачат.
    """
    tejest = 0
    for parche, step in mnojiteli(s):
        e = sp(parche)
        if e.is_Number:
            continue
        tejest += step
        if e.is_Add and sympy.factor(e) != e:
            return False, 'множителят %s се разлага още на %s' % (
                e, sympy.factor(e))
    if tejest < 2:
        return False, 'написаното не е произведение'
    return True, ''


def chislo(s):
    """„2 500“, „1,5“, „няма решение“ → точно число или None."""
    t = chist(s)
    try:
        return sympy.nsimplify(sympy.sympify(t), rational=True)
    except Exception:                                   # noqa: BLE001
        return None


# ── проверките по видове ─────────────────────────────────────────────
def proveri_razvij(kude, z):
    lqvo = sp(matematika(z['izraz']))
    desno = sp(z['otgovor'])
    ok(kude + ': отговорът съвпада с развитото',
       sympy.expand(lqvo - desno) == 0,
       'на екрана „%s“, пресметнато „%s“' % (z['otgovor'], sympy.expand(lqvo)))
    ok(kude + ': отговорът е наистина развит',
       sympy.expand(desno) == desno,
       'остават неразкрити скоби: %s' % z['otgovor'])


def proveri_razloji(kude, z):
    lqvo = sp(matematika(z['izraz']))
    desno = sp(z['otgovor'])
    ok(kude + ': разлагането дава същия израз',
       sympy.expand(lqvo - desno) == 0,
       'на екрана „%s“, развито „%s“ срещу „%s“'
       % (z['otgovor'], sympy.expand(desno), sympy.expand(lqvo)))
    dobre, zashto = razlojen_dokraj(z['otgovor'])
    ok(kude + ': разложено е докрай', dobre, zashto)


def proveri_uravnenie(kude, z):
    tqlo = matematika(z['izraz'])
    ok(kude + ': уравнението има едно равенство', tqlo.count('=') == 1, tqlo)
    if tqlo.count('=') != 1:
        return
    l, d = tqlo.split('=')
    raznica = sympy.expand(sp(l) - sp(d))
    x = sympy.Symbol('x')
    otg = z['otgovor'].strip()
    if otg == 'всяко число':
        ok(kude + ': наистина е вярно за всяко x', raznica == 0, raznica)
    elif otg == 'няма решение':
        ok(kude + ': наистина няма решение',
           raznica != 0 and not raznica.has(x), raznica)
    else:
        koreni = sympy.solve(sympy.Eq(sp(l), sp(d)), x)
        ok(kude + ': уравнението има точно един корен', len(koreni) == 1, koreni)
        if len(koreni) == 1:
            m = re.fullmatch(r'x\s*=\s*(.+)', otg)
            ok(kude + ': отговорът е записан като x = …', bool(m), otg)
            if m:
                ok(kude + ': коренът съвпада',
                   chislo(m.group(1)) == koreni[0],
                   'на екрана „%s“, решено „%s“' % (otg, koreni[0]))


def proveri_smetka(kude, z):
    stoinost = sp(matematika(z['izraz']))
    ok(kude + ': числото съвпада с пресметнатото',
       chislo(z['otgovor']) == stoinost,
       'на екрана „%s“, пресметнато „%s“' % (z['otgovor'], stoinost))


def proveri_sistema(kude, z):
    bukvi = sorted({c for u in z['uslovia'] for c in u if c.isalpha()})
    simvoli = [sympy.Symbol(b) for b in bukvi]
    uravnenia = []
    for u in z['uslovia']:
        l, d = u.split('=')
        uravnenia.append(sympy.Eq(sp(l), sp(d)))
    tursi = sp(z['tursi'])
    reshenia = sympy.solve(uravnenia, simvoli, dict=True)
    ok(kude + ': системата има решение', len(reshenia) > 0, z['uslovia'])
    stoinosti = {sympy.simplify(sympy.expand(tursi.subs(r))) for r in reshenia}
    ok(kude + ': търсеното е едно и също за всички решения',
       len(stoinosti) == 1, stoinosti)
    if len(stoinosti) == 1:
        ok(kude + ': стойността съвпада с отговора',
           chislo(z['otgovor']) == stoinosti.pop(),
           'на екрана „%s“' % z['otgovor'])


def proveri_min(kude, z):
    x = sympy.Symbol('x')
    f = sp(z['izraz_m'])
    kriticni = sympy.solve(sympy.diff(f, x), x)
    ok(kude + ': има една критична точка', len(kriticni) == 1, kriticni)
    if len(kriticni) != 1:
        return
    x0 = kriticni[0]
    ok(kude + ': точката е минимум', sympy.diff(f, x, 2) > 0, sympy.diff(f, x, 2))
    y0 = sympy.simplify(f.subs(x, x0))
    m = re.fullmatch(r'(.+?)\s+при\s+x\s*=\s*(.+)', z['otgovor'].strip())
    ok(kude + ': отговорът е записан като „… при x = …“', bool(m), z['otgovor'])
    if m:
        ok(kude + ': най-малката стойност съвпада', chislo(m.group(1)) == y0, y0)
        ok(kude + ': постига се при същото x', chislo(m.group(2)) == x0, x0)


PROVERKI = {'razvij': proveri_razvij, 'razloji': proveri_razloji,
            'uravnenie': proveri_uravnenie, 'smetka': proveri_smetka,
            'sistema': proveri_sistema, 'min': proveri_min}


# ── обхождане ────────────────────────────────────────────────────────
def razdeli_na_urok():
    """Всички раздели с пътя до тях — и от двата таба."""
    out = [('Формули', r) for r in formuli.RAZDELI]
    for p in razlagane.PODTABOVE:
        for r in p['razdeli']:
            out.append(('Разлагане · ' + p['ime'], r))
    return out


def main():
    vidqni_id = {}
    vidqni_uslovia = {}
    broi = 0

    for put, r in razdeli_na_urok():
        kude_r = '[%s · %s]' % (put, r['ime'])
        for pole in ('zhivotno', 'tema', 'ideya', 'pravilo', 'fakt'):
            ok(kude_r + ': има ' + pole, bool(r.get(pole)))
        ok(kude_r + ': поне пет задачи', len(r['zadachi']) >= 5, len(r['zadachi']))

        for i, z in enumerate(r['zadachi'], 1):
            broi += 1
            kude = '%s задача %d' % (kude_r, i)
            ok(kude + ': има номер', bool(z.get('id')))
            ok(kude + ': номерът не се повтаря', z['id'] not in vidqni_id,
               'същият като %s' % vidqni_id.get(z['id']))
            vidqni_id[z['id']] = kude
            ok(kude + ': има отговор', bool(str(z.get('otgovor', '')).strip()))
            ok(kude + ': решението обяснява', len(z.get('reshenie', '')) > 25,
               z.get('reshenie', '')[:30])
            uslovie = z.get('izraz') or z.get('izraz_m') or ' '.join(
                z.get('uslovia', [])) + ' ' + z.get('tursi', '')
            ok(kude + ': условието не се повтаря', uslovie not in vidqni_uslovia,
               'същото като %s' % vidqni_uslovia.get(uslovie))
            vidqni_uslovia[uslovie] = kude

            f = PROVERKI.get(z['vid'])
            ok(kude + ': познат вид задача', f is not None, z['vid'])
            if f is None:
                continue
            try:
                f(kude, z)
            except Exception as e:                        # noqa: BLE001
                padnali.append(kude + ': сметката не тръгва · ' + repr(e))

    # сглобената страница
    stranica = KOREN / 'uroci/urok_7_formuli_razlagane.html'
    ok('страницата е сглобена', stranica.exists(), stranica.name)
    if stranica.exists():
        html = stranica.read_text(encoding='utf-8').replace('\u00a0', ' ')
        ok('няма поле за въвеждане — урокът се води на дъската',
           '<input' not in html and '<textarea' not in html)
        ok('всички задачи са вътре', html.count('"otgovor"') == broi,
           html.count('"otgovor"'))
        ok('трите подтаба са вътре',
           all(('"ime": "' + p['ime'] + '"') in html
               for p in razlagane.PODTABOVE))
        ok('данните не са глътнати от коментар',
           '/* ДАННИ:КРАЙ */' in html and 'const UROK' in html)
        ok('шрифтът на задачите не пада под 22px на телефон',
           not re.search(r'\.zad__uslovie\{[^}]*font-size:\s*(1\d|[0-9])px', html))

        #  Глаголът се отделя от математиката при сглобяването. Тук се
        #  гледа, че при това разделяне не се е загубило нищо: и двете
        #  половини ги има на страницата.
        lipsvat = []
        for _put, _r in razdeli_na_urok():
            for _z in _r['zadachi']:
                if _z['vid'] in ('sistema', 'min'):
                    continue
                glagol, _, mat = _z['izraz'].partition(':')
                if mat.strip() not in html or glagol.strip() not in html:
                    lipsvat.append(_z['id'])
        ok('условията са цели на страницата', not lipsvat, ', '.join(lipsvat))

    print('задачи: %d · проверки: %d' % (broi, minali))
    if padnali:
        print('ПАДНАЛИ (%d):' % len(padnali))
        for p in padnali[:40]:
            print(' -', p)
        sys.exit(1)
    print('✓ всеки отговор е пресметнат наново и съвпада')


if __name__ == '__main__':
    main()
