//
//  CountdownController.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/15/22.
//

import Foundation
import Combine
import SwiftUI
import Foundation
import Combine
import SwiftUI

enum CancellationReasons {
    case notCancelled, cancelled, ranOut
}

// MARK: - CountdownController
/// Bridge between countdown figures from a `MinutePublisher` and the SwiftUI display.
final class CountdownController: ObservableObject {
//    @Published var timePublisher: MinutePublisher!
    private var timePublisher: MinutePublisher!

    // MARK: Published properties
    @Published var isRunning: Bool = false

    @Published var seconds: Int = 5
    @Published var minutes: Int = 2
    @Published var fraction: TimeInterval = 0.0

    @Published public var minuteColonSecond: String = ""
//    @Published public var speakableTime: String = "Start walking"



    // TEMPORARY
    @Published public var shouldSpeak = true




    static let fixedDurationInSeconds = 135
    @Published var durationInSeconds: Int
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Initialization
    init(duration _duration: Int, forCountdown: Bool = true) {
        // digitSpeaker is initalized in setUpCombine()
        self.isRunning = false
        self.durationInSeconds = _duration // Self.fixedDurationInSeconds

        /*
         WARNING: DO NOT MUTATE durationInSeconds FOR THE PURPOSE OF MINIMAL-EXAMPLE.
         */
    }

    /// Update `self` to match the time components published by `MinutePublisher`.
    ///
    /// This should probably be the last action in `reassamble(newDuration:)`.  `DigitSpeaker` may depend on complete (re)initialization of the controller.
    func setUpCombine() {
        // NOTE: passing self into assign retains self until its upstream is cancelled.
        timePublisher.$fraction
            .assign(to: \.fraction, on: self)
            .store(in: &cancellables)
        timePublisher.$minutes
            .assign(to: \.minutes,  on: self)
            .store(in: &cancellables)
        timePublisher.$seconds
            .assign(to: \.seconds,  on: self)
            .store(in: &cancellables)
        timePublisher.$minuteColonSecond
            .assign(to: \.minuteColonSecond, on: self)
            .store(in: &cancellables)
        timePublisher.$isRunning
            .assign(to: \.isRunning, on: self)
            .store(in: &cancellables)

        let minsAndSecs = timePublisher.$minutes
            .combineLatest(timePublisher.$seconds)

        minsAndSecs
            .filter { mmss in
                self.shouldSpeak &&
                (mmss.1 % 10) == 0
            }
            .map {
                (mins: Int, secs: Int) -> String in
                let retval = spokenInterval(minutes: mins, seconds: secs)
                return retval
            }
            .removeDuplicates()
            .sink { str in
                let utterance = CallbackUtterance(string: str)
                utterance.speak()
            }
            .store(in: &cancellables)
    }

    // MARK: Halt/restart
    // TODO: do we need durationInSeconds at all?
    //       It's subject to change at all times.
    //       Can a MinutePublisher property do better?
    func reassemble(newDuration: TimeInterval) {
        durationInSeconds = Int(round(newDuration))
        // Don't claim to be running.
        isRunning = false
        // New timePublisher
        // (Assignment frees the MP's incumbent publisher.)
        timePublisher = MinutePublisher(after: TimeInterval(newDuration))
        // Wire up the outlets.
        setUpCombine()
    }

    // Reassembly should already be done by here.
    // Work with whatever timePublisher you have.
    // This won't handle a restart, will it.
    // Do I care, in this application?
    func startCounting(reassembling: Bool,
                       duration: TimeInterval) {
        if reassembling { reassemble(newDuration: duration) }

        let roundedDuration = Int(round(countdown_TMP_Duration))
        let minutes = roundedDuration/60
        let seconds = roundedDuration%60
        let string = spokenInterval(minutes: minutes, seconds: seconds)
        CallbackUtterance(string: string)
            .speak()

        timePublisher.start()
    }

    func stopCounting(timeRanOut: Bool = true) {
        // Should this nil-out timePublisher?
        guard isRunning else { return }
        timePublisher.stop(exhausted: timeRanOut)
        CallbackUtterance.synthesizer.stopSpeaking(at: .immediate)
        reassemble(newDuration: countdown_TMP_Duration)
    }
}
