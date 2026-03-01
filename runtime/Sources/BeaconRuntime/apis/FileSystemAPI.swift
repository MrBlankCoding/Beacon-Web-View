import Foundation

/// Filesystem API — permission-gated file operations
class FileSystemAPI {
    func handle(method: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        switch method {
        case "readFile":
            readFile(args: args, completion: completion)
        case "writeFile":
            writeFile(args: args, completion: completion)
        case "listDirectory":
            listDirectory(args: args, completion: completion)
        case "exists":
            exists(args: args, completion: completion)
        default:
            completion(.error("Unknown filesystem method: \(method)"))
        }
    }

    private func readFile(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        guard let path = args["path"] as? String else {
            completion(.error("fs.readFile requires a 'path' argument"))
            return
        }

        let expandedPath = NSString(string: path).expandingTildeInPath

        guard FileManager.default.fileExists(atPath: expandedPath) else {
            completion(.error("File not found: \(path)"))
            return
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: expandedPath), options: .mappedIfSafe)
            let content = String(decoding: data, as: UTF8.self)
            completion(.success(content))
        } catch {
            completion(.error("Failed to read file: \(error.localizedDescription)"))
        }
    }

    private func writeFile(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        guard let path = args["path"] as? String else {
            completion(.error("fs.writeFile requires a 'path' argument"))
            return
        }
        guard let content = args["content"] as? String else {
            completion(.error("fs.writeFile requires a 'content' argument"))
            return
        }

        let expandedPath = NSString(string: path).expandingTildeInPath

        do {
            let parentDir = (expandedPath as NSString).deletingLastPathComponent
            try FileManager.default.createDirectory(
                atPath: parentDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
            let data = Data(content.utf8)
            try data.write(to: URL(fileURLWithPath: expandedPath), options: .atomic)
            completion(.success("ok"))
        } catch {
            completion(.error("Failed to write file: \(error.localizedDescription)"))
        }
    }

    private func listDirectory(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        guard let path = args["path"] as? String else {
            completion(.error("fs.listDirectory requires a 'path' argument"))
            return
        }

        let expandedPath = NSString(string: path).expandingTildeInPath

        do {
            let entries = try FileManager.default.contentsOfDirectory(atPath: expandedPath).sorted()
            let jsonData = try JSONSerialization.data(withJSONObject: entries)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                completion(.successJSON(jsonString))
            } else {
                completion(.error("Failed to serialize directory listing"))
            }
        } catch {
            completion(.error("Failed to list directory: \(error.localizedDescription)"))
        }
    }

    private func exists(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        guard let path = args["path"] as? String else {
            completion(.error("fs.exists requires a 'path' argument"))
            return
        }

        let expandedPath = NSString(string: path).expandingTildeInPath
        let exists = FileManager.default.fileExists(atPath: expandedPath)

        if exists {
            completion(.successJSON("true"))
        } else {
            completion(.successJSON("false"))
        }
    }
}
