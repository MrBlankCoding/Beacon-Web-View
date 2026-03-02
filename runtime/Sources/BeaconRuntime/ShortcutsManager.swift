import AppKit

/// A robust manager for system-wide and local keyboard shortcuts.
final class ShortcutsManager {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var registeredShortcuts = Set<ShortcutDescriptor>()
    var onShortcutTriggered: ((String) -> Void)?

    init() {
        setupMonitors()
    }

    private func setupMonitors() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleEvent(event)
        }
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleEvent(event)
            return event
        }
    }

    private func handleEvent(_ event: NSEvent) {
        guard let chars = event.charactersIgnoringModifiers?.lowercased() else { return }
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        let descriptor = ShortcutDescriptor(key: chars, modifiers: flags)
        if registeredShortcuts.contains(descriptor) {
            onShortcutTriggered?(descriptor.description)
        }
    }

    func register(shortcut string: String) {
        if let descriptor = ShortcutDescriptor.parse(string) {
            registeredShortcuts.insert(descriptor)
        }
    }

    func unregisterAll() {
        registeredShortcuts.removeAll()
    }

    deinit {
        if let monitor = globalMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = localMonitor { NSEvent.removeMonitor(monitor) }
    }
}

struct ShortcutDescriptor: Hashable, CustomStringConvertible {
    let key: String
    let modifiers: NSEvent.ModifierFlags

    var description: String {
        var parts: [String] = []
        if modifiers.contains(.command) { parts.append("command") }
        if modifiers.contains(.shift) { parts.append("shift") }
        if modifiers.contains(.control) { parts.append("control") }
        if modifiers.contains(.option) { parts.append("option") }
        parts.append(key)
        return parts.joined(separator: "+")
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(modifiers.rawValue)
    }

    static func parse(_ string: String) -> ShortcutDescriptor? {
        let parts = string.lowercased().split(separator: "+")
        guard let keyPart = parts.last else { return nil }
        
        var flags: NSEvent.ModifierFlags = []
        for part in parts.dropLast() {
            switch part {
            case "command", "cmd": flags.insert(.command)
            case "shift": flags.insert(.shift)
            case "control", "ctrl": flags.insert(.control)
            case "option", "alt": flags.insert(.option)
            default: break
            }
        }
        
        return ShortcutDescriptor(key: String(keyPart), modifiers: flags)
    }
}

