//
//  DASIPhaseTests.swift
//  G BarsTests
//
//  Created by Fritz Anderson on 7/8/22.
//

import XCTest
@testable import G_Bars


// FIXME: Add tests for Comparable and Range<Bound>

class DASIPhaseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // FIXME: Add testRespondingDecrement
    func testRespondingIncrement() throws {
        var phase = DASIPhase.intro
        XCTAssertEqual(phase, .intro)

        for qn in (DASIPhase.startQuestionID...DASIPhase.endQuestionID) {
            let successorValue = phase.successor()
                // In this look successor should not be nil
            XCTAssertNotNil(successorValue)
            XCTAssertEqual(successorValue!, .responding(index: qn))

            let didAdvance = phase.advance()
            XCTAssert(didAdvance)
            XCTAssert(phase.refersToQuestion)

            XCTAssertNotNil(phase.questionIdentifier)
            if let nextNumber = phase.questionIdentifier {
                XCTAssertEqual(nextNumber, qn)
            }
        }

        XCTAssertEqual(phase, .responding(index: DASIPhase.endQuestionID))
    }

    func testMutationOutOfRange() {
        var lowEnd = DASIPhase.intro
        XCTAssertFalse(lowEnd.decrement())

        var middle = DASIPhase.display
        XCTAssert(middle.decrement())

        var highEnd = DASIPhase.completion
        XCTAssertFalse(highEnd.advance())
        middle = .display
        XCTAssert(middle.advance())
    }

    func testIncrementToDisplay() {
        var phase: DASIPhase = .responding(index: DASIPhase.endQuestionID)
        let successorValue = phase.successor()
        XCTAssertNotNil(successorValue)

        if let sValue = successorValue {
            XCTAssertEqual(sValue, .display)
            XCTAssertFalse(sValue.refersToQuestion)
            XCTAssertNil(sValue.questionIdentifier)
        }

        let nextPhase = phase.advance()
        XCTAssertNotNil(nextPhase)
        XCTAssertEqual(phase, .display)
        XCTAssertFalse(phase.refersToQuestion)
    }

    func testIncrementToCompletion() {
        var phase: DASIPhase = .display
        let successorValue = phase.successor()
        XCTAssertNotNil(successorValue)

        if let sValue = successorValue {
            XCTAssertEqual(sValue, .completion)
            XCTAssertFalse(sValue.refersToQuestion)
            XCTAssertNil(sValue.questionIdentifier)
        }

        let nextPhase = phase.advance()
        XCTAssertNotNil(nextPhase)
        XCTAssertEqual(phase, .completion)
        XCTAssertFalse(phase.refersToQuestion)
    }

    func testEquality() {
        var falseAnswers: [DASIPhase] = [
            .intro, .display, .completion
        ]
        for qn in DASIPhase.indexRange {
            print(qn)
            if qn != 3 {
                falseAnswers.append(.responding(index: qn))
            }
        }
        let trueAnswer = DASIPhase.responding(index: 3)

        XCTAssert(trueAnswer == DASIPhase.responding(index: 3),
                  "responding 3")
        for wrong in falseAnswers {
            XCTAssert(wrong != trueAnswer)
        }

        XCTAssert(DASIPhase.intro != DASIPhase.responding(index: 1))
        XCTAssert(DASIPhase.intro != DASIPhase.display)
        XCTAssert(DASIPhase.intro != DASIPhase.completion)

        XCTAssert(DASIPhase.intro == DASIPhase.intro)
    }

    func testDecrementFromDisplay() {
        var phase: DASIPhase = .display
        let predecessorValue = phase.predecessor()
        XCTAssertNotNil(predecessorValue)

        if let sValue = predecessorValue {
            XCTAssertEqual(sValue, .responding(index: DASIPhase.endQuestionID))
            XCTAssert(sValue.refersToQuestion)
            XCTAssertNotNil(sValue.questionIdentifier)
            XCTAssertEqual(sValue.questionIdentifier!,
                              DASIPhase.endQuestionID)
        }

        let nextPhase = phase.decrement()
        XCTAssertNotNil(nextPhase)
        XCTAssert(phase.refersToQuestion)
        XCTAssertNotNil(phase.questionIdentifier)
        XCTAssertEqual(phase.questionIdentifier!,
                          DASIPhase.endQuestionID)
    }

    func testDecrementFromCompletion() {
        var phase: DASIPhase = .completion
        let predecessorValue = phase.predecessor()
        XCTAssertNotNil(predecessorValue)

        if let sValue = predecessorValue {
            XCTAssertEqual(sValue, .display)
            XCTAssertFalse(sValue.refersToQuestion)
            XCTAssertNil(sValue.questionIdentifier)
        }

        let nextPhase = phase.decrement()
        XCTAssertNotNil(nextPhase)
        XCTAssertEqual(phase, .display)
        XCTAssertFalse(phase.refersToQuestion)
    }

}
