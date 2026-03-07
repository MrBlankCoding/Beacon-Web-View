import AppKit

class ThemeAPI {
    private let onThemeChange: (String) -> Void

    init(onThemeChange: @escaping (String) -> Void) {
        self.onThemeChange = onThemeChange
        
        // Listen for system theme changes
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.notifyThemeChange()
        }
    }

    func handle(method: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        DispatchQueue.main.async {
            switch method {
            case "getTheme":
                completion(.success(self.getCurrentTheme()))
            case "setTheme":
                if let theme = args["theme"] as? String {
                    self.setTheme(theme)
                    completion(.success("ok"))
                } else {
                    completion(.error("setTheme requires a 'theme' argument (light, dark, or system)"))
                }
            default:
                completion(.error("Unknown theme method: \(method)"))
            }
        }
    }

    private func getCurrentTheme() -> String {
        let appearance = NSApp.effectiveAppearance
        if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            return "dark"
        } else {
            return "light"
        }
    }

    private func setTheme(_ theme: String) {
        DispatchQueue.main.async {
            switch theme.lowercased() {
            case "dark":
                NSApp.appearance = NSAppearance(named: .darkAqua)
            case "light":
                NSApp.appearance = NSAppearance(named: .aqua)
            case "system":
                NSApp.appearance = nil
            default:
                break
            }
        }
    }

    private func notifyThemeChange() {
        onThemeChange(getCurrentTheme())
    }
}
