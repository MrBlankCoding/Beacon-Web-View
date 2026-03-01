import Foundation

/// Validates the project struct
enum ConfigValidator {
    struct ValidatedConfig {
        let entry: String
        let window: WindowConfig
        let permissions: PermissionsConfig

        struct WindowConfig {
            let width: Int
            let height: Int
            let resizable: Bool
            let title: String?
        }

        struct PermissionsConfig {
            let filesystem: Bool
            let notifications: Bool
            let shell: Bool
        }
    }

    static func validate(projectDir: URL) throws -> ValidatedConfig {
        let configURL = projectDir.appendingPathComponent("runtime.config.json")

        guard FileManager.default.fileExists(atPath: configURL.path) else {
            throw ValidationError.configNotFound(projectDir.path)
        }

        let data = try Data(contentsOf: configURL)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ValidationError.invalidJSON
        }

        guard let entry = json["entry"] as? String, !entry.isEmpty else {
            throw ValidationError.missingField("entry")
        }

        let entryURL = projectDir.appendingPathComponent(entry)
        guard FileManager.default.fileExists(atPath: entryURL.path) else {
            throw ValidationError.entryFileNotFound(entry)
        }

        guard let windowJSON = json["window"] as? [String: Any] else {
            throw ValidationError.missingField("window")
        }

        guard let width = windowJSON["width"] as? Int, width > 0 else {
            throw ValidationError.invalidField("window.width", "must be a positive integer")
        }

        guard let height = windowJSON["height"] as? Int, height > 0 else {
            throw ValidationError.invalidField("window.height", "must be a positive integer")
        }

        let resizable = windowJSON["resizable"] as? Bool ?? true
        let title = windowJSON["title"] as? String

        // permissions
        let permissionsJSON = json["permissions"] as? [String: Any] ?? [:]
        let permissions = ValidatedConfig.PermissionsConfig(
            filesystem: permissionsJSON["filesystem"] as? Bool ?? false,
            notifications: permissionsJSON["notifications"] as? Bool ?? false,
            shell: permissionsJSON["shell"] as? Bool ?? false
        )

        return ValidatedConfig(
            entry: entry,
            window: ValidatedConfig.WindowConfig(
                width: width,
                height: height,
                resizable: resizable,
                title: title
            ),
            permissions: permissions
        )
    }

    enum ValidationError: LocalizedError {
        case configNotFound(String)
        case invalidJSON
        case missingField(String)
        case invalidField(String, String)
        case entryFileNotFound(String)

        var errorDescription: String? {
            switch self {
            case .configNotFound(let dir):
                return "runtime.config.json not found in \(dir)"
            case .invalidJSON:
                return "runtime.config.json is not valid JSON"
            case .missingField(let field):
                return "Missing required field: \(field)"
            case .invalidField(let field, let reason):
                return "Invalid field '\(field)': \(reason)"
            case .entryFileNotFound(let entry):
                return "Entry file '\(entry)' not found in project directory"
            }
        }
    }
}
