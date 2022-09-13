//
//  2DSeries.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/13/22.
//

import Foundation
import Accelerate

// MARK: - Store2D

/// ## Topics
///
/// ## Initialization
/// - ``init(_:)``
/// - ``cloned()``
///
/// ## Properties
/// - ``tMin``
/// - ``tMax``
/// - ``tSpan``
/// - ``xMin``
/// - ``xMax``
/// - ``xSpan``
///
/// ## Algebra
/// - ``append(_:)``
/// - ``append(contentsOf:)``
/// - ``applying(_:)``
///
/// ## Collection
/// - ``startIndex``
/// - ``endIndex``
/// - ``subscript(_:)``
/// - ``index(before:)``
/// - ``index(after:)``
/// - ``count``

/// Ingest and plot a value+time series of data.
///
/// Notionally is a `Collection` (e.g. `Array`) of ``Datum2D``.  It knows about the spans of value and time in the series, which is convenient for plotting the series.
///
/// There is also an extension to `Array<Store2D>` that does the same,
/// plus normalizes the values to `(0...1)`. Not clear why this class is necessary,
/// unless to have both a value and a reference type. Note that only `[Datum2D]`
/// can generate a SwiftUI `Path`.
/// - warning: `Store2D` does nothing to preserve the time-ordering of its elements.
final class Store2D {
    // TODO: Reconcile the use of [Datum2D] vs Store2D

    /// Array of `Datum2D` constituting the values in the store.
    private var content: [Datum2D] = []

    // MARK: Initialization and storage
    /// Create a `Store2D`, optionally wrapping an existing array of `Datum2D`.
    /// - Parameter existingContent: The `[Datum2D]` to represent. Defaults to `[]`.
    init(_ existingContent: [Datum2D] = []) {
        content = existingContent
    }

    /// Add a single `Datum2D` to the store
    /// - parameter oneDatum: The value to append.
    /// - warning: The  `Store2D` _appends_ the element as-is, without inserting by time.
    func append(_ oneDatum: Datum2D) {
        content.append(oneDatum)
    }

    /// Add a `Sequence` (usually `Array`) of `Datum2D` to the store
    /// - Parameter newElements: A `Sequence` of `Datum2D` to add
    /// - warning: The  `Store2D` _appends_ the elements as-is, without merging them by time.
    func append<S:Sequence>(contentsOf newElements: S) where S.Element == Datum2D {
        content.append(contentsOf: newElements)
    }

    /// A new `Store2D` object duplicating the `content` array.
    ///
    /// Necessary when client code wants to do a value-style replication of the value of a `Store2D`. Subsequent changes to the original will not affect the clone.
    func cloned() -> Store2D {
        return Store2D(content)
    }
}

extension Store2D: ObservableObject {
    // MARK: - Time range

    // FIXME: Time-range properties assume content is time-sorted.

    /// The minimum `t` value in the store
    /// - warning: Assumes the `content` array is already ordered by time.
    @inlinable var tMin: Double? { return content.first?.t }
    /// The maximum `t` value in the store
    /// - warning: Assumes the `content` array is already ordered by time.
    @inlinable var tMax: Double? { return content.last? .t }
    /// The `ClosedRange` encompassing the minimum and maximum `t` values.
    /// - warning: Assumes the `content` array is already ordered by time.
    @inlinable var tSpan: ClosedRange<Double>? {
        guard let min = tMin, let max = tMax else { return nil }
        return min...max
    }

    // MARK: - Value range

    // TODO: cache the min/max values
    //       It is unpleasant to think of a comprehensive
    //       O(N) operation thousands of times per second.
    /// The minimum `x` value in the store
    @inlinable var xMin: Double? { content.map(\.x).min() }
    /// The maximum `x` value in the store
    @inlinable var xMax: Double? { content.map(\.x).max() }
    /// The `ClosedRange` encompassing the minimum and maximum `x` values.
    @inlinable var xSpan: ClosedRange<Double>? {
        guard let min = xMin, let max = xMax else { return nil }
        return min...max
    }

    /// Create a **new** instance of Store2D with a filter function applied to its `x` values.
    ///
    /// The instance called-upon will be unchanged.
    /// - Parameter filter: A closure mapping `Double` to `Double`, to be applied to this `Store2D`’s `x` values.
    /// - Returns: A new, distinct `Store2D` with the transformed `x` values.
    func applying(_ filter: (Double) -> Double) -> Store2D {
        let newData = content.applying(filter)
        return Store2D(newData)
    }
}

// MARK: - Display and iteration
extension Store2D: CustomStringConvertible, RandomAccessCollection {

    // MARK: CustomStringConvertible
    /// Enumerate `content`’s elements, render them as `String`s (`Datum2D.description`) joined by commas.
    /// - Parameter length: The limit to the number of elements to display. Defaults to 5. If greater than the number of elements, only that number are rendered.
    /// - Returns: The comma-delimited representations of the `Datum2D` elements.
    private func describingData(first length: Int = 5) -> String {
        guard let clippedLength = [length, content.count].min() else { return "" }
        let slice = content[...clippedLength]
        return slice.map { "\($0)" }
            .joined(separator: ", ")
    }

