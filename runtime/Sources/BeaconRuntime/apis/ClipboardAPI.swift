import AppKit

class ClipboardAPI {
    func handle(method: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        switch method {
        case "readText":
            readText(completion: completion)
        case "writeText":
            writeText(args: args, completion: completion)
        default:
            completion(.error("Unknown clipboard method: \(method)"))
        }
    }

    private func readText(completion: @escaping (APIResult) -> Void) {
        let pasteboard = NSPasteboard.general
        if let text = pasteboard.string(forType: .string) {
            completion(.success(text))
        } else {
            completion(.success(""))
        }
    }

    private func writeText(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        guard let text = args["text"] as? String else {
            completion(.error("clipboard.writeText requires a 'text' argument"))
            return
        }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        completion(.success("ok"))
    }
}
