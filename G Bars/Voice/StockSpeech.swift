//
//  StockSpeech.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/25/22.
//

import Foundation
import AVFoundation

final class CallbackUtterance: AVSpeechUtterance {
    var shouldSpeak: Bool {
        get {
            let defaults = UserDefaults.standard
            let retval = defaults.bool(forKey: AppStorageKeys.wantsSpeech.rawValue)
            Self.shouldSpeak = retval
            return retval
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: AppStorageKeys.wantsSpeech.rawValue)
            Self.shouldSpeak = newValue
        }
    }
    static var shouldSpeak: Bool = {
        let defaults = UserDefaults.standard
        let retval = defaults.bool(forKey: AppStorageKeys.wantsSpeech.rawValue)
        return retval
    }()


    typealias CVUCallback = (CallbackUtterance) -> Void

    static private let speechDelegate = SpeechDelegate()
    static private let synthesizer: AVSpeechSynthesizer = {
        let retval = AVSpeechSynthesizer()
        retval.delegate = speechDelegate
        return retval
    }()

    static var isSpeaking: Bool { synthesizer.isSpeaking }
    // true iff speech is in progress or any utterance is in the queue.
    // There's also an isPaused flag, but we don't intend to pause.

    let callback: CVUCallback?

    init(string: String, callback: CVUCallback? = nil) {
        self.callback = callback
        super.init(string: string)
    }

    required init?(coder: NSCoder) {
        fatalError("Does not implement NSCodable")
    }

    convenience init(minutesAndSeconds: MinSecAndFraction, callback: CVUCallback? = nil) {
        let speech = minutesAndSeconds.spoken
        self.init(string: speech, callback: callback)
    }

    func speak() {
        Self.synthesizer.speak(self)
    }

    static func stop() {
        Self.synthesizer.stopSpeaking(at: .immediate)
    }
}

final class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    // REMEMBER! AVSpeechSynthesizer keeps a queue of its own.
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance) {
            if let callbackUtterance = utterance as? CallbackUtterance {
                callbackUtterance.callback?(callbackUtterance)
            }
            else {
                preconditionFailure("\(#function) got a strange utterance from callback.")
            }
        }
}

extension CallbackUtterance {
    /// Utter a speakable description of a `MinSecondPair`.
    ///
    /// The utterance is stored in a `static` reference until it calls back to say it's done.
    static func sayCountdown(minutesAndSeconds: MinSecAndFraction) {
        guard shouldSpeak else { return }
        let newUtterance =
        CallbackUtterance(
            minutesAndSeconds: minutesAndSeconds) {
                back in
                print(#function, "Callback for", back.speechString)
            }
        newUtterance.speak()

        // NOTE: All the get/set utterance shouldn't
        //       be necessary: if you send more than
        //       one utterance, it'll be queued.
    }
}

extension MinSecAndFraction {
    @available(*, deprecated,
                message: "Audit use of this method.")
    func doSay() -> String {
        let retval = spoken
        CallbackUtterance
            .sayCountdown(
                minutesAndSeconds: self)
        return retval
    }
}

    /*
     The only event (if any) we care about is didFinish.

     Not necessary:
     didCancel, didContinue, didPause, didStart, willSpeakRangeOfSpeechString

     NOTE: Cancellation comes after the synth has already been told to stop. All pending utterances are also stopped. There's nothing more to do.
     */


