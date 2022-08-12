//
//  FloatEquatable.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/12/22.
//

import Foundation

infix operator ≈  : ComparisonPrecedence
infix operator !≈ : ComparisonPrecedence

protocol RoughlyEquatable {
    static func ≈ (lhs: Self, rhs: Self) -> Bool
}

extension RoughlyEquatable {
    static func !≈ (lhs: Self, rhs: Self) -> Bool {
        !(lhs ≈ rhs)
    }
}
extension Double  : RoughlyEquatable { }
extension Float32 : RoughlyEquatable { }
#if os(macOS)
extension Float80 : RoughlyEquatable { }
#endif

fileprivate let ε = 1.0e-3

extension BinaryFloatingPoint {
    /// Whether two floating-point values are “roughly” equal.
    ///
    /// This is defined as being within ε \* greater magnitde  of each other
    static func ≈ (lhs: Self, rhs: Self) -> Bool {
        guard lhs != rhs else { return true }

        var (low, high) = (Double(lhs), Double(rhs))
        if abs(low) > abs(high) { (low, high) = (high, low) }

        let wing = ε * abs(high)
        let range = (high-wing)...(high+wing)
        return range.contains(low)
    }
}


