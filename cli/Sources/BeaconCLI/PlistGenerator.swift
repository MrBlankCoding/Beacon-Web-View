import Foundation

/// Generates Info.plist for the .app bundle
enum PlistGenerator {
    static func generate(
        appName: String,
        bundleId: String,
        executableName: String,
        notificationsEnabled: Bool = false,
        microphoneEnabled: Bool = false,
        cameraEnabled: Bool = false,
        screenEnabled: Bool = false
    ) -> String {
        let notificationKeys = notificationsEnabled ? """
            <key>NSUserNotificationAlertStyle</key>
            <string>alert</string>
        """ : ""
        
        let microphoneKeys = microphoneEnabled ? """
            <key>NSMicrophoneUsageDescription</key>
            <string>\(appName) needs microphone access for audio calls.</string>
        """ : ""

        let cameraKeys = cameraEnabled ? """
            <key>NSCameraUsageDescription</key>
            <string>\(appName) needs camera access for video calls.</string>
        """ : ""

        let screenKeys = screenEnabled ? """
            <key>NSDisplayCaptureUsageDescription</key>
            <string>\(appName) needs screen recording access to share your screen.</string>
        """ : ""
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>CFBundleDevelopmentRegion</key>
            <string>en</string>
            <key>CFBundleExecutable</key>
            <string>\(executableName)</string>
            <key>CFBundleIconFile</key>
            <string>AppIcon</string>
            <key>CFBundleIdentifier</key>
            <string>\(bundleId)</string>
            <key>CFBundleInfoDictionaryVersion</key>
            <string>6.0</string>
            <key>CFBundleName</key>
            <string>\(appName)</string>
            <key>CFBundleDisplayName</key>
            <string>\(appName)</string>
            <key>CFBundlePackageType</key>
            <string>APPL</string>
            <key>CFBundleShortVersionString</key>
            <string>1.0.0</string>
            <key>CFBundleVersion</key>
            <string>1</string>
            <key>LSMinimumSystemVersion</key>
            <string>13.0</string>
            <key>NSHighResolutionCapable</key>
            <true/>
            <key>NSSupportsAutomaticTermination</key>
            <true/>
            <key>NSSupportsSuddenTermination</key>
            <true/>
        \(notificationKeys)
        \(microphoneKeys)
        \(cameraKeys)
        \(screenKeys)
        </dict>
        </plist>
        """
    }
}
