//
//  Staging.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/17/22.
//

import Foundation
import SwiftUI

protocol AppStages: Hashable {
    // CaseIterable? you can do increment/decrement uniformly(?)
    var csvPrefix: String? { get }
    var incremented: Self? { get }
    var decremented: Self? { get }
//
//    mutating func increment() -> Self?
//    mutating func decrement() -> Self?
}

extension AppStages {
    mutating func increment() {
        if let new = self.incremented {
            self = new
        }
    }

    mutating func decrement() {
        if let new = self.incremented {
            self = new
        }
    }
}

extension AppStages where Self: CaseIterable, Self.AllCases.Index == Int {
    var incremented: Self? {
        let index = Self.allCases.firstIndex(of: self)!
        let nextIndex = Self.allCases.index(after: index)
        if nextIndex >= Self.allCases.count {
            return nil
            // TODO: un-incremented?
        }
        return Self.allCases[nextIndex]
    }

    var decremented: Self? {
        let index = Self.allCases.firstIndex(of: self)!
        let nextIndex = index - 1
        guard nextIndex >= 0 else {
            return nil
            // TODO: un-decremented?
        }
        return Self.allCases[nextIndex]
    }
}

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

    /*
    var incremented: WalkingState? {
        let index = Self.allCases.firstIndex(of: self)!
        let nextIndex = Self.allCases.index(after: index)
        if nextIndex >= Self.allCases.count {
            return nil
            // TODO: ? or un-incremented?
        }
        return Self.allCases[nextIndex]
    }

    var decremented: WalkingState? {
        let index = Self.allCases.firstIndex(of: self)!
        let nextIndex = Self.allCases.index(before: index)
        if nextIndex < 0 {
            return nil
            // TODO: ? or un-decremented?
        }
        return Self.allCases[nextIndex]
    }
*/
}


// See DASIPhase in DASIPhase.swift

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


