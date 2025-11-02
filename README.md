# ETH Zeiterfassung (Flutter)

Plattformen: **iOS & Android**  
Betrieb: **Offline** (lokale JSON-Datei)  
Export: **PDF** (Monatsübersicht)

## Features
- Stempeln (Start/Ende + Tätigkeit: Büro, Pause, Baustelle)
- Tagesliste & Monatsübersicht
- PDF-Export (Monatsübersicht) ähnlich dem Screenshot
- Kein Login, keine Cloud – lokale Speicherung

## Schnellstart
1. Flutter SDK installieren.
2. Im Projektordner:
   ```bash
   flutter pub get
   flutter run
   ```
3. Für PDF-Export auf einem echten Gerät testen (Simulator kann Teilen ggf. nicht öffnen).

## Projektstruktur
- `lib/models/` – Datenklassen
- `lib/services/` – Lokaler Speicher (JSON-Datei) & PDF-Export
- `lib/screens/` – UI-Screens (Stempeln, Stunden, Export)
- `assets/logo.png` – App-Logo (Platzhalter – kann durch das ETH-Logo ersetzt werden)

## Hinweise
- Daten werden in `ApplicationDocumentsDirectory/eth_hours.json` gespeichert.
- Aktivitäten sind fest: Büro, Pause, Baustelle.
- Zeitzonen/Formatierung via `intl`.


### Update
- ETH⚡ Logo wurde nachgezeichnet und integriert (`assets/logo.png`).
