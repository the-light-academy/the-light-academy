#!/usr/bin/env python3
"""Сглобява данните за урока „Изход от Матрицата“ (7. клас).

Условията стоят в scripts/urok7/misia.py така, както се четат. Оттук
нататък всичко се смята:

  · отговорът на всяка задача — чрез разкриване на скобите със sympy;
  · решетката — всяко квадратче е произведение на член от левия и член
    от десния многочлен;
  · примамките — не са измислени, а са истинските грешки: членовете
    ПРЕДИ привеждането (този, който забрави да събере подобните, ги
    вижда точно така), а където няма такива — същият член с обърнат знак;
  · обяснението „защо“ — изписва кои членове се събират в кой;
  · вярно/грешно в ГЛИТЧ — проверява се, не се твърди.

    python3 scripts/build_urok7.py          # пише данните в урока
    python3 scripts/build_urok7.py --json   # само ги показва

Готовите данни влизат в uroci/urok_7_matrica.html между двата реда
„ДАННИ:НАЧАЛО“ и „ДАННИ:КРАЙ“. Самата страница се пише на ръка.
"""
import json
import random
import re
import sys
from pathlib import Path

from sympy import Add, Mul, Pow, Rational, S, Symbol, expand, simplify, solve, symbols

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'scripts'))
from urok7.algebra import fmt_mono, fmt_num, fmt_poly, fmt_terms, parse  # noqa: E402
from urok7.misia import GLITCH, MENU, SEKTORI, VRATI                     # noqa: E402

A, B = symbols('a b')
X, Y = symbols('x y')
ZAMIANA = {X: A + B, Y: A - B}


# ── разсипване: всички произведения ПРЕДИ привеждането ────────────────
def razsipi(e):
    """Израз → членовете, както излизат от скобите, без да се събират."""
    e = S(e)
    if e.is_Add:
        out = []
        for t in e.args:
            out += razsipi(t)
        return out
    if e.is_Mul:
        parts = [razsipi(f) for f in e.args]
        out = [S.One]
        for p in parts:
            out = [u * v for u in out for v in p]
        return out
    if e.is_Pow and e.base.is_Add and e.exp.is_Integer and e.exp > 0:
        out = razsipi(e.base)
        for _ in range(int(e.exp) - 1):
            out = [u * v for u in out for v in razsipi(e.base)]
        return out
    return [e]


def bukvena(t):
    """Буквената част на член: 3a²b → a²b (за групиране на подобните)."""
    _, rest = t.as_coeff_Mul()
    return rest


def grupi(parcheta):
    """Разсипаните членове → групи подобни, в реда на първа поява."""
    red, hash_ = [], {}
    for p in parcheta:
        k = bukvena(p)
        if k not in hash_:
            hash_[k] = []
            red.append(k)
        hash_[k].append(p)
    return [(k, hash_[k]) for k in red]


def zashto_proizvedenie(parcheta, otgovor_terms):
    """Обяснението: кои членове в кой се събират и кои изчезват."""
    redove = []
    for _, chlenove in grupi(parcheta):
        if len(chlenove) == 1:
            continue
        sbor = expand(Add(*chlenove))
        levi = ' '.join(
            (fmt_mono(c) if i == 0 else ('− ' + fmt_mono(c)[1:] if fmt_mono(c).startswith('−')
                                         else '+ ' + fmt_mono(c)))
            for i, c in enumerate(chlenove))
        redove.append('%s = %s' % (levi, fmt_mono(sbor) if sbor != 0 else '0'))
    return redove


# ── примамки ──────────────────────────────────────────────────────────
def primamki(verni_terms, parcheta, broi=4):
    """Членове, които изглеждат като отговор, но не са.

    Първо истинските: частите преди привеждането. Ако не стигат — същите
    членове с обърнат знак. Нито една примамка не е равна на верен член.
    """
    verni = set(verni_terms)
    out = []

    def pusni(expr):
        if expr == 0:
            return
        s = fmt_mono(expr)
        if s not in verni and s not in out:
            out.append(s)

    for p in parcheta:
        if len(out) >= broi:
            break
        pusni(p)
    for t in verni_terms:
        if len(out) >= broi:
            break
        pusni(-parse(t))
    return out[:broi]


