//
//  SyncAccelerationWriter.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/12/22.
//

import Foundation
import CoreMotion

/// Write an ``AcceleratorItem`` array to a given URL.
///
/// The item array is immutable; there is no “append” function.
final class SyncAccelerationWriter {
    enum Errors: Error {
        case couldNotEncodeContents
    }

    static let dummySubjectID = "demo_subject"

    let fileURL: URL
    var fileHandle: FileHandle!
    var records: [AccelerometerItem] = []
    var isOpen: Bool

    /// Create a file at `url` and return a `FileHandle` for it.
    ///
    /// If there is something already at `url`, it is deleted.
    /// - Parameter url: The URL for the desired file. If something is already there, delete it.
    /// - Returns: A `FileHandle` open for writing at `url`
    /// - throws: `FileManager` and `FileHandle` errors.
    static func createFile(at url: URL) throws -> FileHandle {
        let fm = FileManager.default
        // Best to fail before setting any properties.
        // App's extension of FileManager
        try fm.deleteAndCreate(at: url)
        let retval = try FileHandle(
            forWritingTo: url)
        return retval
    }

    /// Accept an `Array` of ``AccelerometerItem`` for writing to a file created at `destination`.
    /// - Parameters:
    ///   - destination: The file that will receive the data.
    ///   - records: The ``AccelerometerItem``s to be written.
    init(destination: URL,
         records: [AccelerometerItem]) throws {
        self.records = records
        fileURL = destination
        assert(fileURL.pathExtension == "csv",
               "The file name should have the csv extension. (\(fileURL.lastPathComponent))")

        // Create and open the output file.
        fileHandle = try Self.createFile(at: destination)
        isOpen = true
    }

    /// Transform the records into CSV lines and write them to the  `.csv` file.
    /// - throws: `FileHandle/write(contentsOf:)` errors.
    func write() throws {
        assert(isOpen, "Attempt to write records out to a closed file handle.")

        let lines = records
            .map(\.csv)
            .map { rawLine in
                return Self.dummySubjectID + "," + rawLine
            }
            .joined(separator: "\r\n")

        guard let contentData = lines.data(using: .utf8) else { throw Errors.couldNotEncodeContents }
        try fileHandle.write(contentsOf: contentData)
    }

    /// Close the CSV output file.
    func close() throws {
        isOpen = false
        try fileHandle.close()
    }
}