    public var description: String {
        "\(type(of: self)): \(describingData())"
    }

    // MARK: RandomAccessCollection
    // These are probably not all necessary; Standard Library can infer some implementations.
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

// MARK: - Array<Datum2D>
extension Array where Element == Datum2D {
    // MARK: Span
    @inlinable var tMin: Double? { return self.first?.t }
    /// The maximum `t` value in the store
    /// - warning: Assumes the `content` array is already ordered by time.
    @inlinable var tMax: Double? { return self.last?.t }
    /// The `ClosedRange` encompassing the minimum and maximum `t` values.
    /// - warning: Assumes the `content` array is already ordered by time.
    @inlinable
    var tSpan: ClosedRange<Double>? {
        guard let min = tMin, let max = tMax else { return nil }
        return min...max
    }

    /// The minimum `x` value in the store
    var xMin: Double? { self.map(\.x).min() }
    /// The maximum `x` value in the store
    var xMax: Double? { self.map(\.x).max() }
    /// The `ClosedRange` encompassing the minimum and maximum `x` values.
    var xSpan: ClosedRange<Double>? {
        guard let min = xMin, let max = xMax else { return nil }
        return min...max
    }

    // MARK: Element arithmetic
    /// Make a new `Datum2D` series with  the `x` component of the contents replaced by the result of a `Double`-to-`Double` closure.
    ///
    /// Think of rescaling the data axis to fit graphical point bounds, or to a logarithmic scale.
    /// - warning: Succeeding generations of  `applying(_:)`, if lossy (as all nontrivial transforms are), will erode the precision of the result.
    /// - Parameter filter: A `Double`-to-`Double` closure to apply the the `x` components of all elements.
    /// - Returns: A new array of `Datum2D` with the `x` components replaced by the result of applying the closure to the original.
    func applying(_ filter: (Double) -> Double) -> [Datum2D] {
        guard !self.isEmpty else { return self }
        var retval = self
        for index in 0..<count {
            retval[index] = Datum2D(
                t: retval[index].t,
                x: filter(retval[index].x))
        }
        return retval
    }

    // MARK: Normalization

    /// Rescale `t` values to the span `(0...1)`
    @discardableResult
    func normalizedByTime() -> [Datum2D] {
        guard let timeSpan = tSpan else { return self }
        var retval = self
        for index in 0..<count {
            retval[index] = retval[index]
                .unsafeTimeNormalized(within: timeSpan)
        }
        return retval
    }

    /// Replace the `x` values in the `content` by mapping the span to `(0...1)`
    func normalizedByValue() -> [Datum2D] {
        guard let span = xSpan else { return self }
        var retval = self
        for index in 0..<count {
            retval[index] = retval[index]
                .unsafeDatumNormalized(within: span)
        }
        return retval
    }

    /// Rescale both value and time to `(0...1)`
    func normalized() -> [Datum2D] {
        guard let xes = xSpan, let ts = tSpan else { return self }
        var retval = self
        for index in 0..<count {
            let nextValue = Datum2D(
                t: retval[index].t.unsafeScaledTo(span: ts ),
                x: retval[index].x.unsafeScaledTo(span: xes)
            )
            retval[index] = nextValue
        }
        return retval
    }

    /// Normalize values, times, or both.
    func normalized(by axis: Datum2D.Normalization) -> [Datum2D] {
        guard !self.isEmpty && !axis.isEmpty else   { return self }
        if axis == .both           { return self.normalized()        }
        if axis.contains(.byTime ) { return self.normalizedByTime()  }
        if axis.contains(.byValue) { return self.normalizedByValue() }
        return self
    }

    // MARK: SwiftUI Path

    /// Normalize the value and time dimensions, then rescale them to the spans of a `CGSize`.
    func fittedTo(_ dimensions: CGSize) -> [Datum2D] {
        guard !self.isEmpty else { return self }
        let retval = self
            .normalized(by: .both)
            .map { dimensions * $0 }
        return retval
    }

    /// Derive a SwiftUI drawable `Shape` from the values normalized to a `SGSize`.
    func path(within size: CGSize) -> some Shape {
        let transform: CGAffineTransform = .identity
            .translatedBy(x: 0.0, y: size.height)
            .scaledBy(x: 1.0, y: -1.0)

        let fittedCopy = self.fittedTo(size)
        return Path() {
            ioPath in
            guard let initialPoint = fittedCopy.first?.asPoint else { return }
            ioPath.move(to: initialPoint)
            if self.count == 1 { return }
            for datum in fittedCopy[1...] {
                ioPath.addLine(to: datum.asPoint)
            }
        }
        .transform(transform)
    }
}

// TODO: Should rendering be part of a data abstraction?

extension Store2D {
    /// `SwiftUI` `Path` `Shape` representing the values in `content`.
    func path(within size: CGSize) -> some Shape {
        return content.path(within: size)
    }
}
