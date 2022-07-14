//
//  CoreGraphics+Extensions.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/24/22.
//

import Foundation
import CoreGraphics


extension CGSize {
    /// The lesser of `width` and `height`
    var short: CGFloat {
        [width, height].min()!
    }
    /// The greater of `width` and `height`
    var long: CGFloat {
        [width, height].max()!
    }
}

extension ClosedRange where Bound: Comparable {
    /// Confine a value to the limits of a `ClosedRange`
    func pinning(_ value: Bound) -> Bound {
        if value < lowerBound { return lowerBound }
        if value > upperBound { return upperBound }
        return value
    }
}
