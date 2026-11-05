#!/usr/bin/env python3
"""Сглобява homework_4_english_to_be.html от три части.

  · scripts/english4/tobe.py             — задачите (съдържанието)
  · scripts/english4/shablon_glava.html  — главата, стиловете, разметката
  · scripts/english4/shablon_dvigatel.html — двигателят (един за всички)

Лентата горе („LightSpace · Изход“) и екранът при липсваща връзка не се
пишат втори път: вземат се точно както са в homework_4_w10.html, за да е
един и същ листът с другите домашни. Ако някой ден палитрата там се
смени, тя се сменя и тук при следващото сглобяване.

Пуска се така:
    /usr/bin/python3.13 scripts/build_english4.py
"""
import json
import pathlib
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from english4.tobe import UPRAJNENIQ, POHVALI  # noqa: E402

SLUG = 'hw4-en-tobe'
IZHOD = KOREN / 'homework_4_english_to_be.html'
OBRAZEC = KOREN / 'homework_4_w10.html'

NACHALO = '/* ДАННИ:НАЧАЛО'
KRAI = '/* ДАННИ:КРАЙ */'


def lenta_css() -> str:
    """Палитрата, лентата и екранът „няма връзка“ — от готовия лист."""
    s = OBRAZEC.read_text(encoding='utf-8')
    kraina = '.gate[hidden]{ display:none; }'
    i = s.index(':root{')
    j = s.index(kraina) + len(kraina)
    css = s[i:j]
    for ime in ('--accent-soft', '--pencil-soft', '--success-soft',
                '--error-soft', '--shadow', '--paper-raised'):
        assert ime + ':' in css, 'липсва ' + ime
    assert '.tlp-bar{' in css and '.gate{' in css
    return css


def broi_redove(u) -> int:
    return len(u['dvojki']) if u['vid'] == 'dvoiki' else len(u['redove'])


def main() -> None:
    glava = (KOREN / 'scripts/english4/shablon_glava.html').read_text(encoding='utf-8')
    dvigatel = (KOREN / 'scripts/english4/shablon_dvigatel.html').read_text(encoding='utf-8')

    assert '__BAR_CSS__' in glava, 'мястото за лентата липсва'
    glava = glava.replace('__BAR_CSS__', lenta_css(), 1)

    danni = {'slug': SLUG, 'upr': UPRAJNENIQ, 'pohvali': POHVALI}
    blok = 'const DANNI = ' + json.dumps(danni, ensure_ascii=False, indent=1) + ';'

    i = glava.index(NACHALO)
    kraj_komentar = glava.index('*/', i) + 2
    j = glava.index(KRAI, kraj_komentar)
    #  Маркерът трябва да затваря коментара си на СВОЯ ред, иначе данните
    #  влизат в коментара и страницата остава празна.
    assert '\n' not in glava[i:kraj_komentar], 'маркерът не е на един ред'
    glava = glava[:kraj_komentar] + '\n' + blok + '\n' + glava[j:]

    stranica = glava + dvigatel
    IZHOD.write_text(stranica, encoding='utf-8')

    otg = sum(broi_redove(u) for u in UPRAJNENIQ)
    print('{}  ·  упражнения: {}  ·  отговора: {}  ·  {} знака'.format(
        IZHOD.name, len(UPRAJNENIQ), otg, len(stranica)))


if __name__ == '__main__':
    main()
