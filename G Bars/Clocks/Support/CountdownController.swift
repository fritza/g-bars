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
    @Published public var speakableTime: String = "Start walking"
    @Published public var shouldSpeak = false

    static let fixedDurationInSeconds = 135
    @Published var durationInSeconds: Int
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Initialization
    init(duration _duration: Int, forCountdown: Bool = true) {
        // digitSpeaker is initalized in setUpCombine()
        self.isRunning = false
        self.durationInSeconds = _duration // Self.fixedDurationInSeconds

        /*
         WARNING: DO NOT MUTATE durationInSecons FOR THE PURPOSE OF MINIMAL-EXAMPLE.
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

        // TODO: Does "speakableTime" belong in MinutePublisher?
        //       Specializing what's published is an uncomfortable dependency.
        //       Is there a way to pass an array of closures or filters
        //       to MinutePublishers? Not obvious how to handle that.

        let msZip = timePublisher.$minutes
            .combineLatest(timePublisher.$seconds)

        msZip
            .filter { ($0.1 % 10) == 0 }
            .map {
                (mins: Int, secs: Int) -> String in
                let retval = spokenInterval(minutes: mins, seconds: secs)
                return retval
            }
            .assign(to: \.speakableTime, on: self)
            .store(in: &cancellables)

        // If shouldSpeak is false, stop any utterance in progress

        $speakableTime
            .filter { _ in self.shouldSpeak }
            .removeDuplicates()
            .throttle(for: 5.0, scheduler: DispatchQueue.main, latest: true)
            .sink { str in
                Task {
                   await TimeSpeaker.shared.say(str)
                }
            }
            .store(in: &cancellables)
        /*
        $shouldSpeak // .removeDuplicates()
            .filter { shouldOrShouldnt in
                !shouldOrShouldnt
            }
        // By here, we're responding only to -> false
            .sink { should in
                Task {
                    TimeSpeaker.shared.
                }
                guard let speaker = self.digitSpeaker else {
                    print(#function, "- should digitSpeaker ever be nil?")
                    return
                }
                speaker.stopSpeaking()
            }
            .store(in: &cancellables)
         */
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
    func startCounting() {
        timePublisher.start()
    }

    func stopCounting(timeRanOut: Bool = true) {
        // Should this nil-out timePublisher?
        guard isRunning else { return }
//        assert(isRunning, "\(#function) - attempt to halt a tracker that isn't running.")
        timePublisher.stop(exhausted: timeRanOut)
    }
}
