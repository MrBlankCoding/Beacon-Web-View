import Foundation

/// Assembles a .app bundle from project assets and runtime binary
class Packager {
    private let projectURL: URL
    private let outputURL: URL
    private let appName: String
    private let bundleId: String
    private let runtimeBinaryURL: URL
    private let config: ConfigValidator.ValidatedConfig
    private let iconURL: URL?
    private let signIdentity: String
    private let skipSign: Bool
    private let incremental: Bool

    init(
        projectURL: URL,
        outputURL: URL,
        appName: String,
        bundleId: String,
        runtimeBinaryURL: URL,
        config: ConfigValidator.ValidatedConfig,
        iconURL: URL?,
        signIdentity: String,
        skipSign: Bool,
        incremental: Bool
    ) {
        self.projectURL = projectURL
        self.outputURL = outputURL
        self.appName = appName
        self.bundleId = bundleId
        self.runtimeBinaryURL = runtimeBinaryURL
        self.config = config
        self.iconURL = iconURL
        self.signIdentity = signIdentity
        self.skipSign = skipSign
        self.incremental = incremental
    }

    func package() throws -> URL {
        let fm = FileManager.default
        let appBundleURL = outputURL.appendingPathComponent("\(appName).app")
        if !incremental, fm.fileExists(atPath: appBundleURL.path) {
            try fm.removeItem(at: appBundleURL)
        }

        let contentsURL = appBundleURL.appendingPathComponent("Contents")
        let macOSURL = contentsURL.appendingPathComponent("MacOS")
        let resourcesURL = contentsURL.appendingPathComponent("Resources")
        let webURL = resourcesURL.appendingPathComponent("web")

        try fm.createDirectory(at: macOSURL, withIntermediateDirectories: true)
        try fm.createDirectory(at: webURL, withIntermediateDirectories: true)

        let executableURL = macOSURL.appendingPathComponent(appName)
        try copyItemIfNeeded(from: runtimeBinaryURL, to: executableURL)
        try fm.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: executableURL.path
        )

        let runtimeBridgeURL = runtimeBinaryURL
            .deletingLastPathComponent()
            .appendingPathComponent("BeaconRuntime_BeaconRuntime.bundle/Resources/bridge.js")
        if fm.fileExists(atPath: runtimeBridgeURL.path) {
            let bridgeDestURL = resourcesURL.appendingPathComponent("bridge.js")
            try copyItemIfNeeded(from: runtimeBridgeURL, to: bridgeDestURL)
        }

        print("Runtime binary copied")

        let projectContents = try fm.contentsOfDirectory(at: projectURL, includingPropertiesForKeys: nil)
        for item in projectContents {
            let filename = item.lastPathComponent
            if filename == "runtime.config.json" { continue }
            if filename.hasPrefix(".") { continue }
            if filename == "node_modules" { continue }
            if filename == "package.json" { continue }
            if filename == "package-lock.json" { continue }

            let destURL = webURL.appendingPathComponent(filename)
            try copyItemIfNeeded(from: item, to: destURL)
        }
        print("Web assets copied")

        let configSrcURL = projectURL.appendingPathComponent("runtime.config.json")
        let configDestURL = resourcesURL.appendingPathComponent("runtime.config.json")
        try copyItemIfNeeded(from: configSrcURL, to: configDestURL)
        print("Config copied")

        if let iconURL {
            let iconDestURL = resourcesURL.appendingPathComponent("AppIcon.icns")
            try copyItemIfNeeded(from: iconURL, to: iconDestURL)
            print("App icon copied")
        }

        let plistContent = PlistGenerator.generate(
            appName: appName,
            bundleId: bundleId,
            executableName: appName,
            notificationsEnabled: config.permissions.notifications
        )
        let plistURL = contentsURL.appendingPathComponent("Info.plist")
        try plistContent.write(to: plistURL, atomically: true, encoding: .utf8)
        print("Info.plist generated")

        // 5. Create a minimal PkgInfo
        // Can be extended later
        let pkgInfoURL = contentsURL.appendingPathComponent("PkgInfo")
        try "APPL????".write(to: pkgInfoURL, atomically: true, encoding: .utf8)

        // 6. Sign app bundle so macOS services (e.g. notifications) can authorize it reliably
        if !skipSign {
            try signApp(at: appBundleURL)
            print("App bundle signed (\(signIdentity))")
        } else {
            print("Skipped app signing")
        }

        return appBundleURL
    }

    private func signApp(at appURL: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        process.arguments = ["--force", "--deep", "--sign", signIdentity, appURL.path]
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw PackagerError.appSigningFailed
        }
    }

    private func copyItemIfNeeded(from srcURL: URL, to destURL: URL) throws {
        let fm = FileManager.default
        let srcValues = try srcURL.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey])
        let isDir = srcValues.isDirectory ?? false

        if isDir {
            try fm.createDirectory(at: destURL, withIntermediateDirectories: true)
            let children = try fm.contentsOfDirectory(at: srcURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            for child in children {
                let childDest = destURL.appendingPathComponent(child.lastPathComponent)
                try copyItemIfNeeded(from: child, to: childDest)
            }
            return
        }

        if fm.fileExists(atPath: destURL.path),
           let destValues = try? destURL.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]),
           destValues.fileSize == srcValues.fileSize,
           destValues.contentModificationDate == srcValues.contentModificationDate {
            return
        }

        if fm.fileExists(atPath: destURL.path) {
            try fm.removeItem(at: destURL)
        }
        try fm.copyItem(at: srcURL, to: destURL)
    }
}
