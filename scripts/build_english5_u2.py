#!/usr/bin/env python3
"""Сглобява трите листа за Unit 2 на English Plus 1 (5. клас).

  1  A Day in the Life  всекидневие, at/on/in, наречия за честота  (37)
  2  Present Simple     -s, don’t/doesn’t, въпроси, кратки отговори (44)
  3  Special Days       празници, предложения, also, Баба Марта     (38 + 4)

Нито една форма не се пише наготово: третото лице с -s, отрицанието и
въпросът се ИЗВЕЖДАТ тук по правилата и се сверяват наново от
scripts/check_english5_u2.py — по друг път, за да има смисъл.

    /usr/bin/python3.13 scripts/build_english5_u2.py
"""
import pathlib
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from english.build import broi_redove, sglobi, za_ocenka          # noqa: E402
from english5 import u2_den, u2_praznik, u2_prosto                # noqa: E402

LENTA = 'Домашно · английски · 5. клас'
NADPIS = 'Домашно · английски · 5. клас · Unit 2'
TITLI = ['Brilliant!', 'Well done!', 'Good try!']

#  Местоимения, които искат глагол с -s.
EDIN = {'he', 'she', 'it'}
MNOGO = {'i', 'you', 'we', 'they'}


# ── правилата, по които се раждат формите ────────────────────────────
def treto_lice(glagol: str) -> str:
    """get → gets, watch → watches, study → studies, have → has."""
    if glagol == 'have':
        return 'has'
    if glagol.endswith(('s', 'sh', 'ch', 'x', 'o')):
        return glagol + 'es'
    if glagol.endswith('y') and glagol[-2] not in 'aeiou':
        return glagol[:-1] + 'ies'
    return glagol + 's'


def edinstveno(podlog: str) -> bool:
    """Един ли е подлогът — значи ли той he, she или it."""
    nisko = podlog.lower().strip()
    if nisko in EDIN:
        return True
    if nisko in MNOGO:
        return False
    if ' and ' in nisko:
        return False
    glavna = nisko.split()[-1]
    if glavna in ('people', 'friends', 'classes', 'parents', 'children'):
        return False
    #  Множествено число се познава по -s, но не и при Bulgarians… —
    #  затова се гледа само последната дума.
    return not (glavna.endswith('s') and not glavna.endswith('ss'))


def formata(podlog: str, glagol: str) -> str:
    return treto_lice(glagol) if edinstveno(podlog) else glagol


def ne_formata(podlog: str) -> str:
    return 'doesn’t' if edinstveno(podlog) else 'don’t'


def otricanie(izr: str, podlog: str, glagol: str) -> str:
    """„She watches TV.“ → „She doesn’t watch TV.“"""
    forma = formata(podlog, glagol)
    i = izr.find(forma)
    assert i != -1, 'глаголът ' + forma + ' липсва от ' + izr
    return izr[:i] + ne_formata(podlog) + ' ' + glagol + izr[i + len(forma):]


def kratuk(podlog: str, da: bool) -> str:
    if da:
        return 'Yes, {} {}.'.format(podlog, 'does' if edinstveno(podlog) else 'do')
    return 'No, {} {}.'.format(podlog, ne_formata(podlog))


