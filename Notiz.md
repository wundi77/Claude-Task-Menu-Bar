# Projektnotiz — Claude Task Menu Bar

**Letzter Stand:** Juni 2026  
**Branch:** `claude/compassionate-thompson-ng7mhv`  
**Repo:** `https://github.com/wundi77/claude-task-menu-bar`

---

## Was ist das?

Eine native macOS-App, die ausschließlich in der Menüleiste lebt (kein Dock-Icon). Sie zeigt ein Trello-ähnliches Board mit drei Spalten: **ToDo**, **Doing**, **Done**.

---

## Umgesetzte Funktionen

| Funktion | Status |
|---|---|
| Menüleisten-App ohne Dock-Icon | ✅ |
| 3 Spalten: ToDo / Doing / Done | ✅ |
| Aufgabe hinzufügen (+ Button) | ✅ |
| Aufgabe löschen (Hover → Papierkorb) | ✅ |
| Aufgabe zwischen Spalten verschieben (Hover-Pfeile) | ✅ |
| Drag & Drop zwischen Spalten | ✅ |
| Rechtsklick-Kontextmenü pro Karte | ✅ |
| Autostart beim Login (Checkbox im Footer) | ✅ |
| Notizfeld pro Karte (hinzufügen/bearbeiten/löschen) | ✅ |
| Scrollbalken in Spalten bei langen Listen | ✅ |
| Kartentitel bearbeiten (Bleistift-Icon / Kontextmenü) | ✅ |
| Kartentitel kopieren (Textauswahl aktiv) | ✅ |
| Datenpersistenz via UserDefaults | ✅ |
| Kein Terminal-Fenster beim Autostart | ✅ |
| Modernes App-Icon (Apple-Stil, Kanban-Design) | ✅ |

---

## Technischer Aufbau

**Sprache / Framework:** Swift / SwiftUI, macOS 13+  
**Projektsystem:** Swift Package Manager (SPM) — kein Xcode-Projekt

### Wichtig: SPM executableTarget ≠ .app Bundle

SPM baut einen Unix-CLI-Prozess, keine `.app`-Datei. Für den Betrieb als echte macOS-App wird `build-app.sh` verwendet, das das Bundle manuell zusammenbaut.

### Projektstruktur

```
Claude-Task-Menu-Bar/
├── Package.swift
├── build-app.sh                          ← App-Bundle Builder (wichtig!)
├── create_icon.swift                     ← Icon-Generator (Core Graphics)
├── README.md
├── Notiz.md                              ← diese Datei
└── Sources/ClaudeTaskMenuBar/
    ├── ClaudeTaskMenuBarApp.swift        ← App-Einstieg, MenuBarExtra
    ├── Models/
    │   └── TaskModel.swift               ← Task-Struct + TaskStore
    └── Views/
        ├── TaskBoardView.swift           ← Board + LoginItemToggle
        ├── ColumnView.swift              ← Spalte mit Scrollview + Drag-Drop
        ├── TaskCardView.swift            ← Karte mit Hover-Controls + Inline-Editing
        └── AddTaskView.swift             ← Eingabeformular neue Aufgabe
```

### Schlüssel-Technologien

- `MenuBarExtra` + `.menuBarExtraStyle(.window)` — Menüleisten-Fenster
- `NSApp.setActivationPolicy(.accessory)` — versteckt das Dock-Icon
- `SMAppService.mainApp.register()` — Login-Item (ServiceManagement)
- `Transferable` + `CodableRepresentation` — Drag & Drop
- `UserDefaults` — Datenspeicherung, Key: `com.claude.taskmenbar.tasks`
- `LSUIElement = true` in Info.plist — verhindert Terminal beim Autostart
- `codesign --force --deep --sign -` — Ad-hoc-Signierung
- `CFBundleIconFile = AppIcon` in Info.plist — App-Icon

### App-Icon (create_icon.swift)

Das Icon wird beim Build automatisch von `build-app.sh` generiert:

