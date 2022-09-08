//
//  CSVArchiver.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/8/22.
//

import Foundation
import ZIPFoundation

/// Accumulate data (expected `.csv`) for export into a ZIP archive.
final class LastWalkingData {
    /// Invariant: The ID of the user
    let subjectID: String
    /// Invariant: time of creation of the export set
    let timestamp = Date().iso
    /// The output ZIP archive
    let csvArchive: Archive

    /// Capture file and directory locations and initialize the archive.
    /// - Parameter subject: The ID of the user
    init(subjectID subject: String) throws {
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
    lazy var workingDirectory: URL! = {
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
        workingDirectory
            .appendingPathComponent(archiveName)
    }

    /// Name of the tagged `.csv` file
    func csvFileName(tag: String) -> String {
        "\(subjectID)_\(tag)_\(timestamp).csv"
    }

    /// Destination (wrapper) directory + per-exercise `.csv` name
    func csvFileURL(tag: String) -> URL {
        workingDirectory
            .appendingPathComponent(csvFileName(tag: tag))
    }
}


