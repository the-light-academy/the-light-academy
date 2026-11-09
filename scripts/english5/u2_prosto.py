#!/usr/bin/env python3
"""Unit 2, лист 2 — „Present Simple“.

Третото лице с -s, отрицанието с don’t и doesn’t, въпросите с Do и
Does и кратките отговори.

Нито една форма не е преписана наготово: проверката ги извежда от
правилата за -s (след -s, -sh, -ch, -x и -o идва -es; съгласна + y
става -ies; have е особен) и от лицето на подлога.
"""

SLUG = 'en5-u2-present'
FAIL = 'homework_5_en_u2_present.html'
IME = 'Present Simple'
H1 = 'Present Simple<br /><em>Unit 2</em> — he, she, it and the little -s'
PODNASLOV = ('Едно малко -s обръща цялото изречение. Шест упражнения: '
             'добавяш го, махаш го, питаш с него и хващаш тези, които са '
             'го сложили на грешно място.')
OPISANIE = ('Домашно по английски за 5. клас, Unit 2: present simple — '
            'третото лице с -s, don’t и doesn’t, въпроси с Do и Does и '
            'кратки отговори.')
SHAPKA = 'baloni'

#  1 · Формата за he / she / it — само глаголът, правилото го знае проверката
GLAGOLI = ['watch', 'go', 'study', 'play', 'do', 'have', 'finish', 'fly',
           'teach', 'get']

#  2 · Коя форма: (изречение с __ , подлог, глагол)
FORMA = [
    ('My sister __ up at six.', 'My sister', 'get'),
    ('I __ to school by bus.', 'I', 'go'),
    ('Tom and Mia __ English every day.', 'Tom and Mia', 'study'),
    ('My father __ TV in the evening.', 'My father', 'watch'),
    ('We __ classes on Monday.', 'We', 'have'),
    ('It __ a lot in November.', 'It', 'rain'),
    ('You __ your homework after dinner.', 'You', 'do'),
    ('Daisy __ the piano very well.', 'Daisy', 'play'),
]

#  3 · Отрицание: (утвърдително, подлог, глагол)
OTRICANIE = [
    ('I get up at six.', 'I', 'get'),
    ('She watches TV.', 'She', 'watch'),
    ('They study French.', 'They', 'study'),
    ('My brother plays football.', 'My brother', 'play'),
    ('We have classes on Saturday.', 'We', 'have'),
    ('Milo goes to bed at nine.', 'Milo', 'go'),
]

#  4 · Въпроси за подреждане
VUPROSI = [
    ('you / get / do / up / early / ?', 'Do you get up early?'),
    ('she / study / does / English / ?', 'Does she study English?'),
    ('watch / they / do / TV / ?', 'Do they watch TV?'),
    ('time / what / you / do / have / breakfast / ?',
     'What time do you have breakfast?'),
    ('sister / where / your / school / to / does / go / ?',
     'Where does your sister go to school?'),
    ('often / how / you / do / your / do / homework / ?',
     'How often do you do your homework?'),
]

#  5 · Кратки отговори: (въпрос, подлог в отговора, да или не)
KRATKI = [
    ('Do you like pizza?', 'I', True),
    ('Does he play tennis?', 'he', False),
    ('Do they live in Sofia?', 'they', True),
    ('Does your mother work at home?', 'she', False),
    ('Do we have classes today?', 'we', True),
    ('Does it rain in July?', 'it', False),
]

#  6 · Хвани грешката
GRESHKI = [
    ('She go to school at eight.', 'She goes to school at eight.',
     'She е he/she/it → goes, с -es.'),
    ('I doesn’t like coffee.', 'I don’t like coffee.',
     'I никога не взима doesn’t.'),
    ('Do your brother play football?', 'Does your brother play football?',
     'Your brother е he → въпросът започва с Does.'),
    ('He don’t watch TV.', 'He doesn’t watch TV.',
     'He е едно лице → doesn’t, а глаголът остава watch.'),
    ('My sister studys every day.', 'My sister studies every day.',
     'Съгласна + y → -ies: studies.'),
    ('They watches a film on Friday.', 'They watch a film on Friday.',
     'They са повече от един → глаголът остава без -s.'),
    ('Does she has breakfast at seven?', 'Does she have breakfast at seven?',
     'След Does глаголът се връща в основната си форма: have.'),
    ('Does your friends like music?', 'Do your friends like music?',
     'Your friends са повече от един → Do.'),
]

POHVALI = [
    'Малкото -s вече те слуша! ✨',
    'Браво! Почти всичко е вярно. \U0001F44F',
    'Добро начало — виж кои редове светят в червено и ги оправи. \U0001F4AA',
]
