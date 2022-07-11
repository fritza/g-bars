//
//  DASIPages.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/14/22.
//

import Foundation
import Combine

/// Observable selection of a DASI question, such as for question-page navigation
///
///Initialized in
/// - `BetterStep_App` (root `environmentObject(_:)`)
///
/// Used in:
/// - `SurveyContainerView`
/// - `DASIQuestionView`
/// - `SurveyContainerView`
/// - `YesNoButton` (**Pull out as a dependency?**
/// - `ApplicationOnboardView` (**Wrong Place**)


enum SurveyProgress: Hashable {
    case introProgress, questionProgress, displayProgress, completionProgress

    init(_ phase: DASIPhase) {
        switch phase {
        case .intro:                self = .introProgress
        case .display:              self = .displayProgress
        case .completion:           self = .completionProgress
        case .responding(index: _): self = .questionProgress
        }
    }
}

final class DASIPages: ObservableObject
{
    static let pagingSubject = CurrentValueSubject<DASIPhase, Error>(.intro)

    @Published var selected: DASIPhase!
    @Published var refersToQuestion: Bool! {
        didSet {
            surveyProgress = SurveyProgress(selected)
        }
    }
    @Published var surveyProgress: SurveyProgress! {
        didSet {
            print("Changed surveyProgress from", (oldValue ?? "NIL"),
                  "to", (surveyProgress ?? "NIL"))
        }
    }

    init(_ selection: DASIPhase = .intro) {
        selected = selection
        refersToQuestion = selection.refersToQuestion
        surveyProgress = SurveyProgress(selection)
        assert(surveyProgress != nil)
    }

    /// Reflect the selection of the next page.
    ///
    /// At the end of the question pages, this should advance to `.completion`. There is no increment from `.completion`.
    func increment() -> Bool {
        guard selected.advance() else { return false }
        refersToQuestion = selected.refersToQuestion
        DASIPages.pagingSubject.send(selected!)
        return true
    }

    /// Reflect the selection of the previous page.
    ///
    /// From the start of the question pages, this should regress to `.intro`. There is no decrement from `.intro`.
    func decrement() -> Bool {
        guard selected.decrement() else { return false }
        refersToQuestion = selected.refersToQuestion
        DASIPages.pagingSubject.send(selected!)
        return true
    }

    var questionIdentifier: Int? {
        guard let containedID = selected.questionIdentifier else {
            return nil
//            preconditionFailure(
//                "selected wasn't a .presenting.")
        }
        return containedID
    }
}


