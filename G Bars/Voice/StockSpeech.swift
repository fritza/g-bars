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
    typealias CVUCallback = (CallbackUtterance) -> Void

    static let speechDelegate = SpeechDelegate()
    static let synthesizer: AVSpeechSynthesizer = {
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

    static var currentCallbackUtterance: CallbackUtterance?
    /// Utter a speakable description of a `MinSecondPair`.
    ///
    /// The utterance is stored in a `static` reference until it calls back to say it's done.
    static func sayCountdown(minutesAndSeconds: MinSecondPair) {
        guard currentCallbackUtterance == nil else {
            return
        }


        precondition(currentCallbackUtterance == nil,
                     "\(#function): Attempt to enqueue an utterance while another is in progress.")
        currentCallbackUtterance = CallbackUtterance(minutesAndSeconds: minutesAndSeconds) {
            cbu in
            currentCallbackUtterance = nil
        }
        currentCallbackUtterance!.speak()
    }

    func speak() {
        Self.synthesizer.speak(self)
    }

    static func stop() {
        Self.synthesizer.stopSpeaking(at: .immediate)
        Self.currentCallbackUtterance = nil
    }
}

extension CallbackUtterance {

}

final class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    // REMEMBER! AVSpeechSynthesizer keeps a queue of its own.
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance) {
            if let callbackUtterance = utterance as? CallbackUtterance {
                callbackUtterance.callback?(callbackUtterance)
            }
        }
}
    /*
     The only event (if any) we care about is didFinish.

     Not necessary:
     didCancel, didContinue, didPause, didStart, willSpeakRangeOfSpeechString

     NOTE: Cancellation comes after the synth has already been told to stop. All pending utterances are also stopped. There's nothing more to do.
     */


