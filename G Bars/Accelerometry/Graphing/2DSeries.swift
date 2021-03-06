//
//  2DSeries.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/13/22.
//

import Foundation
import Accelerate

/// Ingest, normalize, and plot a 1-D time series of data.
final class Store2D {
    /// Array of `Datum2D` constituting the values in the store.
    private var content: [Datum2D] = []

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
    @inlinable
    var tSpan: ClosedRange<Double>? {
        guard let min = tMin, let max = tMax else { return nil }
        return min...max
    }

    // MARK: - Value range

    // TODO: cache the min/max values
    //       It is unpleasant to think of a comprehensive
    //       O(N) operation thousands of times per second.
    /// The minimum `x` value in the store
    var xMin: Double? { content.map(\.x).min() }
    /// The maximum `x` value in the store
    var xMax: Double? { content.map(\.x).max() }
    /// The `ClosedRange` encompassing the minimum and maximum `x` values.
    var xSpan: ClosedRange<Double>? {
        guard let min = xMin, let max = xMax else { return nil }
        return min...max
    }

    /// Create a **new** instance of Store2D with a filter function applied to its `x` values.
    ///
    /// The instance called-upon will be unchanged.
    /// - Parameter filter: A closure mapping `Double` to `Double`, to be applied to this `Store2D`???s `x` values.
    /// - Returns: A new, distinct `Store2D` with the transformed `x` values.
    func applying(_ filter: (Double) -> Double) -> Store2D {
        let newData = content.applying(filter)
        return Store2D(newData)
    }
}

extension Store2D: CustomStringConvertible, RandomAccessCollection {
    /// Enumerate `content`???s elements, render them as `String`s (`Datum2D.description`) joined by commas.
    /// - Parameter length: The limit to the number of elements to display. Defaults to 5. If greater than the number of elements, only that number are rendered.
    /// - Returns: The comma-delimited representations of the `Datum2D` elements.
    func describingData(first length: Int = 5) -> String {
        guard let clippedLength = [length, content.count].min() else { return "" }
        let slice = content[...clippedLength]
        return slice.map { "\($0)" }
            .joined(separator: ", ")
    }

    // MARK: - CustomStringConvertible
    var description: String {
        "\(type(of: self)): \(describingData())"
    }

    // MARK: - RandomAccessCollection
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

// MARK: - SwiftUI
import SwiftUI
extension Store2D {
    /// `SwiftUI` `Path` `Shape` representing the values in `content`.
    func path(within size: CGSize) -> some Shape {
        return content.path(within: size)
    }
}

extension Array where Element == Datum2D {
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

    func normalized(by axis: Datum2D.Normalization) -> [Datum2D] {
        guard !self.isEmpty && !axis.isEmpty else   { return self }
        if axis == .both           { return self.normalized()        }
        if axis.contains(.byTime ) { return self.normalizedByTime()  }
        if axis.contains(.byValue) { return self.normalizedByValue() }
        return self
    }

    func fittedTo(_ dimensions: CGSize) -> [Datum2D] {
        guard !self.isEmpty else { return self }
        let retval = self
            .normalized(by: .both)
            .map { dimensions * $0 }
        return retval
    }

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