# ── листовете ────────────────────────────────────────────────────────
def list_den():
    m = u2_den
    upr = [
        {'kod': '1', 'ime': '⏰ WHAT DO YOU DO ALL DAY?',
         'bg': 'Свържи двойките', 'vid': 'dvoiki',
         'ukazanie': 'Свържи българското с английското: щракни отляво, после отдясно.',
         'dvojki': m.DVOJKI,
         'zashto': 'Това са думите на деня: от ставането до лягането.'},
        {'kod': '2', 'ime': '\U0001F4CD AT, ON or IN?', 'bg': 'Трите думички за КОГА',
         'vid': 'tap', 'izbori': ['at', 'on', 'in'],
         'ukazanie': 'Щракни вярния предлог.',
         'redove': [{'predi': p, 'sled': '', 'otgovor': o, 'zashto': z}
                    for p, o, _, z in m.PREDLOZI],
         'zashto': 'Точен час → at. Ден или дата → on. Част от деня, месец или '
                   'сезон → in. А at the weekend и at night се запомнят.'},
        {'kod': '3', 'ime': '\U0001F4CA HOW OFTEN?', 'bg': 'Колко често значи колко',
         'vid': 'dvoiki',
         'ukazanie': 'Свържи наречието с процента: щракни отляво, после отдясно.',
         'dvojki': m.CHESTOTA,
         'zashto': 'always 100% · usually 80% · often 60% · sometimes 30% · never 0%'},
        {'kod': '4', 'ime': '\U0001F504 PUT IT IN THE RIGHT PLACE',
         'bg': 'Къде застава наречието', 'vid': 'red',
         'ukazanie': 'Щракай думите по ред, за да стане изречението.',
         'redove': [{'otgovor': v, 'razburkano': [d for d in r.split(' / ')],
                     'zashto': 'Наречието ' + n + ' застава '
                               + ('СЛЕД be.' if ' is ' in v or ' are ' in v
                                  else 'пред главния глагол.')}
                    for r, v, n in m.MQSTO],
         'zashto': 'Наречието за честота застава ПРЕД главния глагол, но СЛЕД be: '
                   'I always get up, но She is never late.'},
        {'kod': '5', 'ime': '\U0001F4D6 MIA’S MONDAY', 'bg': 'Цял един понеделник',
         'vid': 'razkaz', 'kutiq': m.KUTIQ, 'tekst': m.TEKST,
         'ukazanie': 'Попълни празните места с думите от Word Box. '
                     'Всяка дума се използва веднъж.',
         'dupki': [{'otgovor': o, 'zashto': z} for _, o, _, _, z in m.DUPKI],
         'zashto': 'Един ден в present simple: he/she/it иска -s, а всички '
                   'останали — не.'},
    ]
    return list_ot(m, upr)


def list_prosto():
    m = u2_prosto
    upr = [
        {'kod': '1', 'ime': '➕ ADD THE -S', 'bg': 'Формата за he, she, it',
         'vid': 'type',
         'ukazanie': 'Напиши формата за he / she / it.',
         'redove': [{'predi': 'he / she / it', 'sled': '← ' + g,
                     'otgovor': treto_lice(g), 'zashto': pravilo_s(g)}
                    for g in m.GLAGOLI],
         'zashto': 'След -s, -sh, -ch, -x и -o идва -es. Съгласна + y става -ies. '
                   'have е особен: has.'},
        {'kod': '2', 'ime': '\U0001F50D ONE OR MANY?', 'bg': 'Коя форма иска подлогът',
         'vid': 'tap',
         'ukazanie': 'Щракни вярната форма на глагола.',
         'redove': [{'predi': izr, 'sled': '', 'otgovor': formata(p, g),
                     'izbori': sorted({g, treto_lice(g)}),
                     'zashto': ('„' + p + '“ е един → ' + treto_lice(g) + '.')
                               if edinstveno(p)
                               else ('„' + p + '“ не е един → ' + g + ', без -s.')}
                    for izr, p, g in m.FORMA],
         'zashto': 'Само he, she и it (и всичко, което значи ТЕ) взимат -s.'},
        {'kod': '3', 'ime': '❌ SAY NO!', 'bg': 'Отрицание',
         'vid': 'type', 'dalgo': True,
         'ukazanie': 'Направи изречението отрицателно. Напиши го цялото.',
         'redove': [{'predi': izr, 'sled': '', 'otgovor': otricanie(izr, p, g),
                     'zashto': ne_formata(p) + ' + ' + g
                               + ' — глаголът се връща в основната си форма.'}
                    for izr, p, g in m.OTRICANIE],
         'zashto': 'don’t или doesn’t поема -s-а, а глаголът остава гол.'},
        {'kod': '4', 'ime': '❓ ASK!', 'bg': 'Въпроси',
         'vid': 'red',
         'ukazanie': 'Щракай думите по ред, за да стане въпросът.',
         'redove': [{'otgovor': v, 'razburkano': [d for d in r.split(' / ')],
                     'zashto': 'Do или Does застава пред подлога, а глаголът '
                               'остава в основна форма.'}
                    for r, v in m.VUPROSI],
         'zashto': 'Въпросът се прави с Do / Does, а не с -s на глагола.'},
        {'kod': '5', 'ime': '✅ SHORT ANSWERS', 'bg': 'Кратките отговори',
         'vid': 'tap', 'shirok': True,
         'ukazanie': 'Щракни верния кратък отговор.',
         'redove': [{'predi': v, 'sled': '(' + ('YES' if da else 'NO') + ')',
                     'otgovor': kratuk(p, da),
                     'izbori': izbori_kratki(p, da),
                     'zashto': 'Отговаря се с do / does, не с целия глагол.'}
                    for v, p, da in m.KRATKI],
         'zashto': 'Yes, I do. · No, he doesn’t. — само подлог и do.'},
        {'kod': '6', 'ime': '\U0001F575️ CATCH THE MISTAKE', 'bg': 'Хвани грешката',
         'vid': 'greshka',
         'ukazanie': 'Щракни върху сгрешената дума.',
         'redove': [greshka_red(a, b, c) for a, b, c in m.GRESHKI],
         'zashto': 'Първо виж КОЙ върши действието, после сложи неговата форма.'},
    ]
    return list_ot(m, upr)


