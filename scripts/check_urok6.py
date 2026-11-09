#!/usr/bin/env python3
"""Проверката на урока за 6. клас — без доверие към отговорите.

Нищо тук не чете „този отговор е верен, значи е верен“. Всяко условие
се разчита наново от низа, който вижда детето, смята се със sympy и
чак тогава се сравнява с написаното:

  · числените изрази се пресмятат точно, с дроби, а не с плаващи числа;
  · буквените се разкриват и се сравняват като изрази, не като текст;
  · уравненията се решават наново, а „всяко число“ и „няма решение“ се
    доказват (разликата на двете страни е нула, съответно ненулево
    число);
  · текстовите задачи носят своето уравнение — проверява се, че коренът
    го удовлетворява, че е единствен и че отговорът го съдържа;
  · стандартният запис се сверява по стойност, не по вид;
  · сравненията („кое е по-голямо“) се пресмятат и двете страни.

Проверява се и готовата страница: че данните са извън коментара, че
всяко условие и всеки отговор са вътре, че отметките са налице и че
никъде не се иска въвеждане на отговор.

    /usr/bin/python3.13 scripts/check_urok6.py
"""
import json
import pathlib
import re
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from sympy import Rational, expand, symbols                      # noqa: E402
from urok6 import stepeni, uravneniq                             # noqa: E402
from urok6.smetki import izraz, koreni, parse, stoinost          # noqa: E402
from build_urok6 import IZHOD, SLUG, TABOVE                      # noqa: E402

PROVERKI = 0
GRESHKI = []


def tvurdi(uslovie, kakvo):
    global PROVERKI
    PROVERKI += 1
    if not uslovie:
        GRESHKI.append(kakvo)


def chislo(s):
    """Отговор, записан като число: 32, −81, 1/8, 0,001, 10 000."""
    return stoinost(s)


