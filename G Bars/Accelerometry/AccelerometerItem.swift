//
//  AccelerometerItem.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/22.
//

import Foundation
import CoreMotion


/// Acceleration components, `Timestamped`, accessible as `XYZ`, and `Codable`
///
/// Makes acceleration useable for generic export code.
struct AccelerometerItem: Codable, Timestamped, XYZ  {
    let x, y, z: Double
    let timestamp: TimeInterval

    enum CodingKeys: String, CodingKey {
        case x, y, z, timestamp
    }

    /// Initialization by properties.
    init(timestamp: TimeInterval, x: Double, y: Double, z: Double) {
        (self.timestamp, self.x, self.y, self.z) = (timestamp, x, y, z)
    }

    /// Initialization by `CMAccelerometerData` timing and accelerations.
    init(_ accelerometry: CMAccelerometerData) {
        let acc = accelerometry.acceleration
        self.init(timestamp: accelerometry.timestamp,
                  x: acc.x, y: acc.y, z: acc.z)
    }
}

extension AccelerometerItem {
    /// The item as marshalled in CSV as stamp, x, y, and z.
    var csv: String {
        let components = [timestamp, x, y, z]
            .map { $0.pointThree }
            .joined(separator: ",")
        return components
    }
}
