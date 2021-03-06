//
//  DASIPhase.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/5/22.
//

import Foundation

// MARK: - DASIPhase
/// A step in the progression/regression of views presented in the DASI portion of the app.
///
/// If the `G_BARS` compilation condition is set, a "display" case is inserted between the survey questions and the completion text.
enum DASIPhase {
    /// Passive display to intriduce the DASI portion of the app
    case intro

    /// Presentation of a question in the DASI survey. `index` identifies the one-based ID for the question.
    case responding(index: Int)

    #if G_BARS
    /// If `G_BARS` is set, displays the selected responses.
    case display
#endif
    /// Passive display to conclude the DASI portion of the app
    case completion

    // MARK: increment
    /// The next `DASIPhase` after `self`.  Does not mutate the value.
    /// - returns: The next` DASIPhase`, or `nil` if there is none (the current phase is `.completion`)
    func successor() -> DASIPhase? {
        switch self {
        case .intro:
            return .responding(index: 1)
        case .responding(let index) where index < DASIQuestion.count:
            return .responding(index: index+1)
#if G_BARS
        case .responding:
            return .display
        case .display:
            return .completion
#else
        case .responding:
            return .completion
#endif
        case .completion:
            return nil
        }
    }

    /// Mutate self to the next phase to be presented. Does mutate the value.
    /// - returns: The next phase as returned by `successor()`, or `nil` if there is none (current phase is `.completion`).
    @discardableResult
    mutating func advance() -> Bool {
        guard let next = successor() else { return false }
        self = next
        return true
    }

    // MARK: decrement
    /// The `DASIPhase` before `self`.  Does not mutate the value.
    /// - returns: The previous` DASIPhase`, or `nil` if there is none (the current phase is `.intro`)
    func predecessor() -> DASIPhase? {
        switch self {
        case .intro:
            return nil
        case .responding(let index) where index == 1:
            return .intro
        case .responding(let index):
            return .responding(index: index - 1)
#if G_BARS
        case .display:
            return .responding(index: DASIQuestion.count)
        case .completion:
            return .display
#else
        case .completion:
            return .responding(index: DASIStatus.dasiQuestions.count)
#endif
        }
    }

    /// Mutate self to the previous phase to be presented.
    /// - note: See comment on ``DASIPhase`` as to nomenclature.
    /// - returns: The previous phase as returned by `successor()`, or `nil` if there is none (current phase is `.intro`).
    @discardableResult
    mutating func decrement() -> Bool {
        guard let previous = predecessor() else { return false }
        self = previous
        return true
    }
}

extension DASIPhase {
    /// Whether this phase is `.responding` rather than `.intro`, `.display`, or `.completion`
    var refersToQuestion: Bool! {
        if case DASIPhase.responding(index: _) = self {
            return true
        }
        else {
            return false
        }
    }

    /// If this phase refers to a question, the number of the question, or `nil` if not a question.
    var questionIdentifier: Int? {
        if case DASIPhase.responding(index: let index) = self {
            return index
        }
        return nil
    }

    static let startQuestionID = 1
    static let endQuestionID   = DASIQuestion.questions.count
    static let indexRange = (startQuestionID ... endQuestionID)

    static func isALegalQuestionNumber(_ number: Int) -> Bool {
        indexRange.contains(number) }
    static let maxResponsePhase = DASIPhase.responding(index: DASIQuestion.questions.count)
    static let minResponsePhase = DASIPhase.responding(index: 1)

    static let responsePhaseRange = (
        DASIPhase.responding(index: startQuestionID)
        ...
        DASIPhase.responding(index: endQuestionID)
    )
}

extension DASIPhase: Hashable, Comparable {
    static func == (lhs: DASIPhase, rhs: DASIPhase) -> Bool {
        switch (lhs, rhs) {
        case (.intro, .intro), (.completion, completion):
            return true
#if G_BARS
        case (.display, .display):
            return true
#endif
        case (.responding(let i), .responding(let j)):
            return i == j
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .intro: hasher.combine(1)
        case .completion: hasher.combine(2)
        case .display: hasher.combine(3)
        case .responding(index: let index):
            hasher.combine(4)
            hasher.combine(index)
        }
    }

    static func < (lhs: DASIPhase, rhs: DASIPhase) -> Bool {
        if lhs == rhs { return false }
        // Eliminated == at all levels.

        switch (lhs, rhs) {
            // Responding/responding ranks by ID.
        case (.responding(index: let lval), .responding(index: let rval)): return lval < rval

            // .intro is less than any non-.intro
        case (.intro, _): return true
        case (_, .intro): return false

            // .completion is greater than any non-.completion
        case (.completion, _): return false
        case (_, .completion): return true

            // .display is greater than any surviving non-.display
            // now that .completion is ruled out.
        case (.display, _): return false
        case (_, .display): return true

        default:
            print("Unexpected combination:", lhs, "and", rhs)
            return false
        }
    }
}

extension DASIPhase: CustomStringConvertible {
    var description: String {
        var retval = "DASIPhase("
        switch self {
        case .completion: retval += "completion"
#if G_BARS
        case .display: retval += "display"
#endif
        case .intro: retval += "intro"
        case .responding(let index):
            retval += "responding(\(index))"
        }

        return retval + ")"
    }
}
