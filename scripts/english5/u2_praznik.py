#!/usr/bin/env python3
"""Unit 2, лист 3 — „Special Days“.

Речникът на празниците, изразите за предложение и отговор на
предложение, мястото на also и един цял текст за Баба Марта.

Накрая има четири въпроса със свободен отговор: те не се проверяват
автоматично, а отиват при преподавателя за ръчна оценка — точно както
при разказа от Unit 1.
"""

SLUG = 'en5-u2-special'
FAIL = 'homework_5_en_u2_special.html'
IME = 'Special Days'
H1 = 'Special Days<br /><em>Unit 2</em> — celebrations and plans'
PODNASLOV = ('Рождени дни, Баба Марта и как се казва „Хайде да…“ на '
             'английски. Седем упражнения — последното го чете '
             'преподавателят.')
OPISANIE = ('Домашно по английски за 5. клас, Unit 2: празниците, изразите '
            'за предложение, мястото на also и текст за Баба Марта.')
SHAPKA = 'praznik'

#  1 · Думите на празника
DVOJKI = [
    ['пея', 'sing'],
    ['танцувам', 'dance'],
    ['нося (дреха)', 'wear'],
    ['подарявам', 'give'],
    ['получавам', 'get'],
    ['празнувам', 'celebrate'],
    ['украсявам', 'decorate'],
    ['гостувам на', 'visit'],
]

#  2 · Кой глагол: (изречение, верен, другите два, защо)
GLAGOLI = [
    ('On my birthday I __ a lot of presents.', 'get', ['give', 'wear'],
     'Подаръците се ПОЛУЧАВАТ на рождения ден → get.'),
    ('We __ “Happy Birthday” together.', 'sing', ['dance', 'wear'],
     'Песен се пее → sing.'),
    ('My mum __ the house with flowers.', 'decorates', ['visits', 'gives'],
     'Къщата се украсява → decorate, а my mum е she → decorates.'),
    ('On the first of March we __ a martenitsa.', 'wear', ['sing', 'get'],
     'Мартеницата се носи на дрехата → wear.'),
    ('At Christmas we __ our grandparents.', 'visit', ['dance', 'wear'],
     'На гости се ходи → visit.'),
    ('At the party everybody __ until midnight.', 'dances', ['wears', 'gets'],
     'На парти се танцува, а everybody е ЕДИН → dances.'),
]

#  3 · Изразите за предложение
PLANOVE = [
    ('__ go to the cinema!', 'Let’s', ['How about', 'Why don’t'],
     'Let’s + глагол в основна форма: Let’s go!'),
    ('__ about a pizza?', 'How', ['Let’s', 'Shall'],
     'How about + съществително или -ing: How about a pizza?'),
    ('__ don’t we meet at six?', 'Why', ['How', 'Let’s'],
     'Why don’t we…? е въпрос, но значи предложение.'),
    ('__ we invite Daisy?', 'Shall', ['Let’s', 'How'],
     'Shall we…? пита дали да го направим заедно.'),
    ('Do you __ to come with us?', 'want', ['like', 'let'],
     'Do you want to + глагол — най-прякото предложение.'),
    ('That’s a good __ !', 'idea', ['day', 'time'],
     'That’s a good idea — така се приема предложение.'),
]

#  4 · Да или не на предложението
OTGOVORI = [
    ('“Let’s go to the park!”', 'Good idea!',
     ['No, I don’t.', 'Yes, I am.'],
     'На предложение се отговаря с предложение, не с Yes, I am.'),
    ('“Shall we meet at five?”', 'Yes, let’s.',
     ['Yes, I do.', 'Yes, I am.'],
     'На Shall we…? се отговаря Yes, let’s.'),
    ('“Do you want to come?”', 'Yes, I’d love to.',
     ['Yes, it is.', 'Yes, I can.'],
     'I’d love to значи „с удоволствие“.'),
    ('“How about a film tonight?”', 'Sorry, I can’t.',
     ['Sorry, I don’t.', 'Sorry, I’m not.'],
     'Отказва се учтиво със Sorry, I can’t.'),
    ('“Why don’t we study together?”', 'That’s a great idea.',
     ['That’s a great day.', 'That is me.'],
     'Пак се приема с idea.'),
]

#  5 · Мястото на also: пред главния глагол, но СЛЕД be
ALSO = [
    ('also / I / chocolate / like', 'I also like chocolate.'),
    ('is / she / my / also / friend', 'She is also my friend.'),
    ('also / we / classes / have / on / Saturday',
     'We also have classes on Saturday.'),
    ('sing / they / and / also / dance', 'They also sing and dance.'),
    ('brother / the / also / my / guitar / plays',
     'My brother also plays the guitar.'),
]

#  6 · Баба Марта — цял текст с осем празни места
KUTIQ = ['celebrate', 'brings', 'gets', 'makes', 'wear', 'don’t', 'say', 'is']

TEKST = """On the first of March Bulgarians {1} a very special day: Baba Marta.
Baba Marta {2} the spring.
Every child {3} a martenitsa — a small red and white present.
My grandmother {4} our martenitsas at home.
We {5} them on our clothes.
We {6} take them off until we see a stork.
People {7} “Chestita Baba Marta!” to each other.
It {8} a day for health, for luck and for the spring."""

#  (номер, отговор, подлог, защо)
DUPKI = [
    (1, 'celebrate', 'Bulgarians',
     'Bulgarians са много → глаголът остава без -s.'),
    (2, 'brings', 'Baba Marta',
     'Baba Marta е she → brings.'),
    (3, 'gets', 'Every child',
     'Every child е ЕДИН → gets, с -s.'),
    (4, 'makes', 'My grandmother',
     'My grandmother е she → makes.'),
    (5, 'wear', 'We',
     'We са повече от един → глаголът остава wear, без -s.'),
    (6, 'don’t', 'We',
     'Отрицание при we → don’t, а глаголът остава take.'),
    (7, 'say', 'People',
     'People са много → say, без -s.'),
    (8, 'is', 'It',
     'It е едно нещо → формата на be за него е is.'),
]

#  7 · Свободните отговори — чете ги преподавателят
SVOBODNI = [
    ('What is your favourite special day?',
     'My favourite special day is my birthday.'),
    ('When is it?',
     'It is on the twelfth of June.'),
    ('What do you do on this day?',
     'I have a party with my friends. We sing, dance and eat cake.'),
    ('What do you wear and what do you eat?',
     'I wear my new dress and we eat chocolate cake and fruit.'),
]

POHVALI = [
    'Честита Баба Марта! \U0001F389',
    'Браво! Почти всичко е вярно. \U0001F44F',
    'Добро начало — виж кои редове светят в червено и ги оправи. \U0001F4AA',
]
