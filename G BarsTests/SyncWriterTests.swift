//
//  SyncWriterTests.swift
//  G BarsTests
//
//  Created by Fritz Anderson on 8/12/22.
//

import XCTest
import CoreMotion

@testable import G_Bars

class SyncWriterTests: XCTestCase {

    static var details: [(x: Double, y: Double, z: Double, t: Double)] = [
        (10, 1, 0, 0), (11, 0, 1, 0),
        (12, 0, 0, 1)
    ]

    static var items: [AccelerometerItem] =
    details.map {
        (t, x, y, z) -> AccelerometerItem in
            .init(timestamp: t, x: x, y: y, z: z)
    }

    static let expected = [
        "10,1.0,0.0,0.0",
        "11,0.0,1.0,0.0",
        "12,0.0,0.0,1.0",
        ]

    static let expectedItems: [AccelerometerItem] = expected
        .map { str -> [Double] in
            let comps = str.split(separator: ",")
                .map { Double($0)! }
            return comps
        }
        .map { dbls -> AccelerometerItem in
                .init(timestamp: dbls[0], x: dbls[1], y: dbls[2], z: dbls[3])
            }

    func testSWInit() throws {
        let lhs = Self.items
        let rhs = Self.expectedItems

        XCTAssertEqual(lhs.count, rhs.count)

        zip(lhs, rhs)
            .map { (l, r) -> (String, String) in (l.csvLine!, r.csvLine!) }
            .forEach { (l, r) in
                XCTAssertEqual(l, r)
            }
    }

    /*
     SyncAccelerationWriter no longer available
     */
//    func testWritingCreate() throws {
//        do {
//            let writer: SyncAccelerationWriter<MockWriter>
//            writer = try
//            SyncAccelerationWriter<MockWriter>(
//                destination: URL(fileURLWithPath: "/dev/null/q.csv"),
//                records: Self.items)
//            try writer.write()
//            try writer.close()
//        }
//        catch {
//            XCTFail("Creation of MockWriter failed: \(error)")
//        }
//    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
