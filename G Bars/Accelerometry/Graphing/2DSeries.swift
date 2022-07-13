//
//  2DSeries.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/13/22.
//

import Foundation
import Accelerate

extension BinaryFloatingPoint {
    /// Map the value to `(0...1)` from a given span of “real-world” values.
    ///
    /// Use `unsafeScaledTo` if you are confident `span` will never be empty (and present a zero divisor). Otherwise, use ```scaledTo(span:)```.
    /// - Parameter span: The range of unscaled values
    /// - Returns: The value mapped within `span` to `(0...1)`
    func unsafeScaledTo(span: ClosedRange<Self>) -> Self {
      return (self - span.lowerBound)
        / (span.upperBound - span.lowerBound)
    }

    /// Map the value to `(0...1)` from a given span of “real-world” values (if any).
    ///
    /// Use `scaledTo` if you cannot guarantee `span`is non-empty. Otherwise, use ```unsafeScaledTo(span:)```.
    /// - Parameter span: The range of unscaled values
    /// - Returns: The value mapped within `span` to `(0...1)`; or `nil` if `span` is empty.
    func scaledTo(span: ClosedRange<Self>) -> Self? {
        guard !span.isEmpty else { return nil }
      return unsafeScaledTo(span: span)
    }
}

/// A value type describing a pair of `Double` values.
///
/// The expectation is that this will represent an element of a time series; hence the stored properties are `t` and `x`.
struct Datum2D: CustomStringConvertible, Comparable, Hashable {
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
    let t: Double
    /// The second (notionally data-at-time) component
    let x: Double

    var description: String {
        "(t: \(t.pointFive), x: \(x.pointFive))"
    }

    static func < (lhs: Datum2D, rhs: Datum2D) -> Bool {
        lhs.t < rhs.t
    }

    var asPoint: CGPoint {
        CGPoint(x: t, y: x)
    }

    static func * (size: CGSize, multiplicand: Datum2D) -> Datum2D {
        Datum2D(t: multiplicand.t * size.width,
                x: multiplicand.x * size.height)
    }

    // MARK: Scaling
    // FIXME: Why am I doing all this with scalars instead of affine transforms?
    @inlinable
    /// A new `Datum2D` with the same value (`x`), but time (`t`) normalized.
    ///
    ///Use `unsafeTimeNormalized(within:)` when you are confident that `span` will not be empty. Otherwise use ```timeNormalized(within:)```.
    ///
    /// See ```BinaryFloatingPoint.unsafeScaledTo(span:)````
    /// - Parameter timeRange: The span of time to map the `t` property to `(0...1)`
    /// - Returns: A `Datum2D` with the `t`-value scaled.
    func unsafeTimeNormalized(within timeRange: ClosedRange<Double>) -> Datum2D {
        return Datum2D(t: t.unsafeScaledTo(span: timeRange),
                       x: self.x)
    }

    /// A new `Datum2D` with the same value (`x`), but time (`t`) normalized; or `nil` if the time range is empty.
    ///
    /// Use `unsafeTimeNormalized(within:)` if you are confident that `span` will not be empty.
    /// - Parameter timeRange: The span of time to map the `t` property to `(0...1)`
    /// - Returns: A `Datum2D` with the `t`-value scaled.
    func timeNormalized(within timeRange: ClosedRange<Double>) -> Datum2D? {
        guard !timeRange.isEmpty else { return nil }
        return unsafeTimeNormalized(within: timeRange)
    }

    /// A new `Datum2D` with the same time (`t`), but data (`x`) normalized.
    ///
    ///Use `unsafeDatumNormalized(within:)` when you are confident that `span` will not be empty. Otherwise use ```datumNormalized(within:)```.
    /// - Parameter timeRange: The span of time to map the `x` property to `(0...1)`
    /// - Returns: A `Datum2D` with the `x`-value scaled.
    @inlinable
    func unsafeDatumNormalized(within valueRange: ClosedRange<Double>) -> Datum2D {
        return Datum2D(t: t,
                       x: x.unsafeScaledTo(span: valueRange))
    }

    func datumNormalized(within valueRange: ClosedRange<Double>) -> Datum2D? {
        guard !valueRange.isEmpty else { return nil }
        return unsafeDatumNormalized(within: valueRange)
    }

    // TODO: Can't Accelerate do all of this, simultaneously?
}

final class Store2D {
    private var content: [Datum2D] = []

    init(_ existingContent: [Datum2D] = []) {
        content = existingContent
    }

    func append(_ oneDatum: Datum2D) {
        content.append(oneDatum)
    }

    func append<S:Sequence>(contentsOf newElements: S) where S.Element == Datum2D {
        content.append(contentsOf: newElements)
    }

    func cloned() -> Store2D {
        return Store2D(content)
    }
}

extension Store2D {
    // MARK: Time range
    // FIXME: Time-range properties assume content is time-sorted.
    @inlinable
    var tMin: Double? {
        return content.first?.t
    }

    @inlinable    var tMax: Double? {
        return content.last?.t
    }

    @inlinable
    var tSpan: ClosedRange<Double>? {
        guard let min = tMin, let max = tMax else { return nil }
        return min...max
    }

    // MARK: Value range

    // TODO: cache the min/max values
    //       It is unpleasant to think of a comprehensive
    //       O(N) operation thousands of times per second.
    var xMin: Double? { content.map(\.x).min() }
    var xMax: Double? { content.map(\.x).max() }
    var xSpan: ClosedRange<Double>? {
        guard let min = xMin, let max = xMax else { return nil }
        return min...max
    }

    func normalizeByTime() {
        guard let timeSpan = tSpan else { return }
        let newValues = content.map { $0.unsafeTimeNormalized(within: timeSpan)
        }
        content = newValues
//        return Store2D(newValues)
    }

    func normalizeByValue() {
        guard let span = xSpan else { return }
        let newValues = content.map {
            $0.unsafeDatumNormalized(within: span)
        }
        content = newValues
//        return Store2D(newValues)
    }

    func normalize(by axis: Datum2D.Normalization) {
        guard !self.isEmpty else { return }
        if axis.contains(.byTime) {
            normalizeByTime()
        }
        if axis.contains(.byValue) {
            normalizeByValue()
        }
    }

    func fitTo(_ dimensions: CGSize) {
        guard !content.isEmpty else { return }
        let newContents = content.map { dimensions * $0 }
        content = newContents
    }
}

extension Store2D: CustomStringConvertible, RandomAccessCollection {
    func describingData(first length: Int = 5) -> String {
        let slice = content[...length]
        return slice.map { "\($0)" }
            .joined(separator: ", ")
    }
    var description: String {
        "\(type(of: self)): \(describingData())"
    }
    var startIndex: Int { 0             }
    var endIndex: Int   { content.count }
    subscript(index: Int) -> Datum2D {
        get { content[index] }
        set { content[index] = newValue }
    }
    func index(before i: Int) -> Int { i-1 }
    func index(after  i: Int) -> Int { i+1 }
    var count: Int { content.count }
}


import SwiftUI
extension Store2D {
    func path() -> Path {
        Path() {
            ioPath in
            guard !self.content.isEmpty else { return }
            ioPath.move(to: content[0].asPoint)
            if self.count == 1 { return }
            for datum in content[1...] {
                ioPath.addLine(to: datum.asPoint)
            }
        }
    }
}


