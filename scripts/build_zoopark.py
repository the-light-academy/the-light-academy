#!/usr/bin/env python3
"""Сглобява uroci/urok_7_formuli_razlagane.html — урокът за 7. клас.

Два таба: „Формулите“ (съкратено умножение) и „Разлагане на множители“,
а вторият има три подтаба — общ множител, групиране и формулите.
Всичко е вързано за една разходка в зоопарка: всеки раздел е спирка при
едно животно, а когато спирката се реши докрай, се отключва факт за него.

Урокът се води НА ДЪСКАТА и се гледа от телефон на споделен екран.
Затова: никъде няма поле за писане, а шрифтът на условията е голям и
НЕ се смалява на тесен екран.

Задачите стоят в scripts/zoopark/, а scripts/check_zoopark.py ги пресмята
наново със sympy.

    /usr/bin/python3.13 scripts/build_zoopark.py
"""
import json
import pathlib
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from zoopark import formuli, razlagane                     # noqa: E402

SLUG = 'urok-7-formuli-razlagane'
IZHOD = KOREN / 'uroci/urok_7_formuli_razlagane.html'

NACHALO = ('/* ДАННИ:НАЧАЛО — пише ги scripts/build_zoopark.py; '
           'задачите са в scripts/zoopark/ */')
KRAI = '/* ДАННИ:КРАЙ */'

