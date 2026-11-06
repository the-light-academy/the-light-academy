#!/usr/bin/env python3
"""Лист 4 — „Grammar Mix“: въпросителни думи, and/or/but, there is/are,
отрицания и some/any. Четирите кратки упражнения от домашното, събрани
на един лист.
"""

#  7. Question-Word Challenge — Where, What или Who
VUPROSI = [
    ('__ are you from?', 'Where', [],
     'The answer is a place — a country or a town — so Where.'),
    ('__ is your favourite sport?', 'What', [],
     'A thing, not a person or a place → What.'),
    ('__ is your best friend?', 'Who', [],
     'A person → Who.'),
    ('__ is your school?', 'Where', [],
     'A place → Where.'),
    ('__ is your favourite singer?', 'Who', [],
     'A person → Who.'),
    ('__ nationality are you?', 'What', [],
     'What + a noun asks which one: What nationality…? What colour…?'),
]

#  8. AND, OR or BUT?
SVRUZKI = [
    ('I’ve got a brother __ a sister.', 'and', [],
     'Two things that go together → and.'),
    ('I like football __ basketball.', 'and', [],
     'You like both → and. Or would mean only one of them.'),
    ('I’ve got a phone, __ I haven’t got a tablet.', 'but', [],
     'Have and haven’t pull in opposite directions → but.'),
    ('Are you from Spain __ Italy?', 'or', [],
     'A question with a choice between two → or.'),
    ('My town is small __ beautiful.', 'but', ['and'],
     'But shows the surprise: small, and still beautiful. And is not wrong, '
     'but it loses the contrast.'),
    ('I can speak English __ Bulgarian.', 'and', [],
     'Both languages → and.'),
    ('I’ve got a bicycle, __ it is very old.', 'but', [],
     'Good news, then bad news → but.'),
]

#  10. There is or There are?
IMA = [
    ('__ a cinema near my house.', 'There is', ['There is', 'There are'],
     'a cinema — one thing → There is.'),
    ('__ three cafés in the square.', 'There are', ['There is', 'There are'],
     'Three cafés → There are.'),
    ('__ any hotels here.', 'There aren’t', ['There isn’t', 'There aren’t'],
     'Hotels is plural → There aren’t.'),
    ('__ a train station.', 'There isn’t', ['There isn’t', 'There aren’t'],
     'a train station — one thing → There isn’t.'),
    ('__ some nice parks.', 'There are', ['There is', 'There are'],
     'Parks is plural → There are.'),
    ('__ an old monument in the centre.', 'There is', ['There is', 'There are'],
     'an old monument — one thing → There is.'),
]

#  Turn them negative! (изреченията 1, 2, 5 и 6 отгоре)
OTRICANIQ = [
    ('There is a cinema near my house.',
     'There isn’t a cinema near my house.',
     ['There is not a cinema near my house.'],
     'is → isn’t, nothing else moves.'),
    ('There are three cafés in the square.',
     'There aren’t three cafés in the square.',
     ['There are not three cafés in the square.'],
     'are → aren’t.'),
    ('There are some nice parks.',
     'There aren’t any nice parks.',
     ['There are not any nice parks.'],
     'Careful! In the negative some becomes any.'),
    ('There is an old monument in the centre.',
     'There isn’t an old monument in the centre.',
     ['There is not an old monument in the centre.'],
     'is → isn’t; an stays, because monument still starts with a vowel sound.'),
]

#  11. SOME or ANY?
NQKOI = [
    ('There are __ restaurants near my house.', 'some', [],
     'Positive sentence → some.'),
    ('Are there __ parks?', 'any', [],
     'Question → any.'),
    ('There aren’t __ cinemas.', 'any', [],
     'Negative → any.'),
    ('There are __ shops in the city centre.', 'some', [],
     'Positive sentence → some.'),
    ('Have you got __ cousins?', 'any', [],
     'Question → any.'),
    ('We’ve got __ interesting books.', 'some', [],
     'Positive sentence → some.'),
    ('Are there __ cafés near the station?', 'any', [],
     'Question → any.'),
]