def list_praznik():
    m = u2_praznik
    upr = [
        {'kod': '1', 'ime': '\U0001F388 PARTY WORDS', 'bg': 'Свържи двойките',
         'vid': 'dvoiki',
         'ukazanie': 'Свържи българското с английското: щракни отляво, после отдясно.',
         'dvojki': m.DVOJKI,
         'zashto': 'Осем глагола, с които се празнува.'},
        {'kod': '2', 'ime': '\U0001F381 WHAT HAPPENS ON THIS DAY?',
         'bg': 'Кой глагол', 'vid': 'tap',
         'ukazanie': 'Щракни верния глагол.',
         'redove': [{'predi': izr, 'sled': '', 'otgovor': v,
                     'izbori': sorted([v] + drugi), 'zashto': z}
                    for izr, v, drugi, z in m.GLAGOLI],
         'zashto': 'Внимавай и за -s: everybody и my mum са ЕДИН.'},
        {'kod': '3', 'ime': '\U0001F5D3️ LET’S MAKE A PLAN!',
         'bg': 'Как се предлага', 'vid': 'tap', 'shirok': True,
         'ukazanie': 'Щракни вярната дума.',
         'redove': [{'predi': izr, 'sled': '', 'otgovor': v,
                     'izbori': sorted([v] + drugi), 'zashto': z}
                    for izr, v, drugi, z in m.PLANOVE],
         'zashto': 'Let’s… · How about…? · Why don’t we…? · Shall we…? · '
                   'Do you want to…?'},
        {'kod': '4', 'ime': '\U0001F44D SAY YES, SAY NO', 'bg': 'Отговорът на предложение',
         'vid': 'tap', 'shirok': True,
         'ukazanie': 'Щракни отговора, който пасва.',
         'redove': [{'predi': izr, 'sled': '', 'otgovor': v,
                     'izbori': sorted([v] + drugi), 'zashto': z}
                    for izr, v, drugi, z in m.OTGOVORI],
         'zashto': 'На предложение не се отговаря с Yes, I am — а с Good idea! '
                   'или Sorry, I can’t.'},
        {'kod': '5', 'ime': '➡️ WHERE DOES ALSO GO?', 'bg': 'Мястото на also',
         'vid': 'red',
         'ukazanie': 'Щракай думите по ред, за да стане изречението.',
         'redove': [{'otgovor': v, 'razburkano': [d for d in r.split(' / ')],
                     'zashto': 'also застава '
                               + ('СЛЕД be.' if ' is ' in v else 'пред главния глагол.')}
                    for r, v in m.ALSO],
         'zashto': 'also стои точно където стоят и наречията за честота: пред '
                   'главния глагол, но след be.'},
        {'kod': '6', 'ime': '\U0001F9F5 BABA MARTA', 'bg': 'Първи март на английски',
         'vid': 'razkaz', 'kutiq': m.KUTIQ, 'tekst': m.TEKST,
         'ukazanie': 'Попълни празните места с думите от Word Box. '
                     'Всяка дума се използва веднъж.',
         'dupki': [{'otgovor': o, 'zashto': z} for _, o, _, z in m.DUPKI],
         'zashto': 'Цял празник в present simple — и пак всичко опира до това '
                   'кой е подлогът.'},
        {'kod': '7', 'ime': '⭐ MY SPECIAL DAY', 'bg': 'Разкажи за своя празник',
         'vid': 'svoboden',
         'ukazanie': 'Отговори с ЦЕЛИ изречения. Тези отговори ги чете и оценява '
                     'преподавателят — не се проверяват автоматично.',
         'redove': [{'vupros': v, 'obrazec': o} for v, o in m.SVOBODNI],
         'zashto': 'Цяло изречение значи подлог и глагол — и не забравяй -s, '
                   'когато разказваш за някой друг.'},
    ]
    return list_ot(m, upr)


