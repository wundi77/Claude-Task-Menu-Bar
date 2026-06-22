import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Task

struct Task: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var column: Column
    var notes: String

    init(id: UUID = UUID(), title: String, column: Column, notes: String = "") {
        self.id = id
        self.title = title
        self.column = column
        self.notes = notes
    }

    enum Column: String, CaseIterable, Codable, Hashable {
        case todo  = "ToDo"
        case doing = "Doing"
        case done  = "Done"

        var next: Column? {
            guard let idx = Column.allCases.firstIndex(of: self),
                  idx < Column.allCases.count - 1
            else { return nil }
            return Column.allCases[idx + 1]
        }

        var previous: Column? {
            guard let idx = Column.allCases.firstIndex(of: self),
                  idx > 0
            else { return nil }
            return Column.allCases[idx - 1]
        }

        var accentColor: String {
            switch self {
            case .todo:  return "columnTodo"
            case .doing: return "columnDoing"
            case .done:  return "columnDone"
            }
        }
    }

    // Custom decoding so existing saved tasks without a "notes" field
    // (from before this feature existed) still load correctly.
    enum CodingKeys: String, CodingKey {
        case id, title, column, notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        column = try container.decode(Column.self, forKey: .column)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }
}

// Drag-and-drop via JSON/plain encoding
extension Task: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

// MARK: - Store

final class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []

    private let saveKey = "com.claude.taskmenbar.tasks"

    init() {
        load()
        if tasks.isEmpty {
            tasks = [
                Task(title: "App-Idee ausarbeiten",    column: .todo),
                Task(title: "Design skizzieren",        column: .todo),
                Task(title: "Prototyp entwickeln",      column: .doing),
                Task(title: "Anforderungen gesammelt",  column: .done),
            ]
        }
    }

    func addTask(title: String, to column: Task.Column) {
        tasks.append(Task(title: title, column: column))
        save()
    }

    func delete(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        save()
    }

    func move(_ task: Task, to column: Task.Column) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].column = column
        save()
    }

    func updateTitle(_ task: Task, title: String) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].title = title
        save()
    }

    func updateNotes(_ task: Task, notes: String) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].notes = notes
        save()
    }

    func tasks(in column: Task.Column) -> [Task] {
        tasks.filter { $0.column == column }
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        UserDefaults.standard.set(data, forKey: saveKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([Task].self, from: data)
        else { return }
        tasks = decoded
    }
}