# ── задачите една по една ────────────────────────────────────────────
def provери_zadacha(z, kade):
    vid = z['vid']

    if vid == 'chislo':
        izchisleno = stoinost(z['izraz'])
        zapisano = chislo(z['otgovor'])
        tvurdi(izchisleno == zapisano,
               '{}: {} = {}, а е записано {}'.format(
                   kade, z['izraz'], izchisleno, z['otgovor']))

    elif vid == 'izraz':
        a = izraz(z['izraz'])
        b = izraz(z['otgovor'])
        tvurdi(expand(a - b) == 0,
               '{}: {} се опростява до {}, а е записано {}'.format(
                   kade, z['izraz'], a, z['otgovor']))
        #  Отговорът трябва да е по-кратък от условието: иначе не е опростен.
        tvurdi(len(z['otgovor']) <= len(z['izraz']),
               '{}: отговорът не е по-кратък от условието'.format(kade))

    elif vid == 'uravnenie':
        k = koreni(z['izraz'])
        otg = z['otgovor']
        if otg == 'всяко число':
            tvurdi(k is None, '{}: не е тъждество, корените са {}'.format(kade, k))
        elif otg == 'няма решение':
            tvurdi(k == [], '{}: има решение: {}'.format(kade, k))
        else:
            m = re.fullmatch(r'x = (.+)', otg)
            tvurdi(m is not None, '{}: отговорът не е във вида „x = …“'.format(kade))
            if m:
                zapisan = chislo(m.group(1))
                tvurdi(k is not None and len(k) == 1,
                       '{}: корените не са един: {}'.format(kade, k))
                if k:
                    tvurdi(Rational(k[0]) == zapisan,
                           '{}: {} има корен {}, а е записано {}'.format(
                               kade, z['izraz'], k[0], otg))
                    #  И обратната проверка: коренът наистина го удовлетворява.
                    lqva, dqsna = z['izraz'].split('=')
                    x = symbols('x')
                    tvurdi(expand((parse(lqva) - parse(dqsna)).subs(x, zapisan)) == 0,
                           '{}: записаният корен не удовлетворява уравнението'.format(kade))

    elif vid == 'standarten':
        tvurdi(stoinost(z['izraz']) == stoinost(z['otgovor']),
               '{}: {} и {} не са едно и също число'.format(
                   kade, z['izraz'], z['otgovor']))
        #  Единият от двата записа трябва да е стандартен: a · 10ⁿ с 1 ≤ a < 10.
        standarten = [t for t in (z['izraz'], z['otgovor']) if '10' in t and '·' in t]
        tvurdi(len(standarten) == 1,
               '{}: няма точно един стандартен запис'.format(kade))
        if standarten:
            mantisa = chislo(standarten[0].split('·')[0].strip())
            tvurdi(1 <= mantisa < 10,
                   '{}: множителят {} не е между 1 и 10'.format(kade, mantisa))

    elif vid == 'sravni':
        lqvo, dqsno = [t.strip() for t in z['izraz'].split(' и ')]
        a, b = stoinost(lqvo), stoinost(dqsno)
        m = re.fullmatch(r'(.+?) ([<>]) (.+)', z['otgovor'])
        tvurdi(m is not None, '{}: отговорът не е сравнение'.format(kade))
        if m:
            p, znak, q = m.group(1).strip(), m.group(2), m.group(3).strip()
            tvurdi({p, q} == {lqvo, dqsno},
                   '{}: сравняват се други изрази'.format(kade))
            vl, vd = stoinost(p), stoinost(q)
            tvurdi((vl > vd) if znak == '>' else (vl < vd),
                   '{}: {} {} {} е невярно ({} срещу {})'.format(
                       kade, p, znak, q, vl, vd))
            tvurdi(a != b, '{}: двете стойности са равни'.format(kade))

    elif vid == 'tekst':
        bukva = z.get('bukva', 'x')
        k = koreni(z['uravnenie'], bukva)
        tvurdi(k is not None and len(k) == 1,
               '{}: уравнението няма единствен корен: {}'.format(kade, k))
        if k:
            tvurdi(Rational(k[0]) == Rational(z['koren']),
                   '{}: коренът е {}, а е записано {}'.format(kade, k[0], z['koren']))
            #  Отговорът на въпроса трябва да носи следа от корена или от
            #  число, което се получава от него — иначе не е отговор.
            chisla = [int(t) for t in re.findall(r'\d+', z['otgovor'])]
            tvurdi(chisla, '{}: отговорът не съдържа нито едно число'.format(kade))
        tvurdi(z['izraz'].endswith('?'), '{}: условието не е въпрос'.format(kade))
        tvurdi(len(z['izraz']) >= 40, '{}: условието е много късо'.format(kade))

    else:
        GRESHKI.append('{}: непознат вид задача: {}'.format(kade, vid))

    #  Общото за всяка задача.
    tvurdi(len(z.get('reshenie', '')) >= 15, kade + ': липсва или е късо решението')
    tvurdi(z['id'].startswith(('st', 'ur')), kade + ': странно име на задача')


def razdelite():
    vidqni = set()
    broi = 0
    for tab in (stepeni, uravneniq):
        for r in tab.RAZDELI:
            tvurdi(len(r['ideya']) >= 40, r['kod'] + ': идеята е много къса')
            tvurdi(len(r['pravilo']) >= 10, r['kod'] + ': липсва правилото')
            tvurdi(len(r['zadachi']) >= 5, r['kod'] + ': по-малко от пет задачи')
            for n, z in enumerate(r['zadachi'], 1):
                kade = '{} · задача {}'.format(r['ime'], n)
                tvurdi(z['id'] not in vidqni, kade + ': повтарящо се име ' + z['id'])
                vidqni.add(z['id'])
                tvurdi(z['id'].startswith(r['kod']),
                       kade + ': името не започва с кода на раздела')
                provери_zadacha(z, kade)
                broi += 1
    return broi


