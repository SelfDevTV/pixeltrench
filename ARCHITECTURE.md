# Architekturübersicht

**Quelle:** `mm.p8`

## High-Level

- **Callbacks:** _init (Zeile ~572), _update (Zeile ~1277), _draw (Zeile ~1783), _draw (Zeile ~2128).
- **Codegröße:** ~2142 LOC, **44** Funktionen.

## Cartridge-Sektionen

- ✅ `__lua__` (~2142 LOC)
- ✅ `__gfx__`
- — `__map__`
- ✅ `__sfx__`
- ✅ `__music__`

## API/Subsystem-Nutzung (aus Code gescannt)

- **Input:** btn btnp
- **Rendering:** spr  map
- **Tile/Flags:** mget mset
- **Audio:** sfx music
- **Kamera:** camera

## Funktionskarte (Top 80)

- `capmap()` – Zeile ~90
- `smallmap()` – Zeile ~115
- `prettymap()` – Zeile ~138
- `gettile(x,y)` – Zeile ~148
- `genmap()` – Zeile ~186
- `lerp(t,a,b)` – Zeile ~207
- `grad(hash,x,y,z)` – Zeile ~211
- `noise(x,y,z)` – Zeile ~239
- `drawlevelscreen()` – Zeile ~307
- `udlevelscreen()` – Zeile ~321
- `initai()` – Zeile ~345
- `startai(cman,mx,a,p,bt,j)` – Zeile ~365
- `levelscreen()` – Zeile ~393
- `drawbg()` – Zeile ~403
- `drawlogo()` – Zeile ~411
- `startgame()` – Zeile ~416
- `setmsg(msg,t,c)` – Zeile ~479
- `beginturn(t)` – Zeile ~486
- `gotomenu()` – Zeile ~561
- `randseed()` – Zeile ~566
- `_init()` – Zeile ~572
- `updateparts()` – Zeile ~589
- `jump(man)` – Zeile ~604
- `checkpixel(x,y,nospr,m)` – Zeile ~616
- `updateman(m,orig)` – Zeile ~689
- `updatemen()` – Zeile ~753
- `bombdmg(x,y,r,dm)` – Zeile ~779
- `splode(x,y,r,dm,pp)` – Zeile ~797
- `explodebomb(b,simulate)` – Zeile ~839
- `updatebombs(simulate)` – Zeile ~867
- `dist(a,b)` – Zeile ~962
- `simulate()` – Zeile ~973
- `fired(bt,x,y,dx,dy,p)` – Zeile ~1140
- `fire(bt,x,y,a,p)` – Zeile ~1152
- `resetmen(movement)` – Zeile ~1159
- `simcycle()` – Zeile ~1175
- `_update()` – Zeile ~1277
- `drawmap(x,y,cl,nospr,skipspr)` – Zeile ~1686
- `text(str,x,y,c,bc,sc)` – Zeile ~1719
- `drawstars()` – Zeile ~1746
- `drawmenuitem(txt,w,x,y,sel)` – Zeile ~1755
- `setflash(enable)` – Zeile ~1771
- `_draw()` – Zeile ~1783
- `_draw()` – Zeile ~2128

## State-Hinweise (heuristisch)

- Vorkommen von `state = ...`: temp

## Tabellen/Konstrukte (heuristisch)

- Mögliche Entity-/Config-Tabellen: ai, aistate, bomb, bombs, bombtype, colfade, ctab, helptext, holes, levelseed, p, robottypes, stars, statetime, tab, teams, watercolor, weap, windnames, xcache

## Globale Variablen (heuristisch)

- `ai_fly_iter` (Zeile ~7) – `ai_fly_iter=2`
- `colfade` (Zeile ~10) – `colfade={0,1,0,1,2,1,2,14,8}`
- `helptext` (Zeile ~11) – `helptext={`
- `watercolor` (Zeile ~31) – `watercolor={`
- `windpos` (Zeile ~50) – `windpos=0`
- `robottypes` (Zeile ~52) – `robottypes={`
- `teams` (Zeile ~59) – `teams={`
- `stars` (Zeile ~64) – `stars={}`
- `seedchars` (Zeile ~66) – `seedchars=".abcdefghijklmnopqrstuvwxyz"`
- `levelseed` (Zeile ~68) – `levelseed={}`
- `seedc` (Zeile ~69) – `seedc=1`
- `menuitem` (Zeile ~73) – `menuitem=1`
- `bombtype` (Zeile ~77) – `bombtype={`
- `hidehud` (Zeile ~94) – `hidehud=true`
- `state` (Zeile ~95) – `state=1`
- `scrollx` (Zeile ~98) – `scrollx = x*8+32`
- `scrolly` (Zeile ~99) – `scrolly = y*8+16`
- `mask` (Zeile ~156) – `mask = 1`
- `tilebase` (Zeile ~195) – `tilebase=flr(rnd(4))`
- `u` (Zeile ~215) – `u=y`
- `v` (Zeile ~219) – `v=y`
- `r` (Zeile ~225) – `r=u`
- `cs` (Zeile ~263) – `cs=0`
- `n` (Zeile ~271) – `n=bn`
- `txt` (Zeile ~314) – `txt=sub(seedchars,levelseed[i],levelseed[i])`
- `aistate` (Zeile ~346) – `aistate={`
- `working` (Zeile ~347) – `working=false,`
- `x` (Zeile ~348) – `x=cman.x,`
- `ox` (Zeile ~349) – `ox=cman.x,`
- `y` (Zeile ~350) – `y=cman.y,`
- `oy` (Zeile ~351) – `oy=cman.y,`
- `d` (Zeile ~352) – `d=cman.d,`
- `dx` (Zeile ~353) – `dx=0,`
- `dy` (Zeile ~354) – `dy=0,`
- `mx` (Zeile ~355) – `mx=0,`
- `bt` (Zeile ~356) – `bt=cman.bt,`
- `a` (Zeile ~357) – `a=cman.a,`
- `p` (Zeile ~358) – `p=cman.p,`
- `bomb` (Zeile ~359) – `bomb={},`
- `score` (Zeile ~360) – `score=0`
- `ai` (Zeile ~362) – `ai={x=cman.x,a=cman.a,p=cman.p,score=-1,bt=cman.bt}`
- `holes` (Zeile ~417) – `holes={}`
- `f` (Zeile ~442) – `f=true`
- `messagetime` (Zeile ~480) – `messagetime=t`
- `messagec` (Zeile ~481) – `messagec=c`
- `helpc` (Zeile ~482) – `helpc=1`
- `message` (Zeile ~483) – `message=msg`
- `xcache` (Zeile ~487) – `xcache={}`
- `ai_shots` (Zeile ~488) – `ai_shots=0`
- `last_dm_x` (Zeile ~489) – `last_dm_x=-999`
- … (+60 weitere)

## Hinweise für Erweiterungen

- Trenne Logik/Render (update*/draw* Hooks).
- Packe Konstanten (Geschwindigkeiten, Damage, TTL) in eine zentrale Config-Tabelle.
- Erweitere Entities über konsistente Hooks (`init`, `update`, `draw`, `hit`).
- Kollisionen kapseln (eine Stelle), um Balancing ohne Querseiteneffekte zu erlauben.
