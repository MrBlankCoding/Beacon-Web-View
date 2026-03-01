import Foundation

struct RuntimeConfig: Codable {
    let window: WindowConfig
    let permissions: PermissionsConfig
    let entry: String

    struct WindowConfig: Codable {
        let width: Int
        let height: Int
        let resizable: Bool
        let title: String?
    }

    struct PermissionsConfig: Codable {
        let filesystem: Bool
        let notifications: Bool
        let shell: Bool

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.filesystem = try container.decodeIfPresent(Bool.self, forKey: .filesystem) ?? false
            self.notifications = try container.decodeIfPresent(Bool.self, forKey: .notifications) ?? false
            self.shell = try container.decodeIfPresent(Bool.self, forKey: .shell) ?? false
        }
    }

    // Load the config
    // This determines the NATIVE apis we will have to deal with
    static func load() throws -> RuntimeConfig {
        let env = ProcessInfo.processInfo.environment
        if let configuredPath = env["BEACON_RUNTIME_CONFIG"], !configuredPath.isEmpty {
            let configURL = URL(fileURLWithPath: configuredPath)
            let data = try Data(contentsOf: configURL)
            return try JSONDecoder().decode(RuntimeConfig.self, from: data)
        }

        let bundle = Bundle.main
        guard let configURL = bundle.url(forResource: "runtime.config", withExtension: "json") else {
            let execURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
            let devConfigURL = execURL.appendingPathComponent("runtime.config.json")
            if FileManager.default.fileExists(atPath: devConfigURL.path) {
                let data = try Data(contentsOf: devConfigURL)
                return try JSONDecoder().decode(RuntimeConfig.self, from: data)
            }
            throw ConfigError.notFound
        }
        let data = try Data(contentsOf: configURL)
        return try JSONDecoder().decode(RuntimeConfig.self, from: data)
    }

    enum ConfigError: LocalizedError {
        case notFound

        var errorDescription: String? {
            switch self {
            case .notFound:
                return "runtime.config.json not found in app bundle"
            }
        }
    }
}
