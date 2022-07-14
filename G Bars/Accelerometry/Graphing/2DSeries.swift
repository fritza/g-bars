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
    @inlinable var tMin: Double? { return content.first?.t }
    @inlinable var tMax: Double? { return content.last? .t }
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
        let newValues = content.map { $0.unsafeTimeNormalized(within: timeSpan) }
        content = newValues
    }

    func normalizeByValue() {
        guard let span = xSpan else { return }
        let newValues = content.map { $0.unsafeDatumNormalized(within: span) }
        content = newValues
    }

    func normalize(by axis: Datum2D.Normalization) {
        guard !self.isEmpty else { return }
        if axis.contains(.byTime ) { normalizeByTime()  }
        if axis.contains(.byValue) { normalizeByValue() }
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


