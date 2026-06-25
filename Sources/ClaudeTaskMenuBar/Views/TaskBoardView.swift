import SwiftUI
import ServiceManagement

struct TaskBoardView: View {
    @EnvironmentObject var store: TaskStore

    @State private var columnContentHeight: CGFloat = 100

    private let headerH: CGFloat = 38
    private let footerH: CGFloat = 36

    private var windowHeight: CGFloat {
        let screenH = NSScreen.main?.visibleFrame.height ?? 800
        let ideal   = headerH + columnContentHeight + footerH
        return min(max(ideal, 160), screenH * 0.5)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(Task.Column.allCases.enumerated()), id: \.element) { idx, column in
                    ColumnView(column: column)
                    if idx < Task.Column.allCases.count - 1 {
                        Divider()
                    }
                }
            }

            Divider()
            boardFooter
        }
        .frame(width: 1440, height: windowHeight)
        .background(Color(NSColor.windowBackgroundColor))
        .animation(.easeInOut(duration: 0.2), value: windowHeight)
        .onPreferenceChange(ColumnContentHeightKey.self) { h in
            columnContentHeight = h
        }
    }

    private var boardFooter: some View {
        HStack {
            LoginItemToggle()
            Spacer()
            Button("Beenden") { NSApp.terminate(nil) }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.system(size: 11))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Login-Item-Toggle

struct LoginItemToggle: View {
    @State private var isEnabled: Bool = (SMAppService.mainApp.status == .enabled)
    @State private var errorMessage: String?

    private var isInstalledProperly: Bool {
        let path = Bundle.main.bundlePath
        guard path.hasSuffix(".app") else { return false }
        return path.hasPrefix("/Applications") ||
               path.hasPrefix("/Users/\(NSUserName())/Applications")
    }

    var body: some View {
        HStack(spacing: 6) {
            if isInstalledProperly {
                Toggle("Beim Login automatisch starten", isOn: $isEnabled)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 11))
                    .onChange(of: isEnabled) { newValue in
                        do {
                            if newValue {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                            errorMessage = nil
                        } catch {
                            isEnabled = !newValue
                            errorMessage = error.localizedDescription
                        }
                    }

                if let msg = errorMessage {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 11))
                        .help(msg)
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("App in /Programme verschieben, um Autostart zu aktivieren")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
