//
//  TimedWalkObserver.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/19/22.
//

import Foundation
import CoreMotion

/// ## Topics
///
/// ### Properties
/// - ``timestamp``
/// - ``acceleration``

/// Adopters provide getters for the properties of ``CMAccelerometerData`` (`timestamp` and `acceleration`). Allows for initializable equivalents suitable for testing.
protocol AccelerometerDataContent: NSObject {
    /// The time recorded, in `TimeInterval` since an epoch related to restart time.
    var timestamp: TimeInterval { get }
    /// The observed forces in G.
    var acceleration: CMAcceleration { get }
}

extension AccelerometerDataContent {
    var csvLine: String? {
        let asString = [timestamp, acceleration.x, acceleration.y, acceleration.z]
            .map(\.pointFive)
            .joined(separator: ",")
        return asString
    }
}

extension CMAccelerometerData: AccelerometerDataContent {}

/// ## Topics
///
/// ### Initialization
/// - ``init(timestamp:acceleration)``
/// - ``init(t:x:y:z:)``
///
/// ### Properties
/// - ``timestamp``
/// - ``acceleration``

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

// MARK: - CMAccelerometerData (content) (CSV)
extension CMAccelerometerData: CSVRepresentable {
    /// Represent acceleration and timestamp as fields in a CSV record.
    var csvLine: String? {
        let asString = [timestamp, acceleration.x, acceleration.y, acceleration.z]
            .map(\.pointFive)
            .joined(separator: ",")
        return asString
    }
}

// MARK: - AccelerometryConsuming
/// Adopters can accept `AccelerometerDataContent` elements and do simple reductions to `[String]`.
///
/// Basically, an array, but could be a writeable `FileHandle`
protocol AccelerometryConsuming {
    /// Add the accelerometer observation to the list
    func append(_ record: AccelerometerDataContent)
    /// Add multiple accelerometer observations to the list.
    func append(contentsOf array: [AccelerometerDataContent])
    /// The accumulated list of observations as an `Array`
    func allRecords() -> [AccelerometerDataContent]
    /// `Array` of the observations, rendered as CSV
    func marshalledRecords() -> [String]
}

// MARK: Default implementation
extension AccelerometryConsuming {
    func append(contentsOf array: [CMAccelerometerData]) {
        for datum in array { self.append(datum) }
    }

    // Adopters should definitely override this,
    // especially when the ad-interim store is a file.
    func marshalledRecords() -> [String] {
        let all = self.allRecords()
        let strings = all.compactMap(\.csvLine)
        return strings
    }
}


/// ## Topics
///
/// ### Properties
///
/// - ``consumer``
/// - ``title``
/// - ``isRunning``
///
/// ### Initialization
///
/// - ``init(title:)``
///
/// ### Life Cycle
///
/// - ``start()``
/// - ``testableStart()``
/// - ``reset()``
/// - ``stop()``
/// - ``clearRecords()``
///
/// ### AccelerometryConsuming
///
/// - ``append(_:)``
/// - ``append(contentsOf:)``
/// -  ``allRecords()``
///
/// ### Marshalling
///
/// - ``marshalledRecords(withPrefix:)``
/// - ``allAsCSV(withPrefix:)``
/// - ``allAsData(prefixed:)``
/// - ``write(withPrefix:to:)``
/// - ``writeToFile(named:linesPrefixedWith:)``
/// - ``writeToFile(walkState:)``

// MARK: - TimedWalkObserver
/// Non-view-related code that consumes and stores accelerometer data.
///
/// `TimedWalkObserver` bridges collection of observations (async for loop  as ``AccelerometryConsuming``) to marshalling and file output.( functions beginning `write`)
final class TimedWalkObserver: ObservableObject, CustomStringConvertible {
    // FIXME: The long-term storage object
    //        ought to be an actor.
    /// The list of observation elements
    var consumer: [AccelerometerDataContent]
    /// Distinguishing label for the observer.
    var title: String
    /// Whether the observer should be open to observations.
    var isRunning: Bool

    // MARK: Initializer
    /// Initialize with a title. The list is empty, `isRunning` is `false`.
    init(title: String) {
        self.title = title
        consumer = []
        isRunning = false
    }

    var description: String {
        "TimedWalkObserver ("
        + (isRunning ? "Running" : "Stopped")
        + ", \(consumer.count)) “\(title)”"
    }

