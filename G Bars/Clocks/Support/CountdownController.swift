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

/**
 ## Topics

 ### Initialization
 - ``init(duration:forCountdown:)``

 ### Operation
 - ``startCounting()``
 - ``stopCounting(timeRanOut:)``

 ### Observable Properties
 - ``isRunning``
 - ``seconds``
 - ``minutes``
 - ``fraction``
 - ``minuteColonSecond``
 - ``shouldSpeak``
 - ``currentSpeakable``
 - ``durationInSeconds``
 */


// MARK: - CountdownController
/// Bridge between countdown figures from a `MinutePublisher` and the SwiftUI display.
final class CountdownController: ObservableObject {
    private var clockPublisher: MinutePublisher!

    // MARK: Published properties
    @Published var isRunning: Bool = false

    @Published var seconds: Int = 5
    @Published var minutes: Int = 2
    @Published var fraction: TimeInterval = 0.0

    @Published public var minuteColonSecond: String = ""
    @AppStorage(AppStorageKeys.wantsSpeech.rawValue) private var shouldSpeak = true
    @Published public var currentSpeakable = ""

    @Published var durationInSeconds: Int

    // TODO: Why do views get this value without @Published?
    @Published var mmssToDisplay: String = ""

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization
    /// Initialize from the length of the countdown
    /// - Parameter \_duration: : Integer length of the countdown **in seconds**
    init(duration _duration: Int)
    {
        self.isRunning = false
        self.durationInSeconds = _duration
    }

    // MARK: - Combine

    /// Initialize the Combine chains. Most of these are direct `assign(to:...)`  trampolines from `MinutePublisher`, some perform task-specific  workflows.
    ///
    /// This function should be run _only once_ per `MinutePublisher`.  If `self.timePublisher` is non-nil, the function returns immediately.
    /// - warning: I _think_ `timePublisher` should be nilled-out before starting a new countdown.
    /// - note: do not confuse with ``MinutePublisher/refreshPublisher()``.
    ///
    private func setUpCombine() {
        // MARK: Publisher
        guard clockPublisher == nil else { return }
        clockPublisher = MinutePublisher(
            duration: TimeInterval(durationInSeconds))
        clockPublisher.refreshPublisher()

        // MARK: Time components
        clockPublisher.$fraction
            .assign(to: \.fraction, on: self)
            .store(in: &cancellables)

        clockPublisher.$minutes
            .assign(to: \.minutes, on: self)
            .store(in: &cancellables)

        clockPublisher.$seconds
            .removeDuplicates()
            .assign(to: \.seconds, on: self)
            .store(in: &cancellables)

        clockPublisher.$minsSecs
            .sink { minsec in
                self.minutes = minsec.minutes
                self.seconds = minsec.seconds
            }
            .store(in: &cancellables)
        clockPublisher.$minuteColonSecond
            .assign(to: \.minuteColonSecond, on: self)
            .store(in: &cancellables)
        clockPublisher.$isRunning
            .assign(to: \.isRunning, on: self)
            .store(in: &cancellables)

        // MARK: MinSecondPair


        /*
         Okay, so I've been watching the mm:ss counter.
         In point of fact, there is no publisher:
         It counts off "one minute, twenty seconds" without
         giving access to the upstream publisher.

         HOWEVER: CONSIDER SETTING CURRENTSPEAKABLE
         IN AN ASSIGN(), AND HAVE THE DOSAY() RUN DOWNSTREAM
         OF THAT, NOT IN A SINK.

         Also, in the case of sweep-second, the
         mmss loop does hit zero, so it gets pronounced
         no matter what.

         SweepSecondView watches controller.seconds
         and controller.fraction.

         We have no problem with controller.fraction.

         What about seconds?
         */



        // Publisher that assembles current minutes and seconds into `MinSecondPair`

        // MARK: MinSecondPair -> speech
        let mmssPublisher = clockPublisher.$minsSecs
        mmssPublisher
            .filter { (minsec: MinSecondPair) -> Bool in
                return self.shouldSpeak && minsec.seconds % 10 == 0
            }
            .removeDuplicates()
            .map(\.speakableDescription)
            .assign(to: \.currentSpeakable, on: self)
            .store(in: &cancellables)

        // MARK: MinSecondPair -> display time
        // Written description: 1:23
        mmssPublisher
            .map(\.description)
            .assign(to: \.mmssToDisplay, on: self)
            .store(in: &cancellables)
    }

    // MARK: - Halt/restart
    func startCounting() {
        // Creates the MinutePublisher, sets
        // and starts the intervals chain

        setUpCombine()

        // Resets the publisher's start date,
        // effectively starting the clock.
        clockPublisher.start()
    }

    /// Halt the the “`timePublisher`” `MinutePublisher`, and the `CallbackUtterance` speaker.
    ///
    /// - warning: I think `timePublisher` ought to be nilled-out.
    func stopCounting(timeRanOut: Bool = true) {
        guard isRunning else { return }
        //    isRunning = false - observes isRunning from the publisher.
        clockPublisher.stop(exhausted: timeRanOut)
        CallbackUtterance.stop()
    }
}
