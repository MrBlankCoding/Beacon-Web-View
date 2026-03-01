import ArgumentParser
import Foundation

struct BuildCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Package a web project into a native macOS .app bundle"
    )

    @Argument(help: "Path to the project directory containing runtime.config.json")
    var projectDir: String

    @Option(name: .long, help: "Output directory for the .app bundle (default: current directory)")
    var output: String = "."

    @Option(name: .long, help: "Application name (default: derived from project directory)")
    var name: String?

    @Option(name: .long, help: "Bundle identifier (default: com.beacon.<name>)")
    var bundleId: String?

    @Option(name: .long, help: "Path to prebuilt BeaconRuntime binary")
    var runtime: String?

    @Option(name: .long, help: "Path to .icns icon file to embed in the app bundle")
    var icon: String?

    @Flag(name: .long, help: "Skip automatic BeaconRuntime build when the binary is missing")
    var skipRuntimeBuild: Bool = false

    @Option(name: .long, help: "Code signing identity for the packaged app (default: ad-hoc '-')")
    var signIdentity: String = "-"

    @Flag(name: .long, help: "Skip code signing the packaged app")
    var skipSign: Bool = false

    @Flag(name: .long, inversion: .prefixedNo, help: "Enable incremental packaging (default: true)")
    var incremental: Bool = true

    mutating func run() throws {
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let projectURL = resolveUserPath(projectDir, relativeTo: cwd)
        let outputURL = resolveUserPath(output, relativeTo: cwd)
        let appName = name ?? projectURL.lastPathComponent
        let iconURL = try resolveIconPath(icon, relativeTo: cwd)
        print("Beacon Packager")
        print("   Project: \(projectURL.path)")
        print("   App Name: \(appName)")
        print("")

        // 1. Validate
        print("Validating project...")
        let config = try ConfigValidator.validate(projectDir: projectURL)
        print("runtime.config.json is valid")
        print("Entry file '\(config.entry)' found")
        print("")

        // 2. Find or build runtime binary
        let runtimeBinaryURL: URL
        if let runtimePath = runtime {
            runtimeBinaryURL = resolveUserPath(runtimePath, relativeTo: cwd)
        } else {
            runtimeBinaryURL = try resolveRuntimeBinary(projectURL: projectURL)
        }

        guard FileManager.default.fileExists(atPath: runtimeBinaryURL.path) else {
            throw PackagerError.runtimeBinaryNotFound(runtimeBinaryURL.path)
        }
        print("Using runtime: \(runtimeBinaryURL.path)")

        // 3. Package
        print("Assembling app bundle...")
        let packager = Packager(
            projectURL: projectURL,
            outputURL: outputURL,
            appName: appName,
            bundleId: bundleId ?? "com.beacon.\(appName.lowercased().replacingOccurrences(of: " ", with: "-"))",
            runtimeBinaryURL: runtimeBinaryURL,
            config: config,
            iconURL: iconURL,
            signIdentity: signIdentity,
            skipSign: skipSign,
            incremental: incremental
        )

        let appURL = try packager.package()

        print("")
        print("Packaged: \(appURL.path)")
        print("")
        print("To run: open \"\(appURL.path)\"")
        print("Size: \(try formattedSize(of: appURL))")
    }

    private func formattedSize(of url: URL) throws -> String {
        let resourceValues = try url.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .isDirectoryKey])
        if resourceValues.isDirectory == true {
            var totalSize: Int64 = 0
            if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
                for case let fileURL as URL in enumerator {
                    let fileSize = try fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                    totalSize += Int64(fileSize)
                }
            }
            return formatBytes(totalSize)
        }
        return formatBytes(Int64(resourceValues.totalFileAllocatedSize ?? 0))
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    private func resolveRuntimeBinary(projectURL: URL) throws -> URL {
        let fm = FileManager.default
        let cwd = URL(fileURLWithPath: fm.currentDirectoryPath).standardized
        let cliBinDir = URL(fileURLWithPath: CommandLine.arguments[0]).standardized.deletingLastPathComponent()
        let cliPackageDir = cliBinDir.deletingLastPathComponent().deletingLastPathComponent()

        let candidates: [URL] = [
            cliBinDir.appendingPathComponent("BeaconRuntime"),
            cwd.appendingPathComponent("runtime/.build/debug/BeaconRuntime"),
            cwd.appendingPathComponent("runtime/.build/release/BeaconRuntime"),
            projectURL.deletingLastPathComponent().appendingPathComponent("runtime/.build/debug/BeaconRuntime"),
            projectURL.deletingLastPathComponent().appendingPathComponent("runtime/.build/release/BeaconRuntime"),
            cliPackageDir.deletingLastPathComponent().appendingPathComponent("runtime/.build/debug/BeaconRuntime"),
            cliPackageDir.deletingLastPathComponent().appendingPathComponent("runtime/.build/release/BeaconRuntime")
        ]

        if let found = candidates.first(where: { fm.fileExists(atPath: $0.path) }) {
            return found.standardized
        }

        if skipRuntimeBuild {
            throw PackagerError.runtimeBinaryNotFound(candidates[0].path)
        }

        let runtimeProjectCandidates: [URL] = [
            cwd.appendingPathComponent("runtime"),
            projectURL.deletingLastPathComponent().appendingPathComponent("runtime"),
            cliPackageDir.deletingLastPathComponent().appendingPathComponent("runtime")
        ]

        guard let runtimeProjectDir = runtimeProjectCandidates.first(where: {
            fm.fileExists(atPath: $0.appendingPathComponent("Package.swift").path)
        }) else {
            throw PackagerError.runtimeProjectNotFound
        }

        print("Runtime binary not found. Building runtime at: \(runtimeProjectDir.path)")
        try runCommand(
            executable: "/usr/bin/env",
            arguments: ["swift", "build"],
            directory: runtimeProjectDir
        )

        let built = runtimeProjectDir.appendingPathComponent(".build/debug/BeaconRuntime")
        guard fm.fileExists(atPath: built.path) else {
            throw PackagerError.runtimeBinaryNotFound(built.path)
        }
        return built.standardized
    }

    private func runCommand(executable: String, arguments: [String], directory: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.currentDirectoryURL = directory
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw PackagerError.runtimeBuildFailed
        }
    }

    private func resolveUserPath(_ path: String, relativeTo base: URL) -> URL {
        let expanded = (path as NSString).expandingTildeInPath
        if expanded.hasPrefix("/") {
            return URL(fileURLWithPath: expanded).standardizedFileURL
        }
        return base.appendingPathComponent(expanded).standardizedFileURL
    }

    private func resolveIconPath(_ path: String?, relativeTo base: URL) throws -> URL? {
        guard let path else { return nil }
        let resolved = resolveUserPath(path, relativeTo: base)
        let fm = FileManager.default
        guard fm.fileExists(atPath: resolved.path) else {
            throw PackagerError.iconFileNotFound(resolved.path)
        }
        guard resolved.pathExtension.lowercased() == "icns" else {
            throw PackagerError.invalidIconFile(resolved.path)
        }
        return resolved
    }
}

enum PackagerError: LocalizedError {
    case runtimeBinaryNotFound(String)
    case runtimeProjectNotFound
    case runtimeBuildFailed
    case appSigningFailed
    case iconFileNotFound(String)
    case invalidIconFile(String)

    var errorDescription: String? {
        switch self {
        case .runtimeBinaryNotFound(let path):
            return "BeaconRuntime binary not found at: \(path)\nYou can specify a binary with: --runtime /path/to/BeaconRuntime"
        case .runtimeProjectNotFound:
            return "Could not locate the runtime project (missing runtime/Package.swift). Build BeaconRuntime manually and pass --runtime."
        case .runtimeBuildFailed:
            return "Failed to build BeaconRuntime automatically. Build it manually with: cd runtime && swift build"
        case .appSigningFailed:
            return "Failed to codesign the generated app bundle. Retry, or build with --skip-sign."
        case .iconFileNotFound(let path):
            return "Icon file not found at: \(path)"
        case .invalidIconFile(let path):
            return "Icon file must be an .icns file: \(path)"
        }
    }
}
