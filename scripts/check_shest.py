#!/usr/bin/env python3
"""Проверява урока „Топящото се домашно“ — 6. клас, шест теми.

Нищо не се вярва на доверие:

  1. ОТГОВОРЪТ. Условието се смята наново със sympy и се сверява с
     написания отговор. Когато отговорът е от две части („3⁵ = 243“),
     и двете трябва да дават същото. Уравненията се решават наново.
  2. ВИДЪТ. Опростеният израз трябва да е НАИСТИНА опростен — без
     неразкрити скоби. Където има мерна единица, тя трябва да я има и в
     отговора.
  3. ЕКРАНЪТ. HTML-ът, който вижда детето, се чете назад по свои
     правила (дробта се връща в A/B, <sup> в степен) и полученият израз
     се сравнява със същата стойност.
  4. РЕШЕНИЕТО. То се чете на глас, затова се проверява ред по ред:
     стига ли до същия отговор; вярно ли е всяко написано равенство
     („3,14 · 25 = 78,5“) и всяко тъждество („6a − 2a = 4a“); пази ли
     корена всяко написано уравнение; вярно ли е всяко НОК и НОД; и
     тръгва ли от същия израз, който стои в условието.
  5. УСЛОВИЕТО. При задачите с думи всяко число от текста трябва да го
     има и в сметката (или да личи в решението, ако е получено по
     пътя — диаметър 12 → радиус 6). Изречените формули се сверяват с
     кратък списък, изписан тук наново по учебника.
  6. Структурата: 45 задачи, уникални номера и условия, обяснение
     навсякъде, и градация — всеки таб свършва с по-дълга задача от тази,
     с която почва.

Какво НЕ хваща: цифра, зазидана в обяснителна дума без равенство около
нея („Всичко към основа 2“, „Общ знаменател 6:“). Мутационният тест го
показва — 189 от 193 развалени подробности биват уловени, а четирите
останали са точно от този вид.

    /usr/bin/python3.13 scripts/check_shest.py
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

from shest.zadachi import TABOVE                   # noqa: E402
from grad6.izraz import izobrazi                   # noqa: E402

from obshto.proverka import (  # noqa: F401
    BUKVI, FORMULI, FRAC, GORNI, GORNI_ZNACI, T, ZNACI, _bukva,
    _normalizirai, _otrqzano_otpred, _otrqzano_otzad, _parcheta, _strana,
    _strani, bez_edinica, chislata_v_teksta, chislo, formulite_sa_pravilni,
    golo, minali, nachaloto_na_resheniyeto, nok_i_nod, ot_ekrana,
    otgovorut_lichi, padnali, ravenstvata_sa_verni, smetkata_lichi, sp,
    tojdestvata_sa_verni, uravneniqta_sled_sebe_si)


def ok(ime, uslovie, dop=''):
    global minali
    if uslovie:
        minali += 1
    else:
        padnali.append(ime + (' · ' + str(dop) if dop else ''))


def proveri_izraz(kude, z):
    stoinost = sympy.expand(sp(z['mat']))
    chasti = [c.strip() for c in z['otgovor'].split('=')]
    for c in chasti:
        e = chislo(c)
        ok('%s: „%s“ се чете като израз' % (kude, c), e is not None)
        if e is not None:
            ok('%s: „%s“ дава същото' % (kude, c),
               sympy.simplify(sympy.expand(e) - stoinost) == 0,
               'пресметнато „%s“' % stoinost)
    if len(chasti) == 1:
        e = chislo(chasti[0])
        if e is not None:
            ok(kude + ': отговорът е опростен докрай',
               sympy.expand(e) == e and '(' not in chasti[0],
               'остават скоби: ' + chasti[0])
    else:
        ok(kude + ': първата част е записана като степен',
           any(c in chasti[0] for c in GORNI), chasti[0])


def proveri_uravnenie(kude, z):
    x = sympy.Symbol('x')
    l, d = z['mat'].split('=')
    koreni = sympy.solve(sympy.Eq(sp(l), sp(d)), x)
    ok(kude + ': уравнението има точно един корен', len(koreni) == 1, koreni)
    m = re.fullmatch(r'x\s*=\s*(.+)', z['otgovor'].strip())
    ok(kude + ': отговорът е записан като x = …', bool(m), z['otgovor'])
    if m and len(koreni) == 1:
        ok(kude + ': коренът съвпада', chislo(m.group(1)) == koreni[0],
           'на екрана „%s“, решено „%s“' % (z['otgovor'], koreni[0]))


def proveri_tekst(kude, z):
    x = sympy.Symbol('x')
    l, d = z['mat'].split('=')
    koreni = sympy.solve(sympy.Eq(sp(l), sp(d)), x)
    ok(kude + ': уравнението има точно един корен', len(koreni) == 1, koreni)
    gol = bez_edinica(z['otgovor'], z.get('edinica'))
    chisla = re.findall(r'-?\d+(?:[.,]\d+)?', gol)
    ok(kude + ': отговорът носи точно едно число', len(chisla) == 1, chisla)
    if len(koreni) == 1 and len(chisla) == 1:
        ok(kude + ': отговорът съвпада с корена',
           chislo(chisla[0]) == koreni[0], 'решено „%s“' % koreni[0])
        ok(kude + ': отговорът има смисъл (положителен)', koreni[0] > 0,
           koreni[0])


def proveri_smetka(kude, z):
    stoinost = sympy.expand(sp(z['mat']))
    gol = bez_edinica(z['otgovor'], z.get('edinica'))
    ok(kude + ': числото съвпада с пресметнатото', chislo(gol) == stoinost,
       'на екрана „%s“, пресметнато „%s“' % (z['otgovor'], stoinost))


PROVERKI = {'izraz': proveri_izraz, 'uravnenie': proveri_uravnenie,
            'tekst': proveri_tekst, 'smetka': proveri_smetka}


def main():
    vidqni, uslovia, broi = {}, {}, 0
    ok('табовете са шест', len(TABOVE) == 6, len(TABOVE))

    for t in TABOVE:
        kude_t = '[%s]' % t['ime']
        ok(kude_t + ' има идея', len(t.get('ideya', '')) > 40)
        ok(kude_t + ' има правила', len(t.get('pravila', [])) >= 2)
        #  Правилата стоят най-отгоре в таба — ако там е изписана
        #  сбъркана формула, целият таб тръгва накриво.
        losho = [x for red in list(t['pravila']) + [t['ideya']]
                 for x in formulite_sa_pravilni(red)]
        ok(kude_t + ': формулите в правилата са по учебник',
           not losho, ' · '.join(losho))
        ok(kude_t + ' има кратко име', len(t.get('kratko', '')) > 2)
        ok(kude_t + ' има знак', bool(t.get('znak')))

        for i, z in enumerate(t['zadachi'], 1):
            broi += 1
            kude = '%s задача %d' % (kude_t, i)
            ok(kude + ': номерът не се повтаря', z['id'] not in vidqni,
               vidqni.get(z['id']))
            vidqni[z['id']] = kude
            ok(kude + ': условието не се повтаря', z['mat'] not in uslovia,
               uslovia.get(z['mat']))
            uslovia[z['mat']] = kude
            ok(kude + ': има решение с обяснение',
               len(z.get('reshenie', '')) > 25, z.get('reshenie', '')[:25])
            ok(kude + ': има отговор', bool(str(z.get('otgovor', '')).strip()))
            ok(kude + ': решението стига до същия отговор',
               otgovorut_lichi(z), z['otgovor'])
            losho = ravenstvata_sa_verni(z['reshenie'])
            ok(kude + ': всяка стъпка в решението е вярна',
               not losho, ' · '.join(losho))
            if '=' in z['mat'] and 'x' in z['mat']:
                losho = uravneniqta_sled_sebe_si(z)
                ok(kude + ': всяко уравнение в решението пази корена',
                   not losho, ' · '.join(losho))
            if z['vid'] == 'izraz':
                losho = tojdestvata_sa_verni(z)
                ok(kude + ': всяко тъждество в решението е вярно',
                   not losho, ' · '.join(losho))
            losho = nok_i_nod(z['reshenie'])
            ok(kude + ': НОК и НОД са пресметнати вярно',
               not losho, ' · '.join(losho))
            edno_i_sushto = nachaloto_na_resheniyeto(z)
            if edno_i_sushto is not None:
                ok(kude + ': решението тръгва от същия израз',
                   edno_i_sushto, z['reshenie'].split('.')[0])
            losho = formulite_sa_pravilni(z['reshenie'])
            ok(kude + ': изречените формули са по учебник',
               not losho, ' · '.join(losho))
            if z.get('izraz'):
                lipsvat = chislata_v_teksta(z)
                ok(kude + ': числата в условието ги има и в сметката',
                   not lipsvat, ', '.join(lipsvat))
            if z.get('edinica'):
                ok(kude + ': решението носи мерната единица',
                   z['edinica'] in z['reshenie'], z['reshenie'][-20:])
            if z.get('edinica'):
                ok(kude + ': отговорът носи мерната единица',
                   str(z['otgovor']).strip().endswith(z['edinica']),
                   z['otgovor'])

            #  екранът показва същото условие
            if z['vid'] in ('izraz', 'uravnenie'):
                try:
                    ekran = izobrazi(z['mat'], True)
                    nazad = ot_ekrana(ekran)
                    if '=' in z['mat']:
                        a1, a2 = z['mat'].split('=')
                        b1, b2 = nazad.split('=')
                        ok(kude + ': екранът показва същото условие',
                           sympy.simplify(sp(a1) - sp(b1)) == 0
                           and sympy.simplify(sp(a2) - sp(b2)) == 0, nazad)
                    else:
                        ok(kude + ': екранът показва същото условие',
                           sympy.simplify(sp(z['mat']) - sp(nazad)) == 0, nazad)
                except Exception as ex:                   # noqa: BLE001
                    padnali.append(kude + ': екранът не се чете · ' + repr(ex))
            else:
                #  Тук условието е изречение; сметката зад него трябва да
                #  личи в написаното решение, инак проверката пази нещо,
                #  което детето никъде не вижда.
                ok(kude + ': решението показва същата сметка',
                   smetkata_lichi(z['mat'], z['reshenie']), golo(z['mat']))

            f = PROVERKI.get(z['vid'])
            ok(kude + ': познат вид', f is not None, z['vid'])
            if f is None:
                continue
            try:
                f(kude, z)
            except Exception as ex:                       # noqa: BLE001
                padnali.append(kude + ': сметката не тръгва · ' + repr(ex))

        #  градация: последната задача в таба е по-дълга от първата
        purva, posledna = t['zadachi'][0], t['zadachi'][-1]
        ok(kude_t + ': последната задача е по-тежка от първата',
           len(posledna['mat']) > len(purva['mat'])
           or len(posledna.get('izraz', '')) > len(purva.get('izraz', '')),
           '%s → %s' % (purva['mat'], posledna['mat']))

    ok('задачите са точно 45', broi == 45, broi)

    #  сглобената страница
    stranica = KOREN / 'artefakti/urok_6_shest_temi.html'
    ok('страницата е сглобена', stranica.exists(), stranica.name)
    if stranica.exists():
        html = stranica.read_text(encoding='utf-8')
        ok('никъде няма поле за въвеждане',
           '<input' not in html and '<textarea' not in html)
        ok('всички задачи са вътре', html.count('"reshenie": "') == broi,
           html.count('"reshenie": "'))
        ok('има бутон „Покажи решението“', 'Покажи решението' in html)
        ok('има тикче за решена задача', 'data-o=' in html)
        ok('има лента с напредъка', 'id="lenta"' in html)
        ok('брои какво остава за домашно', 'за домашно' in html)
        ok('заглавието е на мястото си',
           '<title>Топящото се домашно</title>' in html)
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
