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

extension Store2D {
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

    /// Replace the `t` values in the `content` by mapping the span to `(0...1)`
    func normalizeByTime() {
        guard let timeSpan = tSpan else { return }
        let newValues = content.map { $0.unsafeTimeNormalized(within: timeSpan) }
        content = newValues
    }

    /// Replace the `x` values in the `content` by mapping the span to `(0...1)`
    func normalizeByValue() {
        guard let span = xSpan else { return }
        let newValues = content.map { $0.unsafeDatumNormalized(within: span) }
        content = newValues
    }

    /// Replace the `t` or `x` values in the `content` by mapping the spans to `(0...1)`
    /// - parameter axis: Options for selecting `t`-normalization, or `x`, or both.
    func normalize(by axis: Datum2D.Normalization) {
        guard !self.isEmpty else { return }
        if axis.contains(.byTime ) { normalizeByTime()  }
        if axis.contains(.byValue) { normalizeByValue() }
    }

    /// Scale the `t` and `x` values in `content` to span the axes of a `CGSize`.
    /// - Parameter dimensions: A `CGSize` representing the upper limit of the scale on each axis.
    func fitTo(_ dimensions: CGSize) {
        guard !content.isEmpty else { return }
        let newContents = content.map { dimensions * $0 }
        content = newContents
    }
}

extension Store2D: CustomStringConvertible, RandomAccessCollection {
    /// Enumerate `content`’s elements, render them as `String`s (`Datum2D.description`) joined by commas.
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
