//
//  DASIResponseStatus.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/6/22.
//

import Foundation

protocol CSVRepresentable {
    func csvLine() throws -> String?
}

// MARK: - DASIReportErrors
enum DASIReportErrors: Error {
//    case wrongDataType(UTType)
    case notRegularFile
    case noReadableReport
    case missingDASIHeader(String)
    case dasiResponsesIncomplete
    case wrongNumberOfResponseElements(Int, Int)
    case outputHandleNotInitialized
    case couldntCreateDASIFile
}


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
        let answerList = existing.isEmpty ?
        [AnswerState](repeating: .unknown, count: DASIQuestion.count) :
        existing
        allAnswers = answerList
        currentIndex = index
        currentValue = answerList[index]
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

extension DASIResponseStatus: CSVRepresentable {
    func csvLine() throws -> String? {
        guard firstUnknownIdentifier != nil else {
            throw DASIReportErrors.dasiResponsesIncomplete
        }

        guard let subjectID = SubjectID.shared.subjectID else {
            assertionFailure("No subject ID, shouldn't get to \(#function) in the first place.")
            return nil
        }

        let firstTimestamp = Date().timeIntervalSince1960.rounded

        let numberedResponses = allAnswers.enumerated()
            .map {
                    String(describing: $0)
                    + ","
                    + String(describing: $1)
            }

        let components: [String] =
        [subjectID] + [firstTimestamp] + numberedResponses

        assert(components.count == 2+DASIQuestion.count,
               "Expected \(2+DASIQuestion.count) response items, got \(components.count)")

        return components.joined(separator: ",")
    }
}
