import Foundation

/// Shell API — executes commands through /bin/zsh -lc
class ShellAPI {
    func handle(method: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        switch method {
        case "exec":
            exec(args: args, completion: completion)
        default:
            completion(.error("Unknown shell method: \(method)"))
        }
    }

    private func exec(args: [String: Any], completion: @escaping (APIResult) -> Void) {
        guard let command = args["command"] as? String, !command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.error("shell.exec requires a non-empty 'command' argument"))
            return
        }

        let process = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-lc", command]
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            completion(.error("Failed to run command: \(error.localizedDescription)"))
            return
        }

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""
        let combined = stdout + stderr

        if process.terminationStatus == 0 {
            completion(.success(combined.isEmpty ? "(no output)" : combined))
        } else {
            let output = combined.trimmingCharacters(in: .whitespacesAndNewlines)
            if output.isEmpty {
                completion(.error("Command failed with exit code \(process.terminationStatus)"))
            } else {
                completion(.error(output))
            }
        }
    }
}
