//
//  CSVArchiver.swift
//  G Bars
//
//  Created by Fritz Anderson on 9/8/22.
//

import Foundation
import ZIPFoundation

final class LastWalkingData {

//    let destinationDirectory: URL
    let subjectID: String
    let timestamp = Date().iso
//    let dest


    init(subject: String) {
        subjectID = subject
    }

    var directoryName: String {
        "\(subjectID)_\(timestamp)"
    }

    /// Child directory of temporaties diectory, named uniquely for this package of `.csv` files.
    var destinationDirectoryURL: URL {
        let temporaryPath = NSTemporaryDirectory()
        let retval = URL(fileURLWithPath: temporaryPath, isDirectory: true)
            .appendingPathComponent(directoryName,
                                    isDirectory: true)
        return retval
    }

    /// target `.zip` file name
    var archiveName: String {
        "\(directoryName).zip"
    }

    // Step 1: Create the destination directory

    // MARK: Write one CSV
    lazy var destinationDirectory: URL = {
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

//    func createArchiveDirectory() throws {
//        try FileManager.default
//            .createDirectory(
//                at: destinationDirectory,
//                withIntermediateDirectories: true)
//    }

    /// Working directory + archive (`.zip`) name
    var zipFileURL: URL {
        destinationDirectory.appendingPathComponent(archiveName)
    }

    /// Name of the tagged `.csv` file
    func csvFileName(tag: String) -> String {
        "\(subjectID)_\(tag)_\(timestamp).csv"
    }

    /// Destination (wrapper) directory + per-exercise `.csv` name
    func csvFileURL(tag: String) -> URL {
        destinationDirectory
            .appendingPathComponent(csvFileName(tag: tag))
    }

    static var writtenArchives: [URL] = []

    func writeCSV(withData data : Data,
                  forTag tag    : String) throws {
        let taggedURL = csvFileURL(tag: tag)

        let success = FileManager.default
            .createFile(
                atPath: taggedURL.path,
                contents: data)
        if !success {
            throw FileStorageErrors.cantCreateFileAt(taggedURL)
        }
        Self.writtenArchives.append(taggedURL)
    }

    func listTempDirectory() throws -> String {
        do {
            let content = try Data(contentsOf: csvFileURL(tag: "w_1"))
            if let asString = String(data: content, encoding: .utf8) {
                print("Content length =", asString.count)
                print("Prefix:", asString.prefix(128))
                print()
            }
            else {
                print("Couldn't convert")
            }
        }
        catch {
            print("No content for file:", error)
            print()
        }

        let inTemporary = try FileManager.default
            .contentsOfDirectory(atPath: NSTemporaryDirectory())
        let tempAsArray = "[ " +
        inTemporary.joined(separator: ", ") +
        " ]"

        let inTargetDir = try FileManager.default
            .contentsOfDirectory(atPath: destinationDirectory.path)
        let targetAsArray = "[ " +
        inTargetDir.joined(separator: ", ") +
        " ]"

        var retval = ""
        print("Temporary:", tempAsArray, separator: "\n", terminator: "\n\n", to: &retval)
        print("Target:", targetAsArray, separator: "\n", terminator: "\n", to: &retval)
        return retval
    }

    func writeTheZIPFile() throws {
        let retval = Data()
        guard let archive = Archive(data: retval, accessMode: .create)
        else {
            throw FileStorageErrors.cantInitializeZIPArchive
        }

        do {
            for url in Self.writtenArchives {
                try archive.addEntry(with: url.lastPathComponent, fileURL: url)
            }
        }
        catch {
            fatalError()
        }
    }
}
