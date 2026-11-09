#!/usr/bin/env python3
"""Unit 2, лист 1 — „A Day in the Life“.

Речникът на всекидневието, предлозите за време (at / on / in) и
наречията за честота заедно с мястото им в изречението.

Отговорите не се проверяват „на око“: scripts/check_english5_u2.py ги
извежда наново от правилата (кое време иска at, кое on и кое in;
наречието застава пред главния глагол, но СЛЕД be) и чак тогава ги
сравнява с написаното.
"""

SLUG = 'en5-u2-day'
FAIL = 'homework_5_en_u2_day.html'
IME = 'A Day in the Life'
H1 = 'A Day in the Life<br /><em>Unit 2</em> — Days'
PODNASLOV = ('Ставане, училище, домашно, лягане — и трите думички, които '
             'казват КОГА. Пет упражнения: свързваш, щракаш, подреждаш и '
             'попълваш един цял понеделник.')
OPISANIE = ('Домашно по английски за 5. клас, Unit 2: всекидневието, '
            'предлозите at / on / in и наречията за честота.')
SHAPKA = 'den'

#  1 · Всекидневието: българско ↔ английско
DVOJKI = [
    ['ставам', 'get up'],
    ['закусвам', 'have breakfast'],
    ['отивам на училище', 'go to school'],
    ['имам часове', 'have classes'],
    ['уча', 'study'],
    ['пиша домашно', 'do homework'],
    ['гледам телевизия', 'watch TV'],
    ['лягам си', 'go to bed'],
]

#  2 · at, on или in — всяко с вида си, за да се провери по правило
#     vid: 'chas' (точен час), 'den' (ден или дата), 'chast' (част от деня,
#          месец, сезон), 'izklyuchenie' (устойчив израз)
PREDLOZI = [
    ('__ seven o’clock', 'at', 'chas',
     'Точен час → at: at seven o’clock, at half past six.'),
    ('__ Mondays', 'on', 'den',
     'Ден от седмицата → on: on Monday, on Mondays.'),
    ('__ the morning', 'in', 'chast',
     'Част от деня → in: in the morning, in the afternoon, in the evening.'),
    ('__ the weekend', 'at', 'izklyuchenie',
     'At the weekend е устойчив израз — запомня се цял.'),
    ('__ Saturday', 'on', 'den',
     'Ден от седмицата → on, все едно дали е '
     'един ден или всяка събота.'),
    ('__ the evening', 'in', 'chast',
     'Част от деня → in. Но внимавай: at night, не in the night!'),
    ('__ night', 'at', 'izklyuchenie',
     'At night е другото изключение — единствената част от деня с at.'),
    ('__ the first of March', 'on', 'den',
     'Дата → on: on the first of March.'),
]

#  3 · Колко често: наречието и неговият процент
CHESTOTA = [
    ['always', '100%'],
    ['usually', '80%'],
    ['often', '60%'],
    ['sometimes', '30%'],
    ['never', '0%'],
]

#  4 · Мястото на наречието: пред главния глагол, но СЛЕД be
MQSTO = [
    ('I / always / get / up / at / seven',
     'I always get up at seven.',
     'always'),
    ('never / she / is / late / for / school',
     'She is never late for school.',
     'never'),
    ('we / classes / usually / have / at / eight',
     'We usually have classes at eight.',
     'usually'),
    ('TV / they / watch / sometimes / after / dinner',
     'They sometimes watch TV after dinner.',
     'sometimes'),
    ('often / he / tired / is / in / the / evening',
     'He is often tired in the evening.',
     'often'),
    ('homework / never / my / brother / his / does',
     'My brother never does his homework.',
     'never'),
]

#  5 · Понеделникът на Миа — цял текст с десет празни места
KUTIQ = ['gets', 'brushes', 'has', 'goes', 'start', 'have', 'does', 'watches',
         'In', 'at']

TEKST = """Mia {1} up at half past six.
She always {2} her teeth.
Then she {3} breakfast with her family.
At half past seven she {4} to school.
Her classes {5} at eight o’clock.
Mia and her friends {6} lunch at school.
In the afternoon she {7} her homework.
She never {8} TV before dinner.
{9} the evening she reads a book.
She goes to bed {10} nine o’clock."""

#  (номер, отговор, подлог, вид: 'glagol' или 'predlog', защо)
DUPKI = [
    (1, 'gets', 'Mia', 'glagol',
     'Mia е she → глаголът получава -s: gets up.'),
    (2, 'brushes', 'She', 'glagol',
     'brush завършва на -sh → brushes, с -es.'),
    (3, 'has', 'she', 'glagol',
     'have е особен: при she става has.'),
    (4, 'goes', 'she', 'glagol',
     'go завършва на -o → goes, с -es.'),
    (5, 'start', 'Her classes', 'glagol',
     'Her classes са повече от едно → глаголът остава без -s.'),
    (6, 'have', 'Mia and her friends', 'glagol',
     'Двама и повече → have, не has.'),
    (7, 'does', 'she', 'glagol',
     'do при she става does.'),
    (8, 'watches', 'She', 'glagol',
     'watch завършва на -ch → watches.'),
    (9, 'In', None, 'predlog',
     'Част от деня → in the evening.'),
    (10, 'at', None, 'predlog',
     'Точен час → at nine o’clock.'),
]

POHVALI = [
    'Цял един ден на английски — браво! ☀️',
    'Браво! Почти всичко е вярно. \U0001F44F',
    'Добро начало — виж кои редове светят в червено и ги оправи. \U0001F4AA',
]
