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
    @Published public var shouldSpeak = true
    @Published public var currentSpeakable = ""


    static let fixedDurationInSeconds = 135 // _TMP_
    @Published var durationInSeconds: Int
    private var cancellables: Set<AnyCancellable> = []
    var mmssToDisplay: String = ""

    // MARK: - Initialization
    /// Initialize from the length of the countdown
    /// - Parameter \_duration: : Integer length of the countdown **in seconds**
    init(duration _duration: Int, forCountdown: Bool = true) {
        self.isRunning = false
        self.durationInSeconds = _duration
        // Self.fixedDurationInSeconds
    }

    // MARK: - Combine

    /// Initialize the Combine chains. Most of these are direct `assign(to:...)`  trampolines from `MinutePublisher`, some perform task-specific  workflows.
    ///
    /// This function should be run _only once_ per `MinutePublisher`.  If `self.timePublisher` is non-nil, the function returns immediately.
    /// - warning: I _think_ `timePublisher` should be nilled-out before starting a new countdown.
    /// - note: do not confuse with ``MinutePublisher/setUpCombine``.
    func setUpCombine() {
        // MARK: Publisher
#warning("SHOULD TIMEPUBLISHER BE NILLED FOR EACH COUNTDOWN?")

        guard timePublisher == nil else { return }
        timePublisher = MinutePublisher(
                after: TimeInterval(durationInSeconds))

        // MARK: Time components
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

        // MARK: MinSecondPair
        // Publisher that assembles current minutes and seconds into `MinSecondPair`
        let mmssPublisher = timePublisher.$minutes
            .combineLatest(timePublisher.$seconds)
            .map { (mins: Int, secs: Int) -> MinSecondPair in
                return MinSecondPair(minutes: mins, seconds: secs)
            }
            .filter { _ in return self.shouldSpeak }

        // MARK: MinSecondPair -> speech
        mmssPublisher
            .filter { (minsec: MinSecondPair) -> Bool in
                minsec.seconds % 10 == 0
            }
            .receive(on: DispatchQueue.main)
            .sink { minsec in
                CallbackUtterance
                    .sayCountdown(minutesAndSeconds: minsec)
            }
            .store(in: &cancellables)

        // MARK: MinSecondPair -> display time
        // Written description: 1:23
        mmssPublisher
            .map(\.description)
            .removeDuplicates()
            .print("written time:")
            .assign(to: \.mmssToDisplay, on: self)
            .store(in: &cancellables)
    }

    // MARK: - Halt/restart
    // TODO: do we need durationInSeconds at all?
    //       It's subject to change at all times.
    //       Can a MinutePublisher property do better?

    /// Regenerate the Combine chains from the `MinutePublisher`.
    func reassemble(newDuration: TimeInterval) {
        durationInSeconds = Int(round(newDuration))
        // Don't claim to be running.
        isRunning = false
        setUpCombine()
    }

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

    /// Halt the the “`timePublisher`” `MinutePublisher`, and the `CallbackUtterance` speaker.
    ///
    /// - warning: I think `timePublisher` ought to be nilled-out.
    func stopCounting(timeRanOut: Bool = true) {


        // Should this nil-out timePublisher?
        #warning("SHOULD THIS NIL-OUT TIMEPUBLISHER?")


        guard isRunning else { return }
        timePublisher.stop(exhausted: timeRanOut)
        CallbackUtterance.stop()

        // Here is where timePublisher should go to nil.
        // TODO: Does anyone else create a MinutePublisher?
        // TODO: Does anyone else call reassemble(newDuration:)?
        reassemble(newDuration: countdown_TMP_Duration)
    }
}
