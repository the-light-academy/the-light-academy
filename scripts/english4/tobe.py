#!/usr/bin/env python3
"""„MONSTER FAMILY ALBUM“ — домашно по английски за 4. клас.

Темата е глаголът to be: am, is, are — спрежението на „съм“. Десет
упражнения, подредени от лесно към по-трудно, около едно семейство
чудовища: Momo, Gigi, близнаците Zig и Zag и котката Pixel.

Героите и техните форми (нужни и за проверката):
    Momo   — момче  (he  → is)
    Gigi   — момиче (she → is)
    Pixel  — котка  (it  → is)
    Zig and Zag — близнаци (they → are)

  vid = 'tap'      избира се думата с щракане
        'type'     думата или изречението се пише
        'dvoiki'   свързване: българско ↔ английско
        'red'      подреждане на разбъркани думи

Отговорите не се проверяват „на око“: scripts/check_english4.py ги
извежда наново от правилото за съгласуване (I → am, you/we/they → are,
he/she/it → is) и от правилата за кратка форма, отрицание и въпрос.
"""

UPRAJNENIQ = [
    {
        'kod': '1',
        'ime': 'MEET THE MONSTERS',
        'bg': 'Запознай се с чудовищата',
        'ukazanie': 'Щракни върху вярната дума: am, is или are.',
        'vid': 'tap',
        'izbori': ['am', 'is', 'are'],
        'redove': [
            {'predi': 'I', 'sled': 'a little monster.', 'otgovor': 'am'},
            {'predi': 'You', 'sled': 'my best friend.', 'otgovor': 'are'},
            {'predi': 'Gigi', 'sled': 'very tall.', 'otgovor': 'is'},
            {'predi': 'Zig and Zag', 'sled': 'twins.', 'otgovor': 'are'},
            {'predi': 'It', 'sled': 'a chocolate cookie.', 'otgovor': 'is'},
            {'predi': 'We', 'sled': 'a happy family.', 'otgovor': 'are'},
        ],
        'zashto': 'I винаги иска am. You, we и they искат are. He, she и it искат is.',
    },
    {
        'kod': '2',
        'ime': "MOMO'S DIARY",
        'bg': 'Дневникът на Момо',
        'ukazanie': 'Напиши am, is или are в празното място.',
        'vid': 'type',
        'redove': [
            {'predi': 'My name', 'sled': 'Momo.', 'otgovor': 'is'},
            {'predi': 'I', 'sled': 'seven years old.', 'otgovor': 'am'},
            {'predi': 'My brothers', 'sled': 'noisy.', 'otgovor': 'are'},
            {'predi': 'You', 'sled': 'in my photo album.', 'otgovor': 'are'},
            {'predi': 'The cat', 'sled': 'purple.', 'otgovor': 'is'},
        ],
        'zashto': 'Гледай КОЙ върши действието. „My brothers“ са повече от един — are. '
                  '„The cat“ е един — is.',
    },
    {
        'kod': '3',
        'ime': 'SQUEEZE IT!',
        'bg': 'Скъси го',
        'ukazanie': 'Напиши късата форма. Пример: I am → I’m',
        'vid': 'type',
        'redove': [
            {'predi': 'I am', 'sled': '', 'otgovor': "I'm"},
            {'predi': 'you are', 'sled': '', 'otgovor': "you're"},
            {'predi': 'they are', 'sled': '', 'otgovor': "they're"},
            {'predi': 'she is', 'sled': '', 'otgovor': "she's"},
            {'predi': 'we are', 'sled': '', 'otgovor': "we're"},
        ],
        'zashto': 'Апострофът застава там, където е изядена буква: I am → I’m (изчезва a).',
    },
    {
        'kod': '4',
        'ime': 'SAY NO!',
        'bg': 'Кажи НЕ',
        'ukazanie': 'Направи изречението отрицателно. Напиши го цялото.',
        'vid': 'type',
        'dalgo': True,
        'redove': [
            {'predi': 'I am hungry.', 'sled': '', 'otgovor': 'I am not hungry.',
             'oshte': ["I'm not hungry."]},
            {'predi': 'You are late.', 'sled': '', 'otgovor': 'You are not late.',
             'oshte': ["You're not late.", "You aren't late."]},
            {'predi': 'They are sad.', 'sled': '', 'otgovor': 'They are not sad.',
             'oshte': ["They're not sad.", "They aren't sad."]},
            {'predi': 'Gigi is small.', 'sled': '', 'otgovor': 'Gigi is not small.',
             'oshte': ["Gigi isn't small.", "Gigi's not small."]},
        ],
        'zashto': 'Отрицанието е лесно: NOT застава веднага след am, is или are.',
    },
    {
        'kod': '5',
        'ime': 'ASK ME!',
        'bg': 'Попитай',
        'ukazanie': 'Направи въпрос от изречението. Не забравяй въпросителния знак.',
        'vid': 'type',
        'dalgo': True,
        'redove': [
            {'predi': 'You are a robot.', 'sled': '', 'otgovor': 'Are you a robot?'},
            {'predi': 'They are hungry.', 'sled': '', 'otgovor': 'Are they hungry?'},
            {'predi': 'I am late.', 'sled': '', 'otgovor': 'Am I late?'},
            {'predi': 'Momo is funny.', 'sled': '', 'otgovor': 'Is Momo funny?'},
        ],
        'zashto': 'При въпрос am, is и are скачат най-отпред и си разменят мястото с подлога.',
    },
    {
        'kod': '6',
        'ime': 'SHORT ANSWERS',
        'bg': 'Кратките отговори',
        'ukazanie': 'Щракни върху верния кратък отговор.',
        'vid': 'tap',
        'shirok': True,
        'redove': [
            {'predi': 'Are you a monster?', 'sled': '(YES)', 'otgovor': 'Yes, I am.',
             'izbori': ['Yes, I am.', 'Yes, I is.', 'Yes, you are.']},
            {'predi': 'Are they twins?', 'sled': '(NO)', 'otgovor': "No, they aren't.",
             'izbori': ["No, they aren't.", "No, they isn't.", "No, we aren't."]},
            {'predi': 'Is Gigi green?', 'sled': '(YES)', 'otgovor': 'Yes, she is.',
             'izbori': ['Yes, she is.', 'Yes, she are.', 'Yes, he is.']},
            {'predi': 'Am I funny?', 'sled': '(YES)', 'otgovor': 'Yes, you are.',
             'izbori': ['Yes, you are.', 'Yes, I am.', 'Yes, you is.']},
        ],
        'zashto': 'В краткия отговор не се повтаря цялото изречение — само подлогът и '
                  'глаголът. И внимавай: на „Are you…?“ се отговаря с I, не с you.',
    },
    {
        'kod': '7',
        'ime': 'CATCH THE MISTAKE',
        'bg': 'Хвани грешката',
        'ukazanie': 'Всяко изречение има една сгрешена дума. Напиши вярната.',
        'vid': 'type',
        'redove': [
            {'predi': 'They is hungry.', 'sled': '', 'otgovor': 'are'},
            {'predi': 'I are a monster.', 'sled': '', 'otgovor': 'am'},
            {'predi': 'Gigi am tall.', 'sled': '', 'otgovor': 'is'},
            {'predi': 'The cats is sleeping.', 'sled': '', 'otgovor': 'are'},
            {'predi': 'You is my friend.', 'sled': '', 'otgovor': 'are'},
        ],
        'zashto': 'Първо намери подлога, после сложи неговата форма. Подлогът командва глагола.',
    },
    {
        'kod': '8',
        'ime': 'BULGARIAN ↔ ENGLISH',
        'bg': 'Свържи двойките',
        'ukazanie': 'Свържи българското с английското: щракни отляво, после отдясно.',
        'vid': 'dvoiki',
        'dvojki': [
            ['Аз съм', 'I am'],
            ['Ти си', 'You are'],
            ['Той е', 'He is'],
            ['Тя е', 'She is'],
            ['Ние сме', 'We are'],
            ['Те са', 'They are'],
        ],
        'zashto': 'Цялото спрежение на едно място: I am · you are · he/she/it is · '
                  'we are · you are · they are.',
    },
    {
        'kod': '9',
        'ime': 'MONSTER PUZZLE',
        'bg': 'Подреди думите',
        'ukazanie': 'Щракай думите по ред, за да стане изречение.',
        'vid': 'red',
        'redove': [
            {'otgovor': 'I am not a robot.'},
            {'otgovor': 'Are you tired?'},
            {'otgovor': 'They are my friends.'},
            {'otgovor': 'Pixel is a cat.'},
        ],
        'zashto': 'В английското изречение редът е строг: първо подлогът, после глаголът — '
                  'освен при въпрос, където глаголът изскача отпред.',
    },
    {
        'kod': '10',
        'ime': '★ MONSTER ID CARD',
        'bg': 'Картата на чудовището',
        'ukazanie': 'Попълни цялата карта с am, is или are.',
        'vid': 'type',
        'redove': [
            {'predi': 'Hello! My name', 'sled': 'Momo.', 'otgovor': 'is'},
            {'predi': 'I', 'sled': 'eight years old.', 'otgovor': 'am'},
            {'predi': 'My sisters', 'sled': 'Gigi and Lulu.', 'otgovor': 'are'},
            {'predi': 'They', 'sled': 'very funny.', 'otgovor': 'are'},
            {'predi': 'Our cat', 'sled': 'purple.', 'otgovor': 'is'},
            {'predi': 'We', 'sled': 'a monster family!', 'otgovor': 'are'},
        ],
        'zashto': 'Шест реда, три различни форми. Ако ги улучиш всичките, спрежението ти е в джоба.',
    },
]

#  Героите и техните местоимения — проверката ги ползва, за да изведе
#  вярната форма, вместо да вярва на написаното.
GEROI = {'Momo': 'he', 'Gigi': 'she', 'Lulu': 'she', 'Pixel': 'it',
         'Zig and Zag': 'they'}

POHVALI = [
    'Чудовищата ти ръкопляскат! 🎉',
    'Браво! Почти всичко е вярно. 👏',
    'Добро начало — виж кои редове светят в червено и ги оправи. 💪',
]
