import SwiftUI
import HabitMonCore

/// Content of the menu-bar dropdown — quick stat glance plus controls, since the app runs
/// with no Dock icon (see `LSUIElement` in Scripts/build-app.sh's Info.plist) and this menu
/// is the only always-visible surface once the room window is closed.
struct MenuBarContentView: View {
    @ObservedObject private var poller = ChecklistPoller.shared
    @Environment(\.openWindow) private var openWindow
    @State private var launchAtLogin = LoginItemManager.isEnabled

    var body: some View {
        ForEach(HabitType.allCases) { type in
            Text("\(type.displayName): \(poller.state.xp(for: type)) XP")
        }

        Divider()

        Button("Open HabitMon") {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
        }

        Toggle("Launch at Login", isOn: $launchAtLogin)
            .onChange(of: launchAtLogin) { newValue in
                LoginItemManager.setEnabled(newValue)
            }

        Divider()

        Button("Quit HabitMon") {
            NSApp.terminate(nil)
        }
    }
}
