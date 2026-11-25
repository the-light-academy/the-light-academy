#!/usr/bin/env python3
"""Сглобява artefakti/urok_7_kapani.html — „Осемте капана“.

Урок за 7. клас по това, което НАИСТИНА се обърква. Осемте таба не са
измислени: всеки идва от анализа на сгрешените задачи в таблото, и то
от начина, по който са сгрешени. Затова над всеки таб стои капанът —
едно изречение за това какво точно се обърква — и чак после правилото
и задачите, подредени от лесни към тежки.

Имена на деца тук няма и не бива да има. Урокът е за капана, не за
този, който е паднал в него.

Страницата е АРТЕФАКТ: няма свои <html>, <head> и <body>.

Задачите стоят в scripts/kapani/zadachi.py, изразите се изчертават от
scripts/grad6/izraz.py в алгебричен запис (49m², не 49 · m²), а
scripts/check_kapani.py ги пресмята наново със sympy.

    /usr/bin/python3.13 scripts/build_kapani.py
"""
import json
import pathlib
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from kapani.zadachi import TABOVE                 # noqa: E402
from grad6.izraz import izobrazi                  # noqa: E402

IZHOD = KOREN / 'artefakti/urok_7_kapani.html'

GLAGOLI = {'uravnenie': 'Решете уравнението', 'izraz': 'Пресметнете',
           'razlagane': 'Разложете на множители', 'tekst': ''}

