//
//  DASIResponseStatus.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/6/22.
//

import Foundation

/// Provide content to DASI response views.
///
/// Intended to be an `@EnvironmentObject` for those views.
final class DASIResponseStatus: ObservableObject {
    @Published var allAnswers: [AnswerState]

    var currentIndex: Int
    /// The workflow progress through the questions. **ONE INDEXED**
    var currentPhase: DASIPhase {
        return .responding(index: currentIndex + 1)
    }

    var currentValue: AnswerState {
        get {
            allAnswers[currentIndex]
        }
        set {
            allAnswers[currentIndex] = newValue
        }
    }

    /// Cursor through the lists of questions and responses. **ZERO INDEXED**
    static let dasiQuestions: [DASIQuestion] = DASIQuestion.questions
    var currentQuestion: DASIQuestion { Self.dasiQuestions[currentIndex] }

    init(from existing: [AnswerState] = [], index: Int = 0) {
        if existing.isEmpty {
            allAnswers = [AnswerState](repeating: .unknown, count: DASIQuestion.questions.count)
        }
        else {
            allAnswers = existing
            }
        currentIndex = index
        currentValue = existing[index]
    }

    var indexLimit: Int { allAnswers.count-1 }
    var canAdvance: Bool { currentIndex < indexLimit }
    func advance() {
        if canAdvance {
            currentIndex += 1
        }
    }

    var canRetreat: Bool { currentIndex > 0 }
    func retreat() {
        if canRetreat {
            currentIndex -= 1
        }
    }

    var unknownIdentifiers: [Int] {
        let retval = allAnswers.enumerated()
            .filter { pair in pair.1 == .unknown }
            .map { pair in pair.0+1 }
        return retval
    }

    var firstUnknownIdentifier: Int? {
        unknownIdentifiers.first
    }
}
