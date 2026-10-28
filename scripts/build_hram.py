#!/usr/bin/env python3
"""Сглобява данните за урока „Храмът на трите печата“ (7. клас).

Същият ред като при „Матрицата“: условията стоят в scripts/urok7/hram.py
така, както се четат на екрана, а тук се смята всичко останало —
отговори, примамки, картините с парчетата, обясненията и верността на
твърденията при СТРАЖИТЕ. Нищо не се пише два пъти, затова показаното и
сметнатото не могат да се разминат.

    python3 scripts/build_hram.py          # пише данните в урока
    python3 scripts/build_hram.py --json   # само ги показва
"""
import json
import re
import sys
from pathlib import Path

from sympy import Add, Mul, Pow, Rational, S, Symbol, expand, simplify, solve, symbols

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'scripts'))
from urok7.algebra import fmt_mono, fmt_num, fmt_poly, fmt_terms, parse   # noqa: E402
from urok7.hram import PECHATI, PIR, STRAJI, ZALI                         # noqa: E402
from build_urok7 import primamki, razsipi, red_glitch, zashto_proizvedenie  # noqa: E402

A, B = symbols('a b')


def naum_zashto(izraz, razbivane):
    """Веригата наум: 101² = (100 + 1)² = 100² + 2 · 100 · 1 + 1² = 10201.

    Разбиването се разчита от самия низ, а не от sympy: sympy пресмята
    (100 + 1)² още при четенето и структурата се губи. Всяка стъпка
    после се проверява числено — редът, който се показва на ученика, е
    истински, а не разказан.
    """
    stoinost = expand(parse(izraz))
    redove = [izraz + ' = ' + razbivane]
    kv = re.fullmatch(r'\((\d+) ([+−]) (\d+)\)²', razbivane)
    og = re.fullmatch(r'\((\d+) \+ (\d+)\)\((\d+) − (\d+)\)', razbivane)
    if kv:
        p, znak, q = int(kv.group(1)), kv.group(2), int(kv.group(3))
        redove.append('%d² %s 2 · %d · %d + %d²' % (p, znak, p, q, q))
        redove.append('%d %s %d + %d' % (p * p, znak, 2 * p * q, q * q))
        proverka = p * p + (2 * p * q if znak == '+' else -2 * p * q) + q * q
    elif og and og.group(1) == og.group(3) and og.group(2) == og.group(4):
        p, q = int(og.group(1)), int(og.group(2))
        redove.append('%d² − %d²' % (p, q))
        redove.append('%d − %d' % (p * p, q * q))
        proverka = p * p - q * q
    else:
        proverka = None
    if proverka is not None and proverka != stoinost:
        sys.exit(izraz + ': стъпките наум не дават същото число')
    redove.append('= ' + (fmt_num(stoinost) if stoinost.is_Number else fmt_poly(stoinost)))
    return redove


def sglobi_zadacha(z):
    d = {'id': z['id'], 'vid': z['vid'], 'izraz': z['izraz']}
    for k in ('ideya', 'vupros'):
        if z.get(k):
            d[k] = z[k]

    if z['vid'] == 'izbor':
        verno, drugi = z['verno'], list(z['drugi'])
        cel = parse(z['izraz'])
        if z.get('kontrol') == 'ne_e_kvadrat':
            x = sorted(cel.free_symbols, key=str)[0]
            p = cel.as_poly(x)
            a2, a1, a0 = p.coeff_monomial(x**2), p.coeff_monomial(x), p.coeff_monomial(1)
            if a1**2 - 4*a2*a0 == 0:
                sys.exit(z['id'] + ': това всъщност Е пълен квадрат')
            d['zashto_dop'] = 'Проверка: b² − 4ac = %s ≠ 0, значи не е пълен квадрат.' % \
                fmt_num(a1**2 - 4*a2*a0)
        else:
            if expand(parse(verno)) != expand(cel):
                sys.exit(z['id'] + ': отбелязаният отговор не е верен')
        for dr in drugi:
            if expand(parse(dr)) == expand(cel):
                sys.exit(z['id'] + ': „%s“ също е верен' % dr)
        d['kontrol'] = z.get('kontrol', 'ravenstvo')
        d['izbori'] = [verno] + drugi
        d['veren'] = verno
        d['zashto'] = [z['zashto']] + ([d.pop('zashto_dop')] if 'zashto_dop' in d else [])
        return d

    if z['vid'] == 'chislo':
        lqvo, dqsno = z['izraz'].split('=')
        L, R = parse(lqvo), parse(dqsno)
        v = sorted(L.free_symbols, key=str)[0]
        razkrito = expand(L)
        if razkrito.as_poly(v).degree() != 1:
            sys.exit(z['id'] + ': след формулите не остава линейно уравнение')
        koren = Rational(solve(razkrito - R, v)[0])
        d.update({'promenliva': str(v), 'koren': fmt_num(koren),
                  'p': int(koren.p), 'q': int(koren.q), 'drob': koren.q != 1,
                  'zashto': ['Формулите изяждат квадратите: %s = %s.'
                             % (fmt_poly(razkrito), fmt_num(R)),
                             '%s = %s' % (v, fmt_num(koren))]})
        return d

    if z['vid'] == 'naum':
        e = parse(z['izraz'])
        if expand(parse(z['razbivane'])) != expand(e):
            sys.exit(z['id'] + ': разбиването не е същото число')
        stoinost = expand(e)
        if not stoinost.is_Number:
            sys.exit(z['id'] + ': наум се смята само когато остава число')
        d.update({'koren': fmt_num(stoinost), 'p': int(Rational(stoinost).p),
                  'q': int(Rational(stoinost).q), 'drob': False,
                  'promenliva': 'отговорът',
                  'razbivane': z['razbivane'],
                  'zashto': naum_zashto(z['izraz'], z['razbivane'])})
        return d

    # chipove и mozaika
    e = parse(z['izraz'])
    parcheta = razsipi(e)
    terms = fmt_terms(expand(e))
    d['otgovor'] = terms
    d['chipove'] = terms + primamki(terms, parcheta)
    d['sled'] = fmt_poly(expand(e))
    d['zashto'] = zashto_proizvedenie(parcheta, terms) or \
        ['Нищо не се привежда — всеки член остава сам.']
    return d


