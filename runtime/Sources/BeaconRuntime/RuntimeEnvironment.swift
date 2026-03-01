import Foundation

enum RuntimeEnvironment {
    static func isRunningFromAppBundle() -> Bool {
        Bundle.main.bundleURL.pathExtension.lowercased() == "app"
    }
}
