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
    case noSoundID(String)
}

func playSound(named: String, thenSay text: String) {
    Task {
        do {
            let player = try SoundPlayer(name: named)
            await player.playSoundAndWait()
            await CallbackUtterance(string: text).asyncSpeak()
        }
        catch {
            print("\(#fileID):\(#line) - error:", error)
            print()
        }
    }
}

// MARK: - SoundPlayer

/// Given the base name of an MP3 file in the main `Bundle`, `SoundPlayer` plays it.
final class SoundPlayer {
    // MARK: Properties
    let soundName: String
    private var soundID  : SystemSoundID!
//    private var session  : AVAudioSession

    // MARK: Initialization
    /// Initialize from the base name of the `.mp3` sound file. The file is assumed to be in the main `Bundle`.
    /// - Parameter name: The _base_ name of the audio file.
    /// - throws: AVFoundatin errors from configuring the audio session; or `MP3Error`s if the sound file could not be found or could not be translated into a system sound ID.
    public init(name: String) throws {
        soundName = name
        soundID = try Self.prepareSound(name: name, existingID: 0)
    }

    // MARK: Use
    /// Play the sound asynchronously.
    public func playSound() async {
        await withCheckedContinuation { continuation in
            // SHOULD have a built-in refactoring, but doesn't.
            AudioServicesPlayAlertSoundWithCompletion(soundID) {
                continuation.resume()
            }
        }
    }

    /// Play the sound _asynchronously._
    public func playSoundAndWait() async {
        await withCheckedContinuation { continuation in
            // SHOULD have a built-in refactoring, but doesn't.
            AudioServicesPlayAlertSoundWithCompletion(soundID) {
                continuation.resume()
            }
        }
    }
}

// MARK: Initialization helpers
extension SoundPlayer {

    // TODO: Should this be done once, like upon launch?
    //       Keeping it public, just in case.
//    /// Configure the shared `AVAudioSession` for a voice-style prompt that ducks other sounds under it.
//    /// - throws: `AVFoundation` errors if the session could not be configured or activated.
//    @available(*, unavailable)
//    public static func prepareEnvironment() throws -> AVAudioSession {
//        if let retval = AVAudioSession. { return retval }
//        let returnedSession = AVAudioSession.sharedInstance()
//        try returnedSession.setCategory(
//            .playback,
//            mode: .voicePrompt,
//            // voicePrompt because it accompanies text-to-speech
//            options: [.defaultToSpeaker, .duckOthers])
//
//        try returnedSession.setActive(true)
//        sharedAudioSession = returnedSession
//        return returnedSession
//    }

    // existingID: Do we need to guarantee it won't be called again?
    /// Register a sound for a `SystemSoundID`.
    /// - parameters:
    ///     - name: The base name of an`.mp3` file in the main `Bundle`
    ///     - existingID: A sound ID that may already be assigned to this sound. Not clear that this is necessary.
    ///     - throws: `MP3Errors` if the sound file can't be found or be allocated an ID.
    private static func prepareSound(name: String, existingID: SystemSoundID) throws -> SystemSoundID {
        if existingID != 0 { return existingID }
        guard let soundURL = Bundle.main
                .url(forResource: name,
                     withExtension: "mp3")
        else {
            throw MP3Errors.noSoundResource(name)
        }
        var localSoundID: SystemSoundID = 0
        let result = AudioServicesCreateSystemSoundID(
            soundURL as CFURL, &localSoundID)
        guard result == noErr else {
            throw MP3Errors.noSoundID(name)
        }
        return localSoundID
    }
}

// MARK: CustomStringConvertible
extension SoundPlayer: CustomStringConvertible {
    /// Compliance with `CustomStringConvertible`
    var description: String { "SoundPlayer(\(soundName)" }
}


func setUpAudioEnvironment() {
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
