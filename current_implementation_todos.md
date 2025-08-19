# Current Implementation TODOs

Diese Datei enthält die aktuellen Implementierungsaufgaben für die Weiterentwicklung des Pixel Trench Projekts.

## 🎯 Aktuelle Aufgabe: Aim & Shoot System (Phase 4.4)

### **Strenge Implementierungsaufgabe: Worm Shooting Mechanics**

● **Learn by Doing**

**Context:** Du hast ein vollständiges Explosion-System. Jetzt braucht das Spiel echtes Worms-Gameplay: Zielen, Power aufladen und schießen! Das macht aus deinem Tech-Demo ein spielbares Game.

**Your Task:** Implementiere ein komplettes Aim & Shoot System mit Ziel-Indikator, Power-Charging und Winkel-basiertem Projektil-Launch. Der Spieler soll strategisch zielen und die Schuss-Stärke kontrollieren können.

**Guidance:** 
- Berechne Winkel von Worm zur Maus-Position (`atan2`)
- Power-Charging: Taste halten = mehr Power (0-100%)
- Visual Aim-Line: Zeige Schuss-Richtung an
- Launch-Velocity: Winkel + Power → vx, vy Komponenten
- Power-Indikator: Balken oder Kreis der größer wird
- Schuss nur wenn Worm am Boden und alive

**Strikte Erfolgskriterien:**
1. ✅ Ziel-Linie zeigt von Worm zur Maus-Position
2. ✅ Power lädt auf während Taste gehalten (0-100%)
3. ✅ Projektil startet mit korrektem Winkel und Geschwindigkeit
4. ✅ Keine Schüsse während Worm in der Luft
5. ✅ Power-Indikator ist visuell klar erkennbar
6. ✅ Ein Schuss pro Turn (verhindert Spam)

**Härtetest:** Verschiedene Winkel und Power-Level → Projektile landen vorhersagbar!

### Code-Location:
- **Datei:** `pixeltrench.p8`
- **Neue Systeme:** Aim calculation, Power charging, Projectile launch
- **Integration:** In `update_worm()` und `_draw()`

### Status: 
- [ ] Aim-Winkel von Worm zu Maus berechnet
- [ ] Power-Charging System implementiert
- [ ] Visual Aim-Line gezeichnet
- [ ] Power-Indikator angezeigt
- [ ] Projektil-Launch mit Winkel/Power
- [ ] Turn-Management (ein Schuss pro Turn)

---

## Nächste geplante Aufgaben:

### 4.3 - Explosion mit Schaden/Knockback
- Implementierung von HP-System für Würmer
- Knockback-Mechanik bei Explosionen
- Schaden basierend auf Distanz zur Explosion

### 5.1 - Kamera-Follow System
- Deadzone-basierte Kamera
- Sanftes Nachfolgen des aktiven Wurms
- Viewport-Grenzen berücksichtigen