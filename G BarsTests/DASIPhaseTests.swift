//
//  DASIPhaseTests.swift
//  G BarsTests
//
//  Created by Fritz Anderson on 7/8/22.
//

import XCTest
@testable import G_Bars

class DASIPhaseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRespondingIncrement() throws {
        var phase = DASIPhase.intro
        XCTAssertEqual(phase, .intro)

        for qn in (DASIPhase.startQuestionID...DASIPhase.endQuestionID) {
            let successorValue = phase.successor()
            XCTAssertNotNil(successorValue)
            XCTAssertEqual(successorValue!, .responding(index: qn))

            let nextPhase = phase.advance()
            XCTAssertNotNil(nextPhase)
            XCTAssertEqual(phase, .responding(index: qn))
            XCTAssert(phase.refersToQuestion)

            XCTAssertNotNil(phase.questionNumber)
            if let nextNumber = phase.questionNumber {
                XCTAssertEqual(nextNumber, qn)
            }
        }

        XCTAssertEqual(phase, .responding(index: DASIPhase.endQuestionID))
    }

    func testIncrementToDisplay() {
        var phase: DASIPhase = .responding(index: DASIPhase.endQuestionID)
        let successorValue = phase.successor()
        XCTAssertNotNil(successorValue)

        if let sValue = successorValue {
            XCTAssertEqual(sValue, .display)
            XCTAssertFalse(sValue.refersToQuestion)
            XCTAssertNil(sValue.questionNumber)
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
            XCTAssertNil(sValue.questionNumber)
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
            XCTAssertNotNil(sValue.questionNumber)
            XCTAssertEqual(sValue.questionNumber!,
                              DASIPhase.endQuestionID)
        }

        let nextPhase = phase.decrement()
        XCTAssertNotNil(nextPhase)
        XCTAssert(phase.refersToQuestion)
        XCTAssertNotNil(phase.questionNumber)
        XCTAssertEqual(phase.questionNumber!,
                          DASIPhase.endQuestionID)
    }

    func testDecrementFromCompletion() {
        var phase: DASIPhase = .completion
        let predecessorValue = phase.predecessor()
        XCTAssertNotNil(predecessorValue)

        if let sValue = predecessorValue {
            XCTAssertEqual(sValue, .display)
            XCTAssertFalse(sValue.refersToQuestion)
            XCTAssertNil(sValue.questionNumber)
        }

        let nextPhase = phase.decrement()
        XCTAssertNotNil(nextPhase)
        XCTAssertEqual(phase, .display)
        XCTAssertFalse(phase.refersToQuestion)
    }

}
