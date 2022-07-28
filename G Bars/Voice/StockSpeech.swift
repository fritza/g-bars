//
//  StockSpeech.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/25/22.
//

import Foundation
import AVFoundation

/*
 QUESTION: Will CallbackUtterance be released when the client code lets it get out of scope?
 */
final class CallbackUtterance: AVSpeechUtterance {
    deinit {
        print("CallbackUtterance deinit.")
    }

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

    convenience init(minutesAndSeconds: MinSecondPair, callback: CVUCallback? = nil) {
        let speech = minutesAndSeconds.speakableDescription
        self.init(string: speech, callback: callback)
    }

    // MARK: Current Utterance
    static private var currentCallbackUtterance: CallbackUtterance?
    static private var utteranceCount = 0
    static private func setCurrentUtterance(new: CallbackUtterance) {
        currentCallbackUtterance = new
    }

    static private func clearCurrentUtterance() {
        currentCallbackUtterance = nil
    }

    static private var currentUtteranceIsClear: Bool {
        currentCallbackUtterance == nil
    }

    static fileprivate func utteranceIsSameAsCached(_ utterance: CallbackUtterance?) -> Bool {
        return currentCallbackUtterance === utterance
    }


    /// Utter a speakable description of a `MinSecondPair`.
    ///
    /// The utterance is stored in a `static` reference until it calls back to say it's done.
    static func sayCountdown(minutesAndSeconds: MinSecondPair) {
        guard (currentUtteranceIsClear) && CountdownController.shouldSpeak else  {
            return
        }

        precondition(
            currentUtteranceIsClear,
            "\(#function): Attempt to enqueue an utterance while another is in progress.")
        let newUtterance =
        CallbackUtterance(
            minutesAndSeconds: minutesAndSeconds) {
                _ in clearCurrentUtterance()
            }

        setCurrentUtterance(new: newUtterance)
        newUtterance.speak()

        // NOTE: All the get/set utterance shouldn't
        //       be necessary: if you send more than
        //       one utterance, it'll be queued.
    }

    func speak() {
        Self.synthesizer.speak(self)
    }

    static func stop() {
        Self.synthesizer.stopSpeaking(at: .immediate)
//        clearCurrentUtterance()
//        Self.currentCallbackUtterance = nil
    }
}

final class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    deinit {
        print("SpeechDelegate deinit")
    }

    // REMEMBER! AVSpeechSynthesizer keeps a queue of its own.
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance) {
            if let callbackUtterance = utterance as? CallbackUtterance {
                assert(CallbackUtterance.utteranceIsSameAsCached(callbackUtterance))
                callbackUtterance.callback?(callbackUtterance)
            }
            else {
                preconditionFailure("\(#function) got a strange utterance from callback.")
            }
        }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print(#function, "Hit.")
        print()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print(#function, "Hit.")
        print()
    }
}
    /*
     The only event (if any) we care about is didFinish.

     Not necessary:
     didCancel, didContinue, didPause, didStart, willSpeakRangeOfSpeechString

     NOTE: Cancellation comes after the synth has already been told to stop. All pending utterances are also stopped. There's nothing more to do.
     */


