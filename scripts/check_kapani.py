#!/usr/bin/env python3
"""Проверява урока „Осемте капана“ — 7. клас.

Задачите идват от истински сгрешени задачи, затова е още по-важно
отговорът да е верен. Нищо не се вярва на доверие:

  1. ОТГОВОРЪТ. Условието се смята наново със sympy. Опростяванията се
     разгръщат и се сравняват; разлаганията се разлагат наново с
     factor() и трябва да съвпаднат СТРУКТУРНО — така „2(x² − 25)“ не
     минава за разложено докрай. Уравненията се решават наново.
  2. ВИДЪТ. Опростеният отговор трябва да е в нормален вид (нищо
     неразкрито), а разложеният — произведение, а не сбор.
  3. ЕКРАНЪТ. HTML-ът, който вижда детето, се чете НАЗАД и полученият
     израз се сравнява със същата стойност.
  4. РЕШЕНИЕТО се чете на глас, затова се проверява ред по ред: стига
     ли до същия отговор, вярно ли е всяко написано равенство и
     тъждество, пази ли корена всяко написано уравнение.
  5. УСЛОВИЕТО с думи: всяко число от текста трябва да го има и в
     сметката или в решението.
  6. СТРУКТУРАТА: 45 задачи в 8 таба, уникални номера и условия, всеки
     таб с описан капан, идея и правила, и градация във всеки таб.

Общите проверки стоят в scripts/obshto/proverka.py и се ползват и от
урока за 6. клас.

    /usr/bin/python3.13 scripts/check_kapani.py
"""
import pathlib
import re
import sys

import sympy

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from obshto.proverka import (  # noqa: E402
    T, GORNI, parse_expr,
    sp, chislo, bez_edinica, ot_ekrana, golo, otgovorut_lichi,
    ravenstvata_sa_verni, tojdestvata_sa_verni, uravneniqta_sled_sebe_si,
    chislata_v_teksta, nok_i_nod)
from kapani.zadachi import TABOVE                         # noqa: E402
from kapani.domashno import VUPROSI                       # noqa: E402
from grad6.izraz import izobrazi                          # noqa: E402

STRANICA = KOREN / 'artefakti/urok_7_kapani.html'
LIST = KOREN / 'homework_7_kapani.html'

vsichki, padnali = [], []


def ok(ime, uslovie, dop=''):
    vsichki.append(ime)
    if not uslovie:
        padnali.append(ime + (' · ' + str(dop) if dop else ''))


#  ── проверките по видове ────────────────────────────────────────────
def razgunato(e):
    """Същото ли е, разгърнато — тоест в нормален вид."""
    return sympy.expand(e)


def proveri_izraz(kude, z):
    """Опростяване: отговорът трябва да е същият и вече разгърнат."""
    stoinost = razgunato(sp(z['mat']))
    otg = chislo(z['otgovor'])
    ok('%s: отговорът се чете като израз' % kude, otg is not None,
       z['otgovor'])
    if otg is None:
        return
    ok('%s: отговорът дава същото' % kude,
       sympy.simplify(razgunato(otg) - stoinost) == 0, 'пресметнато %s' % stoinost)
    ok('%s: отговорът е в нормален вид' % kude,
       sympy.simplify(otg - razgunato(otg)) == 0 and otg == razgunato(otg),
       'разгърнато е %s' % razgunato(otg))


def faktorite(s):
    """Множителите на отговора така, както са НАПИСАНИ.

    Четем израза без да го смятаме (evaluate=False) — инак sympy сам
    разкрива „2(x² − 25)“ до „2x² − 50“ и спирката насред пътя става
    неразличима от разлагането докрай. После всеки множител се
    разгръща, за да не зависи сравнението от подредбата вътре в него.
    """
    t = (str(s).replace('−', '-').replace('·', '*').replace('×', '*')
         .replace(' ', '').replace(' ', ''))
    t = re.sub(r'[⁰¹²³⁴⁵⁶⁷⁸⁹]+',
               lambda m: '^(' + ''.join(GORNI[c] for c in m.group(0)) + ')', t)
    izraz = parse_expr(t, transformations=T, evaluate=False)

    def razpadni(e):
        if e.is_Mul:
            return [x for c in e.args for x in razpadni(c)]
        if e.is_Pow and e.exp.is_Integer and e.exp > 0:
            return razpadni(e.base) * int(e.exp)
        return [sympy.expand(e)]

    return sorted((str(x) for x in razpadni(izraz)))


def faktorite_na(e):
    """Същото, но за вече разложен израз на sympy."""
    koef, dvoiki = sympy.factor_list(e)
    spisuk = [] if koef == 1 else [str(sympy.expand(koef))]
    for f, n in dvoiki:
        spisuk += [str(sympy.expand(f))] * int(n)
    return sorted(spisuk)


