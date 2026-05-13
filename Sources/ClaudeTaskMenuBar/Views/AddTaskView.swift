import SwiftUI

struct AddTaskView: View {
    let column: Task.Column
    @Binding var isPresented: Bool
    @EnvironmentObject var store: TaskStore

    @State private var title = ""
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Aufgabe eingeben ...", text: $title, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...5)
                .focused($focused)
                .onSubmit { submit() }
                .onExitCommand { isPresented = false }

            HStack {
                Button("Abbrechen") {
                    isPresented = false
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.system(size: 12))

                Spacer()

                Button("Hinzufügen") {
                    submit()
                }
                .buttonStyle(.borderedProminent)
                .font(.system(size: 12, weight: .medium))
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
        .onAppear { focused = true }
    }

    private func submit() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.addTask(title: trimmed, to: column)
        isPresented = false
    }
}
