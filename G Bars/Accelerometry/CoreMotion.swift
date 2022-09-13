//
//  CoreMotion.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/14/22.
//

import Foundation
import Collections
import CoreMotion
import SwiftUI

// MARK: Time intervals

// FIXME: The collection rate should be settable.

/// Preferred data collection pace, in Hertz
private let hz                : UInt64 = 60
/// Preferred data interval, in seconds
private let hzInterval        : Double = 1.0/Double(hz)
/// Preferred data interval, in nanoseconds
private let nanoSleep         : UInt64 = UInt64(hzInterval * Double(NSEC_PER_SEC))
// TODO: Put the interval in a UserDefault.

/// Expected total high-watermark, in seconds, of enqueued data elements.
private let secondsInBuffer   : UInt64 = 2
/// The greatest _expected_ count of enqueued data elements.
private let minBufferCapacity : UInt64 = secondsInBuffer * hz * 2

// MARK: - IncomingAccelerometry
/// Collect ``CMAccelerometerData`` into an isolated (~semaphored) ``Deque``.
actor IncomingAccelerometry {
    var buffer = Deque<CMAccelerometerData>(minimumCapacity: numericCast(minBufferCapacity))
    var count: Int {
        buffer.count
    }

    func receive(_ accData: CMAccelerometerData) {
        buffer.append(accData)
    }

    // FIXME: - Does pop() deadlock receive(_:)?
    //      It spins waiting for the arrival of data into the buffer.
    //      If the suspension point at Task.sleep(nanoseconds:) doesn't
    //      yield to an async receive(_:), then we're deadlocked, right?
    /// Waits until a record is available from the `Deque`.  If so, remove it from the queue and return it.
    /// If not, sleep for the expected data interval (`nanoSleep`)
    func pop() async throws -> CMAccelerometerData? {
        while buffer.isEmpty {
            try Task.checkCancellation()
            try await Task.sleep(nanoseconds: nanoSleep)
        }
        return buffer.popFirst()
    }
    // And now we're back to polling, right?

    /// Return all elements in the `Deque` as an `Array`, then empty it.
    /// - warning: The `actor` should insulate the caller from the effects of new data coming in, but be careful.
    func popAll() async throws -> [CMAccelerometerData] {
        defer { clear() }
        return Array<CMAccelerometerData>(buffer)
    }

    /// Remove all elements from the `Deque`.
    func clear() {
        buffer.removeAll()
    }
}

// MARK: - Available / Active
/// Wrapper for the availability and activity of some facility.
protocol Availability {
    var cmManager: CMMotionManager { get }
    var available: Bool { get }
    var active   : Bool { get }
}

/// Availability (whether the device supports Core Motion)
struct DeviceState: Availability {
    private(set) var cmManager: CMMotionManager

    init(_ manager: CMMotionManager) {
        self.cmManager = manager
    }

    /// Is CM device motion available on this device?
    ///
    /// In practice, not used. Client code cares only about whether _accelerometry_ is available.
    var available: Bool {
        cmManager.isDeviceMotionAvailable
    }

    /// Has the Core Motion manager (`cmManager`) been activated for device motion?
    ///
    /// In practice, not used. Client code cares only about whether _accelerometry_ is active.
    var active   : Bool  {
        cmManager.isDeviceMotionActive
        }
}

/// Availability (has accelerometers) and active status (collecting) for the inertial platform
struct AccelerometerState: Availability {
    private(set) var cmManager: CMMotionManager

    init(_ manager: CMMotionManager) {
        self.cmManager = manager
    }

    /// Is CM accelerometry available on this device?
    var available: Bool {
        cmManager.isAccelerometerAvailable
        }
    /// Has the Core Motion manager (`cmManager`) been activated for accelerometry?
    var active   : Bool  {
        cmManager.isAccelerometerActive
        }
}


// FIXME: Move MotionManager to its own file

