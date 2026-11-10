# -*- coding: utf-8 -*-
"""Дребните помощници за задачите на второ ниво в 5. клас."""


def fr(n, d):
    """Дроб, както я изписва самата страница."""
    return ('<span class="frac"><span class="num">%s</span>'
            '<span class="den">%s</span></span>' % (n, d))


def mx(w, n, d):
    """Смесено число."""
    return '<span class="mixed">%s%s</span>' % (w, fr(n, d))
