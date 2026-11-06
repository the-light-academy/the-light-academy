#!/usr/bin/env python3
"""Общото сглобяване на листовете по английски.

Три части стават една страница:
  · scripts/english/shablon_glava.html     — глава, стилове, разметка
  · scripts/english/shablon_dvigatel.html  — двигателят, един за всички
  · данните на конкретния лист              — заглавие и упражнения

Лентата горе („LightSpace · Изход“) и екранът при липсваща връзка не се
пишат втори път: вземат се точно както са в homework_4_w10.html, за да
е един и същ листът с другите домашни.
"""
import json
import pathlib
import re

KOREN = pathlib.Path(__file__).resolve().parent.parent.parent
OBRAZEC = KOREN / 'homework_4_w10.html'
NACHALO = '/* ДАННИ:НАЧАЛО'
KRAI = '/* ДАННИ:КРАЙ */'


def lenta_css() -> str:
    """Палитрата, лентата и екранът „няма връзка“ — от готовия лист."""
    s = OBRAZEC.read_text(encoding='utf-8')
    kraina = '.gate[hidden]{ display:none; }'
    css = s[s.index(':root{'): s.index(kraina) + len(kraina)]
    for ime in ('--accent-soft', '--pencil-soft', '--success-soft',
                '--error-soft', '--shadow', '--paper-raised'):
        assert ime + ':' in css, 'липсва ' + ime
    assert '.tlp-bar{' in css and '.gate{' in css
    return css


def broi_redove(u) -> int:
    """Колко отговора има едно упражнение."""
    if u['vid'] == 'dvoiki':
        return len(u['dvojki'])
    if u['vid'] == 'razkaz':
        return len(u['dupki'])
    return len(u['redove'])


def za_ocenka(u) -> int:
    """От тях колко се оценяват автоматично."""
    return 0 if u['vid'] == 'svoboden' else broi_redove(u)


def sglobi(list_, pat: pathlib.Path) -> int:
    """Сглобява един лист и го записва. Връща броя знаци."""
    tuk = pathlib.Path(__file__).resolve().parent
    glava = (tuk / 'shablon_glava.html').read_text(encoding='utf-8')
    dvigatel = (tuk / 'shablon_dvigatel.html').read_text(encoding='utf-8')

    zameni = {
        '__BAR_CSS__': lenta_css(),
        '__TITLE__': list_['title'],
        '__OPISANIE__': list_['opisanie'],
        '__LENTA__': list_['lenta'],
        '__NADPIS__': list_['nadpis'],
        '__H1__': list_['h1'],
        '__PODNASLOV__': list_['podnaslov'],
    }
    for kade, kakvo in zameni.items():
        assert kade in glava, 'мястото ' + kade + ' липсва от шаблона'
        glava = glava.replace(kade, kakvo, 1)
    #  Класовете по BEM също съдържат две долни черти (.ex__top), затова
    #  се търсят само местата от шаблона: ГЛАВНИ БУКВИ между две черти.
    ostanali = re.findall(r'__[A-Z][A-Z_]*__', glava)
    assert not ostanali, 'останали незаменени места: ' + ', '.join(sorted(set(ostanali)))

    danni = {
        'slug': list_['slug'],
        'shapka': list_.get('shapka', ''),
        'upr': list_['upr'],
        'pohvali': list_['pohvali'],
    }
    if list_.get('titli'):
        danni['titli'] = list_['titli']
    blok = 'const DANNI = ' + json.dumps(danni, ensure_ascii=False, indent=1) + ';'

    i = glava.index(NACHALO)
    kraj_komentar = glava.index('*/', i) + 2
    j = glava.index(KRAI, kraj_komentar)
    #  Маркерът трябва да затваря коментара си на СВОЯ ред, иначе данните
    #  влизат в коментара и страницата остава празна.
    assert '\n' not in glava[i:kraj_komentar], 'маркерът не е на един ред'
    stranica = glava[:kraj_komentar] + '\n' + blok + '\n' + glava[j:] + dvigatel

    pat.write_text(stranica, encoding='utf-8')
    return len(stranica)
