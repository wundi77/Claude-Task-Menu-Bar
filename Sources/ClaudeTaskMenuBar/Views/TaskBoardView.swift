import SwiftUI

struct TaskBoardView: View {
    @EnvironmentObject var store: TaskStore

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(Task.Column.allCases.enumerated()), id: \.element) { idx, column in
                ColumnView(column: column)
                if idx < Task.Column.allCases.count - 1 {
                    Divider()
                }
            }
        }
        .frame(width: 720, height: 460)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
