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
 - ``refreshPublisher()``
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
    /// Minutes until deadline
    @Published public var minutes: Int = 0
    /// Seconds-in-minute until deadline
    @Published public var seconds: Int = 0

    @Published public var minsSecs: MinSecondPair

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
    private var countdownTo: Date?
    /// Initialize a countdown toward a future date, or a count-up from the present.
    /// - parameter date: The deadline as `Date` to count down to. If `nil` (the default), the clock counts up indefinitely from the current date.

    private var countdownDuration: TimeInterval
    /// Initialize a count**down** to a future time that is a certain interval from now.
    /// - parameter interval: The **TimeInterval** between now and the time to which the clock will count down.
    init(duration: TimeInterval) {
        countdownDuration = duration
        minsSecs = MinSecondPair(interval: duration)
        isRunning = false
        countdownTo = nil
    }

    private var secondsPublisher: TIPublisher!
}


// MARK: - Combine
extension MinutePublisher {
    // MARK: Root publisher

    typealias TIPublisher  = AnyPublisher<TimeInterval, Never>
//    typealias CTIPublisher = Publishers.MakeConnectable<TIPublisher>

    /// The root time publisher for a `Timer` signaling every `0.01 ± 0.03` seconds.
    ///
    /// `TimePublisher.Output` is `Date`. This is translated to time interval before `countdownTo`. It is `autoconnect`, `share`, and erased to `AnyPublisher<TimeInterval, Never>`.
    ///
    /// - note: This publisher does not escape `refreshPublisher`. Clients should subscribe to the `@Published` time components instead.
    private func setUpSecondsPublisher() -> TIPublisher {
        let timeToSeconds = Timer.publish(
            every: 0.01, tolerance: 0.03,
            on: .current, in: .common)
            .autoconnect()

        // Debugging: Intercept cancellations
//            .handleEvents(receiveCancel: {
//                print(#function, "Main publisher was cancelled.")
//            })
            .compactMap { currentDate -> (current: Date, future: Date)? in
                guard let countdown = self.countdownTo else { return nil }
                return (current: currentDate, future: countdown)
            }
            .map {
                // TODO: A tryMap?
                // Date → downward TimeInterval
                (current: Date, future: Date) -> TimeInterval in
                guard current <= future else {
                    self.stop(exhausted: true)
                    return 0.0
                }
                let retval = -current
                    .timeIntervalSince(future)
                return retval
            }
            .share()
            .eraseToAnyPublisher()
        return timeToSeconds
    }

    // MARK: Derived publishers

//    private var secondsPublisher: MinutePublisher!
    /// Builds on the basic countdown interval from ``setUpSecondsPublisher()`` to publish time components and a `mm:ss` string.
    /// - warning: do not confuse with ``CountdownController/setUpCombine()``.
    func refreshPublisher() {
        // Input is Timer, Output is is TimeInterval to deadline.
        secondsPublisher = setUpSecondsPublisher()

        secondsPublisher.map {
           return MinSecondPair(interval: $0)
        }
        .removeDuplicates()
        .assign(to: \.minsSecs , on: self)
        .store(in: &cancellables)

        secondsPublisher.map {
            interval in
            return interval - Darwin.trunc(interval)
        }
        .assign(to: \.fraction, on: self)
        .store(in: &cancellables)

        // Emit integer seconds within minute
        secondsPublisher.map { (commonSeconds: TimeInterval) -> Int in
            let minimumSeconds = Int(trunc(commonSeconds))
            return minimumSeconds % 60
        }
        .removeDuplicates()
        .assign(to: \.seconds, on: self)
        .store(in: &cancellables)

        // Emit integer minutes
        secondsPublisher.map { (commonSeconds: TimeInterval) -> Int in
            let minimumSeconds = Int(trunc(commonSeconds))
            return minimumSeconds / 60
        }
        .removeDuplicates()
        .assign(to: \.minutes, on: self)
        .store(in: &cancellables)

        // Emit "mm:ss"
        secondsPublisher
            .map { (commonSeconds: TimeInterval) -> MinSecondPair in
                return MinSecondPair(interval: commonSeconds)
            }
            .map { $0.description }
            .removeDuplicates()
            .assign(to: \.minuteColonSecond, on: self)
            .store(in: &cancellables)
    }

    // MARK: - start
    /// Set up internal subscriptions to (ultimately) the `Timer.Publisher`, and start counting down to the deadline.
    public func start() {
        let deadline = Date(timeIntervalSinceNow: countdownDuration)
        countdownTo = deadline
        refreshPublisher()

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
