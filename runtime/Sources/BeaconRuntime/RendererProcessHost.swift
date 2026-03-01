import AppKit
import WebKit

/// Owns WKWebView content hosting and load-state transitions for renderer content.
final class RendererProcessHost {
    private let window: NSWindow
    private let config: RuntimeConfig
    private let webViewManager: WebViewManager
    private var loadingView: NSView?
    private var revealFallbackWorkItem: DispatchWorkItem?

    init(window: NSWindow, config: RuntimeConfig, apiManager: APIManager) {
        self.window = window
        self.config = config
        self.webViewManager = WebViewManager(config: config, apiManager: apiManager)
    }

    func mount() {
        let webView = webViewManager.webView
        let container = NSView(frame: window.contentLayoutRect)
        container.autoresizingMask = [.width, .height]

        webView.frame = container.bounds
        container.addSubview(webView)

        let loadingOverlay = makeLoadingOverlay(frame: container.bounds, title: config.window.title ?? "Loading")
        container.addSubview(loadingOverlay)
        loadingView = loadingOverlay

        webViewManager.onInitialLoadComplete = { [weak self] in
            self?.revealWebContent()
        }

        let fallback = DispatchWorkItem { [weak self] in
            self?.revealWebContent()
        }
        revealFallbackWorkItem = fallback
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: fallback)

        if let base = window.contentView {
            base.addSubview(container)
        } else {
            window.contentView = container
        }
    }

    func reload() {
        webViewManager.reload()
    }

    private func makeLoadingOverlay(frame: NSRect, title: String) -> NSView {
        let overlay = NSVisualEffectView(frame: frame)
        overlay.autoresizingMask = [.width, .height]
        overlay.material = .contentBackground
        overlay.blendingMode = .behindWindow
        overlay.state = .active

        let spinner = NSProgressIndicator(frame: .zero)
        spinner.style = .spinning
        spinner.controlSize = .regular
        spinner.startAnimation(nil)
        spinner.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = NSFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = NSTextField(labelWithString: "Preparing app...")
        subtitleLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        overlay.addSubview(spinner)
        overlay.addSubview(titleLabel)
        overlay.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: overlay.centerXAnchor)
        ])

        return overlay
    }

    private func revealWebContent() {
        revealFallbackWorkItem?.cancel()
        revealFallbackWorkItem = nil

        guard loadingView != nil else { return }

        let webView = webViewManager.webView
        webView.isHidden = false

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.18
            webView.animator().alphaValue = 1
            loadingView?.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            self?.loadingView?.removeFromSuperview()
            self?.loadingView = nil
        }
    }
}
