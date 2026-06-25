import SwiftUI

struct TaskCardView: View {
    let task: Task
    @EnvironmentObject var store: TaskStore
    @State private var isHovered = false
    @State private var isEditingNotes = false
    @State private var notesDraft = ""
    @State private var isEditingTitle = false
    @State private var titleDraft = ""
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .center, spacing: 6) {
                titleArea
                iconControls
            }

            if !task.notes.isEmpty && !isEditingNotes {
                Text(task.notes)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if isEditingNotes {
                notesEditor
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(isHovered ? 0.10 : 0.04),
                        radius: isHovered ? 4 : 2,
                        x: 0, y: isHovered ? 2 : 1)
        )
        .onHover { isHovered = $0 }
        .draggable(task)
        .contextMenu { contextMenuItems }
    }

    // MARK: - Titelbereich

    @ViewBuilder
    private var titleArea: some View {
        if isEditingTitle {
            TextField("Aufgabenname", text: $titleDraft)
                .font(.system(size: 13))
                .textFieldStyle(.plain)
                .focused($isTitleFocused)
                .onAppear { isTitleFocused = true }
                .onSubmit { saveTitleEdit() }
                .onExitCommand { isEditingTitle = false }
                .frame(maxWidth: .infinity)
        } else {
            Text(task.title)
                .font(.system(size: 13))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(4)
                .textSelection(.enabled)
        }
    }

    private func saveTitleEdit() {
        let trimmed = titleDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { store.updateTitle(task, title: trimmed) }
        isEditingTitle = false
    }

    // MARK: - Icons (immer sichtbar, kompakt)

    private var iconControls: some View {
        HStack(spacing: 3) {
            // Titel bearbeiten
            Button {
                titleDraft = task.title
                withAnimation { isEditingTitle = true }
            } label: {
                Image(systemName: "pencil")
            }
            .buttonStyle(CardIconButtonStyle(color: .gray, isHovered: isHovered))
            .help("Titel bearbeiten")

            // Notiz bearbeiten / hinzufügen
            Button {
                notesDraft = task.notes
                withAnimation { isEditingNotes = true }
            } label: {
                Image(systemName: task.notes.isEmpty ? "note.text.badge.plus" : "note.text")
            }
            .buttonStyle(CardIconButtonStyle(color: .purple, isHovered: isHovered))
            .help(task.notes.isEmpty ? "Notiz hinzufügen" : "Notiz bearbeiten")

            // Löschen
            Button {
                withAnimation { store.delete(task) }
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(CardIconButtonStyle(color: .red, isHovered: isHovered))
            .help("Aufgabe löschen")
        }
        .opacity(isEditingNotes || isEditingTitle ? 0 : 1)
    }

    // MARK: - Notiz-Editor

    private var notesEditor: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextEditor(text: $notesDraft)
                .font(.system(size: 12))
                .frame(height: 70)
                .padding(4)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )

            HStack {
                if !task.notes.isEmpty {
                    Button("Notiz löschen") {
                        store.updateNotes(task, notes: "")
                        notesDraft = ""
                        isEditingNotes = false
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                    .font(.system(size: 11))
                }
                Spacer()
                Button("Abbrechen") { isEditingNotes = false }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                Button("Speichern") {
                    store.updateNotes(task, notes: notesDraft.trimmingCharacters(in: .whitespacesAndNewlines))
                    isEditingNotes = false
                }
                .buttonStyle(.borderedProminent)
                .font(.system(size: 11))
            }
        }
    }

    // MARK: - Kontextmenü

    @ViewBuilder
    private var contextMenuItems: some View {
        Button("Titel bearbeiten") {
            titleDraft = task.title
            withAnimation { isEditingTitle = true }
        }
        Button(task.notes.isEmpty ? "Notiz hinzufügen" : "Notiz bearbeiten") {
            notesDraft = task.notes
            withAnimation { isEditingNotes = true }
        }
        if let prev = task.column.previous {
            Button("← Nach \(prev.rawValue)") {
                withAnimation { store.move(task, to: prev) }
            }
        }
        if let next = task.column.next {
            Button("→ Nach \(next.rawValue)") {
                withAnimation { store.move(task, to: next) }
            }
        }
        Divider()
        Button("Löschen", role: .destructive) {
            withAnimation { store.delete(task) }
        }
    }
}

// MARK: - Icon-Button-Style (kompakt, Helligkeit reagiert auf Hover)

struct CardIconButtonStyle: ButtonStyle {
    let color: Color
    let isHovered: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 9, weight: .semibold))
            .frame(width: 16, height: 16)
            .foregroundColor(color.opacity(isHovered ? 0.85 : 0.35))
            .background(
                Circle().fill(color.opacity(configuration.isPressed ? 0.22 : (isHovered ? 0.10 : 0.0)))
            )
    }
}
