import Foundation

enum LogLevel: String, Codable {
    case debug, info, warn, error
}

struct LogMessage: Codable {
    let level: LogLevel
    let source: String
    let message: String
    let timestamp: Double = Date().timeIntervalSince1970
}

enum Logger {
    static func log(_ level: LogLevel, source: String, _ message: String) {
        let msg = LogMessage(level: level, source: source, message: message)
        if let data = try? JSONEncoder().encode(msg),
           let json = String(data: data, encoding: .utf8) {
            // Prefix with a unique marker so the CLI can reliably identify log lines
            print("🔗BEACON_LOG🔗\(json)")
        }
    }

    static func debug(_ source: String, _ message: String) { log(.debug, source: source, message) }
    static func info(_ source: String, _ message: String) { log(.info, source: source, message) }
    static func warn(_ source: String, _ message: String) { log(.warn, source: source, message) }
    static func error(_ source: String, _ message: String) { log(.error, source: source, message) }
}