GLAVA = r"""<!DOCTYPE html>
<html lang="bg">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Формули за съкратено умножение · Разлагане на множители — 7. клас · The Light Academy</title>
<meta name="description" content="Интерактивен урок по математика за 7. клас: всички формули за съкратено умножение и разлагане на множители в три подтаба — общ множител, групиране и формулите. Разходка в зоопарка с едър шрифт за споделен екран." />
<link rel="icon" href="../favicon.ico" sizes="any" />
<link rel="apple-touch-icon" sizes="180x180" href="../apple-touch-icon.png" />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
</head>
<body>
<style>
@import url('https://fonts.googleapis.com/css2?family=Fredoka:wght@500;600;700&family=Nunito:wght@400;600;700;800&display=swap');

/* =====================================================================
   УРОК ЗА 7. КЛАС — Формулите · Разлагане на множители
   ---------------------------------------------------------------------
   Урокът се гледа от ТЕЛЕФОН на споделен екран. Оттам идват всички
   решения по вида:

     · условията са с едър шрифт и НИКЪДЕ не се смаляват под 23px —
       на тесен екран стават по-едри, не по-дребни;
     · нищо не се въвежда: всяка задача има кръгче „решено“ и бутон,
       който показва отговора заедно с решението;
     · бутоните са поне 44px, за да се улучват с пръст;
     · нищо не излиза встрани — дългите изрази се пренасят на нов ред.

   Зоопаркът е подредбата: всеки раздел е спирка при едно животно, а
   когато спирката се реши докрай, се отключва факт за него.

   Отметките се помнят в този браузър (localStorage), за да не се губи
   докъде е стигнал часът.

   Задачите стоят в scripts/zoopark/ и се вграждат тук от
   scripts/build_zoopark.py. Проверяват се от scripts/check_zoopark.py,
   който ги пресмята НАНОВО със sympy.
   ===================================================================== */
:root{
  --ink:#16233F; --ink-soft:#55658A;
  --paper:#FFFDF7; --paper-raised:#FFFFFF;
  --grid:#EFE3CC;
  --accent:#F7AD19; --accent-ink:#8A5407; --accent-soft:#FDF0D5;
  --pencil:#14402F; --pencil-soft:#E1EFE7;
  --leaf:#1E7A52; --leaf-soft:#E3F3EA;
  --success:#16603A; --success-soft:#E3F3EA;
  --zvezda:#8E4BC4; --zvezda-soft:#F3E8FB;
  --shadow:160 35% 18%;
}
*,*::before,*::after{box-sizing:border-box}
html{scroll-behavior:smooth}
body{
  margin:0; background:var(--paper); color:var(--ink);
  font-family:'Nunito',system-ui,sans-serif; font-size:19px; line-height:1.55;
  -webkit-text-size-adjust:100%; overflow-x:hidden;
}
h1,h2,h3{font-family:'Fredoka',system-ui,sans-serif; margin:0}
button{font:inherit; cursor:pointer}
[hidden]{display:none !important}
.wrap{max-width:900px; margin:0 auto; padding:0 clamp(14px,4vw,24px) 120px}

/* ── шапка ──────────────────────────────────────────────────────── */
.top{background:linear-gradient(160deg,#14402F,#1E7A52); color:#fff;
  padding:16px 0 0; position:relative; overflow:hidden}
.top .wrap{padding-bottom:0; position:relative; z-index:2}
.top__red{display:flex; align-items:center; gap:10px; flex-wrap:wrap}
.top__back{color:#BFE6D2; text-decoration:none; font-weight:700; font-size:15px;
  min-height:44px; display:inline-flex; align-items:center}
.top__back:hover{color:#fff}
.top__klas{color:#BFE6D2; font-size:15px; font-weight:700}
.top h1{font-size:clamp(27px,7vw,40px); margin:6px 0 6px; line-height:1.08}
.top__pod{color:#CFEEDD; font-size:clamp(16px,4.2vw,18px); max-width:58ch;
  margin:0 0 14px}
.listo{position:absolute; opacity:.13; pointer-events:none}
.listo--1{top:-30px; right:-20px; width:200px; transform:rotate(18deg)}
.listo--2{bottom:-50px; left:-30px; width:170px; transform:rotate(-24deg)}

.tabove{display:flex; gap:8px; flex-wrap:wrap}
.tab{border:none; background:rgba(255,255,255,.12); color:#DFF3E8;
  padding:12px 18px; border-radius:16px 16px 0 0; font-weight:700;
  font-size:clamp(16px,4.4vw,20px); font-family:'Fredoka',sans-serif;
  min-height:50px; transition:.15s; display:flex; align-items:center; gap:8px}
.tab:hover{background:rgba(255,255,255,.2); color:#fff}
.tab.ima{background:var(--paper); color:var(--ink)}
.tab__n{font-size:14px; opacity:.8; font-family:'Nunito',sans-serif;
  font-weight:800}

/* ── пътеката през зоопарка ─────────────────────────────────────── */
.puteka{display:flex; gap:8px; flex-wrap:wrap; margin:16px 0 4px}
.spirka{border:2px solid var(--grid); background:#fff; border-radius:16px;
  min-width:56px; min-height:56px; display:flex; flex-direction:column;
  align-items:center; justify-content:center; gap:1px; padding:4px 8px;
  font-size:24px; line-height:1; transition:.15s}
.spirka:hover{border-color:var(--accent)}
.spirka b{font-size:11px; font-family:'Nunito',sans-serif; color:var(--ink-soft);
  font-weight:800}
.spirka.gotova{border-color:#5FB98A; background:var(--success-soft)}
.spirka.gotova b{color:var(--success)}

/* ── подтабове ──────────────────────────────────────────────────── */
.podtabove{display:flex; gap:8px; flex-wrap:wrap; margin:14px 0 2px}
.podtab{border:2px solid var(--grid); background:#fff; color:var(--ink-soft);
  border-radius:999px; padding:10px 18px; font-weight:800;
  font-size:clamp(15px,4.2vw,18px); min-height:46px; transition:.15s;
  display:flex; align-items:center; gap:7px}
.podtab:hover{border-color:var(--accent); color:var(--accent-ink)}
.podtab.ima{background:var(--pencil); border-color:var(--pencil); color:#fff}
.podtab__n{font-size:13px; opacity:.85; font-weight:800}

/* ── напредък ───────────────────────────────────────────────────── */
.napredak{display:flex; align-items:center; gap:12px; margin:16px 0 6px;
  flex-wrap:wrap}
.lenta{flex:1; min-width:140px; height:12px; border-radius:999px;
  background:var(--pencil-soft); overflow:hidden}
.lenta i{display:block; height:100%; width:0; border-radius:999px;
  background:linear-gradient(90deg,var(--accent),#7ED3B2); transition:width .4s}
.napredak b{font-size:16px; color:var(--ink-soft); white-space:nowrap}
.nulirai{border:2px solid var(--grid); background:#fff; color:var(--ink-soft);
  border-radius:999px; padding:9px 16px; font-size:15px; font-weight:700;
  min-height:44px}
.nulirai:hover{border-color:var(--accent); color:var(--accent-ink)}

/* ── раздел (спирка) ────────────────────────────────────────────── */
.razdel{background:var(--paper-raised); border:1px solid var(--grid);
  border-radius:22px; padding:18px clamp(14px,3.5vw,24px); margin:18px 0;
  box-shadow:0 10px 30px hsl(var(--shadow) / .07); scroll-margin-top:12px}
.razdel.zvezda{border-color:#DCC4F0; background:linear-gradient(#FDFAFF,#fff)}
.razdel__top{display:flex; align-items:center; gap:13px; flex-wrap:wrap}
.razdel__z{width:58px; height:58px; border-radius:18px; display:grid;
  place-items:center; background:var(--leaf-soft); font-size:32px; flex:none;
  line-height:1}
.razdel.zvezda .razdel__z{background:var(--zvezda-soft)}
.razdel__ime{font-family:'Fredoka',sans-serif;
  font-size:clamp(22px,5.6vw,28px); line-height:1.12}
.razdel__tema{font-size:clamp(15px,4vw,17px); color:var(--ink-soft);
  font-weight:700}
.razdel__broi{margin-left:auto; font-size:15px; font-weight:800;
  color:var(--ink-soft); background:var(--pencil-soft); border-radius:999px;
  padding:6px 14px; white-space:nowrap}
.razdel__ideq{margin:13px 0 0; color:var(--ink);
  font-size:clamp(16.5px,4.3vw,19px)}
/* Формулите вървят с основния шрифт: моноширинният няма истински горни
   индекси и a² се разпада на „a ²“, а минусът става тире. */
.pravilo{margin:13px 0 4px; padding:13px 16px; border-radius:16px;
  background:var(--accent-soft); border:2px dashed var(--accent);
  font-size:clamp(18px,4.8vw,23px); letter-spacing:.01em;
  color:var(--accent-ink); font-weight:800; line-height:1.5;
  overflow-wrap:break-word}
.razdel.zvezda .pravilo{background:var(--zvezda-soft); border-color:#C89AE6;
  color:#6B2E96}

/* ── задача ─────────────────────────────────────────────────────── */
.zadachi{display:grid; gap:12px; margin-top:16px}
.zad{position:relative; border:1px solid var(--grid); border-radius:18px;
  padding:14px 70px 14px 16px; background:#FBF8F1; transition:.15s}
.zad.reshena{background:var(--success-soft); border-color:#BBE3CC}
.zad__n{font-size:clamp(13.5px,3.6vw,15px); font-weight:800;
  color:var(--ink-soft); text-transform:uppercase; letter-spacing:.04em}
.zad__uslovie{font-size:clamp(23px,6.4vw,31px); font-weight:800;
  color:var(--pencil); margin:6px 0 0; line-height:1.4;
  overflow-wrap:break-word; letter-spacing:.01em}
.zad__uslovie.dulag{font-size:clamp(19px,5.2vw,24px); font-weight:700;
  line-height:1.45; color:var(--ink); letter-spacing:0}
.zad__dolu{display:flex; align-items:center; gap:10px; flex-wrap:wrap;
  margin-top:12px}
.pokaji{border:2px solid var(--pencil-soft); background:#fff;
  color:var(--pencil); border-radius:999px; padding:10px 18px;
  font-size:16px; font-weight:800; min-height:46px}
.pokaji:hover{border-color:var(--accent); color:var(--accent-ink)}
.otg{margin-top:12px; padding:14px 16px; border-radius:16px; background:#fff;
  border:1px solid var(--grid)}
.otg__r{font-size:clamp(21px,5.6vw,27px); font-weight:800; color:var(--success);
  line-height:1.4; overflow-wrap:break-word}
.otg__k{margin:9px 0 0; font-size:clamp(16.5px,4.3vw,19px); color:var(--ink-soft)}
.otg__k b{color:var(--ink)}

/* кръгчето за отметка — голямо, за пръст */
.otmetka{position:absolute; top:12px; right:12px; width:50px; height:50px;
  border-radius:50%; border:2px solid var(--grid); background:#fff;
  color:#C3CBD9; display:grid; place-items:center; font-size:24px;
  font-weight:800; transition:.15s}
.otmetka:hover{border-color:var(--accent); color:var(--accent-ink)}
.otmetka.ima{border-color:#5FB98A; background:var(--success-soft);
  color:var(--success)}

/* ── стикерът с факта ───────────────────────────────────────────── */
.stiker{margin-top:14px; padding:14px 16px; border-radius:16px;
  background:var(--leaf-soft); border:2px solid #9CD4B7;
  font-size:clamp(16.5px,4.3vw,19px); color:#124B33}
.stiker b{color:var(--leaf)}
.stiker--zaklyuchen{background:#F6F4EE; border-style:dashed;
  border-color:var(--grid); color:var(--ink-soft)}

/* ── краят на обиколката ────────────────────────────────────────── */
.kraj{margin-top:20px; padding:24px; border-radius:24px; text-align:center;
  background:var(--success-soft); border:2px solid #9CD4B7}
.kraj h2{font-size:clamp(24px,6vw,30px); color:var(--success); margin-bottom:8px}
.kraj p{margin:0 auto; max-width:52ch; font-size:clamp(16.5px,4.3vw,19px)}

/* ── долната лента ──────────────────────────────────────────────── */
.dolu{position:fixed; left:0; right:0; bottom:0; z-index:40; padding:10px 12px;
  background:rgba(255,253,247,.95); backdrop-filter:blur(10px);
  border-top:1px solid var(--grid)}
.dolu__in{max-width:900px; margin:0 auto; display:flex; align-items:center;
  gap:12px; font-size:16px}
.dolu__t{font-weight:800}
.dolu__p{flex:1}

@media (max-width:620px){
  .zad{padding-right:64px}
  .razdel__broi{margin-left:0}
  .dolu__in{font-size:15px}
}
@media print{
  .tabove,.podtabove,.puteka,.dolu,.otmetka,.pokaji,.nulirai{display:none !important}
  .razdel{break-inside:avoid; box-shadow:none}
  .otg,.stiker{display:block !important}
}
@media (prefers-reduced-motion:reduce){*{animation:none !important; transition:none !important}}
</style>

<header class="top">
  <svg class="listo listo--1" viewBox="0 0 100 100" aria-hidden="true"><path d="M50 5C20 25 10 60 20 95 55 85 85 55 50 5z" fill="#fff"/></svg>
  <svg class="listo listo--2" viewBox="0 0 100 100" aria-hidden="true"><path d="M50 5C20 25 10 60 20 95 55 85 85 55 50 5z" fill="#fff"/></svg>
  <div class="wrap">
    <div class="top__red">
      <a class="top__back" href="../portal.html">← към профила</a>
      <span style="color:#78B79A">·</span>
      <span class="top__klas">Математика · 7. клас</span>
    </div>
    <h1>🦁 Ден в зоопарка</h1>
    <p class="top__pod">Формулите и разлагането — спирка по спирка.
      Решаваме на дъската, тук отмятаме готовото.</p>
    <div class="tabove" id="tabove"></div>
  </div>
</header>

<div class="wrap">
  <div class="podtabove" id="podtabove" hidden></div>
  <div class="puteka" id="puteka"></div>
  <div class="napredak">
    <div class="lenta"><i id="lenta"></i></div>
    <b id="broiach">0 / 0</b>
    <button class="nulirai" id="bNulirai">Изчисти отметките</button>
  </div>
  <div id="sudurjanie"></div>
  <div class="kraj" id="kraj" hidden>
    <h2>🎉 Обиколката е завършена!</h2>
    <p>Всички спирки са минати и всички животни са нахранени със задачи.
      Формулите вече не се налучкват — виждат се.</p>
  </div>
</div>

<div class="dolu">
  <div class="dolu__in">
    <span class="dolu__t" id="doluTema"></span>
    <span class="dolu__p"></span>
    <span class="dolu__t" id="doluBroi"></span>
  </div>
</div>

<script>
__DANNI__
</script>
<script>
"use strict";
/* =====================================================================
   Двигателят: два таба, три подтаба във втория, отметки и показване на
   отговора. Нищо не се въвежда — урокът се води на дъската.
   ===================================================================== */
const $ = (s, p) => (p || document).querySelector(s);
const $$ = (s, p) => Array.prototype.slice.call((p || document).querySelectorAll(s));
function ek(t){
  return String(t).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
}

const KLYUCH = 'tla-' + UROK.slug;
let tabSega = 0;
let podSega = {};                 /* кой подтаб е отворен във всеки таб */
let S = {};
try { S = JSON.parse(localStorage.getItem(KLYUCH) || '{}') || {}; } catch(e) { S = {}; }
function zapazi(){
  try { localStorage.setItem(KLYUCH, JSON.stringify(S)); } catch(e) {}
}

/* Разделите, които се показват сега: или направо на таба, или на
   отворения негов подтаб. */
function razdeliNa(t){
  if(t.podtabove) return t.podtabove[podSega[t.kod] || 0].razdeli;
  return t.razdeli;
}
/* Всички раздели на един таб — за брояча отгоре той брои целия таб,
   а не само отворения подтаб. */
function vsichkiRazdeli(t){
  if(t.podtabove) return t.podtabove.reduce((a, p) => a.concat(p.razdeli), []);
  return t.razdeli;
}
function zadachiNa(razdeli){
  return razdeli.reduce((a, r) => a.concat(r.zadachi), []);
}
function resheni(razdeli){
  return zadachiNa(razdeli).filter(z => S[z.id]).length;
}

/* ── табове ─────────────────────────────────────────────────────── */
function risuvaiTabove(){
  $('#tabove').innerHTML = UROK.tabove.map(function(t, i){
    const r = vsichkiRazdeli(t);
    return '<button class="tab' + (i === tabSega ? ' ima' : '') + '" data-t="' + i + '">'
      + ek(t.ime)
      + '<span class="tab__n">' + resheni(r) + '/' + zadachiNa(r).length + '</span>'
      + '</button>';
  }).join('');
  $$('#tabove .tab').forEach(function(b){
    b.addEventListener('click', function(){
      tabSega = +b.dataset.t;
      risuvai();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  });
}

function risuvaiPodtabove(){
  const t = UROK.tabove[tabSega], kutiq = $('#podtabove');
  if(!t.podtabove){ kutiq.hidden = true; kutiq.innerHTML = ''; return; }
  const sega = podSega[t.kod] || 0;
  kutiq.hidden = false;
  kutiq.innerHTML = t.podtabove.map(function(p, i){
    return '<button class="podtab' + (i === sega ? ' ima' : '') + '" data-p="' + i + '">'
      + '<span>' + p.zhivotno + '</span>' + ek(p.ime)
      + '<span class="podtab__n">' + resheni(p.razdeli) + '/'
      + zadachiNa(p.razdeli).length + '</span></button>';
  }).join('');
  $$('#podtabove .podtab').forEach(function(b){
    b.addEventListener('click', function(){
      podSega[t.kod] = +b.dataset.p;
      risuvai();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  });
}

/* ── пътеката: спирките на отворения (под)таб ───────────────────── */
function risuvaiPuteka(){
  const r = razdeliNa(UROK.tabove[tabSega]);
  $('#puteka').innerHTML = r.map(function(x){
    const gotovi = x.zadachi.filter(z => S[z.id]).length;
    return '<button class="spirka' + (gotovi === x.zadachi.length ? ' gotova' : '')
      + '" data-s="' + x.kod + '" title="' + ek(x.ime) + '">'
      + x.zhivotno + '<b>' + gotovi + '/' + x.zadachi.length + '</b></button>';
  }).join('');
  $$('#puteka .spirka').forEach(function(b){
    b.addEventListener('click', function(){
      const el = $('#r-' + b.dataset.s);
      if(el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });
}

/* ── разделите и задачите ───────────────────────────────────────── */
function risuvaiTqlo(){
  const razdeli = razdeliNa(UROK.tabove[tabSega]);
  $('#sudurjanie').innerHTML = razdeli.map(function(r){
    const gotovi = r.zadachi.filter(z => S[z.id]).length;
    const vsички = r.zadachi.length;
    return '<section class="razdel' + (r.zvezda ? ' zvezda' : '') + '" id="r-' + r.kod + '">'
      + '<div class="razdel__top">'
      +   '<div class="razdel__z">' + r.zhivotno + '</div>'
      +   '<div><div class="razdel__ime">' + ek(r.ime) + '</div>'
      +     '<div class="razdel__tema">' + ek(r.tema) + '</div></div>'
      +   '<span class="razdel__broi">' + gotovi + ' / ' + vsички + '</span>'
      + '</div>'
      + '<p class="razdel__ideq">' + ek(r.ideya) + '</p>'
      + '<div class="pravilo">' + ek(r.pravilo) + '</div>'
      + '<div class="zadachi">' + r.zadachi.map(function(z, zi){
          return '<div class="zad' + (S[z.id] ? ' reshena' : '') + '" id="z-' + z.id + '">'
            + '<div class="zad__n">Задача ' + (zi + 1)
            +   (z.glagol ? ' · ' + ek(z.glagol) : '') + '</div>'
            + '<p class="zad__uslovie' + (z.dulag ? ' dulag' : '') + '">'
            +   ek(z.izraz) + '</p>'
            + '<div class="zad__dolu">'
            +   '<button class="pokaji" data-p="' + z.id + '">Покажи отговора</button>'
            + '</div>'
            + '<div class="otg" id="o-' + z.id + '" hidden></div>'
            + '<button class="otmetka' + (S[z.id] ? ' ima' : '') + '" data-o="' + z.id + '" '
            +   'title="Отметни като решена" aria-label="Отметни като решена">✓</button>'
            + '</div>';
        }).join('') + '</div>'
      + stiker(r)
      + '</section>';
  }).join('');

  $$('.otmetka').forEach(function(b){
    b.addEventListener('click', function(){ otmetni(b.dataset.o); });
  });
  $$('.pokaji').forEach(function(b){
    b.addEventListener('click', function(){ pokaji(b.dataset.p, b); });
  });
}

/* Фактът за животното се отключва чак когато спирката е минала цялата —
   инак наградата идва преди работата. */
function stiker(r){
  const gotovi = r.zadachi.filter(z => S[z.id]).length;
  if(gotovi < r.zadachi.length){
    return '<div class="stiker stiker--zaklyuchen" id="s-' + r.kod + '">'
      + '🔒 Остават ' + (r.zadachi.length - gotovi)
      + (r.zadachi.length - gotovi === 1 ? ' задача' : ' задачи')
      + ' до стикера на тази спирка.</div>';
  }
  return '<div class="stiker" id="s-' + r.kod + '">' + r.zhivotno
    + ' <b>Стикер събран!</b> ' + ek(r.fakt) + '</div>';
}

/* Отметката се вдига и сваля: ако е отметната по погрешка, връща се. */
function otmetni(id){
  if(S[id]) delete S[id]; else S[id] = 1;
  zapazi();
  const zad = $('#z-' + id), b = $('.otmetka[data-o="' + id + '"]');
  if(zad) zad.classList.toggle('reshena', !!S[id]);
  if(b) b.classList.toggle('ima', !!S[id]);
  osvejiRazdeli();
  risuvaiTabove();
  risuvaiPodtabove();
  risuvaiPuteka();
  osveji();
}

function pokaji(id, but){
  const z = namiri(id), kutiq = $('#o-' + id);
  if(!z || !kutiq) return;
  if(!kutiq.hidden){ kutiq.hidden = true; but.textContent = 'Покажи отговора'; return; }
  kutiq.innerHTML = '<div class="otg__r">' + ek(z.otgovor) + '</div>'
    + '<p class="otg__k"><b>Как се стига дотам:</b> ' + ek(z.reshenie) + '</p>';
  kutiq.hidden = false;
  but.textContent = 'Скрий отговора';
}

function namiri(id){
  for(const t of UROK.tabove)
    for(const r of vsichkiRazdeli(t))
      for(const z of r.zadachi)
        if(z.id === id) return z;
  return null;
}

function osvejiRazdeli(){
  razdeliNa(UROK.tabove[tabSega]).forEach(function(r){
    const broi = $('#r-' + r.kod + ' .razdel__broi');
    if(broi) broi.textContent = r.zadachi.filter(z => S[z.id]).length
      + ' / ' + r.zadachi.length;
    const st = $('#s-' + r.kod);
    if(st) st.outerHTML = stiker(r);
  });
}

function osveji(){
  const t = UROK.tabove[tabSega];
  const tuk = razdeliNa(t);
  const vsички = zadachiNa(tuk).length, gotovi = resheni(tuk);
  $('#lenta').style.width = (vsички ? Math.round(100 * gotovi / vsички) : 0) + '%';
  $('#broiach').textContent = gotovi + ' / ' + vsички;
  /* В долната лента стои името на отвореното кътче, а не целият път:
     на телефон „Разлагане на множители · Общ множител“ се пренася на
     два реда и лентата изяжда екран. */
  $('#doluTema').textContent = t.podtabove
    ? t.podtabove[podSega[t.kod] || 0].ime : t.ime;
  const vsi = UROK.tabove.reduce((a, x) => a + resheni(vsichkiRazdeli(x)), 0);
  const obshto = UROK.tabove.reduce(
    (a, x) => a + zadachiNa(vsichkiRazdeli(x)).length, 0);
  $('#doluBroi').textContent = 'Общо решени: ' + vsi + ' / ' + obshto;
  $('#kraj').hidden = (vsi < obshto);
}

function risuvai(){
  risuvaiTabove();
  risuvaiPodtabove();
  risuvaiPuteka();
  risuvaiTqlo();
  osveji();
}

$('#bNulirai').addEventListener('click', function(){
  if(!confirm('Да изчистя ли всички отметки за този урок?')) return;
  S = {}; zapazi(); risuvai();
});

risuvai();
</script>
</body>
</html>
"""


