# Current Implementation TODOs

Diese Datei enthält die aktuellen Implementierungsaufgaben für die Weiterentwicklung des Pixel Trench Projekts.

## 🎯 Aktuelle Aufgabe: Explosion mit Schaden/Knockback (Phase 4.3)

### **Strenge Implementierungsaufgabe: Explosion-System**

● **Learn by Doing**

**Context:** Du hast bereits HP zum Worm-Objekt hinzugefügt. Jetzt musst du das komplette Explosion-System implementieren, das Schaden basierend auf Distanz verursacht und Würmer wegschleudert. Explosionen sollen nicht nur Terrain zerstören, sondern auch strategisches Gameplay ermöglichen.

**Your Task:** Erstelle eine `explode(cx, cy, radius, damage_radius)` Funktion und integriere sie in das Projektil-System. Die Funktion soll sowohl Terrain carven als auch Würmer schädigen und wegschleudern.

**Guidance:** 
- Berechne Distanz zwischen Explosion und Worm
- Schaden umgekehrt proportional zur Distanz (näher = mehr Schaden)
- Knockback-Vektor zeigt von Explosion weg
- Knockback-Stärke abhängig von Schaden
- Berücksichtige Terrain-Abschirmung (Line-of-Sight)
- Visuelle Feedback für Schadenszahlen

**Strikte Erfolgskriterien:**
1. ✅ Worm verliert HP basierend auf Explosions-Distanz
2. ✅ Knockback schleudert Worm realistisch weg
3. ✅ Terrain zwischen Explosion und Worm reduziert Schaden
4. ✅ Worm stirbt bei HP ≤ 0 mit visueller Indication
5. ✅ Schadenszahlen werden kurz angezeigt

**Härtetest:** Explodiere neben dem Worm und schaue ob er Schaden nimmt und weggeschleudert wird!

### Code-Location:
- **Datei:** `pixeltrench.p8`
- **Neue Funktion:** `explode(cx, cy, radius, damage_radius)`
- **Integration:** In `update_projectiles()` bei Kollision

### Status: 
- [ ] explode() Funktion implementiert
- [ ] Distanz-basierter Schaden funktioniert
- [ ] Knockback-Physik implementiert
- [ ] Line-of-Sight Terrain-Abschirmung
- [ ] Visuelle Schadens-Indikatoren

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