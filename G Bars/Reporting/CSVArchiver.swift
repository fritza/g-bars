//
//  CSVArchiver.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/8/22.
//

import Foundation
import ZIPFoundation

// Whew. A notification.
let ZIPProgressNotice = Notification.Name(rawValue: "zipProgressNotice")
enum ZIPProgressKeys: String {
    // String, which phase tag has been completed.
    case tagCompleted
    case fileName
}


// Where do I receive this notification?

/*
 1. The outer loop for archiving is a per-tag process of generating data and adding it to the archive.
 2. The generator is LastWalkingData. There is one per archive chunk, one per tag. It's a persistent object.
 3. DigitalTimerView
 4. It cannot be a TimedWalk observer; a fresh one is constructed with each DigitalTimerView
 5. MotionManager (.shared) generates the records for the chunk. It emits to TimedWalkObserver (start() async), which starts and stops it.
 6. TimedWalkObserver appends each measurement (CMAccelerometerData) by comsumer.append()
 7. Consumer (TimedWalkObserver) is an array of AccelerometerDataContent.
 8. AccelerometerDataContent is a protocol that matches CMAccelerometerData.
 9. CMAccelerometerData can emit a .csvLine (but only recently promises CSVRepresentable).
 */

var completedTags: [String] = []
let addToArchive = NotificationCenter.default
    .addObserver(forName: ZIPProgressNotice,
                 object: nil, queue: .main) { notice in
        guard let info = notice.userInfo as? [ZIPProgressKeys: String],
                let fileName = info[.fileName],
                let theTag   = info[.tagCompleted]
        else {
            fatalError()
        }
        completedTags.append(theTag)
        if completedTags.count == 2 {
            try! LastWalkingData.shared.exportZIPFile()
        }
    }


/// Accumulate data (expected `.csv`) for export into a ZIP archive.
final class LastWalkingData {
    static let shared = try! LastWalkingData()

    /// Invariant: The ID of the user
    let subjectID: String
    /// Invariant: time of creation of the export set
    let timestamp = Date().iso
    /// The output ZIP archive
    let csvArchive: Archive

    /// Capture file and directory locations and initialize the archive.
    /// - Parameter subject: The ID of the user
    //    init(subjectID subject: String)
    init() throws {
        guard let subject = SubjectID.shared.id else {
            throw FileStorageErrors.noSubjectID
        }
        self.subjectID = subject

        let backingStore = Data()
        guard let _archive = Archive(
            data: backingStore,
            accessMode: .create)
        else { throw FileStorageErrors.cantInitializeZIPArchive }
        self.csvArchive = _archive
    }

    // Step 1: Create the destination directory

    // MARK: Working Directory

    /// URL of the working directory that receives the `.csv` files and the `.zip` archive.
    lazy var containerDirectory: URL! = {
        do {
            try FileManager.default
                .createDirectory(
                    at: destinationDirectoryURL,
                    withIntermediateDirectories: true)
        }
        catch {
            preconditionFailure(error.localizedDescription)
        }
        return destinationDirectoryURL

    }()

    /// Create the file directory to receive the `.csv` files and the `.zip` archive.
    private func createWorkingDirectory() -> URL {
        do {
            try FileManager.default
                .createDirectory(
                    at: destinationDirectoryURL,
                    withIntermediateDirectories: true)
        }
        catch {
            preconditionFailure(error.localizedDescription)
        }
        return destinationDirectoryURL
    }

    /// Write data into a `.csv` file in the working directory.
    ///
    /// Also, add the data into the `Archive` object
    /// - Parameters:
    ///   - data: The content of the file to archive.
    ///   - tag: A short `String` distinguishing the phase (regular, fast) of collection.
    func writeData(_ data : Data,
                   forTag tag : String) throws {
        // TODO: Replace duplicate-named files with the new one.
        let taggedURL = csvFileURL(tag: tag)
        let success = FileManager.default
            .createFile(
                atPath: taggedURL.path,
                contents: data)
        if !success {
            throw FileStorageErrors.cantCreateFileAt(taggedURL)
        }

        try csvArchive.addEntry(
            with: taggedURL.lastPathComponent,
            fileURL: taggedURL)

        let params: [ZIPProgressKeys : String] = [
            .tagCompleted : tag,
            .fileName     : taggedURL.path
          ]
        NotificationCenter.default
            .post(name: ZIPProgressNotice,
                  object: self, userInfo: params)
    }

    /// Assemble and compress the file data and write it to a `.zip` file.
    func exportZIPFile() throws {
        guard let content = csvArchive.data else {
            throw FileStorageErrors.cantGetArchiveData
        }
        try content.write(to: zipFileURL)
    }
}

// MARK: - File names
extension LastWalkingData {
    var directoryName: String {
        "\(subjectID)_\(timestamp)"
    }

    /// target `.zip` file name
    var archiveName: String {
        "\(directoryName).zip"
    }

    /// Child directory of temporaties diectory, named uniquely for this package of `.csv` files.
    private var destinationDirectoryURL: URL {
        let temporaryPath = NSTemporaryDirectory()
        let retval = URL(fileURLWithPath: temporaryPath, isDirectory: true)
            .appendingPathComponent(directoryName,
                                    isDirectory: true)
        return retval
    }

    /// Working directory + archive (`.zip`) name
    var zipFileURL: URL {
        containerDirectory
            .appendingPathComponent(archiveName)
    }

    /// Name of the tagged `.csv` file
    func csvFileName(tag: String) -> String {
        "\(subjectID)_\(tag)_\(timestamp).csv"
    }

    /// Destination (wrapper) directory + per-exercise `.csv` name
    func csvFileURL(tag: String) -> URL {
        containerDirectory
            .appendingPathComponent(csvFileName(tag: tag))
    }
}


