//
//  LogViewSizing.swift
//  G Bars
//
//  Created by Fritz Anderson on 6/30/22.
//

import Foundation
import CoreGraphics


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
        // ClosedRange.pinning(_:) is in CoreGraphics+Extensions.swift
        let pinnedLogValue = (minLog...maxLog).pinning(logValue)
        let pinnedOffset = pinnedLogValue - minLog
        let scale = containerWidth/logSpan
        let scaledOffset = pinnedOffset * scale
        return CGFloat(scaledOffset)
    }
}