1. `swift create_icon.swift` → erzeugt `AppIcon_1024.png` via Core Graphics / AppKit
2. `sips` → skaliert auf alle macOS-Standardgrößen (16–1024 px, inkl. @2x)
3. `iconutil` → konvertiert `AppIcon.iconset/` → `AppIcon.icns`
4. `.icns` wird in `Contents/Resources/` des Bundles kopiert

**Icon-Design:**
- Abgerundetes Quadrat (Apple-Stil, Radius ≈ 22 % der Breite)
- Blau-Indigo-Verlauf (diagonaler Gradient von oben-links nach unten-rechts)
- Drei weiße Kanban-Spalten mit abgestuften Höhen (ToDo > Doing > Done)
- Weiße Karten in jeder Spalte mit transparenter Abstufung
- Subtiler Glanz-Effekt oben (weißer Gradient)

### Backward-Compatibility

Das `notes`-Feld im Task-Struct hat einen Custom-Decoder mit `decodeIfPresent`, damit ältere gespeicherte Daten (ohne `notes`-Schlüssel) weiterhin geladen werden können.

---

## App auf dem Mac installieren / aktualisieren

### Erster Start (neuer Rechner)

```bash
# 1. Repository klonen
git clone -b claude/compassionate-thompson-ng7mhv \
  https://github.com/wundi77/claude-task-menu-bar.git
cd claude-task-menu-bar

# 2. App bauen (inkl. Icon-Generierung)
chmod +x build-app.sh
./build-app.sh

# 3. In /Programme verschieben
cp -r ClaudeTaskMenuBar.app /Applications/

# 4. Starten
open /Applications/ClaudeTaskMenuBar.app
```

### Update (Repository bereits geklont)

```bash
cd claude-task-menu-bar
git pull
./build-app.sh
rm -rf /Applications/ClaudeTaskMenuBar.app
cp -r ClaudeTaskMenuBar.app /Applications/
open /Applications/ClaudeTaskMenuBar.app
```

### Voraussetzungen

- macOS 13 Ventura oder neuer
- Xcode Command Line Tools: `xcode-select --install`

---

## Bekannte Einschränkungen / offene Punkte

1. **Bilder als Anhang** — noch nicht umgesetzt. Wäre möglich via:
   - Datei-Picker (`.fileImporter`)
   - Speicherung in `~/Library/Application Support/com.claude.taskmenbar/attachments/`
   - Thumbnail-Vorschau in der Karte
   - Cleanup beim Löschen einer Karte

2. **Autostart-Checkbox** — funktioniert nur, wenn die App aus `/Applications` als `.app`-Bundle läuft. Läuft sie aus einem anderen Pfad oder als roher Unix-Prozess, zeigt der Footer stattdessen einen Hinweis.

3. **Alte Login-Item-Einträge** — falls die App früher mal als Unix-Prozess (z. B. aus Xcode heraus) als Login-Item registriert wurde, muss der alte Eintrag manuell entfernt werden: **Systemeinstellungen → Allgemein → Startobjekte**.

4. **Fenstergröße** — aktuell fest auf 720×490 px kodiert in `TaskBoardView.swift` (`.frame(width: 720, height: 490)`).

---

## Commit-Verlauf (zusammengefasst)

| Commit | Inhalt |
|---|---|
| `8609e5a` | Initiale App — 3 Spalten, Hover-Controls, Drag & Drop, Persistenz |
| `77fae27` | Bugfix: fehlender SwiftUI-Import für `Transferable` |
| `f771159` | Autostart via `SMAppService` |
| `a570047` | Bugfix: `onChange` für macOS 13 kompatibel gemacht |
| `f5e2e5e` | Autostart-Toggle gesperrt wenn App nicht in /Applications |
| `d5de4ce` | `build-app.sh` — erzeugt echtes .app-Bundle mit LSUIElement |
| `1e0ea97` | Notizfeld pro Karte — hinzufügen/bearbeiten/löschen |
| `3b1efeb` | Scrollbalken in Spalten; Titel bearbeitbar/kopierbar |
| `4fffe6c` | Notiz.md mit vollständigem Projektstand hinzugefügt |
| aktuell   | App-Icon: create_icon.swift + build-app.sh erweitert |
