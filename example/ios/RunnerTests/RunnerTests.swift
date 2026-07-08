import Flutter
import UIKit
import XCTest


@testable import map_launcher

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {

  func testIsMapAvailableForAppleMaps() {
    let plugin = MapLauncherPlugin()

    let call = FlutterMethodCall(methodName: "isMapAvailable", arguments: ["mapType": "apple"])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertEqual(result as? Bool, true)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

}
