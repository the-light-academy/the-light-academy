#!/usr/bin/env python3
"""Сглобява четирите нови листа по английски за 5. клас, Unit 1.

Unit 1 вече имаше домашни за Reading, Language focus, Review и Vocabulary
— те дойдоха от домашното на Кали. Но юнитът има седем части, а три от
тях стояха празни. Тези листове ги запълват, като вървят по УЧЕБНИКА:

  Around Town              Vocabulary  p12 местата в града, a/an/some/any
                                       p16 прилагателните за сравняване
  Where’s the museum?      Speaking    p18 как се пита къде е нещо
  My Town                  Writing     p19 описание на град, мястото на
                                       прилагателното
  English Plus: Extra      Options     p92 лични данни · p100 посоки на
                                       картата · p106 Обединеното кралство
                                       · p116 песента

Задачите стоят в scripts/english5/u1_*.py, общият шаблон и двигателят —
в scripts/english/. Помощниците (подреждане, грешки, подсказки) се вземат
от scripts/build_english5.py, за да има един-единствен техен екземпляр.

Пуска се така:
    /usr/bin/python3.13 scripts/build_english5_u1b.py

Проверява се отделно: scripts/check_english5_u1b.py пресмята всеки
отговор наново, по свои правила.
"""
import pathlib
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from english.build import sglobi, za_ocenka, broi_redove      # noqa: E402
from build_english5 import tap, red_red, red_greshka, podskazka  # noqa: E402
from english5 import u1_mesta, u1_pitane, u1_pisane, u1_extra    # noqa: E402

LENTA = 'Домашно · английски · 5. клас'
NADPIS = 'Домашно · английски · 5. клас · Unit 1'
TITLI = ['Brilliant!', 'Well done!', 'Good try!']
POHVALI = [
    'Unit 1 ти е в джоба! 🎉',
    'Браво! Почти всичко е вярно. 👏',
    'Добро начало — виж кои редове светят в червено и ги оправи. 💪',
]


def dvoiki(ime, bg, ukazanie, dvojki, zashto):
    return {'kod': '', 'ime': ime, 'bg': bg, 'ukazanie': ukazanie,
            'vid': 'dvoiki', 'dvojki': dvojki, 'zashto': zashto}


def pisane(ime, bg, ukazanie, redove, zashto, s_bukva=False):
    """Упражнение с писане. redove: (предиизречение, отговор, други, защо)."""
    out = []
    for predi, otg, oshte, zasht in redove:
        r = {'predi': predi, 'sled': '', 'otgovor': otg, 'oshte': list(oshte),
             'zashto': zasht}
        if s_bukva:
            r['podskazka'] = podskazka(otg)
        out.append(r)
    return {'kod': '', 'ime': ime, 'bg': bg, 'ukazanie': ukazanie,
            'vid': 'type', 'dalgo': True, 'redove': out, 'zashto': zashto}


def podredi(ime, bg, redove, zashto):
    return {'kod': '', 'ime': ime, 'bg': bg,
            'ukazanie': 'Щракай думите по ред, за да стане изречението.',
            'vid': 'red', 'redove': [red_red(a, b, c) for a, b, c in redove],
            'zashto': zashto}


def svobodno(redove):
    return {'kod': '', 'ime': '⭐ YOUR TURN', 'bg': 'Отговори с цели изречения',
            'ukazanie': 'Пиши с ЦЕЛИ изречения. Тези отговори ги чете и оценява '
                        'преподавателят — не се проверяват автоматично.',
            'vid': 'svoboden',
            'redove': [{'vupros': v, 'obrazec': o} for v, o in redove],
            'zashto': 'Цяло изречение значи подлог и глагол: не „next to the park“, '
                      'а „It’s next to the park.“'}


def номерирай(upr):
    for n, u in enumerate(upr, 1):
        u['kod'] = str(n)
    return upr


