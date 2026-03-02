import Foundation

class TrayAPI {
    private let trayManager: TrayManager
    private let onMenuItemClick: (String) -> Void

    init(trayManager: TrayManager, onMenuItemClick: @escaping (String) -> Void) {
        self.trayManager = trayManager
        self.onMenuItemClick = onMenuItemClick
    }

    func handle(method: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        switch method {
        case "setIcon":
            DispatchQueue.main.async {
                self.trayManager.setIcon(imageName: args["image"] as? String)
                completion(.success("ok"))
            }
        case "setMenu":
            if let items = args["items"] as? [[String: Any]] {
                DispatchQueue.main.async {
                    self.trayManager.setMenu(items: items, onClick: self.onMenuItemClick)
                    completion(.success("ok"))
                }
            } else {
                completion(.error("tray.setMenu requires an 'items' array"))
            }
        case "destroy":
            DispatchQueue.main.async {
                self.trayManager.destroy()
                completion(.success("ok"))
            }
        default:
            completion(.error("Unknown tray method: \(method)"))
        }
    }
}
