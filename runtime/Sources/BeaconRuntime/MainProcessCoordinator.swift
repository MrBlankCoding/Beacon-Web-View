import AppKit

/// Hosts native app lifecycle responsibilities
final class MainProcessCoordinator {
    private let config: RuntimeConfig
    private var windows: [NSWindow] = []
    private var rendererProcesses: [RendererProcessHost] = []
    private var apiManager: APIManager!
    private let trayManager = TrayManager()
    private let shortcutsManager = ShortcutsManager()

    init() throws {
        self.config = try RuntimeConfig.load()
        let initialWindow = WindowManager.createWindow(from: config.window)
        self.windows.append(initialWindow)
        
        self.apiManager = APIManager(
            permissions: config.permissions,
            trayManager: trayManager,
            shortcutsManager: shortcutsManager,
            onEvent: { [weak self] name, detail in
                DispatchQueue.main.async {
                    self?.broadcastEvent(name: name, detail: detail)
                }
            },
            openWindowHandler: { [weak self] in
                DispatchQueue.main.async {
                    self?.openWindow()
                }
            }
        )

        let initialRenderer = RendererProcessHost(
            window: initialWindow,
            config: config,
            apiManager: apiManager
        )
        self.rendererProcesses.append(initialRenderer)
    }

    private func broadcastEvent(name: String, detail: Any) {
        for renderer in rendererProcesses {
            renderer.bridgeHandler.emitEvent(name: name, detail: detail)
        }
    }

    private func openWindow() {
        let newWindow = WindowManager.createWindow(from: config.window)
        windows.append(newWindow)
        let renderer = RendererProcessHost(window: newWindow, config: config, apiManager: apiManager)
        rendererProcesses.append(renderer)
        renderer.mount()
        newWindow.makeKeyAndOrderFront(nil)
    }

    func start() {
        for renderer in rendererProcesses {
            renderer.mount()
        }
        for win in windows {
            win.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
        setupMenu()
    }

    @objc private func reloadRenderer() {
        for r in rendererProcesses { r.reload() }
    }

    private func setupMenu() {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About Beacon", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        let viewMenuItem = NSMenuItem()
        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(withTitle: "New Window", action: #selector(newWindow), keyEquivalent: "n")
        viewMenu.addItem(NSMenuItem.separator())
        viewMenu.addItem(withTitle: "Reload", action: #selector(reloadRenderer), keyEquivalent: "r")
        viewMenuItem.submenu = viewMenu
        mainMenu.addItem(viewMenuItem)

        NSApp.mainMenu = mainMenu
    }

    @objc private func newWindow() {
        openWindow()
    }
}
