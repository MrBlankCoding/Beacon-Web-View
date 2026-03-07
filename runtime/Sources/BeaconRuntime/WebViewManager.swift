import WebKit

enum BridgeScriptError: LocalizedError, Equatable {
    case missing
    case invalid

    var errorDescription: String? {
        switch self {
        case .missing:
            return "bridge.js missing in runtime resources"
        case .invalid:
            return "bridge.js is missing required Beacon bridge symbols"
        }
    }
}

/// Manages the isolated renderer host (WKWebView) and preload bridge wiring.
class WebViewManager: NSObject, WKNavigationDelegate {
    let webView: WKWebView
    var onInitialLoadComplete: (() -> Void)? {
        didSet {
            guard didCompleteInitialLoad else { return }
            DispatchQueue.main.async { [weak self] in
                self?.onInitialLoadComplete?()
            }
        }
    }
    let bridgeHandler: BridgeHandler
    private let config: RuntimeConfig
    private var didCompleteInitialLoad = false
    private static let bridgeScript = loadBridgeScript()

    init(config: RuntimeConfig, apiManager: APIManager) {
        self.config = config
        let webConfig = WKWebViewConfiguration()
        webConfig.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webConfig.setValue(true, forKey: "allowUniversalAccessFromFileURLs")

        #if DEBUG
        webConfig.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif

        let contentController = WKUserContentController()
        self.bridgeHandler = BridgeHandler(apiManager: apiManager)

        contentController.add(self.bridgeHandler, name: "native")
        let userScript = WKUserScript(
            source: Self.bridgeScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)

        webConfig.userContentController = contentController

        self.webView = WKWebView(frame: .zero, configuration: webConfig)
        self.webView.autoresizingMask = [.width, .height]
        self.webView.setValue(false, forKey: "drawsBackground")
        self.webView.alphaValue = 0
        self.webView.isHidden = true

        super.init()
        self.webView.navigationDelegate = self
        self.bridgeHandler.webView = self.webView
        loadEntryFile()
    }

    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "native")
    }

    func reload() {
        webView.reload()
    }

    private func loadEntryFile() {
        if let devURL = ProcessInfo.processInfo.environment["BEACON_DEV_SERVER_URL"],
           let url = URL(string: devURL),
           url.scheme != nil {
            webView.load(URLRequest(url: url))
            return
        }

        let fm = FileManager.default
        if let bundledWebURL = Bundle.main.url(forResource: "web", withExtension: nil) {
            let bundledEntryURL = bundledWebURL.appendingPathComponent(config.entry)
            if fm.fileExists(atPath: bundledEntryURL.path) {
                webView.loadFileURL(bundledEntryURL, allowingReadAccessTo: bundledWebURL)
                return
            }
        }

        let executableDirectory = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
        let devWebURL = executableDirectory.appendingPathComponent("web")
        let devEntryURL = devWebURL.appendingPathComponent(config.entry)
        if fm.fileExists(atPath: devEntryURL.path) {
            webView.loadFileURL(devEntryURL, allowingReadAccessTo: devWebURL)
            return
        }

        let errorHTML = """
        <html>
        <body style="font-family: -apple-system; padding: 40px; background: #f4f6f8; color: #1d2838;">
            <h1>Entry File Not Found</h1>
            <p>Could not find <code>\(config.entry)</code> in the app bundle.</p>
            <p style="color: #888;">Expected at: Resources/web/\(config.entry)</p>
        </body>
        </html>
        """
        webView.loadHTMLString(errorHTML, baseURL: nil)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        completeInitialLoadIfNeeded()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        completeInitialLoadIfNeeded()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        completeInitialLoadIfNeeded()
    }

    private func completeInitialLoadIfNeeded() {
        guard !didCompleteInitialLoad else { return }
        didCompleteInitialLoad = true
        DispatchQueue.main.async { [weak self] in
            self?.onInitialLoadComplete?()
        }
    }

    private static func loadBridgeScript() -> String {
        do {
            return try resolveBridgeScript(in: .main)
        } catch {
            let message = error.localizedDescription
            fatalError("bridge.js missing or invalid in runtime resources. Packaging must include a valid bridge.js file. \(message)")
        }
    }

    static func resolveBridgeScript(in bundle: Bundle) throws -> String {
        let executableDirectory = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
        let fallbackCandidates: [URL] = [
            executableDirectory
                .appendingPathComponent("BeaconRuntime_BeaconRuntime.bundle/Resources/bridge.js"),
            executableDirectory
                .appendingPathComponent("BeaconRuntime_BeaconRuntime.bundle/Contents/Resources/bridge.js"),
            executableDirectory.appendingPathComponent("Resources/bridge.js")
        ]

        let bridgeURL = bundle.url(forResource: "bridge", withExtension: "js")
            ?? bundle.url(forResource: "bridge", withExtension: "js", subdirectory: "Resources")
            ?? fallbackCandidates.first(where: { FileManager.default.fileExists(atPath: $0.path) })

        guard let bridgeURL else {
            throw BridgeScriptError.missing
        }

        guard let script = try? String(contentsOf: bridgeURL, encoding: .utf8) else {
            throw BridgeScriptError.invalid
        }

        guard isValidBridgeScript(script) else {
            throw BridgeScriptError.invalid
        }

        return script
    }

    static func isValidBridgeScript(_ script: String) -> Bool {
        return script.contains("__beacon_nativeCallback")
    }
}