# ── лист 1 · Vocabulary ──────────────────────────────────────────────
def list_mesta():
    m = u1_mesta
    upr = номерирай([
        dvoiki('\U0001F3D9️ PLACES IN TOWN', 'Свържи двойките',
               'Свържи българското с английското: щракни отляво, после отдясно.',
               m.MESTA,
               'Десет нови места в града — другите десет ги има в „Guess the Word“.'),
        tap('\U0001F518 A, AN, SOME or ANY?', 'Кое застава пред мястото',
            'Щракни вярната думичка.',
            ['a', 'an', 'some', 'any'], m.CHLENOVE,
            'Едно нещо → a / an (an пред гласен ЗВУК). Повече неща: some в '
            'утвърдително, any във въпрос и отрицание.'),
        pisane('\U0001F50D WHAT PLACE IS IT?', 'Прочети описанието и напиши мястото',
               'Напиши думата. Първата буква е дадена.',
               [(o, otg, oshte, 'Описанието сочи само към това място.')
                for o, otg, oshte in m.OPISANIQ],
               'Речникът на Unit 1: местата в града.', s_bukva=True),
        dvoiki('\U0001F504 OPPOSITES', 'Свържи противоположните',
               'Свържи прилагателното с неговата противоположност.',
               m.PROTIVOPOLOJNI,
               'Прилагателните от p16 вървят по двойки — така се запомнят.'),
        tap('\U0001F3AF WHICH ADJECTIVE?', 'Кое прилагателно пасва',
            'Щракни прилагателното, което пасва на изречението.',
            None, m.PRILAGATELNI,
            'Второто изречение във всеки ред е подсказката: то обяснява какво '
            'се случва.', shirok=True),
        podredi('\U0001F5E3️ KEY PHRASES', 'Подреди изречението', m.FRAZI,
                'There is / There are тръгва отпред, а въпросът обръща реда.'),
    ])
    return {
        'slug': 'en5-u1-places', 'shapka': 'grad',
        'title': 'Домашно — Around Town — 5. клас',
        'opisanie': 'Домашно по английски за 5. клас, Unit 1, Vocabulary: местата в '
                    'града, a/an/some/any и прилагателните за сравняване на места.',
        'lenta': LENTA, 'nadpis': NADPIS,
        'h1': 'Around Town<br /><em>Unit 1</em> — vocabulary',
        'podnaslov': 'Местата в града и думите, с които се описват. Десет нови места, '
                     'a / an / some / any и прилагателните от страница 16.',
        'upr': upr, 'pohvali': POHVALI, 'titli': TITLI,
    }


# ── лист 2 · Speaking ────────────────────────────────────────────────
def list_pitane():
    p = u1_pitane
    upr = номерирай([
        dvoiki('\U0001F4CD PREPOSITIONS OF PLACE', 'Свържи двойките',
               'Свържи българското с английското: щракни отляво, после отдясно.',
               p.PREDLOZI,
               'Осемте предлога, с които се казва КЪДЕ е нещо.'),
        tap('\U0001F5FA️ WHERE IS IT?', 'Кой предлог пасва',
            'Щракни вярния предлог. Второто изречение е подсказката.',
            None, p.KUDE,
            'Предлогът се избира по картината, не по звученето: между две неща → '
            'between, отсреща → opposite, отзад → behind.', shirok=True),
        podredi('\U0001F5E3️ KEY PHRASES', 'Подреди изречението', p.FRAZI,
                'Учтивият въпрос тръгва с Excuse me, а отговорът — с It’s.'),
        pisane('\U0001F4AC COMPLETE THE CONVERSATION', 'Една дума липсва',
               'Напиши липсващата дума в разговора.',
               p.RAZGOVORI,
               'Предлозите от две и три думи се помнят цели: next to, in front of, '
               'on the corner of.'),
        {'kod': '', 'ime': '\U0001F575️ FIND THE MISTAKE', 'bg': 'Намери сгрешената дума',
         'ukazanie': 'Щракни върху сгрешената дума.',
         'vid': 'greshka',
         'redove': [red_greshka(a, b, c) for a, b, c in p.GRESHKI],
         'zashto': 'Най-честите грешки при питане за път: is/are, a/some/any, '
                   'how much вместо how many и излишното to след opposite.'},
        svobodno(p.SVOBODNI),
    ])
    return {
        'slug': 'en5-u1-speaking', 'shapka': 'grad',
        'title': 'Домашно — Where’s the museum? — 5. клас',
        'opisanie': 'Домашно по английски за 5. клас, Unit 1, Speaking: предлози за '
                    'място, учтиви въпроси за посока и ключовите фрази от страница 18.',
        'lenta': LENTA, 'nadpis': NADPIS,
        'h1': 'Where’s the museum?<br /><em>Unit 1</em> — speaking',
        'podnaslov': 'Как се пита къде е нещо и как се отговаря. Предлозите за място, '
                     'учтивият въпрос и четири отговора със свои думи.',
        'upr': upr, 'pohvali': POHVALI, 'titli': TITLI,
    }


