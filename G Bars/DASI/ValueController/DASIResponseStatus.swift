//
//  DASIResponseStatus.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/6/22.
//

import Foundation
import Combine

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
/// - note: `DASIResponseStatus` does not afford direct write access to its answer list. The `currentValue` property accepts values for the _current_ question (selected by `currentIndex`). This is deliberate.
/// - bug: But `allAnswers` is published, presumably alterable.
final class DASIResponseStatus: ObservableObject {
    @Published var allAnswers: [AnswerState]

    /// **ZERO INDEXED** subscript of the current question.
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

    var cancellables: Set<AnyCancellable> = []

    /// Cursor through the lists of questions and responses. **ZERO INDEXED**
    var currentQuestion: DASIQuestion {
        DASIQuestion.with(id: currentIndex+1)
    }

    init(from existing: [AnswerState] = [], index: Int = 0) {
        let answerList = existing.isEmpty ?
        [AnswerState](repeating: .unknown, count: DASIQuestion.count) :
        existing

        allAnswers = answerList
        currentIndex = index
        currentValue = answerList[index]

        DASIPages.pagingSubject
            .sink { commpletion in

            } receiveValue: { newPhase in
                self.hardSetProgress(newPhase)
            }
            .store(in: &cancellables)
    }

    var indexLimit: Int { allAnswers.count-1 }

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

extension DASIResponseStatus {
    func hardSetProgress(_ phase: DASIPhase) {
        if case DASIPhase.responding(index: let index) = phase {
            currentIndex = index-1
        }
    }
}

extension DASIResponseStatus: RandomAccessCollection {
    /// The subscript does not afford write access to the answers. Use `currentValue` for setting the current answer
    subscript(index: Int) -> AnswerState {
        allAnswers[index]
    }

    var startIndex: Int { 0 }
    var endIndex: Int { allAnswers.count }
    var count: Int { allAnswers.count }
    func index(before i: Int) -> Int {
        return Swift.max(startIndex, i-1)
    }
    func index(after i: Int) -> Int {
        return Swift.min(endIndex, i+1)
    }

    func makeIterator() -> AnswerIterator {
        return AnswerIterator(responses: allAnswers)
    }

    struct AnswerIterator: IteratorProtocol {
        let responses: [AnswerState]
        var index: Int = 0
        mutating func next() -> AnswerState? {
            defer { index += 1 }
            return (index >= responses.count) ? nil : responses[index]
        }
    }
}

extension DASIResponseStatus: CSVRepresentable {
    var csvLine: String {
//        guard firstUnknownIdentifier == nil else {
//            throw DASIReportErrors.dasiResponsesIncomplete
//        }

        let firstTimestamp = Date().timeIntervalSince1960.rounded

        let numberedResponses = allAnswers.enumerated()
            .map {
                    String(describing: $0 + 1)
                    + ","
                    + String(describing: $1)
            }

        let components: [String] =
        [SubjectID.id] + [firstTimestamp] + numberedResponses

        assert(components.count == 2+DASIQuestion.count,
               "Expected \(2+DASIQuestion.count) response items, got \(components.count)")

        return components.joined(separator: ",")
    }
}
