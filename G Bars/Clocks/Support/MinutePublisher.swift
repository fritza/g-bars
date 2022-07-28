//
//  MinutePublisher.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/6/22.
//

import Foundation
import Combine

// TODO: The count-up should also stop the clock when a deadline is reached.
// TODO: set up for fractions only if they will be used.
//       Otherwise, the subscriber need not be created,
//       and maybe the Timer can be given a looser interval and tolerance.

/**
 ## Topics

 ### Initialization

 - ``init(to:)``
 - ``init(after:)``

 ### Published Properties

 - ``isRunning``
 - ``minutes``
 - ``seconds``
 - ``fraction``
 - ``minuteColonSecond``

### Operation
 - ``setUpCombine()``
 - ``start()``
 - ``stop(exhausted:)``

 */

// MARK: - MinutePublisher
/// Publisher of components of `Timer` ticks in integer minutes and seconds; and `Double` subseconds, counting up or down.
///
/// Countdown timers run down to a specified deadline into the future. Count-up timers run indefinitely (but see **Bug**).
///
/// `MinutePublisher` broadcasts a `Bool` through `completedSubject` when the deadline is reached (`true`) or the client called `stop()` (`false`).
/// - bug: The count-up should also stop the clock when a deadline is reached.
final class MinutePublisher: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Publishers
    /// Subscribers get a `Bool` input when the deadline arrives (`true`) or the client calls `.stop()` (`false`). The `Bool` is true iff the clock ran out and nit cancalled.

    @Published var isRunning = false
    // MARK: @Published
    /// Minutes until deadline
    @Published public var minutes: Int = 0
    /// Seconds-in-minute until deadline
    @Published public var seconds: Int = 0
    /// Fractions-in-second until deadline
    @Published public var fraction: Double = 0.0
    /// Formatted `mm:ss` until deadline
    @Published public var minuteColonSecond: String = ""

    /*
     It appears no clients use speakableInterval.
     @Published public var speakableInterval: String = ""
     */

    // MARK: Initialization

    /// The deadline for ending the countdown
    private let countdownTo: Date?
    /// Initialize a countdown toward a future date, or a count-up from the present.
    /// - parameter date: The deadline as `Date` to count down to. If `nil` (the default), the clock counts up indefinitely from the current date.
    init(to date: Date? = nil) {
        countdownTo = date
        isRunning = false
    }

    /// Initialize a count**down** to a future time that is a certain interval from now.
    /// - parameter interval: The **TimeInterval** between now and the time to which the clock will count down.
    convenience init(after interval: TimeInterval) {
        let date = Date(timeIntervalSinceNow: interval)
        self.init(to: date)
    }

    /// The `Date` at which `start()` commenced the count. Used only as a reference point for counting up.
    private var dateStarted: Date!
}


// MARK: - Combine
extension MinutePublisher {
    // MARK: Root publisher
    /// The root time publisher for a `Timer` signaling every `0.01 ± 0.03` seconds.
    ///
    /// `TimePublisher.Output` is `Date`. This is translated to time interval before `countdownTo`. It is `autoconnect`, `share`, and erased to `AnyPublisher<TimeInterval, Never>`.
    ///
    /// - note: This publisher does not escape `setUpCombine`. Clients should subscribe to the `@Published` time components instead.
    private func setUpTimerPublisher() -> AnyPublisher<TimeInterval, Never> {
        let timeToSeconds = Timer.publish(
            every: 0.01, tolerance: 0.03,
            on: .current, in: .common)
            .autoconnect()

        // Debugging: Intercept cancellations
            .handleEvents(receiveCancel: {
                print(#function, "Main publisher was cancelled.")
                print()
            })

        // Date → downward TimeInterval
            .map {
                currentDate -> TimeInterval in
                if let remote = self.countdownTo {
                    if currentDate >= remote { self.stop() }
                    return -currentDate
                        .timeIntervalSince(remote)
                }
                else {
                    return currentDate
                        .timeIntervalSince(self.dateStarted)
                }
            }
            .share()
            .eraseToAnyPublisher()
        return timeToSeconds
    }

    // MARK: Derived publishers

    /// Builds on the basic countdown interval from ``setUpSecondsPublisher()`` to publish time components and a `mm:ss` string.
    /// - warning: do not confuse with ``CountdownController/setUpCombine()``.
    func setUpCombine() {
        // Input is Timer, Output is is TimeInterval to deadline.
        let timeToSeconds = setUpTimerPublisher()

        // Emit fractions
        timeToSeconds
            .map { $0 - Double(Int($0)) }
            .assign(to: \.fraction, on: self)
            .store(in: &cancellables)

        // Emit seconds
        timeToSeconds
            .map { Int($0) % 60 }
            .removeDuplicates()
            .assign(to: \.seconds, on: self)
            .store(in: &cancellables)

        // Emit minutes
        timeToSeconds
            .map { Int($0) / 60 }
            .removeDuplicates()
            .assign(to: \.minutes, on: self)
            .store(in: &cancellables)

        // Emit "mm:ss"
        timeToSeconds
            .map { (commonSeconds: TimeInterval) -> MinSecondPair in // (m: Int, s: Int) in
                return MinSecondPair(interval: commonSeconds)
            }
            .map { minSec -> String in
                minSec.description
            }
            .removeDuplicates()
            .assign(to: \.minuteColonSecond, on: self)
            .store(in: &cancellables)

        /*
         No callers use speakableInterval.

         timeToSeconds
         .map { (commonSeconds: TimeInterval) -> MinSecondPair in // (m: Int, s: Int) in
         return MinSecondPair(interval: commonSeconds)
         }
         .map { minSec -> String in
         minSec.speakableDescription
         }
         .removeDuplicates()
         .assign(to: \.speakableInterval, on: self)
         .store(in: &cancellables)
         */

    }

    // MARK: - start
    /// Set up internal subscriptions to (ultimately) the `Timer.Publisher`, and start counting down to the deadline.
    public func start() {
        dateStarted = Date()
        setUpCombine()
        isRunning = true
    }

    // MARK: Stop
    /// Halt the clock and send a `Bool` to `completedSubject` to indicate exhaustion or halt.
    ///
    /// - parameter exhausted: `true` iff `stop()` was called because the clock ran out. This is passed along through `completedSubject` to inform clients the clock is finished.
    public func stop(exhausted: Bool = true) {
        guard isRunning else {
            assert(isRunning, "\(#function) got a repeated stop message.")
            print(#function, "- double stop")
            return
        }
        for c in cancellables {
            c.cancel()
        }
        isRunning = false
    }
}