/// ## Topics
///
/// ### Singletons
/// -  ``shared``
///
/// ### Properties
/// - ``isCancelled``
/// - ``stream``
/// - ``accelerometryAvailable``
/// - ``accelerometryActive``
///
/// ### Async support
///  - ``next()``
/// - ``makeAsyncIterator()``
/// - ``cancelUpdates()``


// MARK: - MotionManager
/// Wrapper around `CMMotionManager` with convenient start / stop / `AsyncSequence` for accelerometry,
///
/// Available only via the singleton `shared`. You cannot instantiate a `MotionManager` yourself.
final class MotionManager {
    // MARK: Properties

    /// The singleton `MotionManager`. Do not instantiate `MotionManager`.
    static let shared = MotionManager()
    /// How many records are in the `Deque`. Updated whenever data is taken from the `Deque`.
    private static var census = 0

    // FIXME: "A single instance can't be restarted"
    //        Yes, but does it need to? .shared keeps the
    //        object alive, which in turn keeps the
    //        CMMotionManager alive and healthy
    /// The wrapped ``CMMotionManager``.
    private let cmMotionManager: CMMotionManager
    /// Represents the state (basically CM availability) of the device.
    private let deviceState : DeviceState
    /// Represents the state (basically accelerometer availability) of the device.
    private let accState: AccelerometerState
    /// When `true`, asynchronous collection of accelerometry halts.
    var isCancelled: Bool = false

    typealias CMDataStream = AsyncStream<CMAccelerometerData>
    /// The `AsyncStream` that will provide ``CMAccelerometerData`` records
    var stream: CMDataStream!

    /// Holding queue for arriving ``CMAccelerometerData`` records.
    private let asyncBuffer = IncomingAccelerometry()

    // MARK: - Initialization and start
    /// Create and configure the Core Motion manager.
   fileprivate init() {
        let cmManager = CMMotionManager()
        cmManager.accelerometerUpdateInterval = hzInterval
        cmMotionManager = cmManager

        deviceState = DeviceState(cmManager)
        accState = AccelerometerState(cmManager)
    }

    /// Is Core Motion accelerometry available on this device?
    var accelerometryAvailable: Bool {
        accState.available
    }

    /// Is this device collection Core Motion accelerometry?
    var accelerometryActive: Bool {
        accState.active
    }

    /// Halt Core Motion reports on accelerometry.
    ///
    /// Not intended for external use; use `.cancelUpdates()` instead.
    private func stopAccelerometer() {
        cmMotionManager.stopAccelerometerUpdates()
    }
}

extension MotionManager: AsyncSequence, AsyncIteratorProtocol {
    // MARK: - AsyncSequence
    typealias Element = CMAccelerometerData
    typealias AsyncIterator = MotionManager
    /// `AsyncStream` compliance.
    ///
    /// Next `CMAccelerometerData` record to be provided to an `async` `for` loop.
    func next() async throws -> CMAccelerometerData? {
        guard !isCancelled else { return nil }
        return try? await asyncBuffer.pop()
    }

    /// `AsyncStream` compliance.
    ///
    /// Yields an iterator object to manage the incoming data loop.  `MotionManager` itself is the iterator.
    func makeAsyncIterator() -> MotionManager {
        cmMotionManager.startAccelerometerUpdates(to: .main)
        { accData, error in
            if let error = error {
                print(#function, "Accelerometry error:", error)
                self.cancelUpdates()
            }
            if let accData = accData {
                Task {
                    // Task? Really?
                    await self.asyncBuffer.receive(accData)
                    Self.census = await self.asyncBuffer.count
                }
            }
        }
        return self
    }

// MARK: - MotionManager life cycle

    /// Halt the `CMAccelerometerData` stream by signaling the loop that it has been canceled.
    ///
    /// Use this instead of `.stopAccelerometer()` to terminate the stream. This function does call `.stopAccelerometer()`, but maybe shouldn't — see **Note**.
    ///
    /// - note: The call to `stopAccelerometer()` may be redundant of the `.onTermination` action in `startAccelerometry()`
    func cancelUpdates() {
        isCancelled = true
        stopAccelerometer()
    }
}
