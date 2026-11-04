#!/usr/bin/env python3
"""Сглобява данните за урока „Лебедово езеро“ (формули от трета степен).

Както при „Матрицата“ и „Храмът“: условията стоят в scripts/urok7/ezero.py
така, както ще се четат, а тук се смята всичко останало — разложенията,
примамките, веригите наум, двойките за свързване и верността на
твърденията във ФУЕТЕ.

    python3 scripts/build_ezero.py          # пише данните в урока
    python3 scripts/build_ezero.py --json   # само ги показва
"""
import json
import re
import sys
from pathlib import Path

from sympy import Add, Rational, Symbol, expand, solve, symbols

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'scripts'))
from urok7.algebra import fmt_num, fmt_poly, fmt_terms, parse              # noqa: E402
from urok7.ezero import DEISTVIQ, FUETE, POSLEDNO, PROGRAMKA                  # noqa: E402
from build_urok7 import primamki, razsipi, red_glitch, zashto_proizvedenie  # noqa: E402

A, B = symbols('a b')
SMETKA = {'__builtins__': {}}


def naum_zashto(izraz, razbivane):
    """Веригата наум — и всяка стъпка се проверява числено."""
    stoinost = expand(parse(izraz))
    redove = [izraz + ' = ' + razbivane]
    kub = re.fullmatch(r'\((\d+) ([+−]) (\d+)\)³', razbivane)
    dve = re.fullmatch(r'\((.+?)\)\((.+?)\)', razbivane)
    if kub:
        p, znak, q = int(kub.group(1)), kub.group(2), int(kub.group(3))
        z = 1 if znak == '+' else -1
        redove.append('%d³ %s 3 · %d² · %d + 3 · %d · %d² %s %d³'
                      % (p, znak, p, q, p, q, znak, q))
        redove.append('%d %s %d + %d %s %d' % (p**3, znak, 3*p*p*q, 3*p*q*q, znak, q**3))
        proverka = p**3 + z*3*p*p*q + 3*p*q*q + z*q**3
    elif dve:
        a1, a2 = parse('(' + dve.group(1) + ')'), parse('(' + dve.group(2) + ')')
        redove.append('%s · %s' % (fmt_num(a1), fmt_num(a2)))
        proverka = a1 * a2
    else:
        proverka = None
    if proverka is not None and proverka != stoinost:
        sys.exit(izraz + ': стъпките наум не дават същото число')
    redove.append('= ' + fmt_num(stoinost))
    return redove


