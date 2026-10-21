# Правила за работа по този проект

## Файловете за базата — винаги със суров линк

Всеки път, когато има нещо за пускане в Supabase, към отговора върви и
линк към **суровия** текст на файла, за да се копира наведнъж:

```
https://raw.githubusercontent.com/the-light-academy/the-light-academy/main/<път към файла>
```

Например `supabase/probni-otvoreni.sql` →
<https://raw.githubusercontent.com/the-light-academy/the-light-academy/main/supabase/probni-otvoreni.sql>

Линкът сочи към `main` и работи само след като промяната е качена там.

## Какво НЕ се качва в сайта

- `booking.html`, `supabase/schema-v4.sql` и тестът към него стоят само
  на работния клон — не отиват в `main`.
- `matura2025.html` и `matura2024.html` не се линкват никъде в сайта.
- Публичната регистрация в Supabase остава изключена.
- PDF файловете не се променят и не се трият.

## Дребно, но важно

- Умножението в HTML се пише с „·“.
- Ако нещо не е ясно — питай, не гадай.