STRANICA = r"""<title>Осемте капана</title>
<meta name="claude:viewport-fit-sides" content="cover" />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fredoka:wght@500;600;700&family=Nunito:wght@400;600;700;800&display=swap" />
<style>
/* Разположение: една колона — шапка, залепена лента с шестте таба,
   после задачите на отворения таб една под друга. Долу стои лента с
   напредъка, която е и броячът на домашното. */
:root{
  --mastilo:#241B35;        /* тъмно лилаво мастило */
  --mastilo-blqdo:#6E6386;
  --hartiq:#FAF7F2;         /* топла хартия */
  --karta:#FFFFFF;
  --ramka:#E6DFD2;
  --more:#5B3CA8;           /* акцентът — слива */
  --more-meko:#EDE7FB;
  --zlato:#A8431F;          /* капанът — глинено */
  --zlato-meko:#FCEBE2;
  --zeleno:#1C6B46;
  --zeleno-meko:#E3F3EA;
  --senka:265 35% 20%;
}
@media (prefers-color-scheme: dark){
  :root:not([data-theme="light"]){
    --mastilo:#EDE8F6; --mastilo-blqdo:#A99FC2;
    --hartiq:#131021; --karta:#1D1930; --ramka:#342E4A;
    --more:#B6A0F5; --more-meko:#241D3D;
    --zlato:#F09A72; --zlato-meko:#39211A;
    --zeleno:#7CD9A8; --zeleno-meko:#12301F;
    --senka:265 60% 3%;
    color-scheme: dark;
  }
}
:root[data-theme="dark"]{
  --mastilo:#EDE8F6; --mastilo-blqdo:#A99FC2;
  --hartiq:#131021; --karta:#1D1930; --ramka:#342E4A;
  --more:#B6A0F5; --more-meko:#241D3D;
  --zlato:#F09A72; --zlato-meko:#39211A;
  --zeleno:#7CD9A8; --zeleno-meko:#12301F;
  --senka:265 60% 3%;
  color-scheme: dark;
}
*,*::before,*::after{ box-sizing:border-box }
body{
  margin:0; background:var(--hartiq); color:var(--mastilo);
  font-family:'Nunito',system-ui,-apple-system,sans-serif;
  font-size:18px; line-height:1.55; -webkit-text-size-adjust:100%;
  overflow-x:hidden;
}
body::before{
  content:""; position:fixed; inset:0 0 auto; height:env(safe-area-inset-top, 0px);
  z-index:10; background:var(--more);
}
h1,h2,h3{ font-family:'Fredoka',system-ui,sans-serif; margin:0; text-wrap:balance }
button{ font:inherit; cursor:pointer }
[hidden]{ display:none !important }

.ramka{
  max-width:1040px; margin:0 auto;
  padding-left:max(16px, env(safe-area-inset-left, 0px));
  padding-right:max(16px, env(safe-area-inset-right, 0px));
}

/* ── шапка ─────────────────────────────────────────────────────── */
.shapka{ background:var(--more); color:#F6F2FE }
.shapka .ramka{ padding-block:20px 0 }
.nadpis{ font-size:14px; font-weight:800; letter-spacing:.08em;
  text-transform:uppercase; color:#CFC0F7 }
.shapka h1{ font-size:clamp(27px,7vw,42px); line-height:1.06; margin:6px 0 8px }
.shapka p{ margin:0 0 16px; color:#DCD2F8; font-size:clamp(16px,4.2vw,18px);
  max-width:56ch }
.shapka b{ color:#fff }

/* ── лентата с табовете ────────────────────────────────────────── */
.tabove{ position:sticky; top:env(safe-area-inset-top, 0px); z-index:9;
  background:var(--more) }
/*  Шестте таба стоят на един ред и се плъзгат настрани. На телефон
    това спестява два реда височина — а там се гледа урокът. */
.tabove .ramka{ display:flex; gap:6px; padding-block:0; flex-wrap:nowrap;
  overflow-x:auto; scrollbar-width:none; scroll-snap-type:x proximity;
  -webkit-overflow-scrolling:touch }
.tabove .ramka::-webkit-scrollbar{ display:none }
/*  Осем таба не се събират на един ред. На телефон се плъзгат, а на
    по-широк екран минават на два реда и се виждат наведнъж. */
@media (min-width:760px){
  .tabove .ramka{ flex-wrap:wrap; overflow-x:visible; padding-bottom:0 }
  .tab-b{ border-radius:14px 14px 0 0 }
}
.tab-b{ border:none; background:rgba(255,255,255,.14); color:#EEE8FD;
  padding:11px 12px; border-radius:15px 15px 0 0; font-family:'Fredoka',sans-serif;
  font-size:clamp(14.5px,3.9vw,17px); font-weight:600; min-height:50px;
  display:flex; align-items:center; gap:7px; flex:0 0 auto; white-space:nowrap;
  scroll-snap-align:start; transition:background .15s, color .15s }
.tab-b:hover{ background:rgba(255,255,255,.24); color:#fff }
.tab-b[aria-selected="true"]{ background:var(--hartiq); color:var(--mastilo) }
.tab-b .znak{ font-family:'Fredoka',sans-serif; color:#C9B8F5; font-size:17px }
.tab-b[aria-selected="true"] .znak{ color:var(--more) }
.tab-b .broi{ font-family:'Nunito',sans-serif; font-size:12.5px; font-weight:800;
  opacity:.9 }

/* ── идеята на таба ────────────────────────────────────────────── */
.kapan{ background:var(--zlato-meko); border:2px solid var(--zlato);
  border-radius:20px; padding:15px clamp(14px,3.4vw,22px); margin:20px 0 0;
  display:flex; gap:12px; align-items:flex-start }
.kapan .znakche{ flex:0 0 auto; width:34px; height:34px; border-radius:50%;
  background:var(--zlato); color:var(--zlato-meko); display:grid;
  place-items:center; font-family:'Fredoka',sans-serif; font-size:21px;
  font-weight:700; line-height:1 }
.kapan div > b{ display:block; font-family:'Fredoka',sans-serif;
  font-size:14px; letter-spacing:.07em; text-transform:uppercase;
  color:var(--zlato); margin-bottom:3px }
.kapan p{ margin:0; font-size:clamp(16px,4.2vw,18.5px); font-weight:600 }

.ideq{ background:var(--karta); border:1px solid var(--ramka); border-radius:20px;
  padding:18px clamp(14px,3.4vw,22px); margin:20px 0 6px;
  box-shadow:0 10px 28px hsl(var(--senka) / .07) }
.ideq{ margin-top:12px }
.ideq h2{ font-size:clamp(20px,5.2vw,25px); margin-bottom:8px }
.ideq p{ margin:0; color:var(--mastilo-blqdo); font-size:clamp(16px,4.2vw,18px) }
.pravila{ display:flex; flex-wrap:wrap; gap:9px; margin:14px 0 0; padding:0;
  list-style:none }
.pravila li{ background:var(--zlato-meko); border:1.5px dashed var(--zlato);
  color:var(--zlato); border-radius:999px; padding:9px 16px; font-weight:800;
  font-size:clamp(15.5px,4.1vw,19px) }
.stupalo{ margin:18px 0 10px; font-size:14px; font-weight:800;
  letter-spacing:.06em; text-transform:uppercase; color:var(--mastilo-blqdo);
  display:flex; align-items:center; gap:10px }
.stupalo::after{ content:""; flex:1; height:2px; border-radius:2px;
  background:linear-gradient(90deg, var(--more-meko), var(--zlato-meko)) }

/* ── задача ────────────────────────────────────────────────────── */
.zadachi{ display:grid; gap:12px }
.zad{ position:relative; background:var(--karta); border:1px solid var(--ramka);
  border-radius:18px; padding:14px 64px 14px clamp(14px,3.4vw,18px);
  transition:background .15s, border-color .15s }
.zad.reshena{ background:var(--zeleno-meko); border-color:var(--zeleno) }
.zad__n{ font-size:13.5px; font-weight:800; letter-spacing:.05em;
  text-transform:uppercase; color:var(--mastilo-blqdo) }
.izraz{ font-size:clamp(25px,6.5vw,33px); font-weight:700; line-height:1.5;
  margin:8px 0 0; letter-spacing:.01em; overflow-wrap:break-word }
.izraz.dulag{ font-size:clamp(18.5px,4.9vw,22px); font-weight:600;
  line-height:1.5; color:var(--mastilo) }
.izraz sup{ font-size:.58em; vertical-align:super; line-height:0 }
.frac{ display:inline-flex; flex-direction:column; align-items:center;
  vertical-align:middle; text-align:center; margin:0 .2em }
.frac .chis{ padding:0 .3em .06em; border-bottom:.075em solid currentColor }
.frac .znam{ padding:.06em .3em 0 }
.pokaji{ margin-top:12px; border:2px solid var(--more); background:var(--more-meko);
  color:var(--more); border-radius:999px; padding:11px 20px; font-weight:800;
  font-size:16px; min-height:46px }
.pokaji:hover{ filter:brightness(1.04) }
.reshenie{ margin-top:12px; background:var(--hartiq); border:1px solid var(--ramka);
  border-radius:14px; padding:14px 16px }
.reshenie .otg{ font-family:'Fredoka',sans-serif; font-size:clamp(21px,5.4vw,27px);
  color:var(--zeleno); line-height:1.4; overflow-wrap:break-word }
.reshenie .stupki{ margin:8px 0 0; color:var(--mastilo-blqdo);
  font-size:clamp(16px,4.2vw,18px) }
.otmetka{ position:absolute; top:12px; right:12px; width:46px; height:46px;
  border-radius:50%; border:2px solid var(--ramka); background:var(--karta);
  color:var(--ramka); display:grid; place-items:center; font-size:22px;
  font-weight:800; line-height:1; transition:.15s }
.otmetka:hover{ border-color:var(--more); color:var(--more) }
.otmetka[aria-pressed="true"]{ border-color:var(--zeleno);
  background:var(--zeleno-meko); color:var(--zeleno) }

/* ── домашното ─────────────────────────────────────────────────── */
.domashno{ margin:20px 0 0; background:var(--karta); border:2px solid var(--zlato);
  border-radius:20px; padding:18px clamp(14px,3.4vw,22px) }
.domashno h2{ font-size:clamp(20px,5.2vw,25px); color:var(--zlato);
  margin-bottom:6px }
.domashno p{ margin:0 0 10px; color:var(--mastilo-blqdo);
  font-size:clamp(16px,4.2vw,18px) }
.domashno ul{ margin:0; padding-left:1.2em; font-size:clamp(16px,4.2vw,18px) }
.domashno li{ margin:4px 0 }
.domashno b{ color:var(--mastilo) }

.kraj{ margin:20px 0 0; padding:22px; border-radius:20px; text-align:center;
  background:var(--zeleno-meko); border:2px solid var(--zeleno) }
.kraj h2{ font-size:clamp(22px,5.6vw,28px); color:var(--zeleno); margin-bottom:6px }
.kraj p{ margin:0 auto; max-width:46ch }

/* ── долната лента ─────────────────────────────────────────────── */
.dolu{ position:fixed; left:0; right:0; bottom:0; z-index:8;
  background:color-mix(in srgb, var(--hartiq) 93%, transparent);
  backdrop-filter:blur(10px); border-top:1px solid var(--ramka);
  padding-bottom:env(safe-area-inset-bottom, 0px) }
.dolu .ramka{ display:flex; align-items:center; gap:10px; padding-block:10px;
  flex-wrap:wrap }
.lenta{ flex:1; min-width:90px; height:12px; border-radius:999px;
  background:var(--ramka); overflow:hidden }
.lenta i{ display:block; height:100%; width:0; border-radius:999px;
  background:linear-gradient(90deg, var(--more), var(--zeleno));
  transition:width .35s }
.broiach{ font-weight:800; font-size:15px; white-space:nowrap;
  font-variant-numeric:tabular-nums }
.broiach em{ font-style:normal; color:var(--zlato) }
.mal{ border:1.5px solid var(--ramka); background:transparent;
  color:var(--mastilo-blqdo); border-radius:999px; padding:8px 14px;
  font-size:14px; font-weight:700; min-height:40px }
.mal:hover{ border-color:var(--more); color:var(--more) }

:focus-visible{ outline:3px solid var(--more); outline-offset:2px }
@media (prefers-reduced-motion: reduce){ *{ transition:none !important } }
.sled{ height:110px }
</style>

<header class="shapka">
  <div class="ramka">
    <div class="nadpis">Математика · 7. клас</div>
    <h1>Осемте капана</h1>
    <p>Осем места, на които сметката се обърква най-често, и 45 задачи
      към тях — от лесни към тежки. <b>Всеки таб започва с капана:
      какво точно се обърква.</b></p>
  </div>
</header>

<nav class="tabove" aria-label="Теми">
  <div class="ramka" id="tabove" role="tablist"></div>
</nav>

<main class="ramka" id="sudurjanie"></main>
<div class="ramka" id="kutiqDomashno"></div>
<div class="ramka sled"></div>

<div class="dolu">
  <div class="ramka">
    <span class="lenta"><i id="lenta"></i></span>
    <span class="broiach" id="broiach">решени 0 · <em>остават 45</em></span>
    <button class="mal" id="bDomashno" type="button">Какво остава</button>
    <button class="mal" id="bIzchisti" type="button">Изчисти</button>
  </div>
</div>

<script>
__DANNI__
</script>
<script>
"use strict";
/* Урокът се води на дъската: никъде не се въвежда отговор. Всяка задача
   има тикче „решена“ и бутон, който отваря решението. Отметките се
   помнят в този браузър, за да не се губи докъде е стигнал часът. */
var $ = function(s, p){ return (p || document).querySelector(s); };
var $$ = function(s, p){
  return Array.prototype.slice.call((p || document).querySelectorAll(s));
};
function ek(t){
  return String(t).replace(/[&<>"]/g, function(c){
    return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'})[c];
  });
}

var KLYUCH = 'tla-urok-7-kapani';
var S = {};
try { S = JSON.parse(localStorage.getItem(KLYUCH) || '{}') || {}; } catch(e){ S = {}; }
function zapazi(){
  try { localStorage.setItem(KLYUCH, JSON.stringify(S)); } catch(e){}
}

var sega = 0, pokazanoDomashno = false;
var VSICHKI = DANNI.tabove.reduce(function(a, t){ return a + t.zadachi.length; }, 0);
function resheni(t){
  return t.zadachi.filter(function(z){ return S[z.id]; }).length;
}
function vsiResheni(){
  return DANNI.tabove.reduce(function(a, t){ return a + resheni(t); }, 0);
}

function risuvaiTabove(){
  $('#tabove').innerHTML = DANNI.tabove.map(function(t, i){
    return '<button class="tab-b" type="button" role="tab" data-t="' + i + '" '
      + 'aria-selected="' + (i === sega) + '">'
      + '<span class="znak">' + ek(t.znak) + '</span>'
      + '<span>' + ek(t.kratko) + '</span>'
      + '<span class="broi">' + resheni(t) + '/' + t.zadachi.length + '</span>'
      + '</button>';
  }).join('');
  $$('#tabove .tab-b').forEach(function(b){
    b.addEventListener('click', function(){
      sega = +b.dataset.t;
      risuvai();
      var nov = $('#tabove .tab-b[data-t="' + sega + '"]');
      if(nov && nov.scrollIntoView){
        nov.scrollIntoView({ behavior: 'smooth', block: 'nearest',
                             inline: 'center' });
      }
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  });
}

function risuvaiTqlo(){
  var t = DANNI.tabove[sega];
  $('#sudurjanie').innerHTML =
    '<section class="kapan"><span class="znakche">!</span><div>'
    + '<b>Капанът</b><p>' + ek(t.kapan) + '</p></div></section>'
    + '<section class="ideq">'
    + '<h2>' + ek(t.ime) + '</h2>'
    + '<p>' + ek(t.ideya) + '</p>'
    + '<ul class="pravila">' + t.pravila.map(function(p){
        return '<li>' + ek(p) + '</li>'; }).join('') + '</ul>'
    + '</section>'
    + '<div class="stupalo">от по-лесни към по-трудни</div>'
    + '<div class="zadachi">' + t.zadachi.map(function(z, zi){
        return '<article class="zad' + (S[z.id] ? ' reshena' : '') + '" '
          +   'id="z-' + z.id + '">'
          + '<div class="zad__n">Задача ' + (zi + 1)
          +   (z.glagol ? ' · ' + ek(z.glagol) : '') + '</div>'
          + '<p class="izraz' + (z.dulag ? ' dulag' : '') + '">' + z.ekran + '</p>'
          + '<button class="pokaji" type="button" data-p="' + z.id + '" '
          +   'aria-expanded="false" aria-controls="r-' + z.id + '">'
          +   'Покажи решението</button>'
          + '<div class="reshenie" id="r-' + z.id + '" hidden>'
          +   '<div class="otg">' + z.otgovor + '</div>'
          +   '<p class="stupki">' + ek(z.reshenie) + '</p>'
          + '</div>'
          + '<button class="otmetka" type="button" data-o="' + z.id + '" '
          +   'aria-pressed="' + (S[z.id] ? 'true' : 'false') + '" '
          +   'title="Отметни като решена в час" '
          +   'aria-label="Отметни като решена в час">✓</button>'
          + '</article>';
      }).join('') + '</div>';

  $$('.pokaji').forEach(function(b){
    b.addEventListener('click', function(){ pokaji(b); });
  });
  $$('.otmetka').forEach(function(b){
    b.addEventListener('click', function(){ otmetni(b.dataset.o); });
  });
}

/* Домашното е просто това, което НЕ е отметнато — изписано по теми и по
   номера, за да се продиктува накрая на часа. */
function risuvaiDomashno(){
  var kutiq = $('#kutiqDomashno');
  if(!pokazanoDomashno){ kutiq.innerHTML = ''; return; }
  var ostavat = 0;
  var redove = DANNI.tabove.map(function(t){
    var nomera = [];
    t.zadachi.forEach(function(z, i){ if(!S[z.id]) nomera.push(i + 1); });
    ostavat += nomera.length;
    if(!nomera.length) return '<li><b>' + ek(t.ime) + ':</b> няма — този капан е минат</li>';
    return '<li><b>' + ek(t.ime) + ':</b> задачи ' + nomera.join(', ') + '</li>';
  }).join('');
  if(ostavat === 0){
    kutiq.innerHTML = '<div class="kraj"><h2>И осемте капана са минати!</h2>'
      + '<p>И 45-те задачи са решени.</p></div>';
    return;
  }
  kutiq.innerHTML = '<section class="domashno"><h2>Остават '
    + ostavat + (ostavat === 1 ? ' задача' : ' задачи') + '</h2>'
    + '<p>Това са задачите, които още не сме отметнали.</p>'
    + '<ul>' + redove + '</ul></section>';
}

function pokaji(b){
  var kutiq = $('#r-' + b.dataset.p);
  if(!kutiq) return;
  var otvoreno = !kutiq.hidden;
  kutiq.hidden = otvoreno;
  b.setAttribute('aria-expanded', String(!otvoreno));
  b.textContent = otvoreno ? 'Покажи решението' : 'Скрий решението';
}

function otmetni(id){
  if(S[id]) delete S[id]; else S[id] = 1;
  zapazi();
  var zad = $('#z-' + id), b = $('.otmetka[data-o="' + id + '"]');
  if(zad) zad.classList.toggle('reshena', !!S[id]);
  if(b) b.setAttribute('aria-pressed', S[id] ? 'true' : 'false');
  risuvaiTabove();
  risuvaiDomashno();
  osveji();
}

function osveji(){
  var vsi = vsiResheni(), ostavat = VSICHKI - vsi;
  $('#lenta').style.width = Math.round(100 * vsi / VSICHKI) + '%';
  $('#broiach').innerHTML = 'решени ' + vsi + ' · <em>остават '
    + ostavat + '</em>';
}

function risuvai(){ risuvaiTabove(); risuvaiTqlo(); risuvaiDomashno(); osveji(); }

$('#bDomashno').addEventListener('click', function(){
  pokazanoDomashno = !pokazanoDomashno;
  $('#bDomashno').textContent = pokazanoDomashno ? 'Скрий' : 'Какво остава';
  risuvaiDomashno();
  if(pokazanoDomashno){
    $('#kutiqDomashno').scrollIntoView({ behavior: 'smooth', block: 'center' });
  }
});
$('#bIzchisti').addEventListener('click', function(){
  S = {}; zapazi(); risuvai();
});

risuvai();
</script>
"""


