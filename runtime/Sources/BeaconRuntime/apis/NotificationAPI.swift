import Foundation
import UserNotifications

/// Notifications API
class NotificationAPI {
    private let stateQueue = DispatchQueue(label: "com.beacon.notifications.state")
    private var cachedAuthorizationStatus: UNAuthorizationStatus?

    func handle(method: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        switch method {
        case "send":
            sendNotification(args: args, completion: completion)
        default:
            completion(.error("Unknown notifications method: \(method)"))
        }
    }

    private func sendNotification(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        guard let title = args["title"] as? String else {
            completion(.error("notifications.send requires a 'title' argument"))
            return
        }

        guard RuntimeEnvironment.isRunningFromAppBundle() else {
            completion(.error("Notifications require launching BeaconRuntime from a packaged .app bundle."))
            return
        }

        let body = args["body"] as? String ?? ""

        DispatchQueue.main.async {
            let center = UNUserNotificationCenter.current()
            self.getAuthorizationStatus(center: center) { status in
                switch status {
                case .authorized, .provisional, .ephemeral:
                    self.scheduleNotification(center: center, title: title, body: body, completion: completion)
                case .notDetermined:
                    center.requestAuthorization(options: [.alert, .sound]) { granted, error in
                        if let error = error {
                            completion(.error(self.humanReadablePermissionError(error)))
                            return
                        }

                        guard granted else {
                            self.updateCachedAuthorizationStatus(.denied)
                            completion(.error("Notification permission denied. Enable notifications for this app in System Settings > Notifications."))
                            return
                        }

                        self.updateCachedAuthorizationStatus(.authorized)
                        self.scheduleNotification(center: center, title: title, body: body, completion: completion)
                    }
                case .denied:
                    completion(.error("Notifications are disabled for this app. Enable them in System Settings > Notifications."))
                @unknown default:
                    completion(.error("Unknown notification authorization status"))
                }
            }
        }
    }

    private func scheduleNotification(
        center: UNUserNotificationCenter,
        title: String,
        body: String,
        completion: @escaping (APIResult) -> Void
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        center.add(request) { error in
            if let error = error {
                completion(.error("Failed to send notification: \(error.localizedDescription)"))
            } else {
                completion(.success("ok"))
            }
        }
    }

    private func humanReadablePermissionError(_ error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == UNErrorDomain, nsError.code == 1 {
            return "Notifications are not currently allowed for this app. Open System Settings > Notifications and enable notifications for this app, then retry."
        }
        return "Notification permission error: \(error.localizedDescription)"
    }

    private func getAuthorizationStatus(
        center: UNUserNotificationCenter,
        completion: @escaping (UNAuthorizationStatus) -> Void
    ) {
        if let cached = stateQueue.sync(execute: { cachedAuthorizationStatus }),
           cached != .notDetermined {
            completion(cached)
            return
        }

        center.getNotificationSettings { settings in
            self.updateCachedAuthorizationStatus(settings.authorizationStatus)
            completion(settings.authorizationStatus)
        }
    }

    private func updateCachedAuthorizationStatus(_ status: UNAuthorizationStatus) {
        stateQueue.async {
            self.cachedAuthorizationStatus = status
        }
    }
}
