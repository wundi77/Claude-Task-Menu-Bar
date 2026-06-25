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
    }

    // Custom decoding so existing saved tasks without a "notes" field still load.
    enum CodingKeys: String, CodingKey {
        case id, title, column, notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id     = try container.decode(UUID.self,            forKey: .id)
        title  = try container.decode(String.self,          forKey: .title)
        column = try container.decode(Column.self,          forKey: .column)
        notes  = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }
}

// Drag-and-drop via JSON encoding
extension Task: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

// MARK: - Store

final class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []
    // Custom display names for each column, keyed by Column.rawValue
    @Published var columnTitles: [String: String] = [:]

    private let tasksKey     = "com.claude.taskmenbar.tasks"
    private let colTitlesKey = "com.claude.taskmenbar.columnTitles"

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

    // Returns the display name for a column (falls back to rawValue if not customised)
    func title(for column: Task.Column) -> String {
        columnTitles[column.rawValue] ?? column.rawValue
    }

    func updateColumnTitle(_ column: Task.Column, title: String) {
        columnTitles[column.rawValue] = title
        saveColumnTitles()
    }

    func addTask(title: String, to column: Task.Column) {
        tasks.append(Task(title: title, column: column))
        saveTasks()
    }

    func delete(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }

    func move(_ task: Task, to column: Task.Column) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].column = column
        saveTasks()
    }

    func updateTitle(_ task: Task, title: String) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].title = title
        saveTasks()
    }

    func updateNotes(_ task: Task, notes: String) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].notes = notes
        saveTasks()
    }

    func tasks(in column: Task.Column) -> [Task] {
        tasks.filter { $0.column == column }
    }

    // MARK: - Persistence

    private func saveTasks() {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        UserDefaults.standard.set(data, forKey: tasksKey)
    }

    private func saveColumnTitles() {
        guard let data = try? JSONEncoder().encode(columnTitles) else { return }
        UserDefaults.standard.set(data, forKey: colTitlesKey)
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
        if let data = UserDefaults.standard.data(forKey: colTitlesKey),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            columnTitles = decoded
        }
    }
}
