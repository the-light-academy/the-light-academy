#!/usr/bin/env python3
"""Четене на условията от урока за 6. клас.

Условието на екрана и сметката зад него са един и същ низ: тук той се
превръща в израз за sympy. Затова е невъзможно да се разминат.

    stoinost('2³ · 2⁵')        → 256
    izraz('(2a)³')              → 8*a**3
    koreni('5x + 3 = 2x + 15')  → [4]
"""
import re

from sympy import Eq, Rational, expand, nsimplify, solve, symbols, sympify

GORNI = {'⁰': '0', '¹': '1', '²': '2', '³': '3', '⁴': '4',
         '⁵': '5', '⁶': '6', '⁷': '7', '⁸': '8', '⁹': '9'}
DOLNI = {v: k for k, v in GORNI.items()}
BUKVI = 'abmnxy'


def parse(s: str):
    """Низът от екрана → израз за sympy.

    Разбира: горни индекси (2³, 2ˣ и 2ⁿ), знака · за умножение, : за деление,
    десетичната запетая (0,5), интервалите в големите числа (3 500 000),
    минуса − и скритото умножение (3a, 2(x+1)).
    """
    t = s.replace('−', '-').replace('—', '-').replace('·', '*')
    t = t.replace(' ', ' ')
    #  Интервал между цифри = разделител на хилядите, а не нещо друго.
    while re.search(r'\d \d', t):
        t = re.sub(r'(\d) (\d)', r'\1\2', t)
    #  Десетична запетая: 0,5 → 0.5
    t = re.sub(r'(\d),(\d)', r'\1.\2', t)
    t = t.replace(' ', '')
    #  Деление с двоеточие е същото като с наклонена черта, но е по-слабо
    #  от скритото умножение, затова се пази редът отляво надясно.
    t = t.replace(':', '/')
    #  Горни индекси, включително буквените показатели 2ˣ и 2ⁿ.
    t = t.replace('ˣ', '**x').replace('ⁿ', '**n')
    t = re.sub('[' + ''.join(GORNI) + ']+',
               lambda m: '**' + ''.join(GORNI[c] for c in m.group(0)), t)
    #  Скрито умножение: 3a, ab, 2(, )(, )a, a(
    t = re.sub(r'(?<=[a-z0-9)])(?=[a-z(])', '*', t)
    #  Предпазва 2**x и 2**n от разпадане при скритото умножение.
    t = t.replace('*x*x', '*x**x').replace('*n*n', '*n**n')
    if re.search(r'[a-z]\d', t):
        raise ValueError('буква, залепена за цифра: ' + s)
    return sympify(t, rational=True)


def stoinost(s: str):
    """Числената стойност на израз без букви."""
    e = parse(s)
    if e.free_symbols:
        raise ValueError('изразът има букви: ' + s)
    return nsimplify(e, rational=True)


def izraz(s: str):
    """Буквен израз, разкрит и подреден."""
    return expand(parse(s))


def koreni(s: str, bukva: str = 'x'):
    """Корените на уравнение, записано като „лява = дясна“.

    Връща списък; празен списък значи, че уравнението няма решение, а
    None — че е вярно за всяко число (тъждество).
    """
    assert s.count('=') == 1, 'уравнението няма точно едно равенство: ' + s
    lqva, dqsna = s.split('=')
    raz = expand(parse(lqva) - parse(dqsna))
    x = symbols(bukva)
    if raz == 0:
        return None                       # тъждество
    if x not in raz.free_symbols:
        return []                         # противоречие
    return solve(Eq(raz, 0), x)


def kato_tekst(e) -> str:
    """Числото, изписано както се чете: 1/8, −5, 0,001, 1296."""
    r = Rational(e)
    if r.q == 1:
        return str(r.p).replace('-', '−')
    desetichno = r.p / r.q
    if abs(desetichno) < 1 and len(str(r.q)) <= 5 and r.q in (2, 4, 5, 8, 10, 100, 1000):
        return ('%g' % desetichno).replace('.', ',').replace('-', '−')
    return '{}/{}'.format(r.p, r.q).replace('-', '−')
