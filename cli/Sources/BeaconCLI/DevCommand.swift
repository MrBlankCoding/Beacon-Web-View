import ArgumentParser
import Foundation

struct DevCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "dev",
        abstract: "Run BeaconRuntime against a live dev server URL (hot reload)"
    )

    @Argument(help: "Path to the project directory containing runtime.config.json")
    var projectDir: String

    @Option(name: .long, help: "Dev server URL (default: http://localhost:5173)")
    var url: String = "http://localhost:5173"

    @Option(name: .long, help: "Path to prebuilt BeaconRuntime binary")
    var runtime: String?

    @Flag(name: .long, help: "Skip automatic BeaconRuntime build when the binary is missing")
    var skipRuntimeBuild: Bool = false

    mutating func run() throws {
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let projectURL = resolveUserPath(projectDir, relativeTo: cwd)

        guard let devServerURL = URL(string: url), devServerURL.scheme != nil else {
            throw ValidationError.invalidDevURL(url)
        }

        print("Beacon Dev Mode")
        print("   Project: \(projectURL.path)")
        print("   Dev URL: \(devServerURL.absoluteString)")
        print("")

        _ = try ConfigValidator.validate(projectDir: projectURL, requireEntryFile: false)
        print("runtime.config.json is valid")

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
        print("Launching runtime...")

        try launchRuntime(
            binary: runtimeBinaryURL,
            configPath: projectURL.appendingPathComponent("runtime.config.json"),
            devServerURL: devServerURL
        )
    }

    private func launchRuntime(binary: URL, configPath: URL, devServerURL: URL) throws {
        let process = Process()
        process.executableURL = binary
        process.environment = mergedEnvironment(
            [
                "BEACON_RUNTIME_CONFIG": configPath.path,
                "BEACON_DEV_SERVER_URL": devServerURL.absoluteString
            ]
        )
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError
        process.standardInput = FileHandle.standardInput
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ExitCode(process.terminationStatus)
        }
    }

    private func mergedEnvironment(_ vars: [String: String]) -> [String: String] {
        var env = ProcessInfo.processInfo.environment
        for (key, value) in vars {
            env[key] = value
        }
        return env
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
}

enum ValidationError: LocalizedError {
    case invalidDevURL(String)

    var errorDescription: String? {
        switch self {
        case .invalidDevURL(let url):
            return "Invalid dev URL: \(url)"
        }
    }
}
