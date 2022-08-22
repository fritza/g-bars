//
//  Staging.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/17/22.
//

import Foundation
import SwiftUI

/// Adopters allow instances to advance or retreat their values.
public
protocol AppStages: Hashable {
    /// A `String` to prepend to CSV flagging the type of item being reported.
    ///
    /// This is quasi-historical; part of the purpose of `AppStages` is to order phases, some of which generate CSV records.
    var csvPrefix: String? { get }
    /// The item in the order next after this one. `nil` if the item is at the end of the order.
    /// - note: `increment()` silently ignores changes for which `incremented`  would return `nil`.
    var incremented: Self? { get }
    /// The item in the order next before this one. `nil` if the item is at the start of the order.
    /// - note: `decrement()` silently ignores changes for which `decremented`  would return `nil`.
    var decremented: Self? { get }
}

// MARK: - Default implementations.
extension AppStages {
    /// Change this object by advancing it in the order.
    ///
    /// If the object is already at the end of the order, do nothing. Contrast to `incremented`.
    public mutating func increment() {
        if let new = self.incremented {
            self = new
        }
    }

    /// Change this object by advancing it in the order.
    ///
    /// If the object is already at the end of the order, do nothing. Contrast to `decremented`.
    public mutating func decrement() {
        if let new = self.decremented {
            self = new
        }
    }

    /// Whether the item is at the bottom of the order
    public var canIncrement: Bool { self.incremented != nil }
    /// Whether the item is at the top of the order
    public var canDecrement: Bool { self.decremented != nil }
}

// MARK: - CaseIterable implementations
extension AppStages where Self: CaseIterable, Self.AllCases.Index == Int {
    /// Default implementation when `Self` is `CaseIterable` and its indices are `Int`.
    public var incremented: Self? {
        let index = Self.allCases.firstIndex(of: self)!
        let nextIndex = Self.allCases.index(after: index)
        if nextIndex >= Self.allCases.count {
            return nil
        }
        return Self.allCases[nextIndex]
    }

    /// Default implementation when `Self` is `CaseIterable` and its indices are `Int`.
    public var decremented: Self? {
        let index = Self.allCases.firstIndex(of: self)!
        let nextIndex = index - 1
        guard nextIndex >= 0 else {
            return nil
        }
        return Self.allCases[nextIndex]
    }

    // MARK: Ordering

    // You get Equatable for free.
    // Comparable is not provided, and
    // you can't adopt a protocol in a protocol extension.
    //
    // This forces a by-hand implementation of
    // <, <=, >=, and >.
    //
    // You walk the list of cases and see which turns
    // up first. Fortunately, we won't be seeing any
    // thousand-case enums.

    /// `Comparable` mimickry
    static public func < (lhs: Self, rhs: Self) -> Bool {
        if lhs == rhs { return false }
        for item in Self.allCases {
            if lhs == item { return true }
        }
        return false
    }

    static public func > (lhs: Self, rhs: Self) -> Bool {
        if lhs == rhs { return false }
        for item in Self.allCases {
            if rhs == item { return true }
        }
        return false
    }

    static public func >= (lhs: Self, rhs: Self) -> Bool {
        return (lhs == rhs) || (lhs > rhs)
    }

    static public func <= (lhs: Self, rhs: Self) -> Bool {
        return (lhs == rhs) || (lhs < rhs)
    }
}

// MARK: - ApplicationState
final class ApplicationState: ObservableObject {
    /// One phase in the progress of the app.
    enum State: String, CaseIterable, AppStages {
        case onboarding, walking, dasi, usability, offboarding

        /// `CaseIterable/allCases` would iterate through states not in use. Use `statesInUse` for the sequence of available `State`s.
        static let statesInUse: [State] = [
            .walking, .dasi, .usability
        ]
        var csvPrefix: String? { nil }
    }

    /// Set up `UserDefaults` with standard values.
    static func initializeDefaults() {
        let values: [String:Any] = [
            AppStorageKeys.stateCompletion.rawValue : [String](),
            AppStorageKeys.selectedTab.rawValue : 0
        ]
        UserDefaults.standard.register(defaults: values)
    }

    /// The list of raw values for stages that have been completed.
    ///
    /// `get` and `set` go by way of `UserDefaults`.
    var completedStages: [String] {
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey:  AppStorageKeys.stateCompletion.rawValue)
        }
        get {
            let defaults = UserDefaults.standard
            return defaults.object(forKey: AppStorageKeys.stateCompletion.rawValue) as! [String]
        }
    }

    var subjectID: String? {
        set {
            let defaults = UserDefaults.standard
            if let nonnil = newValue {
                defaults.set(nonnil,
                             forKey:  AppStorageKeys.subjectID.rawValue)
            }
            else {
                defaults.removeObject(forKey: AppStorageKeys.subjectID.rawValue)
            }
        }
        get {
            let defaults = UserDefaults.standard
            let raw = defaults.string(forKey: AppStorageKeys.subjectID.rawValue)
            return raw
        }
    }


    init() {
        Self.initializeDefaults()

        var candidate: State? = nil
        for s in State.statesInUse {
            if completedStages.contains(s.rawValue) {
                candidate = s
            }
        }
        currentAppState = candidate
    }

    @Published var currentAppState: State? = .onboarding
    func advance() {
        guard let current = currentAppState else { return }
        completedStages.append(current.rawValue)

        // `incremented` works on `allCases`, which include disused phases.
        let next = State.statesInUse.first(where: {$0 > current})
        currentAppState = next
    }
}

// MARK: - WalkingState
enum WalkingState: String, CaseIterable, AppStages {
    case interstitial_1, countdown_1, walk_1
    case interstitial_2, countdown_2, walk_2
    case ending_interstitial, demo_summary

    var csvPrefix: String? {
        switch self {
        case .walk_1: return "walkNormal"
        case .walk_2: return "walkFast"

        default: return nil
        }
    }
}

// See DASIPhase in DASIPhase.swift
// MARK: - DASIPhase
extension DASIPhase: AppStages {
    var csvPrefix: String? {
        switch self {
        case .completion: return "dasi"
        default: return nil
        }
    }
    var incremented: DASIPhase? { predecessor() }
    var decremented: DASIPhase? { successor()   }
}