def nelomko(izraz: str) -> str:
    """Залепя интервалите ВЪТРЕ в скобите с неразделим интервал.

    На тесен екран браузърът пренася на новия ред където завари — и
    „(x − 3)²“ се чупи на „(x −“ и „3)²“. Със залепени скоби всяка скоба
    остава цяла, а пренасянето става между скобите, където му е мястото.
    Отвън интервалите си остават обикновени, иначе дългите изрази биха
    излезли извън екрана.
    """
    out, dulbochina = [], 0
    for c in izraz:
        if c == '(':
            dulbochina += 1
        elif c == ')':
            dulbochina = max(0, dulbochina - 1)
        out.append('\u00a0' if (c == ' ' and dulbochina > 0) else c)
    return ''.join(out)


def uslovie(z: dict) -> tuple:
    """Условието, разделено на три: глагол, математика и дали е текст.

    Глаголът („Развийте“, „Разложете докрай“) отива при номера на
    задачата с дребен шрифт, а едрият остава САМО за математиката. На
    телефон това е цял спечелен ред — иначе „Решете уравнението:“ изяжда
    половината екран, преди да се е видял самият израз.

    За задачите със система и с най-малка стойност изречението се
    съчинява ТУК, от същите полета, които проверката чете. Така няма две
    копия на условието, които да се разминат.
    """
    if z['vid'] == 'sistema':
        return ('', 'Дадено е, че ' + ' и '.join(z['uslovia'])
                + '. Намерете ' + z['tursi'] + '.', True)
    if z['vid'] == 'min':
        return ('', 'Коя е най-малката стойност на израза ' + z['izraz_m']
                + ' и при кое x се получава?', True)
    if ':' in z['izraz']:
        glagol, mat = z['izraz'].split(':', 1)
        return (glagol.strip(), nelomko(mat.strip()), False)
    return ('', nelomko(z['izraz']), False)


