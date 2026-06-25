import SwiftUI

// Meldet die tatsächlich gerenderte Inhaltshoehe jeder Spalte nach oben.
struct ColumnContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct ColumnView: View {
    let column: Task.Column
    @EnvironmentObject var store: TaskStore

    @State private var isAddingTask   = false
    @State private var isDropTargeted = false
    @State private var isEditingTitle = false
    @State private var titleDraft     = ""
    @FocusState private var titleFocused: Bool

    private var accentColor: Color {
        switch column {
        case .todo:  return Color(red: 0.27, green: 0.52, blue: 0.96)
        case .doing: return Color(red: 0.96, green: 0.60, blue: 0.17)
        case .done:  return Color(red: 0.22, green: 0.78, blue: 0.51)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            columnHeader
            Divider()
            taskList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            isDropTargeted
                ? accentColor.opacity(0.08)
                : Color(NSColor.windowBackgroundColor)
        )
        .dropDestination(for: Task.self) { dropped, _ in
            for task in dropped where task.column != column {
                store.move(task, to: column)
            }
            return true
        } isTargeted: { targeted in
            withAnimation(.easeInOut(duration: 0.15)) { isDropTargeted = targeted }
        }
    }

    // MARK: - Header

    private var columnHeader: some View {
        HStack {
            Circle()
                .fill(accentColor)
                .frame(width: 8, height: 8)

            // Inline-editierbarer Spaltenname
            if isEditingTitle {
                TextField("Spaltenname", text: $titleDraft)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(accentColor)
                    .textFieldStyle(.plain)
                    .focused($titleFocused)
                    .onAppear { titleFocused = true }
                    .onSubmit { saveTitle() }
                    .onExitCommand { isEditingTitle = false }
                    .frame(maxWidth: .infinity)
            } else {
                Text(store.title(for: column))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(accentColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        titleDraft = store.title(for: column)
                        withAnimation { isEditingTitle = true }
                    }
                    .help("Klicken um Spaltenname zu ändern")
            }

            let count = store.tasks(in: column).count
            Text("\(count)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.12))
                .clipShape(Capsule())

            Button {
                withAnimation { isAddingTask = true }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(accentColor)
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            .help("Neue Aufgabe hinzufügen")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(accentColor.opacity(0.07))
    }

    private func saveTitle() {
        let trimmed = titleDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            store.updateColumnTitle(column, title: trimmed)
        }
        isEditingTitle = false
    }

    // MARK: - Task-Liste

    private var taskList: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 6) {
                if isAddingTask {
                    AddTaskView(column: column, isPresented: $isAddingTask)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                ForEach(store.tasks(in: column)) { task in
                    TaskCardView(task: task)
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                }
            }
            .padding(10)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: store.tasks)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isAddingTask)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ColumnContentHeightKey.self,
                        value: geo.size.height
                    )
                }
            )
        }
    }
}
