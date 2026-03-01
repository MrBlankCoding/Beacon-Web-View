import ArgumentParser

@main
struct BeaconCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "beacon",
        abstract: "Beacon — WebKit-based native app runtime packager for macOS",
        version: "1.0.0",
        subcommands: [BuildCommand.self]
    )
}
