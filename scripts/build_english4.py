#!/usr/bin/env python3
"""Сглобява homework_4_english_to_be.html — „Cat Family Album“.

Задачите стоят в scripts/english4/tobe.py, общият шаблон и двигателят —
в scripts/english/. Проверява се от scripts/check_english4.py.

Пуска се така:
    /usr/bin/python3.13 scripts/build_english4.py
"""
import pathlib
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from english.build import sglobi, za_ocenka          # noqa: E402
from english4.tobe import UPRAJNENIQ, POHVALI        # noqa: E402

SLUG = 'hw4-en-tobe'
IZHOD = KOREN / 'homework_4_english_to_be.html'

LIST = {
    'slug': SLUG,
    'title': 'Домашно — To be: am, is, are — 4. клас',
    'opisanie': 'Домашно по английски за 4. клас: глаголът to be — am, is, are. '
                'Десет упражнения със семейството котета: избор, попълване, кратки '
                'форми, отрицание, въпроси, кратки отговори, хващане на грешка, '
                'свързване и подреждане.',
    'lenta': 'Домашно · английски · 4. клас',
    'nadpis': 'Домашно · английски · 4. клас',
    'h1': 'Cat Family Album<br /><em>to be</em> — am · is · are',
    'podnaslov': 'Семейството котета се представя: Milo, Daisy, Luna и\n'
                 '      близнаците Tom и Tim. За да им помогнеш, трябва ти само един глагол —\n'
                 '      <b>to be</b>. Десет упражнения: щракаш, пишеш, свързваш и подреждаш.',
    'shapka': 'kotki',
    'upr': UPRAJNENIQ,
    'pohvali': POHVALI,
}


def main() -> None:
    znaka = sglobi(LIST, IZHOD)
    otg = sum(za_ocenka(u) for u in UPRAJNENIQ)
    print('{}  ·  упражнения: {}  ·  отговора: {}  ·  {} знака'.format(
        IZHOD.name, len(UPRAJNENIQ), otg, znaka))


if __name__ == '__main__':
    main()
