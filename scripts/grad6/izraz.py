# -*- coding: utf-8 -*-
"""Машинният израз → това, което детето вижда на екрана.

Условието се пише веднъж, на машинен език ('2^3 * 2^4'). Оттук излиза
HTML-ът: горните индекси са истински <sup>, а дробите се изчертават на
два реда. Проверката чете ПАК този HTML и го връща в математика по свой
път — така сглобяването не може да покаже едно, а сметката да е друго.
"""
import re

TOKEN = re.compile(r'\s*(\d+\.?\d*|[A-Za-z]+|\*\*|[-+*/^()=])')


def tokeni(s):
    out, i = [], 0
    while i < len(s):
        m = TOKEN.match(s, i)
        if not m:
            raise ValueError('непознат знак в „%s“ на място %d' % (s, i))
        out.append(m.group(1))
        i = m.end()
    return out


class Chet:
    """Разчита израза отляво надясно и го превръща в дърво."""

    def __init__(self, s):
        self.t = tokeni(s)
        self.i = 0

    def vzemi(self):
        return self.t[self.i] if self.i < len(self.t) else None

    def iskam(self, z):
        if self.vzemi() != z:
            raise ValueError('очаквах „%s“, намерих „%s“' % (z, self.vzemi()))
        self.i += 1

    def ravenstvo(self):
        l = self.izraz()
        if self.vzemi() == '=':
            self.i += 1
            return ('=', l, self.izraz())
        return l

    def izraz(self):
        v = self.chlen()
        while self.vzemi() in ('+', '-'):
            z = self.vzemi()
            self.i += 1
            v = (z, v, self.chlen())
        return v

    def chlen(self):
        v = self.mnojitel()
        while self.vzemi() in ('*', '/'):
            z = self.vzemi()
            self.i += 1
            v = (z, v, self.mnojitel())
        return v

    def mnojitel(self):
        v = self.edinichen()
        if self.vzemi() in ('^', '**'):
            self.i += 1
            return ('^', v, self.mnojitel())
        return v

    def edinichen(self):
        if self.vzemi() == '-':
            self.i += 1
            return ('neg', self.edinichen())
        return self.osnova()

    def osnova(self):
        z = self.vzemi()
        if z == '(':
            self.i += 1
            v = self.ravenstvo()
            self.iskam(')')
            return ('()', v)
        if z is None:
            raise ValueError('изразът свършва неочаквано')
        self.i += 1
        if re.fullmatch(r'\d+\.?\d*', z):
            return ('num', z)
        if re.fullmatch(r'[A-Za-z]+', z):
            return ('var', z)
        raise ValueError('не очаквах „%s“' % z)


def razchet(s):
    c = Chet(s)
    v = c.ravenstvo()
    if c.vzemi() is not None:
        raise ValueError('останаха знаци в „%s“: %s' % (s, c.t[c.i:]))
    return v


def _chislo(v):
    return v[0] == 'num'


def _ime(v):
    return v[0] == 'var'


def html(v, drobi=True):
    """Дървото → HTML. drobi=False изписва делението с двоеточие."""
    z = v[0]
    if z == 'num':
        return v[1]
    if z == 'var':
        return '<i>%s</i>' % v[1]
    if z == '()':
        return '(' + html(v[1], drobi) + ')'
    if z == 'neg':
        return '−' + html(v[1], drobi)
    if z == '^':
        return html(v[1], drobi) + '<sup>' + html(v[2], drobi) + '</sup>'
    if z == '=':
        return html(v[1], drobi) + ' = ' + html(v[2], drobi)
    if z in ('+', '-'):
        return (html(v[1], drobi) + (' + ' if z == '+' else ' − ')
                + html(v[2], drobi))
    if z == '*':
        #  Число пред буква или пред скоба се пише слято: 2x, 2(x − 1).
        slqto = _chislo(v[1]) and v[2][0] in ('var', '()')
        return html(v[1], drobi) + ('' if slqto else ' · ') + html(v[2], drobi)
    if z == '/':
        if not drobi:
            return html(v[1], drobi) + ' : ' + html(v[2], drobi)
        #  Чертата на дробта сама групира — скобите отгоре са излишни.
        gore = v[1][1] if v[1][0] == '()' else v[1]
        dolu = v[2][1] if v[2][0] == '()' else v[2]
        return ('<span class="frac"><span class="chis">%s</span>'
                '<span class="znam">%s</span></span>'
                % (html(gore, drobi), html(dolu, drobi)))
    raise ValueError('непознат възел: ' + z)


def izobrazi(mat, drobi=True):
    return html(razchet(mat), drobi)
