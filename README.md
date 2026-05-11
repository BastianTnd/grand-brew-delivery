# Grand Brew Delivery 🍺

**Grand Brew Delivery** ist ein rasanter Top-Down Arcade-Racer, entwickelt mit **Godot 4.3**. Das Spiel kombiniert präzises Fahrverhalten mit einem strategischen Gameplay-Loop aus Sammeln, Brauen und Ausliefern.

> **Hintergrund:** Dieses Projekt entstand ursprünglich im Rahmen des **Godot Wild Jam 92** und wurde post Game jam erweitert, insbesondere um ein prozedurales Generierungssystem (PCG) und verfeinerte Fahrzeugphysik.

---

## 🍺 Game Vision
In einer Stadt schlüpfst du in die Rolle eines Brauerei-Kuriers. Deine Mission:
1. **Sammeln:** Finde die drei essenziellen Zutaten (Hopfen, Malz, Wasser) auf der Karte.
2. **Brauen:** Bringe sie zur Brauerei, um dein Fahrzeug mit frischem Bier zu beladen.
3. **Liefern:** Bringe die Fracht so schnell wie möglich zur Bar – aber Vorsicht: Jeder Unfall kostet wertvolle Ladung!

---

## 🎮 Key Features
* **Procedural Content Generation (PCG):** Ein dynamisches Kartensystem erstellt bei jedem Start ein neues Stadtlayout aus handgefertigten Modulen (Chunks).
* **Dual-Map-System:** Spieler können zwischen der klassischen, handgezeichneten **Legacy Map** und der zufallsgenerierten **PCG Map** wählen.
* **Fahrzeug-Klassen:** *Delivery Van:* Schwerfällig, aber robust mit hoher Ladekapazität.
    * *Sportscar:* Extrem schnell und wendig, jedoch mit begrenztem Tankvolumen für eine bessere Spielbalance.
* **Realistische Physik:** Das Fahrverhalten (Bremsweg, Trägheit) ändert sich dynamisch basierend auf der Menge der geladenen Bierfässer.
* **Highscore-System:** Lokale Speicherung der Bestzeiten (JSON-basiert) inklusive Namenseingabe im Game-Over-Screen.

---

## 🎨 Credits & Eigenleistungen
Folgende Bestandteile wurden von uns eigens für dieses Projekt entworfen:

### Grafik (Original Assets)
* **Fahrzeuge:** Eigens erstellte Sprites für den Lieferwagen und den Sportwagen.
* **Items:** Alle Collectibles (Hopfen, Malz, Wasser) sowie die Bierfass-Icons im HUD.
* **Screens:** Vollständiges Design des Title-Screens und des End-Screens.

### Programmierung & Design
* **Bastian Triendl:** Fahrzeugphysik, UI/HUD-System, eigene Sprites Screens, Highscore-Logik, Core Gameplay-Loop-Logik.
* **Nalin Caswell:** Prozedurale Karten-Generierung (PCG), Sound-Architektur, Core Gameplay-Loop-Logik, Map-Balancing & Test-Organisation.

### Third-Party & Lizenzen
* **Tileset:** The Map was built using the tileset "RPG Urban Pack" from Kenney: https://kenney.nl/assets/rpg-urban-pack
* **Bar and Brewing Station:** The Buildings used for the Brewing Station and Bar are from the tileset "City Prop Tileset" by shidky: https://shidky.itch.io/city-prop-tileset
* **Cars:** The Sprites we used for the cars are from "Top View Car Truck Sprites" by gameguy: https://opengameart.org/content/top-view-car-truck-sprites
* **Audio:** 

---

## 🛠 Technisches Setup
Um das Projekt lokal zu starten:
1. Stellen Sie sicher, dass **Godot 4.3** (oder neuer) installiert ist.
2. Klonen Sie dieses Repository: `git clone [REPO_URL]`
3. Öffnen Sie die `project.godot` im Godot Editor.
4. Starten Sie das Spiel über die `main.tscn`.

---

## 📋 Entwicklungshistorie (Auszug)
* **Phase 1 (Jam):** Prototyping der Steuerung und des Sammel-Systems.
* **Phase 2 (Refinement):** Implementierung der Schadenslogik (Hit-Counter) und der zentralen Driving-Physic.
* **Phase 3 (Final):** Integration der prozeduralen Generierung (PCG) und finales Balancing der Fahrzeugklassen und Kartengrößen.

---
*Erstellt im Rahmen des Moduls Game Engineering bei Prof. Dr. Kai Eckert an der Technischen Hochschule Mannheim.*