def proveri_razlagane(kude, z):
    """Разлагане: вярно И докрай.

    factor() разлага условието по свой път. Отговорът трябва да съвпадне
    с него СТРУКТУРНО, не само по стойност — инак „2(x² − 25)“, което е
    вярно равенство, но спирка насред пътя, би минало.
    """
    cel = sympy.factor(sp(z['mat']))
    otg = chislo(z['otgovor'])
    ok('%s: отговорът се чете като израз' % kude, otg is not None,
       z['otgovor'])
    if otg is None:
        return
    ok('%s: отговорът дава същото' % kude,
       sympy.simplify(razgunato(otg) - razgunato(sp(z['mat']))) == 0,
       'разгърнато %s' % razgunato(otg))
    ok('%s: разложено е докрай' % kude,
       faktorite(z['otgovor']) == faktorite_na(sp(z['mat'])),
       'написано %s, а докрай е %s'
       % (faktorite(z['otgovor']), faktorite_na(sp(z['mat']))))
    ok('%s: отговорът е произведение, не сбор' % kude,
       otg.is_Mul or otg.is_Pow, str(otg.func))


def proveri_uravnenie(kude, z):
    lqvo, dqsno = z['mat'].split('=')
    koren = sympy.solve(sympy.Eq(sp(lqvo), sp(dqsno)), sympy.Symbol('x'))
    ok('%s: уравнението има точно един корен' % kude, len(koren) == 1, koren)
    kazan = str(z['otgovor']).split('=')[-1]
    nash = chislo(kazan)
    ok('%s: казаният корен се чете като число' % kude, nash is not None, kazan)
    if koren and nash is not None:
        ok('%s: коренът съвпада' % kude, sympy.simplify(koren[0] - nash) == 0,
           'решено %s' % koren[0])


def proveri_tekst(kude, z):
    stoinost = sp(z['mat'])
    kazan = bez_edinica(z['otgovor'], z.get('edinica', ''))
    nash = chislo(kazan)
    ok('%s: отговорът се чете' % kude, nash is not None, kazan)
    if nash is not None:
        ok('%s: отговорът дава същото' % kude,
           sympy.simplify(nash - stoinost) == 0, 'пресметнато %s' % stoinost)


PROVERKI = {'izraz': proveri_izraz, 'razlagane': proveri_razlagane,
            'uravnenie': proveri_uravnenie, 'tekst': proveri_tekst}


#  ── домашното ───────────────────────────────────────────────────────
def proveri_vupros(kude, v):
    """Въпросът в домашното: верният отговор е верен, а всеки друг — не.

    Разсейващите отговори не са измислени: те са точно това, което е
    написано в таблото. Затова всеки от тях трябва НАИСТИНА да е
    различен от верния — инак детето получава кръстче за верен отговор.
    """
    cel = sympy.expand(sp(v['mat'])) if v['vid'] == 'izraz' \
        else sympy.factor(sp(v['mat'])) if v['vid'] == 'razlagane' \
        else sp(v['mat'])
    if v['tip'] == 'mc':
        ok(kude + ': има точно четири избора', len(v['izbori']) == 4,
           len(v['izbori']))
        ok(kude + ': посоченият е в границите',
           0 <= v['veren'] < len(v['izbori']), v['veren'])
        for i, izbor in enumerate(v['izbori']):
            e = chislo(izbor)
            ok('%s: избор %d се чете' % (kude, i + 1), e is not None, izbor)
            if e is None:
                continue
            suvpada = sympy.simplify(sympy.expand(e) - sympy.expand(cel)) == 0
            if i == v['veren']:
                ok('%s: верният избор е верен' % kude, suvpada,
                   'пресметнато %s' % cel)
                if v['vid'] == 'razlagane':
                    ok('%s: верният избор е разложен докрай' % kude,
                       faktorite(izbor) == faktorite_na(sp(v['mat'])),
                       'докрай е %s' % faktorite_na(sp(v['mat'])))
            else:
                #  Разсейващ, който е тъждествено равен на верния, е
                #  капан към учителя, не към детето.
                ok('%s: избор %d наистина е грешен' % (kude, i + 1),
                   not suvpada, izbor)
        ok(kude + ': изборите не се повтарят',
           len({golo(x) for x in v['izbori']}) == len(v['izbori']),
           v['izbori'])
    else:
        nash = chislo(bez_edinica(v['otgovor'], v.get('edinica', '')))
        ok(kude + ': отговорът се чете', nash is not None, v['otgovor'])
        if nash is not None:
            ok(kude + ': отговорът дава същото',
               sympy.simplify(nash - cel) == 0, 'пресметнато %s' % cel)
            ok(kude + ': отговорът е число',
               nash.is_number, 'листът приема само числа тук')


