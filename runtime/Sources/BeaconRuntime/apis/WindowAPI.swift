import AppKit

class WindowAPI {
    func handle(method: String, args: [String: Any], window: NSWindow?, completion: @escaping (APIResult) -> Void) {
        DispatchQueue.main.async {
            guard let window = window else {
                completion(.error("No window available for this operation"))
                return
            }

            switch method {
            case "minimize":
                window.miniaturize(nil)
                completion(.success("ok"))
            case "maximize":
                if window.isZoomed {
                    window.zoom(nil)
                } else {
                    window.zoom(nil)
                }
                completion(.success("ok"))
            case "close":
                window.close()
                completion(.success("ok"))
            case "focus":
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                completion(.success("ok"))
            case "setFullscreen":
                if let fullscreen = args["fullscreen"] as? Bool {
                    if fullscreen != (window.styleMask.contains(.fullScreen)) {
                        window.toggleFullScreen(nil)
                    }
                    completion(.success("ok"))
                } else {
                    completion(.error("setFullscreen requires boolean argument"))
                }
            case "isMaximized":
                completion(.success(String(window.isZoomed)))
            case "isMinimized":
                completion(.success(String(window.isMiniaturized)))
            case "isFullscreen":
                completion(.success(String(window.styleMask.contains(.fullScreen))))
            default:
                completion(.error("Unknown window method: \(method)"))
            }
        }
    }
}
