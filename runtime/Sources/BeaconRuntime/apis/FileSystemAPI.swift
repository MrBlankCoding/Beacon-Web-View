import Foundation
import AppKit

/// Filesystem API — permission-gated file operations
class FileSystemAPI {
    private let permission: RuntimeConfig.PermissionsConfig.FilesystemPermission
    private let allowedPaths: [String]
    private var bookmarks: [String: Data] = [:]

    init(permission: RuntimeConfig.PermissionsConfig.FilesystemPermission) {
        self.permission = permission
        if case .scoped(let paths) = permission {
            self.allowedPaths = paths.map { FileSystemAPI.expandPath($0) }
        } else {
            self.allowedPaths = []
        }
        loadBookmarks()
    }

    private func loadBookmarks() {
        if let saved = UserDefaults.standard.dictionary(forKey: "beacon_fs_bookmarks") as? [String: Data] {
            self.bookmarks = saved
        }
    }

    private func saveBookmarks() {
        UserDefaults.standard.set(bookmarks, forKey: "beacon_fs_bookmarks")
    }

    public func addBookmark(url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            self.bookmarks[url.path] = bookmarkData
            self.saveBookmarks()
        } catch {
            print("Failed to create bookmark: \(error.localizedDescription)")
        }
    }

    private static func expandPath(_ path: String) -> String {
        var expanded = path
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        
        expanded = expanded.replacingOccurrences(of: "$HOME", with: home)
        expanded = expanded.replacingOccurrences(of: "$DOCUMENTS", with: (home as NSString).appendingPathComponent("Documents"))
        expanded = expanded.replacingOccurrences(of: "$DESKTOP", with: (home as NSString).appendingPathComponent("Desktop"))
        expanded = expanded.replacingOccurrences(of: "$DOWNLOADS", with: (home as NSString).appendingPathComponent("Downloads"))
        if expanded.contains("$APP_DATA") {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.path ?? (home as NSString).appendingPathComponent("Library/Application Support")
            expanded = expanded.replacingOccurrences(of: "$APP_DATA", with: appSupport)
        }

        return (expanded as NSString).expandingTildeInPath
    }

    private func isPathAllowed(_ path: String) -> Bool {
        if case .full = permission { return true }
        if case .disabled = permission { return false }
        
        let expandedTarget = FileSystemAPI.expandPath(path)
        for allowed in allowedPaths {
            if expandedTarget == allowed || expandedTarget.hasPrefix(allowed + "/") {
                return true
            }
        }
        
        for (bookmarkedPath, _) in bookmarks {
            if expandedTarget == bookmarkedPath || expandedTarget.hasPrefix(bookmarkedPath + "/") {
                return true
            }
        }
        
        return false
    }

    private func resolveBookmark(for path: String) -> (URL, Bool) {
        let expanded = FileSystemAPI.expandPath(path)
        
        let matchingPaths = bookmarks.keys.filter { expanded == $0 || expanded.hasPrefix($0 + "/") }
            .sorted { $0.count > $1.count }
        
        guard let bestMatch = matchingPaths.first, let data = bookmarks[bestMatch] else {
            return (URL(fileURLWithPath: expanded), false)
        }

        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                print("Bookmark for \(bestMatch) is stale")
            }
            
            var finalURL = url
            if expanded.count > bestMatch.count {
                let relativePath = String(expanded.dropFirst(bestMatch.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                finalURL = url.appendingPathComponent(relativePath)
            }
            
            return (finalURL, true)
        } catch {
            print("Failed to resolve bookmark: \(error)")
            return (URL(fileURLWithPath: expanded), false)
        }
    }

    func handle(method: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        if let path = args["path"] as? String {
            if !isPathAllowed(path) {
                completion(.error("Permission denied: path '\(path)' is outside of allowed scopes."))
                return
            }
        }

        switch method {
        case "showOpenDialog":
            showOpenDialog(args: args, completion: completion)
        case "readFile":
            readFile(args: args, completion: completion)
        case "writeFile":
            writeFile(args: args, completion: completion)
        case "listDirectory":
            listDirectory(args: args, completion: completion)
        case "exists":
            exists(args: args, completion: completion)
        case "isDirectory":
            isDirectory(args: args, completion: completion)
        default:
            completion(.error("Unknown filesystem method: \(method)"))
        }
    }

    private func showOpenDialog(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.canChooseDirectories = args["canChooseDirectories"] as? Bool ?? true
            panel.canChooseFiles = args["canChooseFiles"] as? Bool ?? true
            panel.allowsMultipleSelection = false
            
            if panel.runModal() == .OK, let url = panel.url {
                do {
                    let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                    self.bookmarks[url.path] = bookmarkData
                    self.saveBookmarks()
                    completion(.success(url.path))
                } catch {
                    completion(.error("Failed to create bookmark: \(error.localizedDescription)"))
                }
            } else {
                completion(.error("User cancelled"))
            }
        }
    }

    private func isDirectory(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        guard let path = args["path"] as? String else {
            completion(.error("fs.isDirectory requires a 'path' argument"))
            return
        }

        let (url, isScoped) = resolveBookmark(for: path)
        if isScoped { _ = url.startAccessingSecurityScopedResource() }
        defer { if isScoped { url.stopAccessingSecurityScopedResource() } }

        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)

        if exists && isDir.boolValue {
            completion(.successJSON("true"))
        } else {
            completion(.successJSON("false"))
        }
    }

    private func readFile(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        guard let path = args["path"] as? String else {
            completion(.error("fs.readFile requires a 'path' argument"))
            return
        }

        let (url, isScoped) = resolveBookmark(for: path)
        if isScoped { _ = url.startAccessingSecurityScopedResource() }
        defer { if isScoped { url.stopAccessingSecurityScopedResource() } }

        guard FileManager.default.fileExists(atPath: url.path) else {
            completion(.error("File not found: \(path)"))
            return
        }

        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
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

        let (url, isScoped) = resolveBookmark(for: path)
        if isScoped { _ = url.startAccessingSecurityScopedResource() }
        defer { if isScoped { url.stopAccessingSecurityScopedResource() } }

        do {
            let parentDir = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: parentDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
            let data = Data(content.utf8)
            try data.write(to: url, options: .atomic)
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

        let (url, isScoped) = resolveBookmark(for: path)
        if isScoped { _ = url.startAccessingSecurityScopedResource() }
        defer { if isScoped { url.stopAccessingSecurityScopedResource() } }

        do {
            let entries = try FileManager.default.contentsOfDirectory(atPath: url.path).sorted()
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

        let (url, isScoped) = resolveBookmark(for: path)
        if isScoped { _ = url.startAccessingSecurityScopedResource() }
        defer { if isScoped { url.stopAccessingSecurityScopedResource() } }

        let exists = FileManager.default.fileExists(atPath: url.path)

        if exists {
            completion(.successJSON("true"))
        } else {
            completion(.successJSON("false"))
        }
    }
}
