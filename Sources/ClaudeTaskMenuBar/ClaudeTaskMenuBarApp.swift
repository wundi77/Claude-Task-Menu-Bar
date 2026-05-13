import SwiftUI

@main
struct ClaudeTaskMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = TaskStore()

    var body: some Scene {
        MenuBarExtra {
            TaskBoardView()
                .environmentObject(store)
        } label: {
            Label("Tasks", systemImage: "checklist")
        }
        .menuBarExtraStyle(.window)
    }
}

// Kein Dock-Icon, kein App-Switcher-Eintrag
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
