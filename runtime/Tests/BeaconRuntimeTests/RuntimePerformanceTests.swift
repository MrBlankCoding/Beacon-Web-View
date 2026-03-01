import Foundation
import XCTest
@testable import BeaconRuntime

final class RuntimePerformanceTests: XCTestCase {
    func testResolveConcurrencyLimitDefaultsToCpuBoundWithCap() {
        XCTAssertEqual(
            BridgeHandler.resolveConcurrencyLimit(environment: [:], cpuCount: 1),
            2
        )
        XCTAssertEqual(
            BridgeHandler.resolveConcurrencyLimit(environment: [:], cpuCount: 8),
            8
        )
        XCTAssertEqual(
            BridgeHandler.resolveConcurrencyLimit(environment: [:], cpuCount: 64),
            16
        )
    }

    func testResolveConcurrencyLimitUsesEnvironmentOverride() {
        XCTAssertEqual(
            BridgeHandler.resolveConcurrencyLimit(
                environment: ["BEACON_MAX_API_CONCURRENCY": "6"],
                cpuCount: 12
            ),
            6
        )
        XCTAssertEqual(
            BridgeHandler.resolveConcurrencyLimit(
                environment: ["BEACON_MAX_API_CONCURRENCY": "200"],
                cpuCount: 12
            ),
            64
        )
        XCTAssertEqual(
            BridgeHandler.resolveConcurrencyLimit(
                environment: ["BEACON_MAX_API_CONCURRENCY": "invalid"],
                cpuCount: 12
            ),
            12
        )
    }
}

final class BridgeResourceTests: XCTestCase {
    func testResolveBridgeScriptLoadsValidBridge() throws {
        let bundle = try makeBundle(bridgeSource: """
        (function() {
            window.__beacon_nativeCallback = function() {};
            window.beacon = {};
        })();
        """)
        let script = try WebViewManager.resolveBridgeScript(in: bundle)
        XCTAssertTrue(WebViewManager.isValidBridgeScript(script))
    }

    func testResolveBridgeScriptThrowsWhenMissing() throws {
        let bundle = try makeBundle(bridgeSource: nil)
        XCTAssertThrowsError(try WebViewManager.resolveBridgeScript(in: bundle)) { error in
            XCTAssertEqual(error as? BridgeScriptError, .missing)
        }
    }

    func testResolveBridgeScriptThrowsWhenInvalid() throws {
        let bundle = try makeBundle(bridgeSource: "window.beacon = {};")
        XCTAssertThrowsError(try WebViewManager.resolveBridgeScript(in: bundle)) { error in
            XCTAssertEqual(error as? BridgeScriptError, .invalid)
        }
    }

    private func makeBundle(bridgeSource: String?) throws -> Bundle {
        let fm = FileManager.default
        let bundleRoot = fm.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("bundle")
        let contentsURL = bundleRoot.appendingPathComponent("Contents")
        let resourcesURL = contentsURL.appendingPathComponent("Resources")

        try fm.createDirectory(at: resourcesURL, withIntermediateDirectories: true)

        let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>CFBundleIdentifier</key><string>com.beacon.tests.bundle</string>
            <key>CFBundleName</key><string>BeaconRuntimeTests</string>
            <key>CFBundlePackageType</key><string>BNDL</string>
            <key>CFBundleVersion</key><string>1</string>
        </dict>
        </plist>
        """
        try plist.write(to: contentsURL.appendingPathComponent("Info.plist"), atomically: true, encoding: .utf8)

        if let bridgeSource {
            try bridgeSource.write(
                to: resourcesURL.appendingPathComponent("bridge.js"),
                atomically: true,
                encoding: .utf8
            )
        }

        guard let bundle = Bundle(url: bundleRoot) else {
            XCTFail("Failed to create test bundle")
            throw BridgeScriptError.missing
        }
        return bundle
    }
}
