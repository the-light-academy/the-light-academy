#!/usr/bin/env python3
"""Сглобява петте листа по английски за 5. клас, Unit 1.

Домашното на Кали за 12 ноември е едно, но е голямо: 138 задачи за
автоматична проверка и 7 въпроса със свободен отговор. Разделено е на
пет листа по теми, всеки с най-много десет упражнения:

  1  The Lost Backpack   разказът с двайсетте празни места + бонусът
  2  Word Order Workshop разбърканите думи
  3  Grammar Detective   намери сгрешената дума
  4  Grammar Mix         въпросителни думи, and/or/but, there is/are, some/any
  5  Guess the Word      речникът на юнита

Задачите стоят в scripts/english5/, общият шаблон и двигателят — в
scripts/english/. Проверява се от scripts/check_english5.py.

Пуска се така:
    /usr/bin/python3.13 scripts/build_english5.py
"""
import pathlib
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from english.build import sglobi, za_ocenka, broi_redove   # noqa: E402
from english5 import razkaz, podrejdane, detektiv, smes, dumi  # noqa: E402

LENTA = 'Домашно · английски · 5. клас'
TITLI = ['Brilliant!', 'Well done!', 'Good try!']
POHVALI = [
    'Unit 1 ти е в джоба! 🎉',
    'Браво! Почти всичко е вярно. 👏',
    'Добро начало — виж кои редове светят в червено и ги оправи. 💪',
]


# ── помощни ──────────────────────────────────────────────────────────
def razdeli(izr):
    """„Who is your best friend from?“ → (['Who',…,'from'], '?')"""
    krai = ''
    while izr and izr[-1] in '.?!':
        krai = izr[-1] + krai
        izr = izr[:-1]
    return izr.split(), krai


def sgreshenite(izr, vqrno):
    """Кои думи са сгрешени — изведено от двете изречения, не написано.

    Или е подмяна на същия брой думи, или една дума в повече.
    """
    a, ka = razdeli(izr)
    b, kb = razdeli(vqrno)
    assert ka == kb, 'краят се различава: ' + izr
    if len(a) == len(b):
        raz = [i for i, (x, y) in enumerate(zip(a, b)) if x != y]
        assert raz, 'в изречението няма грешка: ' + izr
        return raz
    assert len(a) == len(b) + 1, 'разликата не е една дума: ' + izr
    for i in range(len(b)):
        if a[i] != b[i]:
            return [i]
    return [len(a) - 1]


def red_greshka(izr, vqrno, zashto):
    dumi_, krai = razdeli(izr)
    return {'izr': izr, 'vqrno': vqrno, 'dumi': dumi_, 'krai': krai,
            'greshni': sgreshenite(izr, vqrno), 'zashto': zashto}


def red_red(razb, vqrno, zashto):
    """Ред за подреждане: думите остават разбъркани както на хартия."""
    chasti = [d for d in razb.split(' / ') if d != '?']
    return {'otgovor': vqrno, 'razburkano': chasti, 'zashto': zashto}


def podskazka(duma):
    """„library“ → „L _ _ _ _ _ _“, с толкова чертички, колкото са буквите."""
    out = []
    for chast in duma.split(' '):
        out.append(chast[0].upper() + ''.join(' _' for _ in chast[1:]))
    return '   '.join(out)


def tap(ime, bg, ukazanie, izbori, redove, zashto, shirok=False):
    u = {'kod': '', 'ime': ime, 'bg': bg, 'ukazanie': ukazanie, 'vid': 'tap',
         'redove': [], 'zashto': zashto}
    if izbori:
        u['izbori'] = izbori
    if shirok:
        u['shirok'] = True
    for predi, otg, dop, zasht in redove:
        r = {'predi': predi, 'sled': '', 'otgovor': otg, 'zashto': zasht}
        if izbori:
            #  Изборите са общи за упражнението, затова третото поле са
            #  ДРУГИТЕ приемливи отговори.
            if dop:
                r['oshte'] = dop
        else:
            #  Тук всеки ред си има свои избори и третото поле са ТЕ.
            #  (Бъркаха се и двата избора минаваха за верни.)
            r['izbori'] = dop
            assert otg in dop, 'верният отговор не е сред изборите: ' + predi
        u['redove'].append(r)
    return u


