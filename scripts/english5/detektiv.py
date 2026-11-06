#!/usr/bin/env python3
"""Лист 3 — „Grammar Detective“: намери грешката.

Всяко изречение от домашното има по една сгрешена дума (последното —
две). В листа детето ЩРАКА сгрешената дума, вместо да преписва цялото
изречение: по-бързо е и показва точно какво е видяло.

Затова тук се пази двойката „както е написано“ / „както трябва да
бъде“. Кои думи да светнат при щракане НЕ се пише на ръка — извежда се
от двете изречения, а проверката сверява, че подмяната на точно тези
думи дава вярното изречение.

Две от изреченията в ниво 3 не са сгрешена дума, а объркан ред на
думите. Те не стават за щракане и затова са отделно, като подреждане.
"""

#  (сгрешено, вярно, защо)
NIVA = [
    ('\U0001F7E2 Level 1', 'have got · this, that, these, those', [
        ('I has got a new backpack.', 'I have got a new backpack.',
         'I always takes have got — never has got.'),
        ('She have got two brothers.', 'She has got two brothers.',
         'She is one person → has got.'),
        ('They hasn’t got a pet.', 'They haven’t got a pet.',
         'They is more than one person → haven’t got, never hasn’t got.'),
        ('Have Tom got a mobile phone?', 'Has Tom got a mobile phone?',
         'Tom is he → Has Tom got…?'),
        ('We has got a new teacher.', 'We have got a new teacher.',
         'We is more than one person → have got, just like I, you and they.'),
        ('This books are very interesting.', 'These books are very interesting.',
         'Books is plural, so this becomes these.'),
        ('Those car is very expensive.', 'That car is very expensive.',
         'One car → that, not those.'),
        ('These is my new shoes.', 'These are my new shoes.',
         'These is plural, so the verb is are.'),
    ]),
    ('\U0001F7E1 Level 2', 'there is / there are · some and any', [
        ('There are a nice park near my house.', 'There is a nice park near my house.',
         'a nice park is one thing → There is.'),
        ('There is three cafés in my town.', 'There are three cafés in my town.',
         'Three cafés are more than one → There are.'),
        ('There aren’t a train station here.', 'There isn’t a train station here.',
         'a train station is one thing → There isn’t.'),
        ('There isn’t any restaurants near the school.',
         'There aren’t any restaurants near the school.',
         'Restaurants is plural → There aren’t.'),
        ('There are any good shops in the city centre.',
         'There are some good shops in the city centre.',
         'A positive sentence takes some; any belongs in questions and negatives.'),
        ('Are there some cinemas in your town?', 'Are there any cinemas in your town?',
         'A question takes any.'),
        ('Is there any parks near your house?', 'Are there any parks near your house?',
         'Parks is plural → Are there…?'),
        ('How many restaurant are there in your town?',
         'How many restaurants are there in your town?',
         'How many is always followed by a plural noun.'),
    ]),
    ('\U0001F7E0 Level 3', 'question words · nationalities · two halves', [
        ('Who is your best friend from?', 'Who is your best friend?',
         'One word too many: from belongs to Where are you from?, not here.'),
        ('I am from Brazil and I am Brazilian, but my friend is from Japan and he is Japan.',
         'I am from Brazil and I am Brazilian, but my friend is from Japan and he is Japanese.',
         'Japan is the country; the person is Japanese.'),
        ('Cairo is the Egyptian capital and the pyramids is very famous.',
         'Cairo is the Egyptian capital and the pyramids are very famous.',
         'The pyramids is plural → are.'),
        ('There are some shops in my town, but there isn’t any cafés.',
         'There are some shops in my town, but there aren’t any cafés.',
         'Cafés is plural → there aren’t.'),
        ('My town has got a library and a cinema but there aren’t a sports centre.',
         'My town has got a library and a cinema but there isn’t a sports centre.',
         'a sports centre is one thing → there isn’t.'),
        ('Have your sister got any interesting books?',
         'Has your sister got any interesting books?',
         'Your sister is she → Has… got?'),
    ]),
    ('\U0001F575️ Super Detective', 'slightly trickier — one has TWO mistakes', [
        ('There is some beautiful parks near my school.',
         'There are some beautiful parks near my school.',
         'Parks is plural → There are.'),
        ('My friend hasn’t got a skateboard, but she have got a bicycle.',
         'My friend hasn’t got a skateboard, but she has got a bicycle.',
         'She → has got, in the second half too.'),
        ('How many swimming pool are there in the holiday park?',
         'How many swimming pools are there in the holiday park?',
         'How many + plural: swimming pools.'),
        ('Those students has got some new books.',
         'Those students have got some new books.',
         'Those students is plural → have got.'),
        ('Are there a good restaurant near the train station?',
         'Is there a good restaurant near the train station?',
         'a good restaurant is one thing → Is there…?'),
        ('This shoes are cheap, but those shoes is very expensive.',
         'These shoes are cheap, but those shoes are very expensive.',
         'TWO mistakes: shoes is plural, so this → these, and is → are.'),
    ]),
]

#  Двете изречения с объркан ред на думите — те се подреждат, не се щракат.
REDUT = [
    ('Where you are from?', 'Where are you from?',
     'In a question the verb comes before the person: Where are you…?'),
    ('What your favourite sport is?', 'What is your favourite sport?',
     'Is jumps to the front, right after the question word.'),
]
