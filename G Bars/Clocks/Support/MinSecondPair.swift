//
//  MinSecondPair.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/26/22.
//

import Foundation

/// Time interval expressed as integer minutes and seconds.
struct MinSecondPair: Codable, Hashable {
    let minutes, seconds: Int

    static let zero = MinSecondPair(minutes: 0, seconds: 0)

    internal init(minutes: Int, seconds: Int) {
        self.minutes = minutes
        self.seconds = seconds
    }

    internal init(seconds: Int) {
        self.init(minutes: seconds/60, seconds: seconds%60)
    }

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

extension MinSecondPair: Comparable {   // And Hashable
    static func == (lhs: MinSecondPair, rhs: MinSecondPair) -> Bool {
        lhs.minutes == rhs.minutes && lhs.seconds == rhs.seconds
    }

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

extension MinSecondPair: CustomStringConvertible {
    var description: String {
        try! MinSecFormatter.withMinutesStrategy(
            minutes: minutes, seconds: seconds)
    }

    var speakableDescription: String {
        if self.isZero { return "zero" }
        return spokenInterval(minutes: minutes, seconds: seconds)
    }
}

// MARK: - Arithmetic
extension MinSecondPair {
    // TODO: (Exciting Future Direction): AdditiveArithmetic.

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

    static func += <I: SignedInteger>(addend: inout MinSecondPair, rhs: I) {
        addend = addend + rhs
    }

    static func - <I: SignedInteger>(minuend: MinSecondPair, subtrahend: I) -> MinSecondPair {
        return minuend + -(subtrahend)
    }

    static func -= <I: SignedInteger>(minuend: inout MinSecondPair, subtrahend: I) {
        minuend = minuend - subtrahend
    }
}

extension MinSecondPair: Sequence {
    func makeIterator() -> some IteratorProtocol {
        return MinSecIterator(self)
    }

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