def danni():
    tabove = []
    for t in TABOVE:
        zadachi = []
        for z in t['zadachi']:
            proza = bool(z.get('izraz'))
            zadachi.append({
                'id': z['id'],
                'glagol': z.get('glagol', GLAGOLI.get(z['vid'], '')),
                'ekran': z['izraz'] if proza else izobrazi(z['mat'], True, True),
                'dulag': proza,
                'otgovor': z['otgovor'],
                'reshenie': z['reshenie'],
            })
        tabove.append({'kod': t['kod'], 'ime': t['ime'], 'kratko': t['kratko'],
                       'znak': t['znak'], 'kapan': t['kapan'],
                       'ideya': t['ideya'],
                       'pravila': t['pravila'], 'zadachi': zadachi})
    return {'tabove': tabove}


def main() -> None:
    d = danni()
    blok = 'var DANNI = ' + json.dumps(d, ensure_ascii=False, indent=1) + ';'
    stranica = STRANICA.replace('__DANNI__', blok, 1)
    IZHOD.parent.mkdir(parents=True, exist_ok=True)
    IZHOD.write_text(stranica, encoding='utf-8')
    broi = sum(len(t['zadachi']) for t in d['tabove'])
    print('%s · табове: %d · задачи: %d · %.1f KB' % (
        IZHOD.name, len(d['tabove']), broi,
        len(stranica.encode('utf-8')) / 1024))


if __name__ == '__main__':
    main()