# ── лист 1 · разказът ────────────────────────────────────────────────
def list1():
    dupki = []
    for _, otg, oshte, zashto in razkaz.OTGOVORI:
        d = {'otgovor': otg, 'zashto': zashto}
        if oshte:
            d['oshte'] = oshte
        dupki.append(d)
    upr = [
        {'kod': '1', 'ime': 'THE LOST BACKPACK', 'bg': 'Изгубената раница',
         'ukazanie': 'Прочети историята и попълни празните места. Помагай си с '
                     'Word Box. Не всички думи се използват и някои се повтарят.',
         'vid': 'razkaz', 'kutiq': razkaz.KUTIQ, 'tekst': razkaz.TEKST,
         'dupki': dupki,
         'zashto': 'Цялата история е върху Unit 1: there is / there are, some и any, '
                   'have got, this и those, question words.'},
        {'kod': '2', 'ime': '⭐ BONUS CHALLENGE', 'bg': 'Отговори с цели изречения',
         'ukazanie': 'Отговори на въпросите с ЦЕЛИ изречения. Тези отговори ги чете '
                     'и оценява преподавателят — не се проверяват автоматично.',
         'vid': 'svoboden',
         'redove': [{'vupros': v, 'obrazec': o} for v, o in razkaz.BONUS],
         'zashto': 'Цяло изречение значи подлог и глагол: не „in England“, а '
                   '„They live in a small town in England.“'},
    ]
    return {
        'slug': 'en5-u1-story', 'shapka': 'grad',
        'title': 'Домашно — The Lost Backpack — 5. клас',
        'opisanie': 'Домашно по английски за 5. клас, Unit 1: разказът „The Lost '
                    'Backpack“ с двайсет празни места и бонус въпроси с цели изречения.',
        'lenta': LENTA, 'nadpis': 'Домашно · английски · 5. клас · Unit 1',
        'h1': 'The Lost Backpack<br /><em>Unit 1</em> — Towns and cities',
        'podnaslov': 'Том и Миа намират раница под едно дърво в парка. За да разберат '
                     'чия е, ти трябват двайсет думи — и целият Unit 1.',
        'upr': upr, 'pohvali': POHVALI, 'titli': TITLI,
    }


# ── лист 2 · подреждане ──────────────────────────────────────────────
def list2():
    upr = []
    for n, (ime, bg, redove) in enumerate(podrejdane.CHASTI, 1):
        upr.append({
            'kod': str(n), 'ime': ime.upper(), 'bg': bg,
            'ukazanie': 'Щракай думите по ред, за да стане изречение.',
            'vid': 'red',
            'redove': [red_red(a, b, c) for a, b, c in redove],
            'zashto': 'Редът в английското изречение е строг: подлог, глагол, останалото '
                      '— освен при въпрос, където глаголът изскача отпред.',
        })
    return {
        'slug': 'en5-u1-order', 'shapka': 'grad',
        'title': 'Домашно — Word Order Workshop — 5. клас',
        'opisanie': 'Домашно по английски за 5. клас, Unit 1: подреждане на разбъркани '
                    'думи — have got, this/that/these/those, there is/are, question words.',
        'lenta': LENTA, 'nadpis': 'Домашно · английски · 5. клас · Unit 1',
        'h1': 'Word Order Workshop<br /><em>Unit 1</em> — put the words in order',
        'podnaslov': 'Думите са разбъркани. Щракай ги една по една, докато изречението '
                     'застане на мястото си. Двайсет и четири изречения, от лесни към дълги.',
        'upr': upr, 'pohvali': POHVALI, 'titli': TITLI,
    }


# ── лист 3 · детективът ──────────────────────────────────────────────
def list3():
    upr = []
    for n, (ime, bg, redove) in enumerate(detektiv.NIVA, 1):
        upr.append({
            'kod': str(n), 'ime': ime, 'bg': bg,
            'ukazanie': 'Щракни върху сгрешената дума. (В едно изречение грешките са две!)',
            'vid': 'greshka',
            'redove': [red_greshka(a, b, c) for a, b, c in redove],
            'zashto': 'Първо намери подлога, после виж дали глаголът му пасва. '
                      'Подлогът командва глагола.',
        })
    #  Двете с объркан ред не стават за щракане — подреждат се.
    upr.insert(3, {
        'kod': 'R', 'ime': '\U0001F501 FIX THE WORD ORDER', 'bg': 'Тези не са сгрешена дума',
        'ukazanie': 'Тук думите са в грешен ред. Подреди ги както трябва.',
        'vid': 'red',
        'redove': [{'otgovor': b, 'zashto': c} for _, b, c in detektiv.REDUT],
        'zashto': 'При въпрос глаголът застава пред подлога, веднага след '
                  'въпросителната дума.',
    })
    for n, u in enumerate(upr, 1):
        u['kod'] = str(n)
    return {
        'slug': 'en5-u1-detective', 'shapka': 'grad',
        'title': 'Домашно — Grammar Detective — 5. клас',
        'opisanie': 'Домашно по английски за 5. клас, Unit 1: намери сгрешената дума в '
                    'изречението — have got, there is/are, some/any, въпроси.',
        'lenta': LENTA, 'nadpis': 'Домашно · английски · 5. клас · Unit 1',
        'h1': 'Grammar Detective<br /><em>Unit 1</em> — find the mistake',
        'podnaslov': 'Във всяко изречение се е скрила по една сгрешена дума. Щракни я. '
                     'Трийсет изречения, от лесни към коварни — в последното грешките са две.',
        'upr': upr, 'pohvali': POHVALI, 'titli': TITLI,
    }


