//
//  AccelerometerItem.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/22.
//

import Foundation
import CoreMotion

/// ## Topics
///
///### Initialization
/// - ``init(_:)``
/// - ``init(timestamp:x:y:z:)``
///
///### Properties
///- ``x``
///- ``y``
///- ``z``
///
///### Export
///- ``csvLine``
///
///### RoughlyEquatable
///- ``≈(lhs:rhs:)``
///

/// A wrapper on  ``CMAccelerometerData`` or its components, made accessible to generic code via the ``Timestamped`` and ``XYZ`` protocols.
///
/// - note: `AccelerometerItem` is declared `RoughlyEquatable`, but the implementation ignores the timestamp.
struct AccelerometerItem: Codable, Timestamped, XYZ  {
    /// The x-axis acceleration value
    let x: Double
    /// The y-axis acceleration value
    let y: Double
    /// The z-axis acceleration value
    let z: Double
    /// The time (interval from some epoch) of measurement.
    let timestamp: TimeInterval

    enum CodingKeys: String, CodingKey {
        case x, y, z, timestamp
    }

    /// Initialize from time and space components.
    init(timestamp: TimeInterval, x: Double, y: Double, z: Double) {
        (self.timestamp, self.x, self.y, self.z) = (timestamp, x, y, z)
    }

    /// Initialize from ``CMAccelerometerData`` components.
    init(_ accelerometry: CMAccelerometerData) {
        let acc = accelerometry.acceleration
        self.init(timestamp: accelerometry.timestamp,
                  x: acc.x, y: acc.y, z: acc.z)
    }
}

extension AccelerometerItem: CSVRepresentable {
    /// The value as represented by CSV fields, time-x-y-z.
    public var csvLine: String {
        let components = [timestamp, x, y, z]
            .map { $0.pointThree }
            .joined(separator: ",")
        return components
    }
}

extension AccelerometerItem: RoughlyEquatable {
    /// Whether this value and another are approximately equal.
    static func ≈ (lhs: AccelerometerItem, rhs: AccelerometerItem) -> Bool {
        let paths: [KeyPath<AccelerometerItem,Double>] = [\.x, \.y, \.z]
        return paths
            .allSatisfy { componentPath in
                lhs[keyPath: componentPath] ≈ rhs[keyPath: componentPath]
            }
    }
}
