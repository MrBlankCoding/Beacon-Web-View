import Foundation

/// Central API dispatcher with permission gating
class APIManager {
    private let permissions: RuntimeConfig.PermissionsConfig
    private let fileSystemAPI: FileSystemAPI
    private let notificationAPI: NotificationAPI
    private let shellAPI: ShellAPI
    private let clipboardAPI: ClipboardAPI
    private let dialogAPI: DialogAPI
    private let trayAPI: TrayAPI
    private let shortcutsAPI: ShortcutsAPI
    private let systemAPI: SystemAPI
    private let menuAPI: MenuAPI
    private let cachedConfigJSON: String
    private let openWindowHandler: (() -> Void)?

    init(
        permissions: RuntimeConfig.PermissionsConfig,
        trayManager: TrayManager,
        shortcutsManager: ShortcutsManager,
        onEvent: @escaping (String, Any) -> Void,
        openWindowHandler: (() -> Void)? = nil
    ) {
        self.permissions = permissions
        let fs = FileSystemAPI(permission: permissions.filesystem)
        self.fileSystemAPI = fs
        self.notificationAPI = NotificationAPI()
        self.shellAPI = ShellAPI()
        self.clipboardAPI = ClipboardAPI()
        self.dialogAPI = DialogAPI(onBookmarkCreated: { url in
            fs.addBookmark(url: url)
        })
        self.trayAPI = TrayAPI(trayManager: trayManager, onMenuItemClick: { id in
            onEvent("beacon-tray-click", id)
        })
        self.shortcutsAPI = ShortcutsAPI(manager: shortcutsManager, onShortcutPressed: { combo in
            onEvent("beacon-shortcut", combo)
        })
        shortcutsManager.onShortcutTriggered = { combo in
            onEvent("beacon-shortcut", combo)
        }
        self.systemAPI = SystemAPI()
        self.menuAPI = MenuAPI(onMenuItemClick: { id in
            onEvent("beacon-menu-click", id)
        })
        self.openWindowHandler = openWindowHandler
        
        let filesystemConfig: Any
        switch permissions.filesystem {
        case .disabled: filesystemConfig = false
        case .full: filesystemConfig = true
        case .scoped(let paths): filesystemConfig = paths
        }

        let configInfo: [String: Any] = [
            "permissions": [
                "filesystem": filesystemConfig,
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
            guard permissions.filesystem.isEnabled else {
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

        case "dialog":
            dialogAPI.handle(method: method, args: args, completion: completion)

        case "tray":
            trayAPI.handle(method: method, args: args, completion: completion)

        case "shortcuts":
            shortcutsAPI.handle(method: method, args: args, completion: completion)

        case "system":
            systemAPI.handle(method: method, args: args, completion: completion)

        case "menu":
            menuAPI.handle(method: method, args: args, completion: completion)

        case "clipboard":
            clipboardAPI.handle(method: method, args: args, completion: completion)

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
