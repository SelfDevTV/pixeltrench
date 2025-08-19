# Roadmap – Worms-Klon mit Bitmasken-Terrain (Lehrer-Modus)

Diese Roadmap führt dich Schritt für Schritt durch die Entwicklung eines abgespeckten Worms-Klons in PICO-8, basierend auf einer **2D-Bitmasken-Kollisionslogik** statt Sprite/Map-Flags. Die KI fungiert ausschließlich als Lehrer und gibt dir nur auf Nachfrage Lösungen/Code.

## Architektur – Überblick

- **Terrain (Bitmask):** Breite/Höhe z. B. 256×144, in 32-Bit-Chunks gepackt. 1=fest, 0=Luft.
- **Rendering:** Scanline- oder Blockweise aus Bitmaske, kein `map()` für Kollision.
- **Kollision:** Kreis-gegen-Bitmaske, Resolver zur Korrektur bei Penetration.
- **Bewegung:** Gravity, Bodenhaftung, Rampenlimit, Substeps.
- **Zerstörung:** Explosionen verändern Terrain-Bits (`carve_circle`).
- **Projektile:** Ballistik, TTL, Kollision → Explosion.
- **Turn-System:** Minimaler Rundenwechsel.

## Arbeitsprinzip

1. Du bearbeitest eine Aufgabe und meldest sie als erledigt.
2. Die KI prüft durch Fragen/Checks.
3. Nächste Aufgabe wird freigeschaltet.
4. Code nur auf explizite Anfrage.

## Phase 0 – Grundgerüst & Debug

**0.1 – Skelett + Debug-Overlay [ERLEDIGT]**

- Ziel: Projekt mit `_init`, `_update`, `_draw`, Konstanten und Debug-UI.
- Kriterien: Schwarzer Screen, Debug-Text (FPS, Maus, Zellen), Toggle mit Taste D.
- Hinweis: Zentrales `cfg`-Objekt, einfache Kamera.
- Status: erledigt am 2025-08-11. Abweichung: Debug-Toggle via 🅾️ statt D.

## Phase 1 – Terrain-Bitmaske

**1.1 – Datenstruktur & Zugriff [ERLEDIGT]**

- Ziel: 2D-Bitmaske mit `set_solid`/`is_solid`.
- Kriterien: Korrekte Rückgabe auf Testkoordinaten.
- Tests: 20 Punkte setzen/prüfen.
- Status: erledigt am 2025-08-12. Umsetzung via spaltenweisen Runs [y0,y1) mit `is_solid` und `destroy_range`; Rendering bis `y1-1`.

**1.2 – Heightmap-Terrain [ERLEDIGT]**

- Ziel: Generator mit natürlicher Oberfläche.
- Kriterien: 40–60 % Erde, drei Seeds erzeugen unterschiedliche Silhouetten.

**1.3 – Renderer v1 [ERLEDIGT]**

- Ziel: Terrain sichtbar zeichnen.
- Kriterien: 30–60 FPS, Kamera-Pan mit Pfeilen.

## Phase 2 – Zerstörung & Edit

**2.1 – Carve Circle [ERLEDIGT]**

- Ziel: Bits im Kreis auf Luft setzen.
- Kriterien: Krater ohne Pixelreste.

**2.2 – Fill/Repair (optional) [CANCELED]**

- Ziel: Bits im Kreis auf fest setzen.
- Kriterien: Debug-Hilfe.

## Phase 3 – Kollision & Bewegung

**3.1 – Punkt/Kreis-Test [ERLEDIGT]**

- Ziel: `collide_circle` prüft Kollision.
- Kriterien: korrekt bei Boden/Wand/Decke.
- Status: erledigt am 2025-08-16. Implementierung mit 16 Sample-Punkten um Kreisumfang + Mittelpunkt-Test. Debug mit Z-Taste auf Position (64,92). Funktioniert korrekt.

**3.2 – Normalschätzung [ERLEDIGT]**

