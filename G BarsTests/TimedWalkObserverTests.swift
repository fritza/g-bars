//
//  TimedWalkObserverTests.swift
//  G BarsTests
//
//  Created by Fritz Anderson on 8/22/22.
//

import XCTest
import CoreMotion
@testable import G_Bars

class TimedWalkObserverTests: XCTestCase {

// See AccelerometerItemTests
    var accelerations: [CMAcceleration] = [
        .init(x: 0, y: 0, z: 0),
        .init(x: 1, y: 0, z: 0),
        .init(x: 0, y: 1, z: 0),
        .init(x: 0, y: 0, z: 1),
        .init(x: -1, y: 0, z: 0),
        .init(x: 0, y: -1, z: 0),
        .init(x: 0, y: 0, z: -1),
        ]

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
