//
//  RoughEqualityTests.swift
//  G BarsTests
//
//  Created by Fritz Anderson on 8/12/22.
//

import XCTest
@testable import G_Bars

fileprivate let cases: [(Double, Double, Bool)] =
[
    // with ε == 1.0e-3

    (1.101, 1.0, false),
    (1.0, 1.101, false),
    (-1.101, 1.0, false),
    (1.101, -1.0, false),
    (-1.101, -1.0, false),
    (1.0, 1.1, false),
    (1.0, 1.101, false),
    (1.0, 2.0, false),
    (1.0, 0.0, false),
    (0.0, 1.0, false),
    (0.000001, 0.0, false),
    (1.0, -1.0, false),
    (-1.0, 1.0, false),
    (-1.0, 1.0, false),
    (1_000.0, 1_100.0, false),
    (1_000.0, 1_010.0, false),
    (1.0, 1.0, true),
    (1.0, 1.001, true),
    (0.0, 0.0, true),
    (1_000.0, 1_001.0, true),
]


class RoughEqualityTests: XCTestCase {


    func testRoughEquality() throws {
        for (lhs, rhs, equal) in cases {
            XCTAssert((lhs ≈ rhs) == equal,
                      "≈ between \(lhs) and \(rhs) should be \(equal)")
        }
    }
}
