import ServiceManagement

/// Wraps macOS 13's `SMAppService` for a "Launch at Login" toggle. Only meaningful for a
/// properly installed app bundle (e.g. `/Applications/HabitMon.app`, per `Scripts/build-app.sh`)
/// — registering a raw `swift run` binary as a login item isn't a supported/useful operation.
enum LoginItemManager {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("LoginItemManager: failed to \(enabled ? "register" : "unregister"): \(error.localizedDescription)")
        }
    }
}
