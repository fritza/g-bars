//
//  EndpointSound.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/8/22.
//

import Foundation
import AVFoundation
import AVFAudio

// MARK: - MP3Errors
enum MP3Errors: Error {
    case noSoundResource(String)
    case noSoundID(String, Int)
}

func playSound(named: String, thenSay text: String) {
    Task.detached {
        await SoundPlayer.playSound()
        await CallbackUtterance(string: text).asyncSpeak()
    }
}

// MARK: - SoundPlayer

/// Given the base name of an MP3 file in the main `Bundle`, `SoundPlayer` plays it.
final class SoundPlayer {
    // MARK: Properties
    let soundName: String
//    private var soundID  : SystemSoundID!

    // MARK: Initialization
    /// Initialize from the base name of the `.mp3` sound file. The file is assumed to be in the main `Bundle`.
    /// - Parameter name: The _base_ name of the audio file.
    /// - throws: AVFoundatin errors from configuring the audio session; or `MP3Error`s if the sound file could not be found or could not be translated into a system sound ID.
    public init(name: String) throws {
        soundName = name
        try Self.initializeAudio()
    }

    // MARK: Use
    /// Play the sound _asynchronously_.
    public static func playSound() async {
        await withCheckedContinuation { continuation in
            // SHOULD have a built-in refactoring, but doesn't.
            AudioServicesPlayAlertSoundWithCompletion(klaxonSoundID) {
                continuation.resume()
            }
        }
    }

    // Should play synchronously, blew it.
//    /// Play the sound _asynchronously._
//    public static func playSoundAndWait() async {
//        await withCheckedContinuation { continuation in
//            // SHOULD have a built-in refactoring, but doesn't.
//            AudioServicesPlayAlertSoundWithCompletion(klaxonSoundID) {
//                continuation.resume()
//            }
//        }
//    }
}

// MARK: Initialization helpers
extension SoundPlayer {
    static func initializeAudio() throws {
        guard Self.klaxonSoundID == 0 else { return }
        try setUpAudioEnvironment()
        try registerKlaxon()
    }

    private static func setUpAudioEnvironment() throws {
        // MARK: play from background.
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord,
                                    mode: .spokenAudio,
                                    options: [.defaultToSpeaker])
            try session.setActive(true)
        }
        catch {
            print(#function, "failed somewhere:", error)
        }
    }

    // MARK: initialize the klaxon sound
    private static var klaxonSoundID: SystemSoundID = 0
    private static let klaxonBaseName = "Klaxon"

    private static func registerKlaxon() throws {
        guard Self.klaxonSoundID == 0 else { return }
        // GUARD GUARD GUARD GUARD GUARD GUARD

        guard let soundURL = Bundle.main
            .url(forResource: Self.klaxonBaseName,
                 withExtension: "mp3")
        else {
            throw MP3Errors.noSoundResource(Self.klaxonBaseName)
        }

        let error = AudioServicesCreateSystemSoundID(
            soundURL as CFURL, &Self.klaxonSoundID)
        guard error == noErr else {
            throw MP3Errors.noSoundID(Self.klaxonBaseName,
                                      Int(error))
        }
    }
}

// MARK: CustomStringConvertible
extension SoundPlayer: CustomStringConvertible {
    /// Compliance with `CustomStringConvertible`
    var description: String { "SoundPlayer(\(soundName)" }
}


