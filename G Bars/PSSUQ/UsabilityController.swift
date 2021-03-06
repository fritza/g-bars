//
//  UsabilityController.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/11/22.
//

import Foundation
import Combine

enum UsabilityPhase: CaseIterable, Comparable, Hashable {
    case start, questions, end, summary
}

final class UsabilityController: ObservableObject {

    /// DRY for moving the displayed choice to the persistent record.
    func storeCurrentResponse() {
        results[questionID-1] = currentResponse
    }

    /// The phase (start, questions, end) currently displayed.
    @Published var currentPhase: UsabilityPhase! = .start {
        willSet {
            if newValue != currentPhase && currentPhase == .questions {
                storeCurrentResponse()
            }
        }
    }

    @Published var questionID = 1 {
        willSet {
            storeCurrentResponse()
        }
        didSet {
            currentResponse = results[questionID-1]
        }
    }

    @Published var currentResponse = 0

    // TODO: Validate the question index.

    var currentQuestion: UsabilityQuestion? {
        // Subscript on UsabilityQuestion addresses the ID, not the index in storage.
        return UsabilityQuestion[questionID]
    }

    var canIncrement: Bool { currentPhase < .end }
    func increment() {
        switch currentPhase {
        case .start: currentPhase = .questions; questionID = 1
        case .end  : preconditionFailure("Attempt to increment beyond end")
        case .questions where questionID >= UsabilityQuestion.endID-1:
            currentPhase = .end
        default:
            questionID += 1
        }
    }

    var canDecrement: Bool { currentPhase > .start }
    func decrement() {
        switch currentPhase {
        case .start: preconditionFailure("Attempt to decrement beyond start")
        case .end  : currentPhase = .questions; questionID = UsabilityQuestion.endID - 1
        case .questions where questionID <= 1:
            currentPhase = .start
        default:
            questionID -= 1
        }
    }

    var results =  [Int](repeating: 0, count: UsabilityQuestion.count)

    // TODO: Persist the answers.

    func receive(answer: Int,
                 toQuestion question: Int = 0) {
//        assert(results.count == UsabilityQuestion.count)
//        let realQuestion = (question == 0) ? questionID : question
//        results[realQuestion-1] = answer
        // Don't increment. There'll have to be a Continue button.
//        if canIncrement { increment() }
    }



    // Start without interstitials.
    init(phase: UsabilityPhase = .start, questionID: Int = 1) {
        currentPhase = phase
        self.questionID = questionID
        currentResponse = results[questionID-1]
    }
}
