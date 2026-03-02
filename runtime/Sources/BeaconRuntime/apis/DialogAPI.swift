import AppKit

class DialogAPI {
    private let onBookmarkCreated: (URL) -> Void

    init(onBookmarkCreated: @escaping (URL) -> Void) {
        self.onBookmarkCreated = onBookmarkCreated
    }

    func handle(method: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        switch method {
        case "showOpenDialog":
            showOpenDialog(args: args, completion: completion)
        case "showSaveDialog":
            showSaveDialog(args: args, completion: completion)
        default:
            completion(.error("Unknown dialog method: \(method)"))
        }
    }

    private func showOpenDialog(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.canChooseDirectories = args["canChooseDirectories"] as? Bool ?? true
            panel.canChooseFiles = args["canChooseFiles"] as? Bool ?? true
            panel.allowsMultipleSelection = args["allowsMultipleSelection"] as? Bool ?? false
            panel.message = args["message"] as? String
            panel.prompt = args["buttonLabel"] as? String

            if panel.runModal() == .OK {
                let urls = panel.urls
                for url in urls {
                    self.onBookmarkCreated(url)
                }
                
                if args["allowsMultipleSelection"] as? Bool == true {
                    let paths = urls.map { $0.path }
                    if let jsonData = try? JSONSerialization.data(withJSONObject: paths),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        completion(.successJSON(jsonString))
                    } else {
                        completion(.error("Failed to serialize paths"))
                    }
                } else if let first = urls.first {
                    completion(.success(first.path))
                }
            } else {
                completion(.error("User cancelled"))
            }
        }
    }

    private func showSaveDialog(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        DispatchQueue.main.async {
            let panel = NSSavePanel()
            panel.message = args["message"] as? String
            panel.prompt = args["buttonLabel"] as? String
            panel.nameFieldStringValue = args["defaultName"] as? String ?? ""
            
            if panel.runModal() == .OK, let url = panel.url {
                self.onBookmarkCreated(url)
                completion(.success(url.path))
            } else {
                completion(.error("User cancelled"))
            }
        }
    }
}