def sglobi_zadacha(z, d):
    out = {'id': z['id'], 'vid': z['vid'], 'izraz': z['izraz']}
    for k in ('ideya', 'vupros'):
        if z.get(k):
            out[k] = z[k]

    if z['vid'] == 'kub':
        m = d['kub']
        verni = {t: 0 for t, _ in m['parcheta']}
        for chlen in Add.make_args(expand(parse('(a + b)³'))):
            coef, rest = chlen.as_coeff_Mul()
            verni[str(rest).replace('*', '').replace('**', '')] = int(coef)
        ochakvani = dict(m['parcheta'])
        # сверяване по стойност, не по изписване
        for ime, broi in m['parcheta']:
            if expand(parse(ime) * broi - Add(*[c for c in Add.make_args(expand(parse('(a + b)³')))
                                                if expand(c / parse(ime)).is_Number])) != 0:
                sys.exit(z['id'] + ': парчетата „%s“ не са %d' % (ime, broi))
        out.update({'parcheta': [[t, n] for t, n in m['parcheta']],
                    'vupros': m['vupros'], 'izvod': m['izvod'],
                    'zashto': ['Осемте парчета са: едно a³, три a²b, три ab² и едно b³.',
                               m['izvod']]})
        del ochakvani, verni
        return out

    if z['vid'] == 'paskal':
        m = d['paskal']
        for i, red in enumerate(m['redove']):
            if red[0] != 1 or red[-1] != 1:
                sys.exit(z['id'] + ': редът не започва и завършва с 1')
            for j in range(1, len(red) - 1):
                if red[j] != m['redove'][i-1][j-1] + m['redove'][i-1][j]:
                    sys.exit(z['id'] + ': %d не е сбор на двете над него' % red[j])
        out.update({'redove': m['redove'], 'skriti': [list(s) for s in m['skriti']],
                    'vupros': m['vupros'], 'izvod': m['izvod'],
                    'zashto': ['Всяко число е сборът на двете над него.', m['izvod']]})
        return out

    if z['vid'] == 'dvoiki':
        m = d['dvoiki']
        for lqvo, dqsno in m['dvojki']:
            if expand(parse(lqvo)) != expand(parse(dqsno)):
                sys.exit(z['id'] + ': двойката %s ↔ %s не е вярна' % (lqvo, dqsno))
        out.update({'dvojki': [list(p) for p in m['dvojki']], 'vupros': m['vupros'],
                    'zashto': ['Всяко произведение се проверява наум: отвън скобата дава '
                               'първия и последния член, а средните се унищожават.']})
        return out

    if z['vid'] == 'izbor':
        cel = parse(z['izraz'])
        if z.get('kontrol') == 'nepulen':
            # тук отговорът не е равен на израза, а е вторият множител:
            # (a + 5)(a² − 5a + 25) = a³ + 125
            m = parse(z['mnojitel'])
            if expand(m * parse(z['verno'])) != expand(cel):
                sys.exit(z['id'] + ': отбелязаният множител не дава израза')
            for dr in z['drugi']:
                if expand(m * parse(dr)) == expand(cel):
                    sys.exit(z['id'] + ': „%s“ също върши работа' % dr)
        elif z.get('kontrol') == 'koef_x2':
            veren = expand(cel).coeff(Symbol('x'), 2)
            if str(veren) != z['verno']:
                sys.exit(z['id'] + ': коефициентът е %s, а пише %s' % (veren, z['verno']))
        else:
            if expand(parse(z['verno'])) != expand(cel):
                sys.exit(z['id'] + ': отбелязаният отговор не е верен')
            for dr in z['drugi']:
                if expand(parse(dr)) == expand(cel):
                    sys.exit(z['id'] + ': „%s“ също е верен' % dr)
        out.update({'izbori': [z['verno']] + list(z['drugi']), 'veren': z['verno'],
                    'zashto': [z['zashto']]})
        return out

    if z['vid'] == 'naum':
        e = parse(z['izraz'])
        if expand(parse(z['razbivane'])) != expand(e):
            sys.exit(z['id'] + ': разбиването не е същото число')
        st = Rational(expand(e))
        out.update({'koren': fmt_num(st), 'p': int(st.p), 'q': int(st.q), 'drob': False,
                    'promenliva': 'отговорът', 'razbivane': z['razbivane'],
                    'zashto': naum_zashto(z['izraz'], z['razbivane'])})
        return out

    if z['vid'] == 'chislo':
        if '=' in z['izraz'] and not z.get('stoinost'):
            lqvo, dqsno = z['izraz'].split('=')
            L, R = parse(lqvo), parse(dqsno)
            v = sorted(L.free_symbols, key=str)[0]
            razkrito = expand(L - R)
            koren = Rational(solve(razkrito, v)[0])
            out.update({'promenliva': str(v), 'koren': fmt_num(koren),
                        'p': int(koren.p), 'q': int(koren.q), 'drob': koren.q != 1,
                        'zashto': ['След разкриването на куба: %s = %s.'
                                   % (fmt_poly(expand(L)), fmt_poly(expand(R))),
                                   '%s = %s' % (v, fmt_num(koren))]})
        else:
            st = Rational(eval(z['stoinost'], dict(SMETKA), {}))      # noqa: S307
            out.update({'promenliva': 'отговорът', 'koren': fmt_num(st),
                        'p': int(st.p), 'q': int(st.q), 'drob': st.q != 1,
                        'smetka': z['stoinost'], 'proverka': z.get('proverka', ''),
                        'zashto': ['Пресмятане: %s = %s' % (z['stoinost'].replace('**', '^')
                                                            .replace('*', ' · '), fmt_num(st))]})
        return out

    e = parse(z['izraz'])
    parcheta = razsipi(e)
    terms = fmt_terms(expand(e))
    out.update({'otgovor': terms, 'chipove': terms + primamki(terms, parcheta),
                'sled': fmt_poly(expand(e)),
                'zashto': zashto_proizvedenie(parcheta, terms) or
                ['Нищо не се привежда — всеки член остава сам.']})
    return out


def sglobi():
    deistviq = []
    for d in DEISTVIQ:
        zadachi = [sglobi_zadacha(z, d) for z in d['zadachi']]
        deistviq.append({'kod': d['kod'], 'ime': d['ime'], 'formula': d['formula'],
                         'podnaslov': d['podnaslov'], 'briefing': d['briefing'],
                         'nujni': d['nujni'], 'zadachi': zadachi, 'znak': d['znak']})
    fuete = [{'kod': f['kod'], 'ime': f['ime'],
              'redove': [red_glitch(r) for r in f['redove']]} for f in FUETE]
    if int(POSLEDNO['otgovor']) ** 3 != 1331:
        sys.exit('последното число: кубът не дава 1331')
    return {'deistviq': deistviq, 'fuete': fuete, 'posledno': POSLEDNO,
            'programka': PROGRAMKA}


def main():
    data = sglobi()
    txt = json.dumps(data, ensure_ascii=False, indent=1)
    if '--json' in sys.argv:
        print(txt)
        return
    stranica = ROOT / 'uroci' / 'urok_7_ezero.html'
    if not stranica.exists():
        sys.exit('няма я страницата %s — първо тя, после данните' % stranica)
    html = stranica.read_text(encoding='utf-8')
    nach = html.index('\n', html.index('/* ДАННИ:НАЧАЛО')) + 1
    kraj = html.index('/* ДАННИ:КРАЙ')
    stranica.write_text(html[:nach] + 'const EZERO = ' + txt + ';\n' + html[kraj:],
                        encoding='utf-8')
    print('%s · %d действия · %d задачи · %d фуете' %
          (stranica.name, len(data['deistviq']),
           sum(len(d['zadachi']) for d in data['deistviq']),
           sum(len(f['redove']) for f in data['fuete'])))


if __name__ == '__main__':
    main()
