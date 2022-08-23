//
//  AccelerometerItem.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/22.
//

import Foundation
import CoreMotion


/// A wrapper on  ``CMAccelerometerData`` or its components, made accessible to generic code via the ``Timestamped`` and ``XYZ`` protocols.
///
/// - note: `AccelerometerItem` is declared `RoughlyEquatable`, but the implementation ignores the timestamp.
struct AccelerometerItem: Codable, Timestamped, XYZ  {
    let x, y, z: Double
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
    public var csvLine: String? {
        let components = [timestamp, x, y, z]
            .map { $0.pointThree }
            .joined(separator: ",")
        return components
    }
}

extension AccelerometerItem: RoughlyEquatable {
    static func ≈ (lhs: AccelerometerItem, rhs: AccelerometerItem) -> Bool {
        for p in [
            \AccelerometerItem.x,
             \AccelerometerItem.y,
             \AccelerometerItem.z ] {
            if lhs[keyPath: p] !≈ rhs[keyPath: p] {
                return false
            }
        }
        return true
    }
}

