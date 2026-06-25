# Projektnotiz — Claude Task Menu Bar

**Letzter Stand:** Juni 2026  
**Branch:** `main`  
**Repo:** `https://github.com/wundi77/claude-task-menu-bar`

---

## Was ist das?

Eine native macOS-App, die ausschließlich in der Menüleiste lebt (kein Dock-Icon). Sie zeigt ein Trello-ähnliches Board mit drei Spalten.

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
| Dynamische Fensterhöhe (längste Spalte, max. 50 % Screen) | ✅ |
| Karten-Icons immer sichtbar, keine Höhensprünge beim Hover | ✅ |
| Kein abgeschnittener Text in Titel/Notizen | ✅ |
| Spaltenbreite ca. doppelt so breit (1440 px gesamt) | ✅ |
| Spaltennamen einzeln änderbar (Klick auf Titel, persistiert) | ✅ |

---

## Technischer Aufbau

**Sprache / Framework:** Swift / SwiftUI, macOS 13+  
**Projektsystem:** Swift Package Manager (SPM) — kein Xcode-Projekt

### Projektstruktur

```
Claude-Task-Menu-Bar/
├── Package.swift
├── build-app.sh
├── create_icon.swift
├── CLAUDE.md
├── README.md
├── Notiz.md
└── Sources/ClaudeTaskMenuBar/
    ├── ClaudeTaskMenuBarApp.swift
    ├── Models/
    │   └── TaskModel.swift
    └── Views/
        ├── TaskBoardView.swift
        ├── ColumnView.swift
        ├── TaskCardView.swift
        └── AddTaskView.swift
```

### Schlüssel-Technologien

- `MenuBarExtra` + `.menuBarExtraStyle(.window)`
- `NSApp.setActivationPolicy(.accessory)` — kein Dock-Icon
- `SMAppService.mainApp.register()` — Login-Item
- `Transferable` + `CodableRepresentation` — Drag & Drop
- `UserDefaults` — Aufgaben (`com.claude.taskmenbar.tasks`) + Spaltennamen (`com.claude.taskmenbar.columnTitles`)
- `GeometryReader` + `PreferenceKey` — echte Inhaltshoehe fur dynamische Fenstergröße
- `LSUIElement = true`, `CFBundleIconFile = AppIcon` in Info.plist

### Spaltennamen (ColumnView + TaskStore)

`TaskStore.columnTitles: [String: String]` speichert benutzerdefinierte Namen, gekeyt nach `Column.rawValue`. `title(for:)` gibt den Namen zurück (Fallback: rawValue). In `ColumnView` ist der Spaltenname ein klickbares `Text`-Element das in ein `TextField` wechselt; `saveTitle()` ruft `store.updateColumnTitle(_:title:)` auf.

### App-Icon (create_icon.swift)

`CGContext`-basiert, kein Display nötig. Build: `sips` + `iconutil` → `AppIcon.icns`.

---

## App installieren / aktualisieren

```bash
git clone https://github.com/wundi77/claude-task-menu-bar.git
cd claude-task-menu-bar && chmod +x build-app.sh && ./build-app.sh
cp -r ClaudeTaskMenuBar.app /Applications/ && open /Applications/ClaudeTaskMenuBar.app
```

**Update:** `git pull && ./build-app.sh`, dann App ersetzen und neu starten.

---

## Bekannte Einschränkungen

1. Autostart-Checkbox funktioniert nur aus `/Applications`.
2. Alte Login-Item-Einträge ggf. manuell entfernen.
3. Fensterhöhe bei gleichzeitig vielen langen Titeln + Notizen: Scrollbalken greift automatisch.
