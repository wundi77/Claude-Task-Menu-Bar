# Claude Task Menu Bar

Eine native macOS Menu-Bar-App im Trello-Stil — kein Dock-Icon, lebt nur in der Menüleiste.

## Anforderungen

- macOS 13 Ventura oder neuer
- Xcode Command Line Tools: `xcode-select --install`

## Installation & Start

```bash
git clone https://github.com/wundi77/claude-task-menu-bar.git
cd claude-task-menu-bar
chmod +x build-app.sh
./build-app.sh
cp -r ClaudeTaskMenuBar.app /Applications/
open /Applications/ClaudeTaskMenuBar.app
```

## Update

```bash
cd claude-task-menu-bar
git pull
./build-app.sh
rm -rf /Applications/ClaudeTaskMenuBar.app
cp -r ClaudeTaskMenuBar.app /Applications/
open /Applications/ClaudeTaskMenuBar.app
```

## Bedienung

| Aktion | Methode |
|---|---|
| Board öffnen | Klick auf das Symbol in der Menüleiste |
| Aufgabe hinzufügen | **+** in der Spaltenüberschrift |
| Aufgabe löschen | 🗑 rechts auf der Karte |
| Aufgabe verschieben | Drag & Drop zwischen Spalten **oder** Rechtsklick → Verschieben |
| Titel bearbeiten | ✏ rechts auf der Karte **oder** Rechtsklick → Bearbeiten |
| Notiz bearbeiten | 📝 rechts auf der Karte **oder** Rechtsklick → Notiz |
| Spaltenname ändern | Klick auf den Spaltentitel im Header |
| Kontextmenü | Rechtsklick auf eine Karte |
| Hinzufügen abbrechen | `Escape` |
| Hinzufügen bestätigen | `Return` (einzelne Zeile) / `⌘Return` (mehrzeilig) |

## Fenstergröße

Das Fenster ist **1440 px breit** (ca. doppelt so breit wie zuvor). Die Höhe passt sich automatisch dem Inhalt an — ab 50 % der Bildschirmhöhe erscheint ein Scrollbalken.

## App-Icon

Wird beim Build automatisch generiert (`create_icon.swift`):
- Abgerundetes Quadrat im Apple-Stil, Blau-Indigo-Verlauf
- Drei weiße Kanban-Spalten mit Karten

## Datenspeicherung

Aufgaben und Spaltennamen werden automatisch in `UserDefaults` gespeichert.

## Projektstruktur

```
Sources/ClaudeTaskMenuBar/
├── ClaudeTaskMenuBarApp.swift
├── Models/
│   └── TaskModel.swift          # Task-Struct + TaskStore (inkl. columnTitles)
└── Views/
    ├── TaskBoardView.swift      # Board (1440 px breit, dynamische Höhe)
    ├── ColumnView.swift         # Spalte mit editierbarem Titel
    ├── TaskCardView.swift       # Karte mit immer sichtbaren Icons
    └── AddTaskView.swift
```