# ── лист 3 · Writing ─────────────────────────────────────────────────
def list_pisane():
    w = u1_pisane
    dupki = []
    for _, otg, oshte, zashto in w.OTGOVORI:
        d = {'otgovor': otg, 'zashto': zashto}
        if oshte:
            d['oshte'] = oshte
        dupki.append(d)
    upr = номерирай([
        podredi('\U0001F4CF WHERE DOES THE ADJECTIVE GO?', 'Подреди изречението',
                w.REDUT,
                'Прилагателното стои ПРЕД съществителното (a beautiful park), но '
                'СЛЕД глагола be, когато е сказуемо (the streets are narrow).'),
        tap('\U0001F518 A or AN?', 'Пред прилагателното',
            'Щракни a или an.',
            ['a', 'an'], w.CHLENOVE,
            'Решава ЗВУКЪТ на следващата дума, а тя тук е прилагателното, не '
            'съществителното: an old town, a big city.'),
        {'kod': '', 'ime': '\U0001F4DD A DESCRIPTION OF A TOWN',
         'bg': 'Образецът с десет празни места',
         'ukazanie': 'Прочети описанието и попълни празните места. Помагай си с '
                     'Word Box. Не всички думи се използват.',
         'vid': 'razkaz', 'kutiq': w.KUTIQ, 'tekst': w.TEKST, 'dupki': dupki,
         'zashto': 'Това е образецът, по който се пише собственото описание: '
                   'име и големина, какво има, какво няма, любимо място, накрая '
                   'мнение.'},
        pisane('\U0001F5E3️ KEY PHRASES', 'Една дума липсва',
               'Напиши липсващата дума.',
               w.FRAZI,
               'Готовите фрази за описание на град: in the north of, famous for, '
               'a lot to do, favourite place, kilometres from.'),
        svobodno(w.SVOBODNI),
    ])
    return {
        'slug': 'en5-u1-writing', 'shapka': 'grad',
        'title': 'Домашно — My Town — 5. клас',
        'opisanie': 'Домашно по английски за 5. клас, Unit 1, Writing: описание на '
                    'град — мястото на прилагателното, ключовите фрази и образец с '
                    'празни места.',
        'lenta': LENTA, 'nadpis': NADPIS,
        'h1': 'My Town<br /><em>Unit 1</em> — writing',
        'podnaslov': 'Как се описва град: къде застава прилагателното, кои са готовите '
                     'фрази и как изглежда цял готов текст — преди да напишеш своя.',
        'upr': upr, 'pohvali': POHVALI, 'titli': TITLI,
    }


# ── лист 4 · English Plus options ────────────────────────────────────
def list_extra():
    e = u1_extra
    upr = номерирай([
        dvoiki('\U0001F1EC\U0001F1E7 COUNTRIES AND CAPITALS', 'Свържи двойките',
               'Свържи страната със столицата ѝ.',
               e.STOLICI,
               'Обединеното кралство е ЧЕТИРИ страни: England, Scotland, Wales и '
               'Northern Ireland.'),
        tap('\U0001F9ED READING A MAP', 'Коя посока',
            'Щракни вярната посока.',
            None, e.POSOKI,
            'north горе, south долу, west вляво, east вдясно — както е на всяка '
            'карта.', shirok=True),
        pisane('\U0001F4C7 PERSONAL INFORMATION', 'Една дума липсва',
               'Напиши липсващата дума в разговора.',
               e.LICHNI,
               'Въпросите, с които се представяш: name, surname, spell, number, '
               'old, from, email.'),
        tap('\U0001F3F4 CULTURE QUIZ', 'Какво знаеш за Обединеното кралство',
            'Щракни верния отговор.',
            None, e.VIKTORINA,
            'Четири страни, едно знаме (Union Jack) и две столици, които често се '
            'бъркат.', shirok=True),
        podredi('\U0001F3B5 THE SONG', 'Подреди реда от песента', e.PESEN,
                'В песента се повтаря същата граматика: I’m, There’s, Can I…?, '
                'Who is…?'),
        svobodno(e.SVOBODNI),
    ])
    return {
        'slug': 'en5-u1-extra', 'shapka': 'baloni',
        'title': 'Домашно — English Plus: Extra — 5. клас',
        'opisanie': 'Домашно по английски за 5. клас, Unit 1, English Plus options: '
                    'лични данни, четене на карта, Обединеното кралство и песента.',
        'lenta': LENTA, 'nadpis': NADPIS,
        'h1': 'English Plus: Extra<br /><em>Unit 1</em> — options',
        'podnaslov': 'Четирите допълнителни страници към юнита на един лист: лични '
                     'данни, посоките на картата, Обединеното кралство и песента.',
        'upr': upr, 'pohvali': POHVALI, 'titli': TITLI,
    }


LISTOVE = [list_mesta, list_pitane, list_pisane, list_extra]
IMENA = ['homework_5_en_u1_places.html', 'homework_5_en_u1_speaking.html',
         'homework_5_en_u1_writing.html', 'homework_5_en_u1_extra.html']


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
        print('{:<36} упражнения: {}  ·  отговора: {:>3}{}  ·  {} знака'.format(
            pat.name, len(danni['upr']), a,
            ('  + {} за ръчна оценка'.format(r) if r else ''), znaka))
    print('общо: {} автоматични + {} за ръчна оценка'.format(obshto_a, obshto_r))


if __name__ == '__main__':
    main()