    // MARK: Start/stop
    /// Start the motion manager collecting accelerometry.
    ///
    /// Reports are collected through a `try await for` loop. If the loop iterator throws, the motion manager is cancelled.
    func start() async {
        isRunning = true
        Task {
            do {
                for try await datum in MotionManager.shared {
                    consumer.append(datum)
                }
            }
            catch {
                MotionManager.shared.cancelUpdates()
                isRunning = false
                print("\(#file):\(#line): the incoming data loop threw", error)
            }
        }
    }

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

    /// Tear down the previous run of the manager in preparation for another run.
    func reset() {
        stop()
        clearRecords()
    }

    /// Halt the Core Motion updates.
    func stop() {
        MotionManager.shared.cancelUpdates()
        isRunning = false
    }

    /// Remove all records from the observer (whatever that might be).
    func clearRecords() {
        assert(!isRunning)
        consumer.removeAll()
    }
}

// MARK: AccelerometryConsuming

extension TimedWalkObserver: AccelerometryConsuming {
    /// ``AccelerometryConsuming`` compliance
    func append(_ record: AccelerometerDataContent) {
        consumer.append(record)
    }
    /// ``AccelerometryConsuming`` compliance
    func append(contentsOf array: [AccelerometerDataContent]) {
        consumer.append(contentsOf: array)
    }
    /// ``AccelerometryConsuming`` compliance
    func allRecords() -> [AccelerometerDataContent] {
        return consumer
    }
    // The default implementation is fine.
    // func marshalledRecords() -> [String]

// MARK: Marshalling

    /// Supplementary marshalling which adds  prefix to each line.
    /// - Parameter prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted.
    /// - Returns: An array of `Strings` consisting of `\_prefix` + "," + `marshalled record`.
    /// - warning:Removing a comma from the end of `\_prefix` is a choice of convenience over edge cases.  Clients that _want_ to interpose a comma will find there's no clean way to do it.
    func marshalledRecords(withPrefix _prefix: String) -> [String] {
        let plainMarshalling = marshalledRecords()
        guard !_prefix.isEmpty else { return plainMarshalling }

        let prefix = (_prefix.last! == ",") ? _prefix : _prefix+","
        return plainMarshalling
            .map { prefix + $0}
    }

    /// A `String` containing each line of the CSV data
    ///   - parameter prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted. _See_ the note at ``TimedWalkObserver/marshalledRecords(withPrefix:)``
    ///
    /// - Returns: A single `String`, each line being the marshalling of the `CMAccelerometerData` records
    func allAsCSV(withPrefix prefix: String) -> String {
        return marshalledRecords(withPrefix: prefix)
            .joined(separator: "\r\n")
    }

    /// A `Data` instance containing the entire text of a CSV `String`
    ///
    /// This is a simple wrapper that takes the result of `allAsCSV(withPrefix:)` and renders it as bytes.
    ///   - parameter prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted. _See_ the note at ``TimedWalkObserver/marshalledRecords(withPrefix:)``
    func allAsData(prefixed prefix: String) -> Data {
        let content = allAsCSV(withPrefix: prefix)
        guard let data = content.data(using: .utf8) else { fatalError("Could not derive Data from the CSV string") }
        return data
    }

    /// Write all CSV records into a file.
    /// - Parameters:
    ///   - prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted. _See_ the note at ``TimedWalkObserver/marshalledRecords(withPrefix:)``
    ///   - url: The location of the new file.
    func write(withPrefix prefix: String, to url: URL) throws {
        // TODO: Make it async

        let fm = FileManager.default

        let data = allAsData(prefixed: prefix)
        try fm.deleteAndCreate(at: url, contents: data)
    }

    /// Marshall all the `CMAccelerometerData` data and write it out to a named file in the Documents directory.
    /// - Parameters:
    ///   - fileName: The base name of the target file as a `String`. No extension will be added.
    ///   - prefix: A fragment of CSV that will be added to the front of each record. Any trailing comma at the end will be omitted. _See_ the note at ``TimedWalkObserver/marshalledRecords(withPrefix:)``
    func writeToFile(named fileName: String,
                     linesPrefixedWith prefix: String) throws {
        // TODO: Make it async
        precondition(!fileName.isEmpty,
                     "\(#function): empty prefix string")
        let destURL = try FileManager.default
            .docsDirectory()
            .appendingPathComponent(fileName)

        try write(withPrefix: prefix, to: destURL)
    }

    func writeToFile(walkState: WalkingState) throws {
        precondition(walkState == .walk_2 || walkState == .walk_1,
                     "Unexpected walk state \(walkState)"
        )
        let isoDate = Date().iso
        let state = walkState.csvPrefix ?? "!!!!"
        try writeToFile(
            named: "Sample-\(isoDate)",
            linesPrefixedWith: "\(state),Sample")
    }
}