# ── общото за трите ──────────────────────────────────────────────────
def pravilo_s(g: str) -> str:
    if g == 'have':
        return 'have е особен глагол: при he/she/it става has.'
    if g.endswith(('s', 'sh', 'ch', 'x', 'o')):
        return 'Завършва на -' + g[-2:].lstrip('aeiou') + ' → добавя се -es.'
    if g.endswith('y') and g[-2] not in 'aeiou':
        return 'Съгласна + y → y пада и идва -ies.'
    if g.endswith('y'):
        return 'Гласна + y → просто -s, y остава.'
    return 'Нищо особено → само -s.'


def izbori_kratki(podlog: str, da: bool):
    """Верният отговор и две примамки, които НЕ са верни."""
    veren = kratuk(podlog, da)
    primamki = [
        kratuk(podlog, not da),
        ('Yes, ' if da else 'No, ') + podlog + (' is.' if da else ' isn’t.'),
    ]
    out = [veren] + [p for p in primamki if p != veren]
    return out[:3]


def greshka_red(izr: str, vqrno: str, zashto: str):
    a = izr.rstrip('?.!').split()
    b = vqrno.rstrip('?.!').split()
    assert len(a) == len(b), 'думите не са толкова: ' + izr
    greshni = [i for i, (x, y) in enumerate(zip(a, b)) if x != y]
    assert greshni, 'в изречението няма грешка: ' + izr
    krai = izr[len(izr.rstrip('?.!')):]
    return {'izr': izr, 'vqrno': vqrno, 'dumi': a, 'krai': krai,
            'greshni': greshni, 'zashto': zashto}


def list_ot(m, upr):
    return {
        'slug': m.SLUG, 'shapka': m.SHAPKA,
        'title': 'Домашно — ' + m.IME + ' — 5. клас',
        'opisanie': m.OPISANIE,
        'lenta': LENTA, 'nadpis': NADPIS,
        'h1': m.H1, 'podnaslov': m.PODNASLOV,
        'upr': upr, 'pohvali': m.POHVALI, 'titli': TITLI,
    }


LISTOVE = [list_den, list_prosto, list_praznik]
MODULI = [u2_den, u2_prosto, u2_praznik]


def vsichki():
    return [(f(), KOREN / m.FAIL) for f, m in zip(LISTOVE, MODULI)]


def main() -> None:
    obshto_a = obshto_r = 0
    for danni, pat in vsichki():
        znaka = sglobi(danni, pat)
        a = sum(za_ocenka(u) for u in danni['upr'])
        r = sum(broi_redove(u) for u in danni['upr'] if u['vid'] == 'svoboden')
        obshto_a += a
        obshto_r += r
        print('{:<34} упражнения: {}  ·  отговора: {:>3}{}  ·  {} знака'.format(
            pat.name, len(danni['upr']), a,
            ('  + ' + str(r) + ' за ръчна оценка') if r else '', znaka))
    print('общо: {} автоматични + {} за ръчна оценка = {}'.format(
        obshto_a, obshto_r, obshto_a + obshto_r))


if __name__ == '__main__':
    main()
