//
//  MockAccelerometerData.swift
//  G BarsUITests
//
//  Created by Fritz Anderson on 9/9/22.
//

import Foundation
import CoreMotion
@testable import G_Bars

extension TimedWalkObserver {
    /// A sunchronous analogue to ``start()`` for testing
    func testableStart() {
        let accelerations: [MockAccelerometerData] = [
            .init(t: 0.1, x: 0, y: 0, z: 0),
            .init(t: 0.2, x: 1, y: 0, z: 0),
            .init(t: 0.3, x: 0, y: 1, z: 0),
            .init(t: 0.4, x: 0, y: 0, z: 1),
            .init(t: 0.5, x: -1, y: 0, z: 0),
            .init(t: 0.6, x: 0, y: -1, z: 0),
            .init(t: 0.7, x: 0, y: 0, z: -1),
            ]
        consumer.append(contentsOf: accelerations)

        // AccelerometerDataContent
        isRunning = true
    }
}

/// An analogue to `CMAccelerometerData` that has an initializer that includes `timestamp`.
final class MockAccelerometerData: NSObject, AccelerometerDataContent {
    /// Initialize by `timestamp` and `acceleration`.
    internal init(timestamp: TimeInterval, acceleration: CMAcceleration) {
        self.timestamp = timestamp
        self.acceleration = acceleration
    }

    /// The time recorded, in `TimeInterval` since an epoch related to restart time.
    let timestamp: TimeInterval
    /// The observed forces in G.
    let acceleration: CMAcceleration

    /// Initialize by `timestamp` and the `x`, `y`, and `z` components of acceleration.
    convenience init(t: TimeInterval? = nil,
                     x: Double, y: Double, z: Double) {
        let acc = CMAcceleration(x: x, y: y, z: z)
        let ts = t ?? Date().timeIntervalSinceReferenceDate
        self.init(timestamp: ts, acceleration: acc)
    }
}

