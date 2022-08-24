//
//  StagingTests.swift
//  G BarsTests
//
//  Created by Fritz Anderson on 8/17/22.
//

import XCTest
@testable import G_Bars

enum NotIterable: String, AppStages {
    var incremented: NotIterable? {
        switch self {
        case .niFour: return nil
        case .niOne: return .niTwo
        case .niThree: return .niThree
        case .niTwo: return .niThree
        }
    }

    var decremented: NotIterable? {
        switch self {
        case .niFour: return .niThree
        case .niOne: return nil
        case .niThree: return .niTwo
        case .niTwo: return .niOne
        }
    }
    case niOne, niTwo, niThree, niFour
    var csvPrefix: String? { "Ni\(self.rawValue)"}
}


enum IsIterable: String, CaseIterable, AppStages {
    /*
     NEEDS NEITHER
     var incremented: IsIterable?
     var decremented: IsIterable?
     */
    case iiOne, iiTwo, iiThree, iiFour
    var csvPrefix: String? { "Ii\(self.rawValue)"}
}



class StagingTests: XCTestCase {

    func testNotIterable() {
//        XCTAssert(NotIterable.niTwo == NotIterable.niTwo)
        XCTAssertEqual(NotIterable.niTwo.incremented, NotIterable.niThree)
        XCTAssertEqual(NotIterable.niTwo.decremented, NotIterable.niOne)

        XCTAssert(NotIterable.niThree.canDecrement)
        XCTAssert(NotIterable.niThree.canIncrement)
        XCTAssertNotNil(NotIterable.niThree.incremented)
        XCTAssertNotNil(NotIterable.niThree.decremented)

        XCTAssertFalse(NotIterable.niOne.canDecrement)
        XCTAssert(NotIterable.niOne.canIncrement)
        XCTAssertNotNil(NotIterable.niOne.incremented)
        XCTAssertNil(NotIterable.niOne.decremented)

        XCTAssert(NotIterable.niFour.canDecrement)
        XCTAssertFalse(NotIterable.niFour.canIncrement)
        XCTAssertNil(NotIterable.niFour.incremented)
        XCTAssertNotNil(NotIterable.niFour.decremented)
    }

    func testNonIterableEquality() {
        // You get Equatable for free,
        // but apparently not Comparable
        XCTAssert(NotIterable.niOne == NotIterable.niOne)
        XCTAssertFalse(NotIterable.niOne != NotIterable.niOne)
        XCTAssertFalse(NotIterable.niOne == NotIterable.niThree)
        XCTAssertFalse(NotIterable.niThree == NotIterable.niOne)
        XCTAssert(NotIterable.niOne != NotIterable.niThree)
        XCTAssert(NotIterable.niThree != NotIterable.niOne)
        XCTAssertEqual(NotIterable.niOne, NotIterable.niOne)
    }

    func testIsIterable() {
        XCTAssertEqual(IsIterable.iiTwo.incremented, IsIterable.iiThree)
        XCTAssertEqual(IsIterable.iiTwo.decremented, IsIterable.iiOne)

        XCTAssert(IsIterable.iiThree.canDecrement)
        XCTAssert(IsIterable.iiThree.canIncrement)
        XCTAssertNotNil(IsIterable.iiThree.incremented)
        XCTAssertNotNil(IsIterable.iiThree.decremented)

        XCTAssertFalse(IsIterable.iiOne.canDecrement)
        XCTAssert(IsIterable.iiOne.canIncrement)
        XCTAssertNotNil(IsIterable.iiOne.incremented)
        XCTAssertNil(IsIterable.iiOne.decremented)

        XCTAssert(IsIterable.iiFour.canDecrement)
        XCTAssertFalse(IsIterable.iiFour.canIncrement)
        XCTAssertNil(IsIterable.iiFour.incremented)
        XCTAssertNotNil(IsIterable.iiFour.decremented)
    }

    func testIsIterableEquality() {
        // You get Equatable for free,
        // but apparently not Comparable
        XCTAssert(IsIterable.iiOne == IsIterable.iiOne)
        XCTAssertFalse(IsIterable.iiOne != IsIterable.iiOne)
        XCTAssertFalse(IsIterable.iiOne == IsIterable.iiThree)
        XCTAssertFalse(IsIterable.iiThree == IsIterable.iiOne)
        XCTAssert(IsIterable.iiOne != IsIterable.iiThree)
        XCTAssert(IsIterable.iiThree != IsIterable.iiOne)
        XCTAssertEqual(IsIterable.iiOne, IsIterable.iiOne)
    }

    func testIsIterableComparison() {
        XCTAssert(IsIterable.iiOne < IsIterable.iiThree)
        XCTAssertFalse(IsIterable.iiThree < IsIterable.iiThree)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}