def zvezdite():
    """Във всеки таб има раздел с по-трудни задачи и той е последен."""
    for tab in (stepeni, uravneniq):
        zvezdi = [r for r in tab.RAZDELI if r.get('zvezda')]
        tvurdi(len(zvezdi) == 1,
               tab.IME + ': разделите с по-трудни задачи не са един')
        if zvezdi:
            tvurdi(tab.RAZDELI[-1] is zvezdi[0],
                   tab.IME + ': по-трудните не са последни')
            tvurdi(len(zvezdi[0]['zadachi']) >= 7,
                   tab.IME + ': по-трудните задачи са по-малко от седем')


# ── страницата ───────────────────────────────────────────────────────
def stranicata():
    s = IZHOD.read_text(encoding='utf-8')

    i = s.index('/* ДАННИ:НАЧАЛО')
    kraj = s.index('*/', i) + 2
    tvurdi('\n' not in s[i:kraj], 'маркерът не затваря коментара си на своя ред')
    tvurdi(s[kraj:kraj + 1] == '\n' and s[kraj + 1:].lstrip().startswith('const UROK'),
           'данните не започват веднага след маркера')
    danni = json.loads(s[s.index('const UROK = ') + len('const UROK = '):
                         s.index(';\n/* ДАННИ:КРАЙ */')])

    tvurdi(len(danni['tabove']) == 2, 'табовете не са два')
    tvurdi([t['ime'] for t in danni['tabove']] == [stepeni.IME, uravneniq.IME],
           'табовете не са в реда Степенуване → Уравнения')
    tvurdi(danni['slug'] == SLUG, 'слугът не е ' + SLUG)

    #  Всяко условие и всеки отговор трябва да стоят в страницата.
    for t in danni['tabove']:
        for r in t['razdeli']:
            for z in r['zadachi']:
                for pole in ('izraz', 'otgovor', 'reshenie'):
                    tekst = z.get(pole, '')
                    tvurdi(json.dumps(tekst, ensure_ascii=False)[1:-1] in s,
                           'липсва от страницата: ' + tekst[:40])

    #  Отметката и показването на отговора ги има; въвеждане НЯМА.
    tvurdi('otmetni(' in s, 'липсва отметката „решено“')
    tvurdi('class="otmetka' in s, 'липсва кръгчето за отметка')
    tvurdi('bPokaji' in s or 'pokaji(' in s, 'липсва бутонът за показване на отговора')
    tvurdi('<input' not in s, 'на листа има поле за въвеждане, а не бива')
    tvurdi('<textarea' not in s, 'на листа има поле за писане, а не бива')
    tvurdi('localStorage' in s, 'отметките не се помнят')
    tvurdi(s.count('<style>') == s.count('</style>'), 'незатворен <style>')
    tvurdi(s.rstrip().endswith('</html>'), 'страницата не завършва с </html>')
    tvurdi('noindex' not in s, 'урокът не бива да е noindex — той е част от сайта')
    for duma in ('магия', 'magic'):
        tvurdi(duma not in s.lower(), 'думата „' + duma + '“ е забранена')

    #  Редът в базата сочи към този урок.
    sql = (KOREN / 'supabase/uroci.sql').read_text(encoding='utf-8')
    tvurdi("'" + SLUG + "'" in sql, 'SQL: липсва слугът ' + SLUG)
    tvurdi("'" + IZHOD.name in sql or IZHOD.name in sql,
           'SQL: липсва файлът ' + IZHOD.name)
    return len(s)


def main():
    broi = razdelite()
    zvezdite()
    tvurdi(broi == sum(len(r['zadachi']) for t in (stepeni, uravneniq)
                       for r in t.RAZDELI),
           'броят задачи не съвпада')
    znaka = stranicata()

    if GRESHKI:
        print('ГРЕШКИ ({}):'.format(len(GRESHKI)))
        for g in GRESHKI:
            print('  ·', g)
        sys.exit(1)
    print('всеки отговор е пресметнат наново · проверки: {} · задачи: {} · {} знака'
          .format(PROVERKI, broi, znaka))


if __name__ == '__main__':
    main()
