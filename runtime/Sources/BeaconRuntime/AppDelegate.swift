import AppKit
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    private var mainProcess: MainProcessCoordinator?

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)

        if RuntimeEnvironment.isRunningFromAppBundle() {
            UNUserNotificationCenter.current().delegate = self
        } else {
            print("Notifications delegate disabled: runtime is not launched from a .app bundle")
        }

        do {
            let coordinator = try MainProcessCoordinator()
            coordinator.start()
            self.mainProcess = coordinator
        } catch {
            let alert = NSAlert()
            alert.messageText = "Configuration Error"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .critical
            alert.runModal()
            NSApp.terminate(nil)
            return
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
