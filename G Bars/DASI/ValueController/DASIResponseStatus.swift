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
        return .responding(currentIndex + 1)
    }

    @Published var currentValue: AnswerState {
        didSet {
            allAnswers[currentIndex] = currentValue
        }
    }
    /// Cursor through the lists of questions and responses. **ZERO INDEXED**
    static let dasiQuestions: [DASIQuestion] = DASIQuestion.questions

    init(from existing: [AnswerState], index: Int = 0) {
        allAnswers = existing
        currentIndex = index
        currentValue = existing[index]
    }

    var indexLimit: Int { allAnswers.count-1 }
    var canAdvance: Bool { currentIndex < indexLimit }
    func advance() {
        if canAdvance {
            currentIndex += 1
            currentValue = allAnswers[currentIndex]
        }
    }

    var canRetreat: Bool { currentIndex > 0 }
    func retreat() {
        if canRetreat {
            currentIndex -= 1
            currentValue = allAnswers[currentIndex]
        }
    }
}
