# Projektregeln — Claude Task Menu Bar

## Vor jedem GitHub-Push

**Immer zuerst `README.md` und `Notiz.md` aktualisieren**, bevor Änderungen gepusht werden:

- `README.md` — Benutzer-Dokumentation: neue Features, geänderte Bedienung, Build-Schritte
- `Notiz.md` — Technische Übergabedatei: umgesetzte Funktionen (Tabelle), Commit-Verlauf, offene Punkte

Beide Dateien sollen stets den aktuellen Stand widerspiegeln, damit jemand der das Repo neu öffnet sofort alle relevanten Infos hat.

## Branch

Entwicklung auf `main`. Alle Commits und Pushes gehen dorthin.

## Git-Konfiguration

```bash
git config user.email noreply@anthropic.com
git config user.name Claude
```

## Projektüberblick

Native macOS Menu-Bar-App (SwiftUI, SPM, macOS 13+).  
Kein Xcode-Projekt — Build via `./build-app.sh`.  
Icon wird beim Build automatisch generiert (`create_icon.swift`).
