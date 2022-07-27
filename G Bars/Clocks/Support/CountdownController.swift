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

    #warning("initialize minuteColonSecond with nonblank mm:ss")
    @Published public var minuteColonSecond: String = ""

    //    @Published public var speakableTime: String = "Start walking"



    // TEMPORARY
    @Published public var shouldSpeak = true
    @Published public var currentSpeakable = ""



    static let fixedDurationInSeconds = 135
    @Published var durationInSeconds: Int
    private var cancellables: Set<AnyCancellable> = []

//    @Published
//    var mmssToSpeak: String = ""
//    @Published
    var mmssToDisplay: String = ""

    // MARK: Initialization
    /// Initialize from the length of the countdown
    /// - Parameter \_duration: : Integer length of the countdown **in seconds**
    init(duration _duration: Int, forCountdown: Bool = true) {
        self.isRunning = false
        self.durationInSeconds = _duration
        // Self.fixedDurationInSeconds
    }

    /// Update `self` to match the time components published by `MinutePublisher`.
    ///
    /// This should probably be the last action in `reassamble(newDuration:)`.  `DigitSpeaker` may depend on complete (re)initialization of the controller.
    func setUpCombine() {
/*
 setUpCombine is getting to be a problem.

 You really do have to regenerate the time publisher after it either exhausts or is cancelled.

 So you call this function.

 All formatting — mm:ss, nn minutes, ss seconds — now comes through MinutePublisher. It has the Truth.
 */


        guard timePublisher == nil else { return }
        timePublisher = MinutePublisher(
                after: TimeInterval(durationInSeconds))


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

        let mmssPublisher = timePublisher.$minutes
            .combineLatest(timePublisher.$seconds)
            .map { (mins: Int, secs: Int) -> MinSecondPair in
                return MinSecondPair(minutes: mins, seconds: secs)
            }
            .filter { _ in return self.shouldSpeak }

        // Spoken description: "one minute, twenty-three seconds"
        mmssPublisher
            .filter { (minsec: MinSecondPair) -> Bool in
//                return shouldSpeak &&
                // shouldSpeak is filtered upstream.
                minsec.seconds % 10 == 0
            }
//            .map(\.speakableDescription)

            .receive(on: DispatchQueue.main)
            .sink { minsec in
                CallbackUtterance
                    .sayCountdown(minutesAndSeconds: minsec)
            }
            .store(in: &cancellables)

        // Written description: 1:23
        mmssPublisher
            .map(\.description)
            .removeDuplicates()
            .print("written time:")
            .assign(to: \.mmssToDisplay, on: self)
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
        setUpCombine()
        // FIXME: Where do I put initial time announcement
    }

    // Reassembly should already be done by here.
    // Work with whatever timePublisher you have.
    // This won't handle a restart, will it.
    // Do I care, in this application?
    func startCounting(reassembling: Bool,
                       duration: TimeInterval) {
        if reassembling { reassemble(newDuration: duration) }

        let roundedDuration = Int(round(duration))
        // Int(round(countdown_TMP_Duration))
        let minsec = MinSecondPair(seconds: roundedDuration)
        if shouldSpeak && (minsec.seconds % 10 == 0) {
            CallbackUtterance
                .sayCountdown(minutesAndSeconds: minsec)
        }

        timePublisher.start()
    }

    func stopCounting(timeRanOut: Bool = true) {
        // Should this nil-out timePublisher?
        guard isRunning else { return }
        timePublisher.stop(exhausted: timeRanOut)
        CallbackUtterance.stop()
//        CallbackUtterance.synthesizer.stopSpeaking(at: .immediate)
        reassemble(newDuration: countdown_TMP_Duration)
    }
}
