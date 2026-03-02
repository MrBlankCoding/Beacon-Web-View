import AppKit

/// Menu API — allows the web app to show native context menus
class MenuAPI: NSObject {
    private let onMenuItemClick: (String) -> Void

    init(onMenuItemClick: @escaping (String) -> Void) {
        self.onMenuItemClick = onMenuItemClick
    }

    func handle(method: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        switch method {
        case "showContextMenu":
            showContextMenu(args: args, completion: completion)
        default:
            completion(.error("Unknown menu method: \(method)"))
        }
    }

    private func showContextMenu(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        guard let items = args["items"] as? [[String: Any]] else {
            completion(.error("menu.showContextMenu requires an 'items' array"))
            return
        }

        DispatchQueue.main.async {
            let menu = NSMenu()
            menu.autoenablesItems = false
            
            self.populate(menu: menu, from: items)
            
            // Show at current mouse location
            menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
            completion(.success("ok"))
        }
    }

    private func populate(menu: NSMenu, from items: [[String: Any]]) {
        for item in items {
            if let isSeparator = item["isSeparator"] as? Bool, isSeparator {
                menu.addItem(NSMenuItem.separator())
                continue
            }

            let title = item["label"] as? String ?? ""
            let menuItem = NSMenuItem(title: title, action: #selector(menuItemAction(_:)), keyEquivalent: "")
            menuItem.target = self
            menuItem.isEnabled = item["enabled"] as? Bool ?? true
            
            if let id = item["id"] as? String {
                menuItem.representedObject = id
            }

            if let submenuItems = item["submenu"] as? [[String: Any]] {
                let submenu = NSMenu()
                submenu.autoenablesItems = false
                populate(menu: submenu, from: submenuItems)
                menuItem.submenu = submenu
            }

            menu.addItem(menuItem)
        }
    }

    @objc private func menuItemAction(_ sender: NSMenuItem) {
        if let id = sender.representedObject as? String {
            onMenuItemClick(id)
        }
    }
}