def pechat(zala, zadachi):
    f = dict(zala['pechat'])
    z = next(q for q in zadachi if q['id'] == f['na'])
    k = f['kontrol']
    if k == 'koef':
        cifra = abs(int(expand(parse(z['izraz'])).coeff(Symbol(f['bukva']), 1)))
    elif k == 'svoboden':
        izraz = expand(parse(z['izraz']))
        cifra = abs(int(izraz.subs({s: 0 for s in izraz.free_symbols})))
    elif k == 'stepen':
        izraz = expand(parse(z['izraz']))
        cifra = max(int(sum(t.as_poly(s).degree() for s in izraz.free_symbols))
                    for t in Add.make_args(izraz))
    elif k == 'stoinost':
        cifra = abs(int(Rational(z['koren'].replace('−', '-'))))
    else:
        sys.exit('непознат печат: ' + k)
    if not (0 <= cifra <= 9):
        sys.exit('печатът не е една цифра: %s → %s' % (zala['kod'], cifra))
    return {'vupros': f['vupros'], 'cifra': str(cifra), 'na': f['na'], 'kontrol': k}


def sglobi():
    zali = []
    for z in ZALI:
        zadachi = [sglobi_zadacha(q) for q in z['zadachi']]
        mz = None
        if z.get('mozaika'):
            m = dict(z['mozaika'])
            cqlo = parse(z['zadachi'][0]['izraz'])
            sbor = Add(*[parse(s) for s in m['slotove']])
            if m.get('nachalo'):
                sbor += parse(m['nachalo'])
            if expand(sbor) != expand(cqlo):
                sys.exit(z['kod'] + ': парчетата не дават формулата')
            for p in m['primamki']:
                if any(expand(parse(p) - parse(s)) == 0 for s in m['slotove']):
                    sys.exit(z['kod'] + ': примамка, равна на парче — ' + p)
            mz = m
        zali.append({'kod': z['kod'], 'ime': z['ime'], 'formula': z['formula'],
                     'podnaslov': z['podnaslov'], 'briefing': z['briefing'],
                     'nujni': z['nujni'], 'zadachi': zadachi, 'mozaika': mz,
                     'pechat': pechat(z, zadachi)})
    straji = [{'kod': g['kod'], 'ime': g['ime'],
               'redove': [red_glitch(r) for r in g['redove']]} for g in STRAJI]
    pechati = []
    for p in PECHATI:
        rg = red_glitch(p['red'])
        pechati.append({'etiket': p['etiket'], 'red': p['red'],
                        'vqrno': rg['vqrno'], 'zashto': rg['zashto']})
    if sum(1 for p in pechati if p['vqrno']) != 1:
        sys.exit('печатите: верен трябва да е точно един')
    return {'zali': zali, 'straji': straji, 'pechati': pechati, 'pir': PIR,
            'kod': ''.join(z['pechat']['cifra'] for z in zali)}


def main():
    data = sglobi()
    txt = json.dumps(data, ensure_ascii=False, indent=1)
    if '--json' in sys.argv:
        print(txt)
        return
    stranica = ROOT / 'uroci' / 'urok_7_hram.html'
    if not stranica.exists():
        sys.exit('няма я страницата %s — първо тя, после данните' % stranica)
    html = stranica.read_text(encoding='utf-8')
    nach = html.index('\n', html.index('/* ДАННИ:НАЧАЛО')) + 1
    kraj = html.index('/* ДАННИ:КРАЙ')
    stranica.write_text(html[:nach] + 'const HRAM = ' + txt + ';\n' + html[kraj:],
                        encoding='utf-8')
    print('%s · %d зали · %d задачи · %d стража · код %s' %
          (stranica.name, len(data['zali']),
           sum(len(z['zadachi']) for z in data['zali']),
           sum(len(s['redove']) for s in data['straji']), data['kod']))


if __name__ == '__main__':
    main()
