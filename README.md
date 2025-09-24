# rs_hud

Ein modularer, performant aufgebauter Advanced-ESX-HUD für FiveM im gelben LimeV-Stil.

## Features
- Spielerstatus: Health, Armor, Hunger, Durst (Stress optional über `Config.CustomStressStatus`)
- Fahrzeug-HUD: Geschwindigkeit (km/h|mph), RPM, Gang, Tankfüllung
- Voice-Integration (pma-voice): Talk-Indikator & Reichweite
- Seatbelt-Support via Export `exports['rs_hud']:SetSeatbelt(state)`
- Standort: Straße, Zone, Himmelsrichtung sowie In-Game-Uhrzeit
- Cinematic-Modus und HUD-Toggle per Command/Keybind
- Safezone-aware Layout & gelbes UI-Theme

## Commands & Keybinds
| Befehl | Beschreibung | Standard-Key |
| ------ | ------------ | ------------ |
| `/hud` | HUD ein-/ausblenden | F7 |
| `/cinematic` | Cinematic-Opacity umschalten | F8 |
| `/hudsettings` | Einstellungsmenü öffnen | F9 |

> Die Keybinds werden über `RegisterKeyMapping` registriert und können im FiveM-Keybinding-Menü angepasst werden.

## Installation
1. Ordner `rs_hud` in deinen Server `resources`-Ordner kopieren.
2. Resource in der `server.cfg` starten: `ensure rs_hud`.
3. Stelle sicher, dass `es_extended`, `esx_status` und optional `pma-voice` laufen.
4. Passe die `config.lua` nach Bedarf an (Update-Intervalle, Opacity, Safe-Zone etc.).

## Anpassungen
- Farben, Layout und Animationen liegen unter `html/styles.css` und `html/app.js`.
- Weitere Anzeigen (Stress, Funkkanal, Waffen, Job, Kontostände) lassen sich über zusätzliche `SendNUIMessage`-Events erweitern.
- Für persistente Settings kann in `server/server.lua` eine Speicherung (z. B. via `oxmysql`) ergänzt werden.

## Performance-Hinweise
- Unterschiedliche Tick-Raten für schnelle/mittlere/langsame Updates (150 / 400 / 1000 ms)
- Delta-basierte UI-Updates reduzieren DOM-Writes
- HUD blendet sich bei offenem Pause-Menü automatisch aus

Viel Spaß mit deinem gelben Advanced-HUD! ✨
