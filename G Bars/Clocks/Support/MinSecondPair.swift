//
//  MinSecondPair.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/26/22.
//

import Foundation

struct MinSecondPair: Comparable, Codable, CustomStringConvertible, Hashable {
    let minutes, seconds: Int

    static let zero = MinSecondPair(minutes: 0, seconds: 0)

    internal init(minutes: Int, seconds: Int) {
        self.minutes = minutes
        self.seconds = seconds
    }

    internal init(interval: TimeInterval) {
        assert(interval < 3600.0)
        let intInterval = Int(trunc(interval))
        self.init(minutes: intInterval/60,
                  seconds: intInterval%60)
    }

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

    var description: String {
       try! MinSecFormatter.withMinutesStrategy(
            minutes: minutes, seconds: seconds)
    }

    var speakableDescription: String {
        if self == .zero { return "zero" }
        return spokenInterval(minutes: minutes, seconds: seconds)
    }
}