def kletka_primamki(r, k):
    """Двете грешни квадратчета до вярното: обърнат знак и сбъркан показател."""
    veren = expand(r * k)
    s_ver = fmt_mono(veren)
    kand = []

    def dobavi(e):
        if e == 0:
            return
        s = fmt_mono(e)
        if s != s_ver and s not in kand:
            kand.append(s)

    dobavi(-veren)                                   # сгрешен знак
    # показателите умножени вместо събрани: a²·a³ → a⁶
    cr, sr = r.as_coeff_Mul(), None
    try:
        mnoj = S.One
        razlichen = False
        for v in sorted(set(list(r.free_symbols) + list(k.free_symbols)), key=str):
            er, ek = r.as_poly(v).degree() if r.has(v) else 0, k.as_poly(v).degree() if k.has(v) else 0
            nova = er * ek if (er and ek) else er + ek
            if nova != er + ek:
                razlichen = True
            mnoj *= v ** nova
        if razlichen:
            dobavi(cr[0] * k.as_coeff_Mul()[0] * mnoj)
    except Exception:                                 # noqa: BLE001
        pass
    # коефициентите събрани вместо умножени: 3a²·(−2a) → a³
    ca, cb = r.as_coeff_Mul()[0], k.as_coeff_Mul()[0]
    if ca + cb != ca * cb:
        dobavi((ca + cb) * bukvena(expand(r * k)))
    # последна резерва: показателят с единица по-голям
    for v in sorted(veren.free_symbols, key=str):
        dobavi(veren * v)
    rnd = random.Random(s_ver + str(len(kand)))
    rnd.shuffle(kand)
    return kand[:2]


# ── задачите ──────────────────────────────────────────────────────────
def skobi(izraz):
    """„(7 + 3a² − 3a)(−2a + 5 − a³)“ → членовете на двете скоби, В РЕДА,
    в който са написани. Решетката трябва да изглежда като задачата на
    листа, иначе окото не ги свързва."""
    m = re.fullmatch(r'\((.+?)\)\((.+?)\)', izraz.strip())
    if not m:
        return None
    def chlenove(vutre):
        parcheta, buf, dulbochina = [], '', 0
        for ch in vutre:
            if ch == '(':
                dulbochina += 1
            elif ch == ')':
                dulbochina -= 1
            if dulbochina == 0 and ch in '+−' and buf.strip():
                parcheta.append(buf.strip())
                buf = '' if ch == '+' else '−'
                continue
            buf += ch
        parcheta.append(buf.strip())
        return [parse(t) for t in parcheta]
    return chlenove(m.group(1)), chlenove(m.group(2))


def sglobi_zadacha(z, sektor):
    izraz = z['izraz']
    vid = z['vid']
    d = {'id': z['id'], 'vid': vid, 'izraz': izraz}
    if z.get('knige'):
        d['knige'] = z['knige']
    if z.get('ideya'):
        d['ideya'] = z['ideya']

    if vid == 'chislo':
        lqvo, dqsno = izraz.split('=')
        L, R = parse(lqvo), parse(dqsno)
        pr = sorted(L.free_symbols, key=str)
        if len(pr) != 1:
            sys.exit(z['id'] + ': уравнението трябва да е с една буква')
        v = pr[0]
        razkrito = expand(L)
        if razkrito.as_poly(v).degree() != 1:
            sys.exit(z['id'] + ': след скобите не остава линейно уравнение')
        koren = solve(razkrito - R, v)
        if len(koren) != 1:
            sys.exit(z['id'] + ': очаквам точно един корен')
        koren = Rational(koren[0])
        svoboden = razkrito.subs(v, 0)
        k = razkrito.coeff(v, 1)
        d['promenliva'] = str(v)
        d['koren'] = fmt_num(koren)
        d['p'] = int(koren.p)          # числител и знаменател: страницата
        d['q'] = int(koren.q)          # сравнява точно, не на око
        d['drob'] = koren.q != 1
        d['zashto'] = [
            'След скобите x² се унищожава: %s = %s.' % (fmt_poly(razkrito), fmt_num(R)),
            '%s%s = %s' % (fmt_num(k) if k != 1 else '', v, fmt_num(R - svoboden)),
            '%s = %s' % (v, fmt_num(koren)),
        ]
        return d

    e = parse(izraz)
    if vid == 'zamiana':
        parcheta = [expand(p.subs(ZAMIANA)) for p in razsipi(e)]
        parcheta = [q for p in parcheta for q in razsipi(p)]
        otg = expand(e.subs(ZAMIANA))
        d['pokazhi'] = '%s,  при x = a + b и y = a − b' % izraz
        d['zamiana'] = (izraz.replace('x', '(a + b)').replace('y', '(a − b)'))
        if expand(parse(d['zamiana'])) != otg:
            sys.exit(z['id'] + ': написаната замяна не дава същото')
    else:
        parcheta = razsipi(e)
        otg = expand(e)

    terms = fmt_terms(otg)
    d['otgovor'] = terms
    d['chipove'] = terms + primamki(terms, parcheta)
    d['zashto'] = ([d['zamiana']] if vid == 'zamiana' else []) + \
        (zashto_proizvedenie(parcheta, terms) or
         ['Нищо не се привежда — всеки член остава сам.'])
    d['sled'] = fmt_poly(otg)

    if vid == 'mreja':
        mn = skobi(izraz)
        if not mn:
            sys.exit(z['id'] + ': решетка става само при точно две скоби')
        levi, desni = mn
        if expand(Add(*levi) * Add(*desni)) != expand(e):
            sys.exit(z['id'] + ': разчетените скоби не дават същия израз')
        d['mreja'] = {
            'redove': [fmt_mono(t) for t in levi],
            'koloni': [fmt_mono(t) for t in desni],
            'kletki': [[{'t': fmt_mono(expand(r * k)), 'p': kletka_primamki(r, k)}
                        for k in desni] for r in levi],
        }
    return d


