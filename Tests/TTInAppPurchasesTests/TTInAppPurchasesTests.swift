import XCTest
@testable import TTInAppPurchases

final class TTInAppPurchasesTests: XCTestCase {

    /// `message` and `category` are folded into the breadcrumb properties.
    /// Tests the pure property builder so nothing is sent to live PostHog.
    func testBreadcrumbPropertiesMergesMessageAndCategory() {
        let props = AnalyticsHelper.breadcrumbProperties("App launched", category: "lifecycle")
        XCTAssertEqual(props["message"] as? String, "App launched")
        XCTAssertEqual(props["category"] as? String, "lifecycle")
    }

    /// Caller-supplied properties are preserved alongside the reserved keys.
    func testBreadcrumbPropertiesPreservesCustomProperties() {
        let props = AnalyticsHelper.breadcrumbProperties("Transcription finished",
                                                         category: "transcription",
                                                         properties: ["result": "Success"])
        XCTAssertEqual(props["result"] as? String, "Success")
        XCTAssertEqual(props["message"] as? String, "Transcription finished")
        XCTAssertEqual(props["category"] as? String, "transcription")
    }

    /// Reserved keys win: caller-supplied `category`/`message` are overwritten.
    func testBreadcrumbReservedKeysOverrideCallerValues() {
        let props = AnalyticsHelper.breadcrumbProperties("real message",
                                                         category: "real",
                                                         properties: ["category": "fake", "message": "fake"])
        XCTAssertEqual(props["category"] as? String, "real")
        XCTAssertEqual(props["message"] as? String, "real message")
    }
}
