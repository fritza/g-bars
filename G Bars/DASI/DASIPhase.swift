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
        case .responding(let index) where index < DASIStatus.dasiQuestions.count:
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

    /// Mutate self to the next phase to be presented.
    /// - returns: The next phase as returned by `successor()`, or `nil` if there is none (current phase is `.completion`).
    mutating func advance() -> DASIPhase? {
        guard let next = successor() else { return nil }
        self = next
        return next
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
            return .responding(index: DASIStatus.dasiQuestions.count)
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
    mutating func decrement() -> DASIPhase? {
        guard let previous = predecessor() else { return nil }
        self = previous
        return previous
    }
}

extension DASIPhase: Equatable {
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