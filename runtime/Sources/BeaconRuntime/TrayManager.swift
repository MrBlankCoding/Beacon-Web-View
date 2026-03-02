import AppKit

/// Managed macOS system status bar (tray) interaction.
final class TrayManager: NSObject {
    private var statusItem: NSStatusItem?
    private var onMenuItemClick: ((String) -> Void)?
    private func ensureStatusItem() {
        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        }
    }

    func setIcon(imageName: String?) {
        ensureStatusItem()
        guard let button = statusItem?.button else { return }

        if let imageName = imageName {
            let image: NSImage?
            if #available(macOS 11.0, *), let symbol = NSImage(systemSymbolName: imageName, accessibilityDescription: nil) {
                image = symbol
            } else {
                image = NSImage(named: imageName) ?? (FileManager.default.fileExists(atPath: imageName) ? NSImage(contentsOfFile: imageName) : nil)
            }
            
            image?.isTemplate = true
            button.image = image
        } else {
            button.title = "Beacon"
            button.image = nil
        }
    }

    func setMenu(items: [[String: Any]], onClick: @escaping (String) -> Void) {
        ensureStatusItem()
        self.onMenuItemClick = onClick
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        for item in items {
            if let isSeparator = item["isSeparator"] as? Bool, isSeparator {
                menu.addItem(NSMenuItem.separator())
                continue
            }
            
            let title = item["title"] as? String ?? "Unnamed Item"
            let id = item["id"] as? String ?? title
            let keyEquivalent = item["key"] as? String ?? ""
            
            let menuItem = NSMenuItem(title: title, action: #selector(menuItemAction(_:)), keyEquivalent: keyEquivalent)
            menuItem.target = self
            menuItem.representedObject = id
            menuItem.isEnabled = true
            menu.addItem(menuItem)
        }
        
        statusItem?.menu = menu
    }

    @objc private func menuItemAction(_ sender: NSMenuItem) {
        if let id = sender.representedObject as? String {
            onMenuItemClick?(id)
        }
    }
    
    func destroy() {
        if let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
            statusItem = nil
        }
    }
}
