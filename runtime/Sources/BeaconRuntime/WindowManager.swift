import AppKit

/// Creates and configures NSWindow from runtime config
enum WindowManager {
    static func createWindow(from config: RuntimeConfig.WindowConfig) -> NSWindow {
        let contentRect = NSRect(
            x: 0, y: 0,
            width: CGFloat(config.width),
            height: CGFloat(config.height)
        )

        var styleMask: NSWindow.StyleMask = [
            .titled,
            .closable,
            .miniaturizable
        ]

        if config.resizable {
            styleMask.insert(.resizable)
        }

        let window = NSWindow(
            contentRect: contentRect,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )

        window.title = config.title ?? "Beacon App"
        window.center()
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 400, height: 300)

        return window
    }
}