def razdel(r: dict) -> dict:
    zadachi = []
    for z in r['zadachi']:
        glagol, txt, dulag = uslovie(z)
        zadachi.append({'id': z['id'], 'glagol': glagol, 'izraz': txt,
                        'dulag': dulag, 'otgovor': nelomko(z['otgovor']),
                        'reshenie': z['reshenie']})
    return {'kod': r['kod'], 'zhivotno': r['zhivotno'], 'ime': r['ime'],
            'tema': r['tema'], 'ideya': r['ideya'], 'pravilo': r['pravilo'],
            'fakt': r['fakt'], 'zvezda': bool(r.get('zvezda')),
            'zadachi': zadachi}


def danni() -> dict:
    return {'slug': SLUG, 'tabove': [
        {'kod': 'f', 'ime': formuli.IME, 'podnaslov': formuli.PODNASLOV,
         'razdeli': [razdel(r) for r in formuli.RAZDELI]},
        {'kod': 'r', 'ime': razlagane.IME, 'podnaslov': razlagane.PODNASLOV,
         'podtabove': [
             {'kod': p['kod'], 'ime': p['ime'], 'zhivotno': p['zhivotno'],
              'razdeli': [razdel(r) for r in p['razdeli']]}
             for p in razlagane.PODTABOVE]},
    ]}


def main() -> None:
    d = danni()
    blok = 'const UROK = ' + json.dumps(d, ensure_ascii=False, indent=1) + ';'
    stranica = GLAVA.replace('__DANNI__', NACHALO + '\n' + blok + '\n' + KRAI, 1)
    IZHOD.parent.mkdir(parents=True, exist_ok=True)
    IZHOD.write_text(stranica, encoding='utf-8')

    def broi(t):
        r = t.get('razdeli') or [x for p in t['podtabove'] for x in p['razdeli']]
        return sum(len(x['zadachi']) for x in r)

    print('%s · табове: %d · подтабове: %d · задачи: %d · %.1f KB' % (
        IZHOD.name, len(d['tabove']),
        len(d['tabove'][1]['podtabove']),
        sum(broi(t) for t in d['tabove']),
        len(stranica.encode('utf-8')) / 1024))


if __name__ == '__main__':
    main()
