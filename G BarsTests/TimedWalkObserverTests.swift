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
    static let accelerations: [MockAccelerometerData] = [
        .init(t: 0.1, x: 0, y: 0, z: 0),
        .init(t: 0.2, x: 1, y: 0, z: 0),
        .init(t: 0.3, x: 0, y: 1, z: 0),
        .init(t: 0.4, x: 0, y: 0, z: 1),
        .init(t: 0.5, x: -1, y: 0, z: 0),
        .init(t: 0.6, x: 0, y: -1, z: 0),
        .init(t: 0.7, x: 0, y: 0, z: -1),
        ]

    static let itemsMarshalled: [String] = [
        "0.10000,0.00000,0.00000,0.00000",
        "0.20000,1.00000,0.00000,0.00000",
        "0.30000,0.00000,1.00000,0.00000",
        "0.40000,0.00000,0.00000,1.00000",
        "0.50000,-1.00000,0.00000,0.00000",
        "0.60000,0.00000,-1.00000,0.00000",
        "0.70000,0.00000,0.00000,-1.00000",
        ]

    static let ts = accelerations.map(\.timestamp)
    static let xes = accelerations.map(\.acceleration.x)
    static let ys  = accelerations.map(\.acceleration.y)
    static let zs  = accelerations.map(\.acceleration.z)


    static func observer(titled: String) -> TimedWalkObserver {
        return TimedWalkObserver(title: titled)
    }

    func testInitialization() {
        let observer = Self.observer(titled: "Title not used - start")

        XCTAssertEqual("Title not used - start",
                       observer.title)
        XCTAssertFalse(observer.isRunning)
        XCTAssert(observer.consumer.isEmpty)
    }

    func testStarting() {
        let observer = Self.observer(
            titled: "Title not used - start")
        observer.testableStart()

        XCTAssert(observer.isRunning)
        XCTAssertEqual(observer.consumer.count, 7)
    }

    func testTickloop() async {
        let observer = Self.observer(titled: "Title not used - tick")
        observer.testableStart()
        
        // TODO:  Find a way to test the actual heartbeat from MotionManager.
        for (n, datum) in Self.accelerations.enumerated() {
            XCTAssertEqual(Self.ts[n], datum.timestamp)
            XCTAssertEqual(Self.xes[n], datum.acceleration.x)
            XCTAssertEqual(Self.ys[n], datum.acceleration.y)
            XCTAssertEqual(Self.zs[n], datum.acceleration.z)
        }
    }
    
    func testDataMarshalling() {
        let observer = Self.observer(titled: "Title not used - marshall-1")
        observer.testableStart()

        let observerStrings = observer.marshalledRecords()
        XCTAssertEqual(observerStrings.count, observer.consumer.count)

        for n in (0..<Self.itemsMarshalled.count) {
            XCTAssertEqual(Self.itemsMarshalled[n], observerStrings[n])
        }
    }

    func testPrefixedMarshalling() {
        let observer = Self.observer(titled: "Title not used - marshall-prefix")
        observer.testableStart()

        let prefix = "PREFIX"
        let expectedStrings = Self.itemsMarshalled
            .map { "\(prefix),\($0)" }

        let observerStrings = observer.marshalledRecords(withPrefix: "PREFIX")
        XCTAssertEqual(observerStrings.count, expectedStrings.count)

        for n in (0..<Self.itemsMarshalled.count) {
            XCTAssertEqual(expectedStrings[n],
                           observerStrings[n],
            "Checking the prefixed marshall")
        }
    }

    func testAllAsCSV() {
        let observer = Self.observer(titled: "Not used")
        observer.testableStart()

        let prefix = "PrixFixe"
        let expectedRows = Self.itemsMarshalled
            .map { "\(prefix),\($0)" }
        let expectedString = expectedRows.joined(separator: "\r\n")

        let observerString = observer.allAsCSV(withPrefix: prefix)
        XCTAssertEqual(expectedString, observerString,
        "Marshalled records into string")

        let broken = observerString.split(separator: "\r\n")
        XCTAssert(!broken.last!.isEmpty,
        "if the last item is empty, it means an off-by-one in the encoding process.")
        // BUT: Is the \r\n a separator or a terminator?
        // If it's supposed to be aterminator then the last
        // line _should_ be empty… and… force
        // the consumer of the file to handle an empty
        // record?
        XCTAssertEqual(broken.count, Self.accelerations.count, "Reconstitute record count")
    }

}
