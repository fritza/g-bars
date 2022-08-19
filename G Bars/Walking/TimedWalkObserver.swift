//
//  TimedWalkObserver.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/19/22.
//

import Foundation
import CoreMotion

// MARK: - CMAccelerometerData (CSV)
extension CMAccelerometerData: CSVRepresentable {
    var csvLine: String? {
        let asString = [timestamp, acceleration.x, acceleration.y, acceleration.z]
            .map(\.pointFive)
            .joined(separator: ",")
        return asString
    }
}

// MARK: - AccelerometryConsuming
protocol AccelerometryConsuming {
    func append(_ record: CMAccelerometerData)
    func append(contentsOf array: [CMAccelerometerData])
    func allRecords() -> [CMAccelerometerData]
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

// MARK: - TimedWalkObserver
/// Non-view-related code that consumes and stores accelerometer data.
///
/// - todo: `TimedWalkObserver` should accept any storage method (`AccelerometryConsuming`) rather than stick with `Array`.
final class TimedWalkObserver: ObservableObject {
    // MARK: Properties
    var motionManager: MotionManager
    var consumer: [CMAccelerometerData]
    let title: String
    var isRunning: Bool

    // MARK: Initializer
    init(title: String) {
        self.title = title
        motionManager = MotionManager()
        consumer = []
        isRunning = false
    }

    // MARK: Start/stop
    func start() async {
        isRunning = true
        Task {
            do {
                for try await datum in motionManager {
                    // FIXME: This long-term storage
                    // object ought to be an actor.
                    consumer.append(datum)
                }
            }
            catch {
                motionManager.cancelUpdates()
                isRunning = false
                print("\(#file):\(#line): the incoming data loop threw", error)
            }
        }
    }

    func stop() {
        motionManager.cancelUpdates()
        isRunning = false

    }

    func clearRecords() async {
        assert(!isRunning)
        consumer.removeAll()
    }
}

// MARK: AccelerometryConsuming
extension TimedWalkObserver: AccelerometryConsuming {
    func append(_ record: CMAccelerometerData) {
        consumer.append(record)
    }
    func append(contentsOf array: [CMAccelerometerData]) {
        consumer.append(contentsOf: array)
    }
    func allRecords() -> [CMAccelerometerData] {
        return consumer
    }
    // The default implementation is fine.
    // func marshalledRecords() -> [String]

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

    func allAsCSV(withPrefix prefix: String) -> String {
        return marshalledRecords(withPrefix: prefix)
            .joined(separator: "\r\\n")
    }

    func allAsData(prefixed prefix: String) -> Data {
        let content = allAsCSV(withPrefix: prefix)
        guard let data = content.data(using: .utf8) else { fatalError("Could not derive Data from the CSV string") }
        return data
    }

    func write(withPrefix prefix: String, to url: URL) throws {
        let fm = FileManager.default

        let data = allAsData(prefixed: prefix)
        try fm.deleteAndCreate(at: url, contents: data)
    }
}
