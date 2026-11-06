#!/usr/bin/env python3
"""Лист 5 — „Guess the Word“: описанието отгоре, думата отдолу.

Отговорите са ключът, който стои накрая на самото домашно — преписан
дума по дума. Подсказката с първата буква и чертичките НЕ се пише на
ръка: сглобява се от самата дума, за да има толкова чертички, колкото
са буквите. (В листа някои от тях не излизат — „C _ _ _“ за cheap е с
една чертичка по-малко.)
"""

GRUPI = [
    ('\U0001F3D9️ Places in Town', 'places', True, [
        ('You can borrow books from this place.', 'library'),
        ('You go here to watch films.', 'cinema'),
        ('You can have coffee, tea, or a snack here.', 'café'),
        ('You can take a train from this place.', 'train station'),
        ('You can buy many different things here.', 'shop'),
        ('This is a green area where people can walk, play, or relax.', 'park'),
        ('You can watch a play here.', 'theatre'),
        ('People can stay here when they are on holiday.', 'hotel'),
        ('You can eat lunch or dinner here.', 'restaurant'),
        ('This structure helps people or cars cross a river.', 'bridge'),
    ]),
    ('\U0001F4F1 Everyday Objects', 'objects', True, [
        ('You can use this to call someone, send messages, and take photos.',
         'mobile phone'),
        ('You use this to write. It usually has ink.', 'pen'),
        ('You carry books and other things in this.', 'bag'),
        ('You use this to take photographs.', 'camera'),
        ('You can read stories and information in this.', 'book'),
    ]),
    ('\U0001F30D Countries & Nationalities', 'countries', True, [
        ('A person from Spain is …', 'Spanish'),
        ('A person from Japan is …', 'Japanese'),
        ('A person from Brazil is …', 'Brazilian'),
        ('A person from the UK is …', 'British'),
        ('Cairo is the capital of this country.', 'Egypt'),
    ]),
    ('\U0001F3A8 Adjectives', 'adjectives', True, [
        ('The opposite of big.', 'small'),
        ('The opposite of expensive.', 'cheap'),
        ('Something that is not new.', 'old'),
        ('The opposite of fast.', 'slow'),
        ('Something that makes you want to know or learn more.', 'interesting'),
        ('The opposite of popular.', 'unpopular'),
        ('The opposite of good.', 'bad'),
        ('Something that costs a lot of money.', 'expensive'),
    ]),
    ('\U0001F575️ Challenge: No Letters!', 'challenge', False, [
        ('There can be many of these in a city. People live in them, and each '
         'one is part of a larger building.', 'flats'),
        ('You can go here to play football, basketball, or other sports.',
         'sports centre'),
        ('People come here to buy fruit, vegetables, clothes, and other things '
         'from different sellers.', 'market'),
        ('It is usually built to remember an important person or event. You can '
         'often see one in a city square.', 'monument'),
        ('This word connects two opposite ideas: My phone is old, ___ it is very good.',
         'but'),
        ('This word is used in questions and negative sentences: Are there ___ '
         'cafés near here?', 'any'),
    ]),
]
