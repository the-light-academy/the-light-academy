#!/usr/bin/env python3
"""Unit 1 · Speaking — „Excuse me, where’s the museum?“.

Страница 18 от учебника: как се пита и как се казва КЪДЕ е едно място.
Говоренето не може да се провери от машина, затова листът го пренася на
хартия: предлозите за място, учтивият въпрос и редът на думите в него,
а накрая четири отговора с цели изречения, които чете преподавателят.
"""

#  p18 · Предлозите за място.
PREDLOZI = [
    ['до', 'next to'],
    ['срещу', 'opposite'],
    ['между', 'between'],
    ['зад', 'behind'],
    ['пред', 'in front of'],
    ['близо до', 'near'],
    ['на ъгъла на', 'on the corner of'],
    ['в края на', 'at the end of'],
]

#  Кой предлог пасва. В скобите стои обяснението на картинката, за да се
#  избира по смисъл, а не по звучене.
#  (изречение, отговор, двата избора, защо)
KUDE = [
    ('The bank is ___ the post office and the café. It is in the middle.',
     'between', ['between', 'behind'],
     'between е между ДВЕ неща — затова са изброени две.'),
    ('The bus stop is ___ the school. You cross the road and you are there.',
     'opposite', ['opposite', 'next to'],
     'Пресичаш улицата значи отсреща: opposite.'),
    ('There is a car park ___ the supermarket. You cannot see it from the street.',
     'behind', ['behind', 'in front of'],
     'Не се вижда от улицата значи отзад: behind.'),
    ('The chemist’s is ___ the bank. The two buildings are side by side.',
     'next to', ['next to', 'between'],
     'Едно до друго значи next to.'),
    ('There are two big trees ___ the house. You see them first.',
     'in front of', ['in front of', 'behind'],
     'Виждаш ги първи значи отпред: in front of.'),
    ('The hotel is ___ Green Street. Two streets meet there.',
     'on the corner of', ['on the corner of', 'at the end of'],
     'Където две улици се срещат, е ъгъл: on the corner of.'),
]

#  p18 · Key phrases — редът на думите в учтивия въпрос и в отговора.
#  (разбъркано, вярното, защо)
FRAZI = [
    ('train / station / me, / Excuse / where’s / the / ?',
     'Excuse me, where’s the train station?',
     'Учтивият въпрос тръгва с Excuse me, после въпросителната дума.'),
    ('bank / a / near / Is / there / here / ?',
     'Is there a bank near here?',
     'Във въпроса is застава пред there.'),
    ('the / to / It’s / post / next / office / .',
     'It’s next to the post office.',
     'Отговорът тръгва с It’s, после предлогът и мястото.'),
    ('and / Go / left / straight / turn / on / .',
     'Go straight on and turn left.',
     'Две упътвания се свързват с and — първо посоката, после завоят.'),
    ('cinemas / your / How / are / in / many / there / town / ?',
     'How many cinemas are there in your town?',
     'How many + съществителното върви слято, чак после are there.'),
    ('for / Thank / you / your / much / help / very / .',
     'Thank you very much for your help.',
     'very much следва веднага след Thank you.'),
]

#  Кратки разговори с една липсваща дума.
#  (изречение с ___, отговор, други приети, защо)
RAZGOVORI = [
    ('A: Excuse me, is there a bank ___ here?  B: Yes, there is.',
     'near', [], 'near here значи „наблизо“ — стои накрая на въпроса.'),
    ('A: Where’s the cinema?  B: It’s ___ to the park.',
     'next', [], 'next to е предлог от две думи — тук липсва първата.'),
    ('A: Is there a café in this street?  B: Yes, it’s ___ the corner.',
     'on', [], 'on the corner — ъгълът иска on.'),
    ('A: Where’s the bus stop?  B: It’s ___ front of the school.',
     'in', [], 'in front of — предлогът е от три думи и започва с in.'),
    ('A: Thanks a lot!  B: You’re ___.',
     'welcome', [], 'You’re welcome е готовият отговор на благодарност.'),
    ('A: ___ me, where’s the museum?  B: It’s over there.',
     'Excuse', [], 'Excuse me отваря учтивия въпрос към непознат. '
     'Двигателят не гледа главни и малки букви.'),
]

#  Намери сгрешената дума. Всяко изречение има ТОЧНО една грешка —
#  или подменена дума, или една дума в повече.
#  (сгрешено, вярно, защо)
GRESHKI = [
    ('Excuse me, where are the museum?',
     'Excuse me, where is the museum?',
     'museum е едно нещо, значи is, не are.'),
    ('Is there some bank near here?',
     'Is there a bank near here?',
     'Едно нещо във въпрос иска a, не some.'),
    ('The café is opposite to the park.',
     'The café is opposite the park.',
     'opposite не иска to след себе си.'),
    ('The bank is between the café or the shop.',
     'The bank is between the café and the shop.',
     'between свързва двете места с and.'),
    ('Excuse me, how much cinemas are there?',
     'Excuse me, how many cinemas are there?',
     'Броими неща се броят с how many, не с how much.'),
    ('The hotel is on the corner in Green Street.',
     'The hotel is on the corner of Green Street.',
     'on the corner OF — ъгълът е НА улицата.'),
    ('Is there any swimming pool near here?',
     'Is there a swimming pool near here?',
     'Едно нещо във въпрос иска a; any е за повече неща.'),
    ('They are a lot of shops in the square.',
     'There are a lot of shops in the square.',
     'За съществуване се казва There are, а не They are.'),
]

#  Четири отговора с цели изречения — чете ги преподавателят.
SVOBODNI = [
    ('A friend comes to your town for one day. Where do you take them? '
     'Write two sentences with there is / there are.',
     'There is a beautiful old castle in my town. There are also some nice '
     'cafés in the square.'),
    ('You are in a new town and you want a café. Write TWO questions you can ask.',
     'Excuse me, is there a café near here? Where is it, please?'),
    ('Where is your school? Write two sentences and use two different '
     'prepositions (next to, opposite, near, between, behind).',
     'My school is next to the park. It is opposite the bus station.'),
    ('A tourist asks you: “Excuse me, is there a post office near here?” '
     'Write your answer in one or two sentences.',
     'Yes, there is. It’s on the corner of Main Street, opposite the bank.'),
]
