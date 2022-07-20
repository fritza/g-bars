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

// MARK: - MinutePublisher
/// Publisher of components of `Timer` ticks in integer minutes and seconds; and `Double` subseconds, counting up or down.
///
/// Countdown timers run down to a specified deadline into the future. Count-up timers run indefinitely (but see **Bug**).
///
/// `MinutePublisher` broadcasts a `Bool` through `completedSubject` when the deadline is reached (`true`) or the client called `stop()` (`false`).
/// - bug: The count-up should also stop the clock when a deadline is reached.
final class MinutePublisher: ObservableObject {
    var cancellables: Set<AnyCancellable> = []

    var isRunning = false

    // MARK: Subjects
    /// Subscribers get a `Bool` input when the deadline arrives (`true`) or the client calls `.stop()` (`false`). The `Bool` is true iff the clock ran out and nit cancalled.
    public var completedSubject = PassthroughSubject<Bool, Never>()
    // TODO: Replace with a @Published Bool, isRunning?

    /// The root time publisher for a `Timer` signaling every `0.01 ± 0.03` seconds.
    ///
    /// Clients do not see this publisher; they should subscribe to the `@Published` time components instead.
    private let timePublisher = Timer.publish(
        every: 0.01, tolerance: 0.03,
        on: .current, in: .common)

    // MARK: @Published
    /// Minutes until deadline
    @Published public var minutes: Int = 0
    /// Seconds-in-minute until deadline
    @Published public var seconds: Int = 0
    /// Fractions-in-second until deadline
    @Published public var fraction: Double = 0.0
    /// Formatted `mm:ss` until deadline
    @Published public var minuteColonSecond: String = ""

    // MARK: Initialization

    /// The deadline for ending the countdown
    private let countdownTo: Date?
    /// Initialize a countdown toward a future date, or a count-up from the present.
    /// - parameter date: The deadline as `Date` to count down to. If `nil` (the default), the clock counts up indefinitely from the current date.
    init(to date: Date? = nil) {
        countdownTo = date
        isRunning = false
    }

    deinit {
        print("MinutePublisher deallocated.")
    }

    /// Initialize a count**down** to a future time that is a certain interval from now.
    /// - parameter interval: The interval between now and the time to which the clock will count down.
    convenience init(after interval: TimeInterval) {
        let date = Date(timeIntervalSinceNow: interval)
        self.init(to: date)
    }

    /// The `Date` at which `start()` commenced the count. Used only as a reference point for counting up.
    private var dateStarted: Date!
    /// The time publisher, converted to emitting a `TimeInterval` between now and the deadline.
    private var commonPublisher: AnyPublisher<TimeInterval, Never>!

    // MARK: start
    /// Set up internal subscriptions to (ultimately) the `Timer.Publisher`, and start counting down to the deadline.
    public func start() {
        dateStarted = Date()

        // Subscribe to the timer, correct to count-down or -up, and check for deadlines.
        commonPublisher = timePublisher
            .autoconnect()
            .handleEvents(receiveCancel: {
                print("Cancel on the common publisher.")
            }
            )
//            .print("common publisher")
            .map {
                currentDate -> TimeInterval in
                if let remote = self.countdownTo {
                    if currentDate >= remote { self.stop() }
                    return -currentDate.timeIntervalSince(remote)
                }
                else {
                    return currentDate.timeIntervalSince(self.dateStarted)
                }
            }
            .share()
            .eraseToAnyPublisher()

        // Emit fractions
        commonPublisher
            .map {
                $0 - Double( Int($0) )
            }
        // Known to get downstream from the publisher
            .sink { fraction in
                self.fraction = fraction
            }
            .store(in: &cancellables)

        // Emit seconds
        commonPublisher
            .map { Int($0) % 60 }
            .removeDuplicates()
            .sink { seconds in
                self.seconds = seconds
            }
            .store(in: &cancellables)

        // Emit minutes
        commonPublisher
            .map { Int($0) / 60 }
            .removeDuplicates()
            .sink { minutes in
                self.minutes = minutes
            }
            .store(in: &cancellables)

        // Emit "mm:ss"
        commonPublisher
            .map { (commonSeconds: TimeInterval) -> (m: Int, s: Int) in
                let dblMin = (commonSeconds / 60.0).rounded(.towardZero)
                let dblSec = (commonSeconds.rounded(.towardZero)).truncatingRemainder(dividingBy: 60.0)
                return (m: Int(dblMin), s: Int(dblSec))
            }
            .map { msPair -> String in
                let (m, s) = msPair
                let mString = String(m)
                var sString = String(s)
                if sString.count < 2 { sString = "0" + sString }

                return "\(mString):\(sString)"
            }
            .removeDuplicates()
            .sink {
                self.minuteColonSecond = $0
            }
            .store(in: &cancellables)
        isRunning = true
    }

    // MARK: Stop
    /// Halt the clock and send a `Bool` to `completedSubject` to indicate exhaustion or halt.
    ///
    /// - parameter exhausted: `true` iff `stop()` was called because the clock ran out. This is passed along through `completedSubject` to inform clients the clock is finished.
    public func stop(exhausted: Bool = true) {
        guard isRunning else {
            print(#function, "- double stop")
            return
        }
        for c in cancellables {
            c.cancel()
        }
        completedSubject.send(exhausted)
    }
}

