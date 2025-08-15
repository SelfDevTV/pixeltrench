# Projektübersicht – Worms-Klon mit Bitmasken-Terrain

Dieses Dokument verknüpft alle relevanten Dateien des Projekts und erklärt deren Zweck. Es dient als **einzige Einstiegsdatei** für eine KI oder neue Entwickler, um das gesamte Projektkonzept, die Architektur, Mechaniken und die Entwicklungs-Roadmap zu verstehen.

## Dateien

1. **ARCHITECTURE.md**
- Enthält den technischen Überblick über Code-Struktur, Module, Funktionen, globale Variablen und Subsysteme.
- Beschreibt, wie das Spiel intern aufgebaut ist, inkl. PICO-8-spezifischer Nutzung.

2. **MECHANICS.md**
- Enthält alle Gameplay-Mechaniken, Steuerung, Physik, Kollisionslogik, Entity-Design, Balancing-Parameter und UI/HUD-Elemente.
- Erklärt das Regelwerk und die Abweichungen vom Referenzspiel.

3. **ROADMAP.md**
- Schritt-für-Schritt-Plan im *Lehrer-Modus*.
- Phasen und Aufgaben mit Zielen, Kriterien, Tests und Hinweisen.
- Grundlage für iteratives Arbeiten und gezielte Aufgabenvergabe.

## Nutzungshinweis für KI

- Lade **nur diese Datei** (`PROJECT_OVERVIEW.md`) in den Kontext.
- Die KI findet hier Verweise auf alle wichtigen Unterlagen.
- Lies zunächst die *ARCHITECTURE.md*, um den technischen Rahmen zu verstehen.
- Sieh dann in *MECHANICS.md* für das Gameplay-Design.
- Nutze *ROADMAP.md* für die konkrete Arbeitsplanung im Lehrer-Modus.

## Projektziel

- Entwicklung eines **2D-Worms-Klons** in PICO-8 mit Bitmasken-Terrain.
- Fokus: Terrain-Generierung, Zerstörung, Worm-Bewegung, Kollisionen.
- Erst eine abgespeckte Version, danach erweiterbar.


## Referenzprojekt

- **Datei:** `mm.p8`
- Dies ist der vollständige Source-Code des Beispielprojekts (PICO-8-Cartridge), aus dem die Architektur- und Mechanik-Dokumente abgeleitet wurden.
- Die KI kann daraus Techniken und Muster analysieren, um das neue Spiel zu entwerfen, jedoch **keinen Code direkt kopieren**.

### Parsing-Hinweise

Beim Parsen der `.p8`-Datei ist zu beachten:
- Die Datei liegt im **Textformat** vor und enthält Abschnitte, die mit `__lua__`, `__gfx__`, `__map__`, `__sfx__`, `__music__` beginnen.
- Der Lua-Quelltext steht zwischen `__lua__` und dem nächsten `__...__`-Marker.
- Manche Parser scheitern, wenn vor `__lua__` unsichtbare Zeichen (BOM, Spaces, Tabs) stehen.
- Robuste Strategie:
  1. Zeilenweise einlesen.
  2. Eine Regex verwenden, die auch führende/folgende Whitespaces akzeptiert, z. B. `^\s*__([a-z0-9]+)__\s*$`.
  3. Ab der Zeile nach `__lua__` bis zum nächsten Marker alles als Codeblock übernehmen.
- Analog können die anderen Abschnitte extrahiert werden.

## Leitprinzipien

- **Lehrer-Modus:** KI gibt Aufgaben, Code nur auf Anfrage.
- **Saubere Trennung:** Architektur, Mechanik, Roadmap sind klar getrennt.
- **Eigenständigkeit:** Spiel basiert auf eigenem Code, nicht auf dem Referenzprojekt.