- Ziel: `ground_normal` liefert Oberflächennormalen.
- Kriterien: Normalenvektor (nx, ny) zeigt vom Terrain weg, funktioniert bei Boden/Wand/Decke.
- Status: erledigt am 2025-08-16. Implementierung mit 16-Punkt-Sampling um Kreis, relative Vektoren sammeln, umkehren und normalisieren. Edge-Case mit l=0 abgefangen.

**3.3 – Resolver [ERLEDIGT]**

- Ziel: Wurm aus Terrain heraus schieben.
- Kriterien: Ball wird korrekt aus Terrain geschoben, Geschwindigkeit reflektiert, keine Penetration.
- Status: erledigt am 2025-08-16. Implementierung mit Geschwindigkeits-Reflektion via Dot Product, Dämpfung 0.8, Bounce-Counter. Physik funktioniert realistisch mit geringer visueller Penetration (akzeptabel für Prototyp).

**3.4 – Movement v1 [ERLEDIGT]**

- Ziel: Laufen, Gravity, Sprung, Steigungsgrenze.
- Kriterien: Wurm läuft auf Terrain, springt, respektiert Steigungsgrenze, Bodenhaftung funktioniert.
- Status: erledigt am 2025-08-16. Vollständige Implementierung mit Wurm-Objekt, Links/Rechts-Bewegung, Gravity, Sprung-Mechanik mit Anti-Doppelsprung, Steigungsgrenze via cfg.max_slope, automatisches Terrain-Following mit find_surface_y/find_ground_y.

## Phase 4 – Projektile & Explosion

**4.1 – Projektilflug [ERLEDIGT]**

- Ziel: Parabel, TTL.
- Kriterien: Projektile fliegen in Parabel-Bahn, verschwinden nach Zeit, realistische Ballistik.
- Status: erledigt am 2025-08-17. Vollständige Implementierung mit create_projectile(), update_projectiles(), Gravity-basierter Ballistik, TTL-System, Kollisionserkennung und automatischer Explosion am Aufschlagpunkt.

**4.2 – Projektil-Kollision [ERLEDIGT]**

- Ziel: Treffererkennung ohne Tunneling, Kollisions-Verfeinerung.
- Kriterien: Keine Projektile durchdringen Terrain bei hoher Geschwindigkeit, präzise Aufschlagpunkte, robuste Kollisionserkennung auch bei Edge-Cases.
- Status: erledigt am 2025-08-17. Raytracing-basierte Kollisionserkennung mit sqrt-Distanz-Berechnung, schrittweiser Interpolation entlang Bewegungspfad, Explosion am exakten Aufschlagpunkt mit realistischem Offset (projektil_radius + 1) in den Boden.

**4.3 – Explosion = Carve + Schaden [ERLEDIGT]**

- Ziel: Krater + Knockback + HP-Reduktion.
- Kriterien: HP-System für Würmer, distanz-basierter Schaden, Knockback-Physik bei Explosionen, visuelle Schadens-Indikatoren.
- Status: erledigt am 2025-08-17. Vollständiges Explosion-System mit HP-Management, distanz-basiertem Schaden, realistischer Knockback-Physik, Line-of-Sight Terrain-Abschirmung via Raycast, floating damage numbers und Mouse-Click-Testing.

**4.4 – Aim & Shoot System [IN_PROGRESS]**

- Ziel: Spielbare Worm-Steuerung mit Zielen, Power-Charging und Projektil-Launch.
- Kriterien: Ziel-Indikator, Power-Charging via Tastendruck, Winkel-basierter Projektil-Launch, Turn-Management.

## Phase 5 – Kamera, HUD, Turn-Loop

**5.1 – Kamera-Follow**

- Ziel: Deadzone, sanftes Nachziehen.

**5.2 – HUD Minimal**

- Ziel: Wind/Power-Placeholder, Health, Timer.

**5.3 – Rundenlogik**

- Ziel: Spielerwechsel nach Schuss/Timer.

## Leitplanken

- Bitpacking für Performance.
- Carve nur im betroffenen AABB-Bereich.
- Substeps für stabilere Bewegung.
- Erst korrekt, dann optimieren (Dirty-Rects, Segment-Fill).
