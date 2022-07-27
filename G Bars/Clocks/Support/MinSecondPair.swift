//
//  MinSecondPair.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/26/22.
//

import Foundation

/// Time interval expressed as integer minutes and seconds.
struct MinSecondPair: Codable, Hashable {
    var minutes, seconds: Int

    static let zero = MinSecondPair(minutes: 0, seconds: 0)

    /// Initialize from minutes and seconds
    internal init(minutes: Int, seconds: Int) {
        self.minutes = minutes
        self.seconds = seconds
    }

    /// Initialize from integer seconds
    internal init(seconds: Int) {
        self.init(minutes: seconds/60, seconds: seconds%60)
    }

    /// Initialize from floating-point (`TimeInterval`)  seconds
    ///
    /// The interval will be truncated and cast to `Int`: 9.75 seconds → 9.0, not 10.0
    internal init(interval: TimeInterval) {
        assert(interval < 3600.0)
        let intInterval = Int(trunc(interval))
        self.init(minutes: intInterval/60,
                  seconds: intInterval%60)
    }

    /// The interval in seconds without carrying into `minutes`.
    var asSeconds: Int {
        return 60 * minutes + seconds
    }
}

// MARK: Comparable
extension MinSecondPair: Comparable {   // And Hashable
    /// `Equatable`: `true` iff the two operands have the same `minutes` and `seconds` attributes.
    static func == (lhs: MinSecondPair, rhs: MinSecondPair) -> Bool {
        lhs.minutes == rhs.minutes && lhs.seconds == rhs.seconds
    }

    /// `Comparable`: `true` iff the first operand should sort before the second.
    static func < (lhs: MinSecondPair, rhs: MinSecondPair) -> Bool {
        if lhs.minutes < rhs.minutes { return true }
        if lhs.minutes == rhs.minutes {
            return lhs.seconds < rhs.seconds
        }
        return false
    }

    var isZero: Bool {
        return minutes == 0 && seconds == 0
    }
}

// MARK: String Convertible
extension MinSecondPair: CustomStringConvertible {
    /// `CustomStringConvertible`: A string rendering of `mm:ss`
    var description: String {
        try! MinSecFormatter.withMinutesStrategy(
            minutes: minutes, seconds: seconds)
    }

    /// The value of self in a form suitable for TTS: "one minute, thirty-five seconds".
    var speakableDescription: String {
        if self.isZero { return "zero" }
        return spokenInterval(minutes: minutes, seconds: seconds)
    }
}

// MARK: - Arithmetic
extension MinSecondPair {
    // TODO: (Exciting Future Direction): AdditiveArithmetic.

    // MARK: Signed Numeric
    mutating func negate() {
        minutes = -minutes; seconds = -seconds
    }

    prefix static func - (operand: MinSecondPair) -> MinSecondPair {
        var copy = operand
        copy.negate()
        return copy
    }

    // MARK: AdditiveArithmetic (sort of)

    /// The sum of a `MinSecondPair` and an integral number of seconds.
    static func + <I: SignedInteger>(addend: MinSecondPair, rhs: I) -> MinSecondPair {
        if rhs == 0 { return addend }

        var newMinutes = addend.minutes
        var newSeconds = addend.seconds + numericCast(rhs)
        if newSeconds >=  60 {
            newSeconds -= 60; newMinutes += 1
        }
        else if newSeconds < 0 {
            newSeconds += 60; newMinutes -= 1
        }
        return MinSecondPair(minutes: newMinutes, seconds: newSeconds)
    }

    /// Increment a `MinSecondPair`  by an integral number of seconds.
    static func += <I: SignedInteger>(addend: inout MinSecondPair, rhs: I) {
        addend = addend + rhs
    }

    /// A `MinSecondPair` decremented by an integral number of seconds.
    static func - <I: SignedInteger>(minuend: MinSecondPair, subtrahend: I) -> MinSecondPair {
        return minuend + -(subtrahend)
    }

    /// Decrement a `MinSecondPair` by an integral number of seconds.
    static func -= <I: SignedInteger>(minuend: inout MinSecondPair, subtrahend: I) {
        minuend = minuend - subtrahend
    }
}

// MARK: - Sequence
extension MinSecondPair: Sequence {
    /// `Sequence` adoption: Create an iterator from `self`.
    func makeIterator() -> some IteratorProtocol {
        return MinSecIterator(self)
    }

    /// A `Sequence` iterator starting from the given `MinSecondPair` and incrementing at each iteration.
    struct MinSecIterator: IteratorProtocol {
        var currentMinSec: MinSecondPair
        init(_ current: MinSecondPair) {
            currentMinSec = current
        }

        mutating func next() -> MinSecondPair? {
            currentMinSec += 1
            return currentMinSec
        }
    }
}