def sveri_uslovieto(kude, v):
    """Това, което детето ЧЕТЕ, трябва да е същото, което се смята.

    Инак листът пита едно, а брои отговора на друго — и детето получава
    кръстче за вярна сметка.
    """
    posleden = str(v['uslovie']).split('\n')[-1].strip()
    if v['sverka'] == 'izraz':
        chete = chislo(posleden)
        ok(kude + ': написаното на листа се чете като израз',
           chete is not None, posleden)
        if chete is not None:
            ok(kude + ': написаното на листа дава същото',
               sympy.simplify(sympy.expand(chete)
                              - sympy.expand(sp(v['mat']))) == 0,
               'сметката е %s' % sp(v['mat']))
    else:
        #  Тук условието и сметката нарочно се различават (заместване,
        #  задача с думи): иска се само числата да са същите.
        imame = set(re.findall(r'\d+(?:[.,]\d+)?',
                               v['mat'] + ' ' + str(v.get('otgovor', ''))))
        imame = {x.replace(',', '.') for x in imame}
        lipsvat = [x for x in re.findall(r'\d+(?:[.,]\d+)?', v['uslovie'])
                   if x.replace(',', '.') not in imame]
        ok(kude + ': числата на листа ги има и в сметката',
           not lipsvat, ', '.join(lipsvat))


def sveri_obyasnenieto(kude, v):
    """Обяснението се чете след проверката — то също трябва да е вярно."""
    o = v['obyasnenie']
    losho = ravenstvata_sa_verni(o)
    ok(kude + ': всяко числово равенство в обяснението е вярно',
       not losho, ' · '.join(losho))
    losho = tojdestvata_sa_verni({'obyasnenie': o, 'reshenie': o})
    ok(kude + ': всяко тъждество в обяснението е вярно',
       not losho, ' · '.join(losho))
    veren = (v['izbori'][v['veren']] if v['tip'] == 'mc'
             else bez_edinica(v['otgovor'], v.get('edinica', '')))
    ok(kude + ': обяснението стига до верния отговор',
       golo(veren) in golo(o), veren)


