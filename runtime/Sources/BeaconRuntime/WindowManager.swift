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

        if config.frame == false {
            styleMask.insert(.fullSizeContentView)
        }

        let window = NSWindow(
            contentRect: contentRect,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )

        window.title = config.title ?? "Beacon App"
        if config.frame == false {
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
        }

        window.center()
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 400, height: 300)

        let baseContent = NSView(frame: contentRect)
        baseContent.autoresizingMask = [.width, .height]

        if let vib = config.vibrancy, vib.enabled {
            let materialString = vib.material ?? "sidebar"
            let material: NSVisualEffectView.Material
            switch materialString.lowercased() {
            case "titlebar": material = .titlebar
            case "hud": material = .hudWindow
            case "underwindow": material = .underWindowBackground
            case "content": material = .contentBackground
            default: material = .sidebar
            }

            let vibView = NSVisualEffectView(frame: baseContent.bounds)
            vibView.autoresizingMask = [.width, .height]
            vibView.material = material
            vibView.blendingMode = .withinWindow
            vibView.state = .active
            baseContent.addSubview(vibView, positioned: .below, relativeTo: nil)
        }

        window.contentView = baseContent

        return window
    }
}
