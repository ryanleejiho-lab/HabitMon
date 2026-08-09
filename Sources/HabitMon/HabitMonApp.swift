import SwiftUI

@main
struct HabitMonApp: App {
    init() {
        // Started once, here, regardless of window state — this is what makes progress
        // tracking continue in the background even with the room window closed.
        ChecklistPoller.shared.start()
    }

    var body: some Scene {
        WindowGroup("HabitMon", id: "main") {
            ContentView()
        }
        .windowResizability(.contentSize)

        MenuBarExtra("HabitMon", systemImage: "pawprint.fill") {
            MenuBarContentView()
        }
        .menuBarExtraStyle(.menu)
    }
}