def main():
    broi, vidqni, uslovia = 0, {}, {}
    ok('осем таба', len(TABOVE) == 8, len(TABOVE))

    for t in TABOVE:
        kude_t = '[%s]' % t['ime']
        for pole in ('kod', 'ime', 'kratko', 'znak', 'kapan', 'ideya'):
            ok('%s има %s' % (kude_t, pole), bool(str(t.get(pole, '')).strip()))
        ok(kude_t + ': капанът е описан с изречение',
           len(t['kapan']) > 40 and t['kapan'].endswith('.'), t['kapan'])
        ok(kude_t + ': има поне три правила', len(t.get('pravila', [])) >= 3,
           len(t.get('pravila', [])))

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
            ok(kude + ': всяко числово равенство в решението е вярно',
               not losho, ' · '.join(losho))
            if z['vid'] != 'uravnenie':
                #  В уравнение „=“ значи „решаваме“, а не „едно и също“:
                #  „x = 5 − 12 = −7“ е вярна стъпка, не невярно тъждество.
                losho = tojdestvata_sa_verni(z)
                ok(kude + ': всяко тъждество в решението е вярно',
                   not losho, ' · '.join(losho))
            if '=' in z['mat'] and 'x' in z['mat']:
                losho = uravneniqta_sled_sebe_si(z)
                ok(kude + ': всяко уравнение в решението пази корена',
                   not losho, ' · '.join(losho))
            losho = nok_i_nod(z['reshenie'])
            ok(kude + ': НОК и НОД са пресметнати вярно', not losho,
               ' · '.join(losho))
            if z.get('izraz'):
                lipsvat = chislata_v_teksta(z)
                ok(kude + ': числата в условието ги има и в сметката',
                   not lipsvat, ', '.join(lipsvat))
            if z.get('edinica'):
                ok(kude + ': отговорът носи мерната единица',
                   str(z['otgovor']).strip().endswith(z['edinica']),
                   z['otgovor'])

            #  екранът показва същото условие
            if z['vid'] in ('izraz', 'razlagane', 'uravnenie'):
                try:
                    nazad = ot_ekrana(izobrazi(z['mat'], True, True))
                    if '=' in z['mat']:
                        a1, a2 = z['mat'].split('=')
                        b1, b2 = nazad.split('=')
                        edno = (sympy.simplify(sp(a1) - sp(b1)) == 0
                                and sympy.simplify(sp(a2) - sp(b2)) == 0)
                    else:
                        edno = sympy.simplify(sp(z['mat']) - sp(nazad)) == 0
                    ok(kude + ': екранът показва същото условие', edno, nazad)
                except Exception as ex:                   # noqa: BLE001
                    padnali.append(kude + ': екранът не се чете · ' + repr(ex))

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
           len(posledna['mat']) + len(posledna.get('izraz', ''))
           > len(purva['mat']) + len(purva.get('izraz', '')),
           '%s → %s' % (purva['mat'], posledna['mat']))

    ok('общо 45 задачи', broi == 45, broi)

    #  ── домашното ───────────────────────────────────────────────────
    ok('домашното има 10 въпроса', len(VUPROSI) == 10, len(VUPROSI))
    kapani_v_uroka = {t['kod'] for t in TABOVE}
    pokriti = set()
    for i, v in enumerate(VUPROSI, 1):
        kude = 'домашно въпрос %d' % i
        ok(kude + ': сочи към капан от урока', v['kapan'] in kapani_v_uroka,
           v['kapan'])
        pokriti.add(v['kapan'])
        ok(kude + ': има обяснение', len(v.get('obyasnenie', '')) > 20)
        ok(kude + ': казано е как се сверява',
           v.get('sverka') in ('izraz', 'chisla'), v.get('sverka'))
        try:
            sveri_uslovieto(kude, v)
            sveri_obyasnenieto(kude, v)
        except Exception as ex:                           # noqa: BLE001
            padnali.append(kude + ': текстът не се чете · ' + repr(ex))
        try:
            proveri_vupros(kude, v)
        except Exception as ex:                           # noqa: BLE001
            padnali.append(kude + ': сметката не тръгва · ' + repr(ex))
    ok('домашното покрива всичките осем капана',
       pokriti == kapani_v_uroka, sorted(kapani_v_uroka - pokriti))

    #  Числата в домашното са ДРУГИ — инак то проверява паметта, не
    #  разбирането.
    uslovia_v_uroka = {golo(z['mat']) for t in TABOVE for z in t['zadachi']}
    for i, v in enumerate(VUPROSI, 1):
        ok('домашно въпрос %d: не повтаря задача от урока' % i,
           golo(v['mat']) not in uslovia_v_uroka, v['mat'])

    #  ── страниците ──────────────────────────────────────────────────
    if STRANICA.exists():
        html = STRANICA.read_text(encoding='utf-8')
        ok('урокът: няма полета за въвеждане',
           '<input' not in html and '<textarea' not in html)
        ok('урокът: всички задачи са вътре',
           html.count('"reshenie": "') == broi, html.count('"reshenie": "'))
        ok('урокът: има бутон за решението', 'Покажи решението' in html)
        ok('урокът: има тикче', 'data-o=' in html)
        ok('урокът: има лента с напредъка', 'id="lenta"' in html)
        ok('урокът: има брояч за оставащите', 'остават' in html)
        ok('урокът: има списък какво остава', 'Какво остава' in html)
        ok('урокът: капаните са на екрана',
           all(t['kapan'][:30] in html for t in TABOVE))
        ok('урокът: заглавието е на място',
           '<title>Осемте капана</title>' in html)
        ok('урокът: няма своя обвивка',
           '<body' not in html and '<html' not in html)
        ok('урокът: тъмната тема е описана двата пъти',
           'prefers-color-scheme: dark' in html
           and ':root[data-theme="dark"]' in html)
        ok('урокът: полетата пазят ръба на телефона',
           html.count('max(16px, env(safe-area-inset-left, 0px))') >= 1
           and html.count('max(16px, env(safe-area-inset-right, 0px))') >= 1)
    else:
        ok('урокът е сглобен', False, STRANICA.name)

    if LIST.exists():
        html = LIST.read_text(encoding='utf-8')
        ok('листът: има десет въпроса',
           html.count('{ type:"mc"') + html.count('{ type:"free-frac"') == 10,
           html.count('{ type:"mc"') + html.count('{ type:"free-frac"'))
        ok('листът: пише се в платформата',
           "TLA.saveAttempt('hw7-kapani'" in html)
        ok('листът: иска влязъл ученик', 'TLA.requireAuth()' in html)
        ok('листът: не се индексира',
           'noindex' in html and 'nofollow' in html)
        ok('листът: заглавието говори за капаните',
           'капан' in html.lower())
        for v in VUPROSI:
            ok('листът: въпросът „%s“ е вътре' % v['mat'][:24],
               v['obyasnenie'].split('\n')[0][:30] in html)
    else:
        ok('листът е сглобен', False, LIST.name)

    print('задачи: %d · въпроси: %d · проверки: %d'
          % (broi, len(VUPROSI), len(vsichki)))
    if padnali:
        print('ПАДНАЛИ (%d):' % len(padnali))
        for x in padnali:
            print(' -', x)
        sys.exit(1)
    print('✓ всеки отговор е пресметнат наново и екранът съвпада с него')


if __name__ == '__main__':
    main()