# ── лист 4 · смесената граматика ─────────────────────────────────────
def list4():
    upr = [
        tap('❓ QUESTION-WORD CHALLENGE', 'Where, What или Who',
            'Щракни вярната въпросителна дума.',
            ['Where', 'What', 'Who'], smes.VUPROSI,
            'Where пита за място, What за нещо, Who за човек.'),
        tap('\U0001F517 AND, OR or BUT?', 'Свържи двете половини',
            'Щракни вярната свързваща дума.',
            ['and', 'or', 'but'], smes.SVRUZKI,
            'and събира, or дава избор, but показва обратното.'),
        tap('\U0001F3D9️ THERE IS or THERE ARE?', 'Едно или повече',
            'Щракни вярното начало на изречението.',
            None, [(a, b, c, d) for a, b, c, d in smes.IMA],
            'Едно нещо → there is / there isn’t. Повече от едно → '
            'there are / there aren’t.', shirok=True),
        {'kod': '4', 'ime': '➖ TURN THEM NEGATIVE!', 'bg': 'Направи ги отрицателни',
         'ukazanie': 'Напиши изречението в отрицателна форма. Внимавай със some!',
         'vid': 'type', 'dalgo': True,
         'redove': [{'predi': a, 'sled': '', 'otgovor': b, 'oshte': c, 'zashto': d}
                    for a, b, c, d in smes.OTRICANIQ],
         'zashto': 'is → isn’t, are → aren’t. И в отрицанието some става any.'},
        tap('\U0001F34E SOME or ANY?', 'Кога се използва кое',
            'Щракни some или any.',
            ['some', 'any'], smes.NQKOI,
            'some в утвърдителни изречения; any във въпроси и отрицания.'),
    ]
    for n, u in enumerate(upr, 1):
        u['kod'] = str(n)
    return {
        'slug': 'en5-u1-grammar', 'shapka': 'grad',
        'title': 'Домашно — Grammar Mix — 5. клас',
        'opisanie': 'Домашно по английски за 5. клас, Unit 1: въпросителни думи, '
                    'and/or/but, there is/there are, отрицания и some/any.',
        'lenta': LENTA, 'nadpis': 'Домашно · английски · 5. клас · Unit 1',
        'h1': 'Grammar Mix<br /><em>Unit 1</em> — five short rounds',
        'podnaslov': 'Пет кратки упражнения върху граматиката на юнита: въпросителни думи, '
                     'and / or / but, there is / there are, отрицания и some / any.',
        'upr': upr, 'pohvali': POHVALI, 'titli': TITLI,
    }


# ── лист 5 · познай думата ───────────────────────────────────────────
def list5():
    upr = []
    for n, (ime, _, s_bukva, redove) in enumerate(dumi.GRUPI, 1):
        upr.append({
            'kod': str(n), 'ime': ime, 'bg': 'Прочети описанието и напиши думата',
            'ukazanie': ('Напиши думата. Първата буква е дадена.' if s_bukva
                         else 'Тук няма първа буква — само описанието.'),
            'vid': 'type', 'dalgo': True,
            'redove': [
                {'predi': opis, 'sled': '', 'otgovor': otg,
                 'oshte': ([otg.replace('é', 'e')] if 'é' in otg else []),
                 'podskazka': (podskazka(otg) if s_bukva else '')}
                for opis, otg in redove
            ],
            'zashto': 'Речникът на Unit 1: местата в града, нещата, които носиш, '
                      'държавите и прилагателните.',
        })
    return {
        'slug': 'en5-u1-words', 'shapka': 'grad',
        'title': 'Домашно — Guess the Word — 5. клас',
        'opisanie': 'Домашно по английски за 5. клас, Unit 1: познай думата по описанието '
                    '— места в града, всекидневни предмети, държави и прилагателни.',
        'lenta': LENTA, 'nadpis': 'Домашно · английски · 5. клас · Unit 1',
        'h1': 'Guess the Word<br /><em>Unit 1</em> — vocabulary',
        'podnaslov': 'Описанието е отгоре, думата се пише отдолу. Трийсет и четири думи от '
                     'юнита — последните шест са без първа буква.',
        'upr': upr, 'pohvali': POHVALI, 'titli': TITLI,
    }


LISTOVE = [list1, list2, list3, list4, list5]
IMENA = ['homework_5_en_u1_story.html', 'homework_5_en_u1_order.html',
         'homework_5_en_u1_detective.html', 'homework_5_en_u1_grammar.html',
         'homework_5_en_u1_words.html']


def vsichki():
    return [(f(), KOREN / ime) for f, ime in zip(LISTOVE, IMENA)]


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
