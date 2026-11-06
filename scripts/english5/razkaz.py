#!/usr/bin/env python3
"""Лист 1 — „The Lost Backpack“: историята с двайсетте празни места.

Текстът е дума по дума от домашното на Кали за 12 ноември. Празните
места са означени с {1} … {20} и остават точно там, където са в
листа.

ТРИ МЕСТА, КЪДЕТО WORD BOX-ЪТ НЕ СТИГА
Кутията с думи в оригинала е с 20 думи за 20 празни места, но три от
тях искат форма, която я няма вътре:

  {14} „…but the backpack ___ got an ID card.“  →  hasn't
       (в кутията стои haven't got — то е за they/we, не за backpack)
  {19} „Yes, I ___!“                             →  have
  {20} „You ___ been very kind!“                 →  have

Затова в кутията са добавени hasn't и have, а указанието казва
честно, че не всички думи се използват и че някои се повтарят.
Останалите седемнайсет празни места са точно по кутията.
"""

#  Кутията с думи — както е в листа, плюс двете добавени форми.
KUTIQ = ['has got', 'hasn’t', 'have got', 'haven’t got', 'have',
         'is', 'are', 'any', 'some', 'this', 'those', 'but', 'and', 'where',
         'British', 'expensive', 'old', 'interesting', 'library', 'café',
         'park', 'shops']

TEKST = """Tom and Mia live in a small town in England. They are {1}, and they love exploring their town.
Their town isn’t very big, {2} it is very nice. There {3} a beautiful {4} in the centre, and there {5} some nice cafés and {6}.
One Saturday, Tom and Mia are walking through the park when they see an {7} backpack under a tree.
“Look at {8} backpack!” says Tom.
“Who does it belong to?” asks Mia.
They open it carefully. Inside, there are {9} books, a mobile phone and a very {10} camera.
“Wow! The owner {11} a really good camera!” says Tom.
Mia looks at the books.
“{12} books are about Japan. They’re really {13}.”
They look for a name, but the backpack {14} got an ID card.
“What can we do?” asks Tom.
“Let’s go to the {15}. Maybe someone there knows who owns it.”
At the library, Mia asks:
“Have you got {16} information about this backpack?”
The librarian looks at the backpack.
“Yes! A student came here this morning looking for it.”
“{17} is the student now?” asks Tom.
“At the {18} next to the park.”
Tom and Mia run there. A student is sitting at a table.
“Have you lost a backpack?” asks Mia.
“Yes, I {19}! It’s mine!”
Tom gives back the backpack.
“Thank you!” says the student. “You {20} been very kind!”
Tom smiles.
“And now we’ve got a new friend!”"""

#  Отговорите: номер → (вярното, и какво още се приема, и защо).
OTGOVORI = [
    (1,  'British',     [],
     'They live in England, so they are British — the nationality, not the country.'),
    (2,  'but',         [],
     'Two opposite ideas — small, yet nice. That is what but is for.'),
    (3,  'is',          [],
     'There is + one thing: a beautiful park.'),
    (4,  'park',        [],
     'Later they are walking through the park, so the park is in the centre.'),
    (5,  'are',         [],
     'There are + more than one: some nice cafés and shops.'),
    (6,  'shops',       [],
     'The only plural place left in the Word Box.'),
    (7,  'old',         [],
     'an + a vowel sound: an old backpack. Expensive is needed for the camera '
     'and interesting for the books.'),
    (8,  'this',        [],
     'The backpack is right in front of them — one thing, close: this backpack.'),
    (9,  'some',        [],
     'A positive sentence with a plural noun takes some.'),
    (10, 'expensive',   [],
     'a very expensive camera — a is correct before a consonant sound.'),
    (11, 'has got',     ['has'],
     'The owner is he or she — one person — so has got, not have got.'),
    (12, 'those',       [],
     'More than one book, and Mia is pointing at them: those books.'),
    (13, 'interesting', [],
     'They’re really interesting — an adjective after the verb be.'),
    (14, 'hasn’t', ['hasnt', 'has not'],
     'The backpack is one thing, so hasn’t got. The Word Box only has '
     'haven’t got, which is for we, you and they.'),
    (15, 'library',     [],
     'The next line says “At the library, Mia asks…”'),
    (16, 'any',         [],
     'A question takes any: Have you got any information?'),
    (17, 'Where',       [],
     'The answer is a place — “At the café” — so the question word is Where.'),
    (18, 'café',   ['cafe'],
     'A place next to the park where a student can sit at a table.'),
    (19, 'have',        [],
     'Short answer to “Have you lost…?” — Yes, I have. Not the whole verb again.'),
    (20, 'have',        [],
     'You have been very kind — have for you, and been after it.'),
]

#  ⭐ Bonus Challenge — пише се със свободен текст и се проверява на ръка.
BONUS = [
    ('Where do Tom and Mia live?',
     'They live in a small town in England.'),
    ('What do they find in the park?',
     'They find an old backpack under a tree.'),
    ('What is inside the backpack?',
     'Inside the backpack there are some books, a mobile phone and a very '
     'expensive camera.'),
    ('Has the backpack got an ID card?',
     'No, it hasn’t. The backpack hasn’t got an ID card.'),
    ('Where do Tom and Mia go first?',
     'They go to the library first.'),
    ('Where is the owner of the backpack?',
     'The owner is at the café next to the park.'),
    ('Which three adjectives are used in the story?',
     'The three adjectives are old, expensive and interesting.'),
]
