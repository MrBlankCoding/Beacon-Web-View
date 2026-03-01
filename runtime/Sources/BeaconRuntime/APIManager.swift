import Foundation

/// Central API dispatcher with permission gating
class APIManager {
    private let permissions: RuntimeConfig.PermissionsConfig
    private let fileSystemAPI: FileSystemAPI
    private let notificationAPI: NotificationAPI
    private let shellAPI: ShellAPI
    private let cachedConfigJSON: String
    private let openWindowHandler: (() -> Void)?

    init(permissions: RuntimeConfig.PermissionsConfig, openWindowHandler: (() -> Void)? = nil) {
        self.permissions = permissions
        self.fileSystemAPI = FileSystemAPI()
        self.notificationAPI = NotificationAPI()
        self.shellAPI = ShellAPI()
        self.openWindowHandler = openWindowHandler
        let configInfo: [String: Any] = [
            "permissions": [
                "filesystem": permissions.filesystem,
                "notifications": permissions.notifications,
                "shell": permissions.shell
            ]
        ]
        if let data = try? JSONSerialization.data(withJSONObject: configInfo),
           let json = String(data: data, encoding: .utf8) {
            self.cachedConfigJSON = json
        } else {
            self.cachedConfigJSON = "{\"permissions\":{\"filesystem\":false,\"notifications\":false,\"shell\":false}}"
        }
    }

    func handle(command: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        let parts = command.split(separator: ".", maxSplits: 1)
        guard parts.count == 2 else {
            completion(.error("Invalid command format: \(command)"))
            return
        }

        let namespace = String(parts[0])
        let method = String(parts[1])

        switch namespace {
        case "fs":
            guard permissions.filesystem else {
                completion(.error("Permission denied: filesystem access is not enabled in runtime.config.json"))
                return
            }
            fileSystemAPI.handle(method: method, args: args, completion: completion)

        case "notifications":
            guard permissions.notifications else {
                completion(.error("Permission denied: notifications access is not enabled in runtime.config.json"))
                return
            }
            notificationAPI.handle(method: method, args: args, completion: completion)

        case "shell":
            guard permissions.shell else {
                completion(.error("Permission denied: shell access is not enabled in runtime.config.json"))
                return
            }
            shellAPI.handle(method: method, args: args, completion: completion)

        case "app":
            handleAppCommand(method: method, args: args, completion: completion)

        default:
            completion(.error("Unknown API namespace: \(namespace)"))
        }
    }

    private func handleAppCommand(method: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        switch method {
        case "getConfig":
            completion(.successJSON(cachedConfigJSON))

        case "getVersion":
            completion(.success("Beacon Runtime 1.0.0"))

        case "openWindow":
            guard let opener = openWindowHandler else {
                completion(.error("openWindow not supported in this runtime build"))
                return
            }
            opener()
            completion(.success("ok"))

        default:
            completion(.error("Unknown app method: \(method)"))
        }
    }
}
