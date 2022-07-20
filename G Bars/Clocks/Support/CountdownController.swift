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



func spokenInterval(minutes: Int, seconds: Int) -> String {
    // Assume mins are div-60 and secs are mod-60
    assert(minutes >= 0)
    assert(seconds >= 0)
    assert(seconds < 60)
    if minutes == 0 && seconds == 0 {
        return "zero"
    }

    func pluralRule(for unit: Int, singular: String, plural _plural: String? = nil) -> String {
        let plural = _plural ?? singular + "s"

        let retval: String
        if unit == 0 {
            retval = ""
        }
        else if unit == 1 {
            retval = String(unit) + " " + singular
        }
        else {
            retval = String(unit) + " " + plural
        }
        return retval
    }

    let minsString = pluralRule(for: minutes, singular: "minute")
    let secsString = pluralRule(for: seconds, singular: "second")
    let retval = [minsString, secsString].filter { !$0.isEmpty }.joined(separator: ", ")

    return retval
}


// WAIT.
// How do I simultaneously maintain sweep-seconds and mm:ss?
// A single controller can't easily switch between the time
// scales, right?

enum CancellationReasons {
    case notCancelled, cancelled, ranOut
}

/// Bridge between countdown figures from a `MinutePublisher` and the SwiftUI display.
final class CountdownController: ObservableObject {
//    @Published var timePublisher: MinutePublisher!
    private var timePublisher: MinutePublisher!

    @Published var isRunning: Bool = false

    @Published var seconds: Int = 5
    @Published var minutes: Int = 2
    @Published var fraction: TimeInterval = 0.0

    @Published public var minuteColonSecond: String = ""
    @Published public var speakableTime: String = "Start walking"

    static let fixedDurationInSeconds = 135
    @Published var durationInSeconds: Int
    private var cancellables: Set<AnyCancellable> = []


    init(forCountdown: Bool) {
        self.isRunning = false
        self.durationInSeconds = Self.fixedDurationInSeconds

        /*
         WARNING: DO NOT MUTATE durationInSecons FOR THE PURPOSE OF MINIMAL-EXAMPLE.
         */
    }

    /// Update `self` to match the time components published by `MinutePublisher`.
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
            .print()
            .map {
                (mins: Int, secs: Int) -> String in
                let retval = spokenInterval(minutes: mins, seconds: secs)
                return retval
            }
            .assign(to: \.speakableTime, on: self)
            .store(in: &cancellables)
    }

    func reassemble(newDuration: TimeInterval) {
        // Don't claim to be running.
        isRunning = false
        // New timePublisher
        // (Assignment frees the MP's incumbent publisher.)
        timePublisher = MinutePublisher(after: TimeInterval(durationInSeconds))
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
        assert(isRunning, "\(#function) - attempt to halt a tracker that isn't running.")
        timePublisher.stop(exhausted: timeRanOut)
    }
}
