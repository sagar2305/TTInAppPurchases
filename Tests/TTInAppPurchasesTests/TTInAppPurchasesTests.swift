import XCTest
@testable import TTInAppPurchases

final class TTInAppPurchasesTests: XCTestCase {
    func testExample() throws {
    }

    /// Exercises the new breadcrumb API end-to-end through the real AnalyticsHelper
    /// (which configures PostHog in its init). Proves logBreadcrumb runs without crashing
    /// and accepts the message/category/properties shapes used at the app call sites.
    func testLogBreadcrumbRunsWithoutCrashing() {
        AnalyticsHelper.shared.logBreadcrumb("unit-test breadcrumb")
        AnalyticsHelper.shared.logBreadcrumb("App launched", category: "lifecycle")
        AnalyticsHelper.shared.logBreadcrumb("Transcription finished",
                                             category: "transcription",
                                             properties: ["result": "Success"])
        XCTAssertTrue(true)
    }
}
