# Claude Task Menu Bar

Eine native macOS Menu-Bar-App im Trello-Stil — kein Dock-Icon, lebt nur in der Menüleiste.

```
┌──────────────────────────────────────────────────────────┐
│  ToDo  (2)  +  │  Doing  (1)  +  │  Done  (1)  +        │
│────────────────│─────────────────│──────────────────────│
│ ┌────────────┐ │ ┌─────────────┐ │ ┌──────────────────┐ │
│ │ Aufgabe A  │ │ │ Aufgabe C  ← │ │ │ Aufgabe D  ← 🗑 │ │
│ └────────────┘ │ └─────────────┘ │ └──────────────────┘ │
│ ┌────────────┐ │                 │                       │
│ │ Aufgabe B →│ │                 │                       │
│ └────────────┘ │                 │                       │
└──────────────────────────────────────────────────────────┘
```

## Anforderungen

- macOS 13 Ventura oder neuer
- Xcode 15 oder neuer

## Installation & Start

### Option 1 — Xcode (empfohlen)

1. Repository klonen:
   ```bash
   git clone https://github.com/wundi77/claude-task-menu-bar.git
   cd claude-task-menu-bar
   ```
2. `Package.swift` in Xcode öffnen:
   ```bash
   open Package.swift
   ```
3. Target **ClaudeTaskMenuBar** auswählen, **My Mac** als Ziel wählen
4. **Run** (⌘R) drücken

### Option 2 — Kommandozeile

```bash
swift run
```

> **Hinweis:** Beim ersten Start fragt macOS nach Berechtigungen. Einfach bestätigen.

## Bedienung

| Aktion | Methode |
|---|---|
| Board öffnen | Klick auf das Checklisten-Symbol in der Menüleiste |
| Aufgabe hinzufügen | **+** in der Spaltenüberschrift |
| Aufgabe löschen | Hover über Karte → 🗑 |
| Aufgabe verschieben | Hover über Karte → ← / → **oder** Drag & Drop zwischen Spalten |
| Kontextmenü | Rechtsklick auf eine Karte |
| Hinzufügen abbrechen | `Escape` |
| Hinzufügen bestätigen | `Return` (einzelne Zeile) / `⌘Return` (mehrzeilig) |

## Datenspeicherung

Aufgaben werden automatisch in `UserDefaults` gespeichert und beim nächsten Start wiederhergestellt.

## Projektstruktur

```
Sources/ClaudeTaskMenuBar/
├── ClaudeTaskMenuBarApp.swift   # App-Einstiegspunkt, MenuBarExtra
├── Models/
│   └── TaskModel.swift          # Task-Struct + TaskStore (ObservableObject)
└── Views/
    ├── TaskBoardView.swift      # Haupt-Board (3 Spalten nebeneinander)
    ├── ColumnView.swift         # Einzelne Spalte mit Drag-Drop-Ziel
    ├── TaskCardView.swift       # Aufgaben-Karte mit Hover-Controls
    └── AddTaskView.swift        # Formular zum Hinzufügen einer Aufgabe
```
