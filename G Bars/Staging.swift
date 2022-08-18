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

// MARK: - WalkingState
enum WalkingState: String, CaseIterable, AppStages {
    case interstitial_1, countdown_1, walk_1
    case interstitial_2, countdown_2, walk_2
    case end_interstitial

    var csvPrefix: String? {
        switch self {
        case .walk_1: return "wN"
        case .walk_2: return "wF"

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


