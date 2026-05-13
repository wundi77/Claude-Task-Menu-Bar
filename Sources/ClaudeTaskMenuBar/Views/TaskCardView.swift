import SwiftUI

struct TaskCardView: View {
    let task: Task
    @EnvironmentObject var store: TaskStore
    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(task.title)
                .font(.system(size: 13))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(4)

            if isHovered {
                controls
                    .transition(.opacity)
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

    // MARK: - Kontextmenü (Rechtsklick)

    @ViewBuilder
    private var contextMenuItems: some View {
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
