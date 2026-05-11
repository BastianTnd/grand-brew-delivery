# Grand Brew Delivery 🍺

**Grand Brew Delivery** is a fast-paced top-down arcade racer developed with **Godot 4.3**. The game combines precise driving mechanics with a strategic gameplay loop consisting of gathering, brewing, and delivering.

> **Background:** This project originally originated as part of **Godot Wild Jam 92** and was expanded post-jam, specifically focusing on a Procedural Content Generation (PCG) system and refined vehicle physics.

---

## 🍺 Game Vision
As a brewery courier in a bustling city, your mission is:
1. **Gather:** Locate the three essential ingredients (**Hops, Malt, Water**) scattered across the map.
2. **Brew:** Return them to the brewery to load your vehicle with fresh beer.
3. **Deliver:** Transport the cargo to the bar as quickly as possible—but be careful: every crash costs you valuable cargo!

---

## 🎮 Key Features
* **Procedural Content Generation (PCG):** A dynamic map system generates a new city layout from handcrafted modules (chunks) every time you start a game.
* **Dual-Map System:** Players can choose between the classic, handcrafted **Legacy Map** and the randomly generated **PCG Map**.
* **Vehicle Classes:** * *Delivery Van:* Heavy and robust with a high load capacity.
    * *Sportscar:* Extremely fast and agile, but with limited tank volume to ensure gameplay balance.
* **Realistic Physics:** Driving behavior (braking distance, inertia) changes dynamically based on the amount of beer currently loaded.
* **Highscore System:** Local storage of best times (JSON-based) including name entry on the Game Over screen.

---

## 🎨 Credits & Original Contributions
We take pride in the following components which were designed and implemented specifically for this project:

### Art & Graphics (Original Assets)
* **Vehicles:** Custom-designed sprites for the Delivery Van and the Sportscar.
* **Items:** Original artwork for all collectibles (Hops, Malt, Water) as well as the beer keg icons used in the HUD.
* **Screens:** Complete visual design of the Title Screen (Main Menu) and the End Screen (Game Over).

### Programming & Design
* **Bastian Triendl:** Vehicle physics, UI/HUD system, custom screen sprites, highscore logic, core gameplay loop.
* **Nalin Caswell:** Procedural Content Generation (PCG), sound architecture, core gameplay loop, map balancing, and playtest organization.

### Third-Party & Licenses
* **Tileset:** Built using the "RPG Urban Pack" by Kenney: [kenney.nl](https://kenney.nl/assets/rpg-urban-pack)
* **Buildings:** The Brewing Station and Bar are from the "City Prop Tileset" by shidky: [shidky.itch.io](https://shidky.itch.io/city-prop-tileset)
* **Car Sprites (Legacy):** Base car sprites from "Top View Car Truck Sprites" by gameguy: [opengameart.org](https://opengameart.org/content/top-view-car-truck-sprites)
* **Menu-Music:** "A Conversation with Saul (Jazz/Blues Shuffle)" by Matthew Pablo: [opengameart.org](https://opengameart.org/content/a-conversation-with-saul-jazzblues-shuffle)
* **Game-Music** "Pixel Sprinter" by Zane Little Music: [opengameart.org](https://opengameart.org/content/pixel-sprinter)

---

## 🛠 Technical Setup
To run the project locally:
1. Ensure **Godot 4.3** (or newer) is installed.
2. Clone this repository: `git clone [REPO_URL]`
3. Open `project.godot` in the Godot Editor.
4. Run the game via `main.tscn`.

---

## 📋 Development History (Highlights)
* **Phase 1 (Jam):** Prototyping controls and the gathering system.
* **Phase 2 (Refinement):** Implementation of damage logic (hit counter) and core driving physics.
* **Phase 3 (Final):** Integration of Procedural Content Generation (PCG) and final balancing of vehicle classes and map scales.

---
*Developed for the "Game Engineering" module under Prof. Dr. Kai Eckert at the University of Applied Sciences Mannheim (Technische Hochschule Mannheim).*
