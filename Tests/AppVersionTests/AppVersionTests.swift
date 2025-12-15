import XCTest
@testable import AppVersion

@MainActor
final class AppVersionTests: XCTestCase {
    
    var userDefaults: UserDefaults!
    var suiteName: String!
    
    override func setUp() async throws {
        try await super.setUp()
        suiteName = UUID().uuidString
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
    }
    
    override func tearDown() async throws {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        try await super.tearDown()
    }
    
    func testFirstLaunch() {
        let tracker = AppVersionTracker(userDefaults: userDefaults, currentVersion: "1.0")
        
        // Before tracking
        XCTAssertTrue(tracker.isFirstLaunch)
        XCTAssertNil(tracker.previousVersion)
        XCTAssertTrue(tracker.history.isEmpty)
        
        // Track
        tracker.track()
        
        // After tracking also we treat it as the first launch for the rest of the current session.
        XCTAssertTrue(tracker.isFirstLaunch)
        XCTAssertEqual(tracker.history.count, 1)
        XCTAssertEqual(tracker.history.first, "1.0")
        XCTAssertNil(tracker.previousVersion)
        XCTAssertFalse(tracker.isUpgrade)
    }
    
    func testSubsequentLaunchSameVersion() {
        // First launch
        let tracker1 = AppVersionTracker(userDefaults: userDefaults, currentVersion: "1.0")
        tracker1.track()
        
        // Second launch, same version
        let tracker2 = AppVersionTracker(userDefaults: userDefaults, currentVersion: "1.0")
        
        // Before track
        XCTAssertFalse(tracker2.isFirstLaunch)
        XCTAssertEqual(tracker2.history, ["1.0"])
        
        tracker2.track()
        
        XCTAssertEqual(tracker2.history.count, 1)
        XCTAssertEqual(tracker2.history.first, "1.0")
        XCTAssertEqual(tracker2.previousVersion, "1.0")
        XCTAssertFalse(tracker2.isUpgrade)
    }
    
    func testUpgrade() {
        // First launch v1.0
        let tracker1 = AppVersionTracker(userDefaults: userDefaults, currentVersion: "1.0")
        tracker1.track()
        
        // Upgrade to v2.0
        let tracker2 = AppVersionTracker(userDefaults: userDefaults, currentVersion: "2.0")
        
        // Before track
        XCTAssertFalse(tracker2.isFirstLaunch)
        XCTAssertEqual(tracker2.history, ["1.0"])
        
        tracker2.track()
        
        XCTAssertEqual(tracker2.history, ["1.0", "2.0"])
        XCTAssertEqual(tracker2.previousVersion, "1.0")
        XCTAssertTrue(tracker2.isUpgrade)
        XCTAssertEqual(tracker2.currentVersion, "2.0")
    }
    
    func testMultipleUpgrades() {
        // v1.0
        let t1 = AppVersionTracker(userDefaults: userDefaults, currentVersion: "1.0")
        t1.track()
        
        // v1.1
        let t2 = AppVersionTracker(userDefaults: userDefaults, currentVersion: "1.1")
        t2.track()
        
        XCTAssertEqual(t2.previousVersion, "1.0")
        XCTAssertTrue(t2.isUpgrade)
        
        // v2.0
        let t3 = AppVersionTracker(userDefaults: userDefaults, currentVersion: "2.0")
        t3.track()
        
        XCTAssertEqual(t3.previousVersion, "1.1")
        XCTAssertTrue(t3.isUpgrade)
        XCTAssertEqual(t3.history, ["1.0", "1.1", "2.0"])
    }
}

