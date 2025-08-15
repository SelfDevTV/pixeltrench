# Spielmechaniken

Automatisch aus dem Code gescannt und als Vorlage strukturiert. Werte/Details bitte im Playtest verifizieren und ergänzen.

## Core Loop
- `_update` treibt Logik/Physik; `_draw` rendert; `_init` setzt Startzustand.

## Steuerung
- `btn/btnp` erkannt → dokumentiere genaue Tasten/Belegungen.

## Bewegung & Physik
- Trage hier Konstanten ein (z. B. `gravity`, `friction`, `accel`, `jump_v`).
- Kollisionsmethode: (Tile/Pixel/AABB) aus Codeabschnitten mit `mget/fget` oder Distanzprüfungen ableiten.

## Entities
- **Player**: Felder (x, y, vx, vy, hp, state, anim, facing …) + Aktions-Set.
- **Projectiles**: (x, y, dx, dy, dmg, ttl, radius …) + Spawn-/Despawn-Logik.
- **Enemies/NPCs**: Zustandsmaschine (idle, chase, attack, die …), Spawnraten.
- **Pickups/Items**: Effekte, Dauer, Stackbarkeit.

## Kampf / Interaktion
- Kollisions-Test (AABB/Radius/Tileflag). Schaden/Krit/Knockback-Formeln. I-Frames. Feedback (SFX, Screenshake, Pal-Swap).

## Level/Map
- Keine Mapdaten erkannt → dokumentiere Levelaufbau/Progression ohne Tiles.

## Audio
- SFX-Slots dokumentieren (IDs, Ereignisse) | Music-Pattern/Tracks (Start/Loop/Stop)

## UI/HUD
- Anzeigen (HP, Score, Ammo, Timer), Pausenmenü, Game Over/Retry, Hinweise/Prompts.

## Kamera
- `camera()` erkannt → Center/Deadzone/Shake-Policy hier definieren.

## Balancing (Startwerte)

| Parameter | Wert | Notizen |
|---|---:|---|
| Spieler-HP | 3 | |
| Laufgeschwindigkeit | 1.0 | px/frame |
| Gravitation | 0.2 | px/frame² |
| Projektil-Schaden | 1 | |
| Projektil-TTL | 60 | frames |


## Unterschiede zur Referenz (für eigenständige Version)
- Theme/Artstyle variieren
- Kernmechanik(en) abwandeln
- Progression/Ziele umstellen
