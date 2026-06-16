import SwiftUI

struct TaskCardView: View {
    let task: Task
    @EnvironmentObject var store: TaskStore
    @State private var isHovered = false
    @State private var isEditingNotes = false
    @State private var notesDraft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                Text(task.title)
                    .font(.system(size: 13))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(4)

                if isHovered && !isEditingNotes {
                    controls
                        .transition(.opacity)
                }
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
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(isHovered ? 0.10 : 0.04),
                        radius: isHovered ? 4 : 2,
                        x: 0, y: isHovered ? 2 : 1)
        )
        .animation(.easeInOut(duration: 0.12), value: isHovered)
        .onHover { isHovered = $0 }
        .draggable(task)
        .contextMenu {
            contextMenuItems
        }
    }

    // MARK: - Controls (erscheinen beim Hover)

    private var controls: some View {
        VStack(spacing: 4) {
            if let prev = task.column.previous {
                Button {
                    withAnimation { store.move(task, to: prev) }
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 10, weight: .semibold))
                }
                .buttonStyle(IconButtonStyle(color: .blue))
                .help("Nach \(prev.rawValue) verschieben")
            }

            Button {
                notesDraft = task.notes
                withAnimation { isEditingNotes = true }
            } label: {
                Image(systemName: task.notes.isEmpty ? "note.text.badge.plus" : "note.text")
                    .font(.system(size: 10, weight: .semibold))
            }
            .buttonStyle(IconButtonStyle(color: .purple))
            .help(task.notes.isEmpty ? "Notiz hinzufügen" : "Notiz bearbeiten")

            Button {
                withAnimation { store.delete(task) }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 10, weight: .semibold))
            }
            .buttonStyle(IconButtonStyle(color: .red))
            .help("Aufgabe löschen")

            if let next = task.column.next {
                Button {
                    withAnimation { store.move(task, to: next) }
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .semibold))
                }
                .buttonStyle(IconButtonStyle(color: .green))
                .help("Nach \(next.rawValue) verschieben")
            }
        }
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

                Button("Abbrechen") {
                    isEditingNotes = false
                }
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

    // MARK: - Kontextmenü (Rechtsklick)

    @ViewBuilder
    private var contextMenuItems: some View {
        Button(task.notes.isEmpty ? "Notiz hinzufügen" : "Notiz bearbeiten") {
            notesDraft = task.notes
            withAnimation { isEditingNotes = true }
        }
        if let prev = task.column.previous {
            Button("→ Nach \(prev.rawValue)") {
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

// MARK: - Kleiner Icon-Button-Style

struct IconButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 20, height: 20)
            .foregroundColor(color)
            .background(color.opacity(configuration.isPressed ? 0.25 : 0.12))
            .clipShape(Circle())
    }
}
