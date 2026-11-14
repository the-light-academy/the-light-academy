#!/usr/bin/env python3
"""Unit 1 · Writing — „My Town“.

Страница 19 от учебника: описание на град. Езиковата точка е мястото на
прилагателното — ПРЕД съществителното вътре в израза, но СЛЕД глагола
be, когато е сказуемо. Ключовите фрази са тези, с които се описва град.

Листът върви от подреждане към готов образец с празни места и накрая
към собствено писане, което чете преподавателят.
"""

#  p19 · Мястото на прилагателното. (разбъркано, вярното, защо)
REDUT = [
    ('old / in / an / There’s / church / the / square / .',
     'There’s an old church in the square.',
     'Прилагателното old стои ПРЕД съществителното church.'),
    ('has / park / town / a / beautiful / My / .',
     'My town has a beautiful park.',
     'a + прилагателно + съществително вървят слято: a beautiful park.'),
    ('The / narrow / are / river / the / streets / near / .',
     'The streets near the river are narrow.',
     'Тук narrow е сказуемо и идва СЛЕД are, а не пред streets.'),
    ('shops / a / with / of / a / It’s / modern / city / lot / .',
     'It’s a modern city with a lot of shops.',
     'Първо какъв е градът, после какво има в него.'),
    ('favourite / castle / My / old / the / is / place / .',
     'My favourite place is the old castle.',
     'My favourite place е подлогът, is го свързва с отговора.'),
    ('my / are / museums / some / There / town / in / interesting / .',
     'There are some interesting museums in my town.',
     'some + прилагателно + съществително, накрая мястото.'),
]

#  p19 · a или an пред прилагателно и съществително.
#  (изречение, отговор, други приети, защо)
CHLENOVE = [
    ('It’s ___ old town with narrow streets.', 'an', [],
     'an пред гласен звук — чува се „олд“, а не „таун“.'),
    ('It’s ___ big city in the south of the country.', 'a', [],
     'a пред съгласен звук: big.'),
    ('There’s ___ interesting museum near the square.', 'an', [],
     'an пред гласен звук: interesting.'),
    ('There’s ___ ugly building in the centre.', 'an', [],
     'an пред гласен звук: ugly.'),
    ('It’s ___ quiet village in the mountains.', 'a', [],
     'a пред съгласен звук: quiet.'),
    ('There’s ___ expensive hotel near the beach.', 'an', [],
     'an пред гласен звук: expensive.'),
    ('It’s ___ modern sports centre with a swimming pool.', 'a', [],
     'a пред съгласен звук: modern.'),
    ('There’s ___ old market in the square.', 'an', [],
     'an пред гласен звук: old. Решава ЗВУКЪТ, не буквата.'),
]

#  p19 · Образецът: описание на град с десет празни места.
KUTIQ = ['is', 'are', 'aren’t', 'isn’t', 'a', 'an', 'any', 'some',
         'square', 'beautiful', 'interesting', 'tourists', 'quiet', 'lovely']

TEKST = """My town is called Kazanlak. It {1} a small town in the centre of Bulgaria.
There {2} about 45,000 people here, so it isn’t very big.
In the middle of the town there is a big {3} with a fountain and some old trees.
There {4} any skyscrapers in Kazanlak, but there are some {5} old houses with red roofs.
My favourite place is the Museum of Roses. It’s a very {6} place, because our valley is famous for roses.
In May there are a lot of {7} here. They come for the Rose Festival.
There isn’t {8} cinema in my street, but there’s one in the shopping centre.
The streets near the park are {9} and clean.
I think Kazanlak is a {10} town and I love living here."""

#  (номер, отговор, други приети, защо)
OTGOVORI = [
    (1, 'is', [], 'It е едно нещо → is.'),
    (2, 'are', [], '45,000 people са много → there are.'),
    (3, 'square', [], 'Голямо открито място в средата на града с фонтан.'),
    (4, 'aren’t', ['are not'],
     'any след себе си иска отрицание: there aren’t any…'),
    (5, 'beautiful', [], 'Прилагателно ПРЕД old houses — описва ги.'),
    (6, 'interesting', [], 'Музей, за който има какво да се каже.'),
    (7, 'tourists', [], 'Хора, които идват за фестивала.'),
    (8, 'a', [], 'Едно кино в отрицание: there isn’t a cinema.'),
    (9, 'quiet', [], 'Улици до парка — тихи, а не шумни.'),
    (10, 'lovely', [], 'Какъв е градът според автора — хубав.'),
]

#  p19 · Key phrases: Describing a town or city.
#  (изречение, отговор, други приети, защо)
FRAZI = [
    ('It’s a small town ___ the north of Bulgaria.', 'in', [],
     'in the north / south / east / west of — посоката иска in.'),
    ('My town is ___ for its roses.', 'famous', [],
     'be famous for — известен С нещо.'),
    ('There’s a lot ___ do here in summer.', 'to', [],
     'a lot to do — „много за правене“.'),
    ('My ___ place is the old castle.', 'favourite', ['favorite'],
     'favourite place — любимото място.'),
    ('It’s about 200 kilometres ___ Sofia.', 'from', [],
     'Разстояние ОТ един град: kilometres from.'),
    ('I ___ living here because the people are friendly.', 'love', ['like'],
     'love / like + -ing форма: love living.'),
]

#  Собственото писане — чете го преподавателят.
SVOBODNI = [
    ('Write the first TWO sentences of a description of your town: '
     'its name, how big it is and where it is.',
     'My town is called Plovdiv. It’s a big city in the south of Bulgaria.'),
    ('Write TWO sentences about places in your town. Use There’s / There are '
     'and one adjective in each sentence.',
     'There’s a beautiful old theatre in the centre. There are some quiet '
     'parks near my house.'),
    ('What is your favourite place in your town, and why? Write two sentences.',
     'My favourite place is the river park. It’s quiet and there are a lot of '
     'trees.'),
    ('Write ONE sentence about something your town HASN’T got. '
     'Use There isn’t or There aren’t.',
     'There isn’t a zoo in my town.'),
]