def fragment(sektor, zadachi):
    f = dict(sektor['fragment'])
    z = next(q for q in zadachi if q['id'] == f['na'])
    k = f['kontrol']
    if k == 'broi':
        cifra = len(z['otgovor'])
    elif k == 'koef':
        e = parse(z['izraz'])
        cifra = abs(int(expand(e).coeff(Symbol(f['koef']), 1)))
    elif k == 'stepen':
        e = expand(parse(z['izraz']))
        cifra = max(int(t.as_poly(A).degree()) for t in Add.make_args(e))
    elif k == 'koren':
        cifra = abs(int(Rational(z['koren'].replace('−', '-'))))
    else:
        sys.exit('непознат фрагмент: ' + k)
    if not (0 <= cifra <= 9):
        sys.exit('фрагментът не е една цифра: %s → %s' % (sektor['kod'], cifra))
    return {'vupros': f['vupros'], 'cifra': str(cifra)}


def red_glitch(red):
    lqvo, dqsno = red.split('=')
    L, R = parse(lqvo), parse(dqsno)
    vqrno = simplify(expand(L) - expand(R)) == 0
    return {'red': red, 'vqrno': vqrno,
            'zashto': ('Вярно.' if vqrno else
                       'Грешно — вярното е %s.' % fmt_poly(expand(L)))}


def sglobi():
    sektori = []
    for s in SEKTORI:
        zadachi = [sglobi_zadacha(z, s) for z in s['zadachi']]
        sektori.append({
            'kod': s['kod'], 'ime': s['ime'], 'podnaslov': s['podnaslov'],
            'briefing': s['briefing'], 'nujni': s['nujni'],
            'zadachi': zadachi, 'fragment': fragment(s, zadachi),
        })
    glitch = [{'kod': g['kod'], 'ime': g['ime'],
               'redove': [red_glitch(r) for r in g['redove']]} for g in GLITCH]
    vrati = []
    for v in VRATI:
        rg = red_glitch(v['red'])
        vrati.append({'etiket': v['etiket'], 'red': v['red'], 'vqrno': rg['vqrno'],
                      'zashto': rg['zashto']})
    if sum(1 for v in vrati if v['vqrno']) != 1:
        sys.exit('вратите: вярна трябва да е точно една')
    return {'sektori': sektori, 'glitch': glitch, 'vrati': vrati, 'menu': MENU,
            'kod': ''.join(s['fragment']['cifra'] for s in sektori)}


def main():
    data = sglobi()
    txt = json.dumps(data, ensure_ascii=False, indent=1)
    if '--json' in sys.argv:
        print(txt)
        return
    stranica = ROOT / 'uroci' / 'urok_7_matrica.html'
    if not stranica.exists():
        sys.exit('няма я страницата %s — първо тя, после данните' % stranica)
    html = stranica.read_text(encoding='utf-8')
    nach = html.index('/* ДАННИ:НАЧАЛО')
    nach = html.index('\n', nach) + 1
    kraj = html.index('/* ДАННИ:КРАЙ')
    html = html[:nach] + 'const MISIA = ' + txt + ';\n' + html[kraj:]
    stranica.write_text(html, encoding='utf-8')
    br = sum(len(s['zadachi']) for s in data['sektori'])
    print('%s · %d сектора · %d задачи · %d реда в ГЛИТЧ · код %s' %
          (stranica.name, len(data['sektori']), br,
           sum(len(g['redove']) for g in data['glitch']), data['kod']))


if __name__ == '__main__':
    main()
