# Projektnotiz — Claude Task Menu Bar

**Letzter Stand:** Juni 2026  
**Branch:** `main`  
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
| Aufgabe löschen (Papierkorb-Icon auf Karte) | ✅ |
| Aufgabe zwischen Spalten verschieben (Drag & Drop) | ✅ |
| Aufgabe verschieben via Rechtsklick-Kontextmenü | ✅ |
| Rechtsklick-Kontextmenü pro Karte | ✅ |
| Autostart beim Login (Checkbox im Footer) | ✅ |
| Notizfeld pro Karte (hinzufügen/bearbeiten/löschen) | ✅ |
| Scrollbalken in Spalten bei langen Listen | ✅ |
| Kartentitel bearbeiten (Bleistift-Icon / Kontextmenü) | ✅ |
| Kartentitel kopieren (Textauswahl aktiv) | ✅ |
| Datenpersistenz via UserDefaults | ✅ |
| Kein Terminal-Fenster beim Autostart | ✅ |
| Modernes App-Icon (Apple-Stil, Kanban-Design) | ✅ |
| Dynamische Fensterhöhe (längste Spalte, max. 50% Screen) | ✅ |
| Karten-Icons immer sichtbar, keine Höhensprünge beim Hover | ✅ |

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
├── CLAUDE.md                             ← Projektregeln für KI-Assistenten
├── README.md
├── Notiz.md                              ← diese Datei
└── Sources/ClaudeTaskMenuBar/
    ├── ClaudeTaskMenuBarApp.swift        ← App-Einstieg, MenuBarExtra
    ├── Models/
    │   └── TaskModel.swift               ← Task-Struct + TaskStore
    └── Views/
        ├── TaskBoardView.swift           ← Board + dynamische Höhe + Footer
        ├── ColumnView.swift              ← Spalte mit Scrollview + Drag-Drop
        ├── TaskCardView.swift            ← Karte mit immer sichtbaren Icons
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
- `NSScreen.main?.visibleFrame.height` — dynamische Fensterhöhe

### Karten-Layout (TaskCardView)

Die drei Icons (Bleistift, Notiz, Papierkorb) sind **immer sichtbar** in einem kompakten `HStack` rechts neben dem Titel. Sie reagieren nur mit Opacity auf Hover (gedimmt → kräftig), die Kartenhöhe bleibt dabei konstant. Pfeil-Buttons zum Verschieben wurden entfernt — das Verschieben funktioniert per Drag & Drop und Rechtsklick-Menü.

### Dynamische Fensterhöhe (TaskBoardView)

```swift
private var boardHeight: CGFloat {
    let maxCards = Task.Column.allCases.map { store.tasks(in: $0).count }.max() ?? 0
    // headerH(38) + maxCards * cardH(42) + colPad(20) + footerH(36)
    let ideal = 38 + CGFloat(maxCards) * 42 + 20 + 36
    let screenH = NSScreen.main?.visibleFrame.height ?? 800
    return min(max(ideal, 160), screenH * 0.5)
}
```

### App-Icon (create_icon.swift)

1. `swift create_icon.swift` → `AppIcon_1024.png` via `CGContext` (kein Display nötig)
2. `sips` → alle Größen (16–1024 px, inkl. @2x)
3. `iconutil` → `AppIcon.icns`
4. `.icns` in `Contents/Resources/`, `CFBundleIconFile` in `Info.plist`

### Backward-Compatibility

Das `notes`-Feld im Task-Struct hat einen Custom-Decoder mit `decodeIfPresent`, damit ältere gespeicherte Daten (ohne `notes`-Schlüssel) weiterhin geladen werden können.

---

## App auf dem Mac installieren / aktualisieren

### Erster Start (neuer Rechner)

```bash
git clone https://github.com/wundi77/claude-task-menu-bar.git
cd claude-task-menu-bar
chmod +x build-app.sh
./build-app.sh
cp -r ClaudeTaskMenuBar.app /Applications/
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

1. **Bilder als Anhang** — noch nicht umgesetzt.
2. **Autostart-Checkbox** — funktioniert nur aus `/Applications` als `.app`-Bundle.
3. **Alte Login-Item-Einträge** — ggf. manuell entfernen: Systemeinstellungen → Allgemein → Startobjekte.
4. **Kartenhöhe bei mehrzeiligen Titeln** — `boardHeight` nutzt einen festen Schätzwert (42 px/Karte); bei vielen langen Titeln kann das Fenster etwas zu niedrig sein. Der Scrollbalken greift dann automatisch.

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
| `3d73619` | App-Icon: create_icon.swift + build-app.sh erweitert |
| `c39b338` | Bugfix Icon-Generator: CGContext statt NSImage.lockFocus |
| aktuell   | Dynamische Fensterhöhe; Icons immer sichtbar; CLAUDE.md |
