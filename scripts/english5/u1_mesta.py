#!/usr/bin/env python3
"""Unit 1 · Vocabulary — „Around Town“.

Речникът на юнита така, както е в учебника: p12 местата в града заедно
с There’s / There are и a, an, some, any, и p16 прилагателните за
сравняване на места.

Листът „Guess the Word“ вече пита за library, cinema, café, train
station, shop, park, theatre, hotel, restaurant, bridge, monument,
market и sports centre. Тук нарочно няма нито едно от тях — местата са
други десет, за да се разширява речникът, а не да се повтаря. (Пазарът
и спортният център остават само в упражнението за свързване, където
се разпознават, а не се пишат.)
"""

#  p12 · Places in a town or city — десет НОВИ места.
MESTA = [
    ['музей', 'museum'],
    ['стадион', 'stadium'],
    ['плувен басейн', 'swimming pool'],
    ['автогара', 'bus station'],
    ['поща', 'post office'],
    ['болница', 'hospital'],
    ['площад', 'square'],
    ['замък', 'castle'],
    ['банка', 'bank'],
    ['аптека', 'chemist’s'],
]

#  p12 · Language point: There’s / There are + a, an, some, any.
#  (изречение, отговор, други приети, защо)
CHLENOVE = [
    ('There’s ___ old castle on the hill.', 'an', [],
     'an пред гласен ЗВУК: old започва с „о“.'),
    ('There’s ___ market in the square every Saturday.', 'a', [],
     'a пред съгласен звук: market.'),
    ('There are ___ nice cafés in the old town.', 'some', [],
     'some при повече неща в утвърдително изречение.'),
    ('Are there ___ hotels near the beach?', 'any', [],
     'any във въпрос за повече неща.'),
    ('There isn’t ___ swimming pool in my village.', 'a', [],
     'Едно нещо в отрицание пак иска a: there isn’t a…'),
    ('There aren’t ___ cinemas in this town.', 'any', [],
     'any в отрицание за повече неща.'),
    ('There’s ___ umbrella in my bag.', 'an', [],
     'an пред гласен звук: umbrella.'),
    ('Is there ___ bank near here?', 'a', [],
     'Едно нещо във въпрос: Is there a…?'),
    ('There are ___ beautiful parks in Sofia.', 'some', [],
     'some при повече неща в утвърдително изречение.'),
    ('There aren’t ___ good shops in this street.', 'any', [],
     'any в отрицание за повече неща.'),
]

#  p12 · Кое място е това? Описанието отгоре, думата отдолу.
OPISANIQ = [
    ('You can see old and interesting things from history here.', 'museum', []),
    ('You can swim here.', 'swimming pool', ['pool']),
    ('Buses stop here and people travel to other towns.', 'bus station', []),
    ('People go here when they are ill.', 'hospital', []),
    ('You can send a letter or a parcel from this place.', 'post office', []),
    ('This is a big open place in the centre of a town.', 'square', []),
    ('You can get money here.', 'bank', []),
    ('Kings and queens lived in this big old building.', 'castle', []),
    ('You can buy medicine here.', 'chemist’s', ['chemist']),
    ('Thousands of people watch football matches here.', 'stadium', []),
]

#  p16 · Comparing places — прилагателните по двойки противоположни.
PROTIVOPOLOJNI = [
    ['old', 'new'],
    ['quiet', 'noisy'],
    ['pretty', 'ugly'],
    ['cheap', 'expensive'],
    ['big', 'small'],
    ['modern', 'traditional'],
    ['clean', 'dirty'],
    ['boring', 'interesting'],
]

#  p16 · Кое прилагателно пасва на изречението.
#  (изречение, отговор, двата избора, защо)
PRILAGATELNI = [
    ('The streets are very ___ — there are cars and buses everywhere.',
     'noisy', ['noisy', 'quiet'],
     'Много коли и автобуси значи шум.'),
    ('This hotel is ___ — a room costs 400 leva a night.',
     'expensive', ['expensive', 'cheap'],
     '400 лева на вечер е скъпо.'),
    ('The castle is very ___ — it is 800 years old.',
     'old', ['old', 'modern'],
     '800 години значи старо.'),
    ('The park is ___ and green. I love walking there.',
     'pretty', ['pretty', 'ugly'],
     'Зелено и хубаво за разходка значи красиво.'),
    ('The museum is ___ — there is nothing to do there.',
     'boring', ['boring', 'interesting'],
     'Няма какво да се прави значи скучно.'),
    ('The beach is ___ — there is no rubbish on it.',
     'clean', ['clean', 'dirty'],
     'Няма боклук значи чисто.'),
]

#  p12 · Key phrases: Talking about places — подреждане на изреченията.
#  (разбъркано, вярното изречение, защо)
FRAZI = [
    ('town / in / shops / are / of / There / lot / my / a / .',
     'There are a lot of shops in my town.',
     'There are тръгва отпред, после a lot of + нещата, накрая мястото.'),
    ('There / cinema / near / my / a / isn’t / house / .',
     'There isn’t a cinema near my house.',
     'Отрицанието застава в there isn’t, а не пред цялото изречение.'),
    ('there / city / many / the / museums / are / in / How / ?',
     'How many museums are there in the city?',
     'How many + съществителното, чак после are there.'),
    ('town / there / park / Is / your / a / in / ?',
     'Is there a park in your town?',
     'Във въпроса is изскача пред there.'),
    ('the / buildings / old / are / in / town / some / beautiful / There / .',
     'There are some beautiful buildings in the old town.',
     'Прилагателното стои ПРЕД съществителното: beautiful buildings.'),
]
