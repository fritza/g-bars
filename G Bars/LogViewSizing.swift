//
//  LogViewSizing.swift
//  G Bars
//
//  Created by Fritz Anderson on 6/30/22.
//

import Foundation
import CoreGraphics

extension ClosedRange where Bound: Comparable {
    func pinning(_ value: Bound) -> Bound {
        if value < lowerBound { return lowerBound }
        if value > upperBound { return upperBound }
        return value
    }
}


func pinnedFloat<F:BinaryFloatingPoint>(_ toPin: F, in range: ClosedRange<F>) -> F {
    if toPin < range.lowerBound { return range.lowerBound }
    if toPin > range.upperBound { return range.upperBound }
    return toPin
}

struct LogViewSizing {
    let maxValue, maxLog: Double
    let minValue, minLog: Double
    let logSpan: Double

    init(min: Double, max: Double) {
        (minValue, maxValue) = (abs(min), abs(max))
        maxLog = log10(maxValue); minLog = log10(minValue)
        logSpan = (maxLog - minLog)
    }

    func scale(_ rawValue: Double, within containerWidth: Double) -> CGFloat {
        let logValue = log10(abs(rawValue))
        let pinnedLogValue = pinnedFloat(logValue, in: minLog...maxLog)
        let pinnedOffset = pinnedLogValue - minLog
        let scale = containerWidth/logSpan
        let scaledOffset = pinnedOffset * scale
        return CGFloat(scaledOffset)
    }
}

