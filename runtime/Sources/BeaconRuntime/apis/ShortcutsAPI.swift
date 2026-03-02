import Foundation

class ShortcutsAPI {
    private let manager: ShortcutsManager
    private let onShortcutPressed: (String) -> Void

    init(manager: ShortcutsManager, onShortcutPressed: @escaping (String) -> Void) {
        self.manager = manager
        self.onShortcutPressed = onShortcutPressed
    }

    func handle(method: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        switch method {
        case "register":
            guard let combo = args["shortcut"] as? String else {
                completion(.error("shortcuts.register requires a 'shortcut' string"))
                return
            }
            manager.register(shortcut: combo)
            completion(.success("ok"))
        case "unregisterAll":
            manager.unregisterAll()
            completion(.success("ok"))
        default:
            completion(.error("Unknown shortcuts method: \(method)"))
        }
    }
}
