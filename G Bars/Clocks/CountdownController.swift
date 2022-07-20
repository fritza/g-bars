//
//  CountdownController.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/15/22.
//

import Foundation
import Combine
import SwiftUI

// WAIT.
// How do I simultaneously maintain sweep-seconds and mm:ss?
// A single controller can't easily switch between the time
// scales, right?

enum CancellationReasons {
    case notCancelled, cancelled, ranOut
}

final class CountdownController: ObservableObject {
    deinit {
        print("well, here we are.")
    }


    @Published var isRunning: Bool = false
//    @Published var durationInSeconds: Int = dur

    // Making this non-optional did not make controller.timePublisher.fraction (e.g.) carry through
    @Published var timePublisher: MinutePublisher

    @Published var mmss: String = ""
    @Published var seconds: Int = 5
    @Published var minutes: Int = 2
    @Published var fraction: TimeInterval = 0.0

    private var cancellables: Set<AnyCancellable> = []

//    @AppStorage(AppStorageKeys.walkInMinutes.rawValue) private var durationInSeconds: Int = 2

    @Published var durationInSeconds: Int

    static func walkDuration() -> Int {
        let defaults = UserDefaults.standard
        var candidateSeconds = defaults.integer(
            forKey: AppStorageKeys.walkInMinutes.rawValue)
        * 60
        if candidateSeconds < 60 {
            defaults.set(1, forKey: AppStorageKeys.walkInMinutes.rawValue)
            candidateSeconds = 60
        }
        return candidateSeconds
    }

    static func countdownDuration() -> Int { return 5 }

    init(forCountdown: Bool) {
        self.isRunning = false

        // FIXME: Allow for walk durations.
        let prefsSeconds = forCountdown ? Self.countdownDuration() : Self.walkDuration()
        self.durationInSeconds = prefsSeconds

        let publisher = MinutePublisher(
            after: TimeInterval(prefsSeconds)
        )

        timePublisher = publisher
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
            .assign(to: \.mmss,     on: self)
            .store(in: &cancellables)
    }

    func startCounting() {
        timePublisher.start()
        isRunning = true
    }

    func stopCounting(timeRanOut: Bool = true) {
//        guard timePublisher != nil else {
//            assertionFailure("\(#function) - Attempt to stop a counter that does not exist")
//            return
//        }
        timePublisher.stop(exhausted: timeRanOut)
    }
}
