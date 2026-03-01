import Foundation
import WebKit

/// Handles JS
class BridgeHandler: NSObject, WKScriptMessageHandler {
    private let apiManager: APIManager
    weak var webView: WKWebView?
    private let apiQueue = DispatchQueue(label: "com.beacon.api", qos: .userInitiated, attributes: .concurrent)
    private let inflightLimiter: DispatchSemaphore
    private var pendingBatchEntries: [String] = []
    private var flushScheduled = false
    private let maxBatchSize = 128

    init(apiManager: APIManager) {
        self.apiManager = apiManager
        self.inflightLimiter = DispatchSemaphore(value: Self.resolveConcurrencyLimit())
        super.init()
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let body = message.body as? [String: Any],
              let callId = body["id"] as? String,
              let command = body["command"] as? String else {
            print("[Beacon Bridge] Invalid message format")
            return
        }

        let args = body["args"] as? [String: Any] ?? [:]
        let limiter = inflightLimiter

        apiQueue.async { [weak self] in
            limiter.wait()
            guard let self else {
                limiter.signal()
                return
            }

            self.apiManager.handle(command: command, args: args) { [weak self] result in
                DispatchQueue.main.async {
                    self?.enqueueResponse(callId: callId, result: result)
                    limiter.signal()
                }
            }
        }
    }

    private func enqueueResponse(callId: String, result: APIResult) {
        let entry: String
        switch result {
        case .success(let value):
            entry = "[\(quoteJS(callId)), true, \(quoteJS(value))]"
        case .successJSON(let jsonPayload):
            entry = "[\(quoteJS(callId)), true, \(jsonPayload)]"
        case .error(let message):
            entry = "[\(quoteJS(callId)), false, \(quoteJS(message))]"
        }

        pendingBatchEntries.append(entry)

        if pendingBatchEntries.count >= maxBatchSize {
            flushPendingResponses()
            return
        }

        guard !flushScheduled else { return }
        flushScheduled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(4)) { [weak self] in
            self?.flushPendingResponses()
        }
    }

    private func flushPendingResponses() {
        guard !pendingBatchEntries.isEmpty else {
            flushScheduled = false
            return
        }

        let payload = "[\(pendingBatchEntries.joined(separator: ","))]"
        pendingBatchEntries.removeAll(keepingCapacity: true)
        flushScheduled = false

        let js = """
        if (window.__beacon_nativeCallbackBatch) {
            window.__beacon_nativeCallbackBatch(\(payload));
        } else {
            (function() {
                const batch = \(payload);
                for (let i = 0; i < batch.length; i += 1) {
                    window.__beacon_nativeCallback(batch[i][0], batch[i][1], batch[i][2]);
                }
            })();
        }
        """

        webView?.evaluateJavaScript(js) { _, error in
            if let error = error {
                print("[Beacon Bridge] JS callback error: \(error.localizedDescription)")
            }
        }
    }

    private func quoteJS(_ value: String) -> String {
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        return "\"\(escaped)\""
    }

    static func resolveConcurrencyLimit(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        cpuCount: Int = ProcessInfo.processInfo.activeProcessorCount
    ) -> Int {
        let cpuBased = max(2, cpuCount)
        let env = environment["BEACON_MAX_API_CONCURRENCY"]
        if let env, let parsed = Int(env), parsed > 0 {
            return min(parsed, 64)
        }
        return min(cpuBased, 16)
    }
}
enum APIResult {
    case success(String)
    case successJSON(String)
    case error(String)
}
