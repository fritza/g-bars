//
//  Datum2D.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/14/22.
//

import Foundation
import CoreGraphics

extension BinaryFloatingPoint {
    /// Map the value to `(0...1)` from a given span of “real-world” values.
    ///
    /// Use `unsafeScaledTo` if you are confident `span` will never be empty (and present a zero divisor). Otherwise, use ``scaledTo(span:)``.
    /// - Parameter span: The range of unscaled values
    /// - Returns: The value mapped within `span` to `(0...1)`
    public func unsafeScaledTo(span: ClosedRange<Self>) -> Self {
      return (self - span.lowerBound)
        / (span.upperBound - span.lowerBound)
    }

    /// Map the value to `(0...1)` from a given span of “real-world” values (if any).
    ///
    /// Use `scaledTo` if you cannot guarantee `span`is non-empty. Otherwise, use ``unsafeScaledTo(span:)``.
    /// - Parameter span: The range of unscaled values
    /// - Returns: The value mapped within `span` to `(0...1)`; or `nil` if `span` is empty.
    public func scaledTo(span: ClosedRange<Self>) -> Self? {
        guard !span.isEmpty else { return nil }
      return unsafeScaledTo(span: span)
    }
}

/// A value type describing a pair of `Double` values.
///
/// The expectation is that this will represent an element of a time series; hence the stored properties are `t` and `x`.
public struct Datum2D: CustomStringConvertible, Comparable, Hashable {
    /// `OptionSet` to specify whether to apply normalization to times, values, or both.
    struct Normalization: RawRepresentable, OptionSet {
        let rawValue: Int
        init(rawValue: Int) { self.rawValue = rawValue }
        /// Normalization is to be by time only.
        static let byTime  = Normalization(rawValue: 1)
        /// Normalization is to be by value only.
        static let byValue = Normalization(rawValue: 2)
        /// Normalization is to be by time and valye both.
        static let both: Normalization = [.byValue, .byTime]
    }

    /// The first (notionally time) component
    public let t: Double
    /// The second (notionally data-at-time) component
    public let x: Double

    public init(t: Double, x: Double) {
        (self.t, self.x) = (t, x)
    }

    public var description: String {
        "(t: \(t.pointFive), x: \(x.pointFive))"
    }

    public static func < (lhs: Datum2D, rhs: Datum2D) -> Bool {
        lhs.t < rhs.t
    }

    /// Simple cast to `CGPoint`
    public var asPoint: CGPoint {
        CGPoint(x: t, y: x)
    }

    public static func * (size: CGSize, multiplicand: Datum2D) -> Datum2D {
        Datum2D(t: multiplicand.t * size.width,
                x: multiplicand.x * size.height)
    }

    // MARK: Scaling
    // FIXME: Why am I doing all this with scalars instead of affine transforms?
    @inlinable
    /// A new `Datum2D` with the same value (`x`), but time (`t`) normalized.
    ///
    ///Use `unsafeTimeNormalized(within:)` when you are confident that `span` will not be empty. Otherwise use ``timeNormalized(within:)``.
    ///
    /// See ``BinaryFloatingPoint/unsafeScaledTo(span:)``
    /// - Parameter timeRange: The span of time to map the `t` property to `(0...1)`
    /// - Returns: A `Datum2D` with the `t`-value scaled.
    public func unsafeTimeNormalized(within timeRange: ClosedRange<Double>) -> Datum2D {
        return Datum2D(t: t.unsafeScaledTo(span: timeRange),
                       x: self.x)
    }

    /// A new `Datum2D` with the same value (`x`), but time (`t`) normalized; or `nil` if the time range is empty.
    ///
    /// Use `unsafeTimeNormalized(within:)` if you are confident that `span` will not be empty.
    /// - Parameter timeRange: The span of time to map the `t` property to `(0...1)`
    /// - Returns: A `Datum2D` with the `t`-value scaled.
    public func timeNormalized(within timeRange: ClosedRange<Double>) -> Datum2D? {
        guard !timeRange.isEmpty else { return nil }
        return unsafeTimeNormalized(within: timeRange)
    }

    /// A new `Datum2D` with the same time (`t`), but data (`x`) normalized.
    ///
    ///Use `unsafeDatumNormalized(within:)` when you are confident that `span` will not be empty. Otherwise use ``datumNormalized(within:)``.
    /// - Parameter timeRange: The span of time to map the `x` property to `(0...1)`
    /// - Returns: A `Datum2D` with the `x`-value scaled.
    @inlinable
    public func unsafeDatumNormalized(within valueRange: ClosedRange<Double>) -> Datum2D {
        return Datum2D(t: t,
                       x: x.unsafeScaledTo(span: valueRange))
    }

    /// A new `Datum2D` with the same time (`t`) value, but value (`x`) normalized; or `nil` if the value range is empty.
    ///
    /// Use `unsafeDatumNormalized(within:)` if you are confident that `valueRange` will not be empty.
    /// - Parameter valueRange: The span of values to map the `x` property to `(0...1)`.
    /// - Returns: A `Datum2D` with the `x`-value scaled.
    func datumNormalized(within valueRange: ClosedRange<Double>) -> Datum2D? {
        guard !valueRange.isEmpty else { return nil }
        return unsafeDatumNormalized(within: valueRange)
    }

    // TODO: Can't Accelerate do all of this, simultaneously?
}
