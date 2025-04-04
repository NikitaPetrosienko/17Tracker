
import XCTest
import UIKit
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewController() {
        
        let vc = TrackersViewController()
        
        assertSnapshot(of: vc, as: .image(traits: (UITraitCollection(userInterfaceStyle: .light))), record: false)
        assertSnapshot(of: vc, as: .image(traits: (UITraitCollection(userInterfaceStyle: .dark))), record: false)
        
    }
}
