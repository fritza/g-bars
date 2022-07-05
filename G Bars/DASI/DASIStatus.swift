//
//  DASIStatus.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/5/22.
//

import SwiftUI

// MARK: - DASIStatus
/// View model embodying the progress and responses for the DASI survey.
///
/// You record changed values of responses by assigning the `AnswerState` to the subscripted `self[responseIndex]`, where `(1...count).contains(responseIndex)`. Note that `responseIndex` refers to a value in `responses`, not to any non-response item in `DASIPhase`.
/// - note: I hate "View Model."
final class DASIStatus: ObservableObject {
    static let dasiQuestions: [DASIQuestion] = DASIQuestion.questions
    @Published var responses: [AnswerState]
    @Published var currentPhase: DASIPhase

    init(phase: DASIPhase = .intro, existingAnswers: [AnswerState] = []) {
        currentPhase = phase

        if existingAnswers.isEmpty {
            responses = [AnswerState](repeating: .unknown, count: Self.dasiQuestions.count)
        }
        else {
            precondition(existingAnswers.count == Self.dasiQuestions.count)
            responses = existingAnswers
        }
    }

    // MARK: Navigating display
    /// Advance the `DASIPhase` cursor.
    ///
    /// The client/caller must be sure to record the user's response before removing the focus from the question being answered.
    @discardableResult
    func advance() -> DASIPhase {
        currentPhase = currentPhase.advance() ?? .completion
        return currentPhase
    }

    /// Retard the `DASIPhase` cursor.
    ///
    /// The client/caller must be sure to record the user's response before removing the focus from the question being answered.
    @discardableResult
    func decrement() -> DASIPhase {
        currentPhase = currentPhase.decrement() ?? .intro
        return currentPhase
    }

    // MARK: Access to responses
    var currentResponseIndex: Int? {
        guard case .responding(let questionID) = currentPhase else { return nil }
        return questionID
    }

    /// The response to the `position`th question. `currentResponseIndex` need not be a `.responding`.
    subscript(position: Int) -> AnswerState {
        get {
            precondition((1...Self.dasiQuestions.count).contains(position))
            return responses[position-1]
        }
        set {
            precondition((1...Self.dasiQuestions.count).contains(position))
            responses[position-1] = newValue
        }
    }

    /// Assign an answer to the  current phase, which must be a `.response`.
    ///
    /// Callers must take care not to advance or decrement the current-phase cursor before calling this function.
    func recordInCurrent(answer: AnswerState) {
        guard let index = currentResponseIndex else {
            assertionFailure("Attempt to record a response when the active phase is not .responding")
            return
        }
        self[index] = answer
    }

    /// The yes/no/unknown value for the current response, or `nil` if the current phase isn't a `.response`.
    var currentAnswer: AnswerState? {
        guard let index = currentResponseIndex else {
            assertionFailure("Attempt to record a response when the active phase is not .responding")
            return nil
        }
        return self[index]
    }
}



