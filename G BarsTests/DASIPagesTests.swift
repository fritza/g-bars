//
//  DASIPagesTests.swift
//  G BarsTests
//
//  Created by Fritz Anderson on 7/8/22.
//

import XCTest
@testable import G_Bars

class DASIPagesTests: XCTestCase {
    // Unfortunately, I don't have time to consume the @Published attributes

    func testIncrement() {
        let pages = DASIPages()
        XCTAssertEqual(pages.selected, .intro)
        XCTAssertFalse(pages.refersToQuestion)

        XCTAssert(pages.increment())
        XCTAssertEqual(pages.selected, .responding(index: DASIPhase.startQuestionID))
        for qID in (DASIPhase.startQuestionID+1
                    ...
                    DASIPhase.endQuestionID) {
            XCTAssert(pages.increment())
            XCTAssertEqual(pages.selected, .responding(index: qID),
                           "Increment from ID \(qID)")
            XCTAssert(pages.refersToQuestion)
        }

        XCTAssert(pages.increment())
        XCTAssertEqual(pages.selected, .display)
        XCTAssert(pages.increment())
        XCTAssertEqual(pages.selected, .completion)
        XCTAssertFalse(pages.refersToQuestion)

        // FIXME: What happens if you increment beyond .completion?
    }
//
//    func testIN() {
//        let pages = DASIPages()
//
//        for qn in (DASIPhase.startQuestionID...DASIPhase.endQuestionID) {
//            XCTAssert(pages.increment())
//            XCTAssertNotNil(pages.selected)
//            XCTAssertEqual(pages.selected, .responding(index: qn))
//                // In this look successor should not be nil
//
//            XCTAssertNotNil(pages.questionIdentifier)
//            if let nextNumber = pages.questionIdentifier {
//                XCTAssertEqual(nextNumber, qn)
//            }
//        }
//    }


}
