#!/usr/bin/env python3
"""Четене и изписване на многочлени за урока „Матрицата“ (7. клас).

Задачите в scripts/urok7/misia.py са написани ТОЧНО както се четат на
екрана: „(7 + 3a² − 3a)(−2a + 5 − a³)“. Оттук нататък нищо не се пише
два пъти — изразът се разчита от този същия низ и се смята със sympy.
Така е невъзможно условието на екрана и сметката зад него да се
разминат: те са едно и също нещо.

    parse('(x + 3)(x + 5)')        → sympy израз
    fmt_terms(expand(...))         → ['x²', '8x', '15']
"""
import re
from sympy import Add, Mul, Pow, Integer, Rational, expand, sympify, symbols  # noqa: F401

GORNI = {'⁰': '0', '¹': '1', '²': '2', '³': '3', '⁴': '4',
         '⁵': '5', '⁶': '6', '⁷': '7', '⁸': '8', '⁹': '9'}
DOLNI = {v: k for k, v in GORNI.items()}

#  Редът на буквите в един член: ab², а не b²a. Редът на самите членове
#  се определя от главната буква — тази, по която задачата е написана.
AZBUKA = 'abcmnxy'
GLAVNI = ['x', 'm', 'y', 'a']


def parse(s: str):
    """„(7 + 3a² − 3a)(−2a + 5 − a³)“ → израз за sympy."""
    t = (s.replace('−', '-').replace('·', '*').replace('—', '-')
          .replace(' ', '').replace(' ', ''))
    t = re.sub('[' + ''.join(GORNI) + ']+',
               lambda m: '**' + ''.join(GORNI[c] for c in m.group(0)), t)
    # скритото умножение: 3a, ab, 2(, )(, )a, a(
    t = re.sub(r'(?<=[a-z0-9)])(?=[a-z(])', '*', t)
    if re.search(r'[a-z]\d', t):
        raise ValueError('буква, залепена за цифра (липсващ горен индекс): ' + s)
    return sympify(t, rational=True)


def _sup(k: int) -> str:
    return '' if k == 1 else ''.join(DOLNI[c] for c in str(k))


def _glaven(e):
    """Главната буква на израза — по нея се подреждат членовете."""
    imena = {str(v) for v in e.free_symbols}
    for g in GLAVNI:
        if g in imena:
            return g
    return sorted(imena)[0] if imena else 'x'


def _chasti(term):
    """Един член → (коефициент, {буква: показател})."""
    coef, rest = term.as_coeff_Mul()
    sila = {}
    for f in Mul.make_args(rest):
        if f.is_Symbol:
            sila[str(f)] = sila.get(str(f), 0) + 1
        elif f.is_Pow and f.base.is_Symbol and f.exp.is_Integer:
            sila[str(f.base)] = sila.get(str(f.base), 0) + int(f.exp)
        elif f.is_Number:
            coef = coef * f
        else:
            raise ValueError('не разпознавам множителя ' + str(f))
    return coef, sila


def fmt_mono(term, minus_kato_znak=True) -> str:
    """Член → „−13a³“. Коефициент 1 не се пише, 0 връща „0“."""
    coef, sila = _chasti(term)
    if coef == 0:
        return '0'
    znak = '−' if coef < 0 else ''
    ab = abs(coef)
    if ab.q != 1:
        glava = ('%d/%d' % (ab.p, ab.q))
    else:
        glava = '' if (ab == 1 and sila) else str(ab.p)
    bukvi = ''.join(k + _sup(sila[k])
                    for k in sorted(sila, key=lambda c: (AZBUKA.index(c) if c in AZBUKA else 99, c)))
    s = znak + glava + bukvi
    return s if minus_kato_znak else s.replace('−', '-')


def _kluch(term, glaven):
    coef, sila = _chasti(term)
    ostanali = [sila.get(c, 0) for c in sorted(sila) if c != glaven]
    return (-sila.get(glaven, 0), -sum(sila.values()), [-k for k in ostanali],
            sorted(sila))


def fmt_terms(e) -> list:
    """Многочлен → членовете му, подредени като в учебник."""
    e = expand(e)
    glaven = _glaven(e)
    chlenove = Add.make_args(e)
    chlenove = sorted(chlenove, key=lambda t: _kluch(t, glaven))
    return [fmt_mono(t) for t in chlenove]


def fmt_poly(e) -> str:
    """Многочлен → „x² + 8x + 15“."""
    parts = fmt_terms(e)
    out = parts[0]
    for p in parts[1:]:
        out += (' − ' + p[1:]) if p.startswith('−') else (' + ' + p)
    return out


def fmt_num(v) -> str:
    """Число → „6“, „−4“, „12/17“."""
    v = Rational(v)
    s = ('%d/%d' % (abs(v.p), v.q)) if v.q != 1 else str(abs(v.p))
    return ('−' if v < 0 else '') + s
