#!/usr/bin/env python3
"""Unit 1 · English Plus options — „Extra“.

Четирите допълнителни страници към юнита, събрани на един лист:

  p92  Extra listening and speaking: лични данни — име, фамилия, възраст,
       телефон, откъде си и как се казва буква по буква.
  p100 Curriculum Extra · Geography: четене на карта — посоките.
  p106 Culture: Обединеното кралство — четирите страни и столиците им.
  p116 Song: „I’m the King“.

Всички факти тук са проверими: столици, брой страни, посоки. Проверката
ги сверява с отделен списък, написан на ръка, а не с този файл.
"""

#  p106 · Culture — страна и столица.
STOLICI = [
    ['England', 'London'],
    ['Scotland', 'Edinburgh'],
    ['Wales', 'Cardiff'],
    ['Northern Ireland', 'Belfast'],
    ['Bulgaria', 'Sofia'],
]

#  p100 · Geography — посоките върху картата.
#  (изречение, отговор, двата избора, защо)
POSOKI = [
    ('Scotland is in the ___ of Great Britain.', 'north', ['north', 'south'],
     'Шотландия е най-отгоре на острова.'),
    ('Wales is in the ___ of Great Britain.', 'west', ['west', 'east'],
     'Уелс е отляво на картата, тоест на запад.'),
    ('London is in the ___ of England.', 'south-east',
     ['south-east', 'north-west'],
     'Лондон е долу вдясно — югоизток.'),
    ('Varna is in the ___ of Bulgaria.', 'east', ['east', 'west'],
     'Варна е на Черно море, вдясно на картата.'),
    ('Greece is in the ___ of Bulgaria.', 'south', ['south', 'north'],
     'Гърция е под България.'),
    ('Romania is in the ___ of Bulgaria.', 'north', ['north', 'south'],
     'Румъния е над България, отвъд Дунав.'),
]

#  p92 · Лични данни — липсващата дума в разговора.
#  (изречение, отговор, други приети, защо)
LICHNI = [
    ('A: What’s your ___ name?   B: Kalina.', 'first', [],
     'first name е малкото име.'),
    ('A: What’s your ___?   B: Ilieva.', 'surname', ['family name'],
     'surname е фамилното име.'),
    ('A: How do you ___ it?   B: I-L-I-E-V-A.', 'spell', [],
     'spell значи „кажи буква по буква“.'),
    ('A: What’s your phone ___?   B: 0888 123 456.', 'number', [],
     'phone number — телефонен номер.'),
    ('A: How ___ are you?   B: I’m twelve.', 'old', [],
     'How old are you? пита за възраст.'),
    ('A: Where are you ___?   B: I’m from Bulgaria.', 'from', [],
     'Where are you from? пита откъде си.'),
    ('A: What’s your ___ address?   B: kalina@mail.bg', 'email', ['e-mail'],
     'email address — електронна поща.'),
]

#  p106 · Culture quiz. (изречение, отговор, двата избора, защо)
VIKTORINA = [
    ('The capital city of the United Kingdom is ___.',
     'London', ['London', 'Manchester'],
     'Лондон е столицата на цялото кралство.'),
    ('The flag of the UK is called the ___ Jack.',
     'Union', ['Union', 'Royal'],
     'Union Jack — знамето събира кръстовете на три страни.'),
    ('People in Wales speak English and ___.',
     'Welsh', ['Welsh', 'Irish'],
     'Езикът на Уелс се казва Welsh (уелски).'),
    ('The United Kingdom has ___ countries.',
     'four', ['four', 'three'],
     'England, Scotland, Wales и Northern Ireland — четири.'),
    ('Big Ben is in ___.',
     'London', ['London', 'Edinburgh'],
     'Big Ben е часовниковата кула до парламента в Лондон.'),
    ('The longest river in the UK is the ___.',
     'Severn', ['Severn', 'Thames'],
     'Темза е по-известна, но Севърн е по-дълга — 354 км.'),
]

#  p116 · Song „I’m the King“ — редът на думите в припева.
#  (разбъркано, вярното, защо)
PESEN = [
    ('I’m / the / castle / the / king / of / .',
     'I’m the king of the castle.',
     'I’m + the king, после чий е замъкът.'),
    ('big / castle / a / hill / on / the / There’s / .',
     'There’s a big castle on the hill.',
     'There’s + a + прилагателно + съществително, накрая мястото.'),
    ('I / Can / in / come / ?',
     'Can I come in?',
     'Във въпрос с can глаголът застава пред I.'),
    ('is / Who / door / at / the / ?',
     'Who is at the door?',
     'Who пита за човек и стои най-отпред.'),
]

#  Свободните отговори — чете ги преподавателят.
SVOBODNI = [
    ('Introduce yourself in four sentences: your first name, your surname, '
     'your age and where you are from.',
     'My first name is Maria. My surname is Petrova. I’m twelve years old. '
     'I’m from Bulgaria.'),
    ('Write THREE sentences about the United Kingdom. Use the facts from '
     'this worksheet.',
     'The United Kingdom has four countries. The capital city is London. '
     'People in Wales speak English and Welsh.'),
    ('Look at a map of Bulgaria. Write TWO sentences with north, south, east '
     'or west.',
     'Varna is in the east of Bulgaria. Blagoevgrad is in the south-west.'),
]
