//
//  Formatting+Extensions.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/14/22.
//

import Foundation

let _leadingZeroFmt: NumberFormatter = {
    let retval = NumberFormatter()
    retval.minimumIntegerDigits = 2
    retval.maximumFractionDigits = 0
    return retval
}()

let _spelledFmt: NumberFormatter = {
    let retval = NumberFormatter()
    return retval
}()

extension BinaryInteger {
    /// The integer formatted to be at least two digits long, with leading zeros if necessary.
    public var twoZeros: String {
        _leadingZeroFmt.string(from: self as! NSNumber)!
    }

    /// The integer formatted into natural language.
    public var spelled: String {
        _spelledFmt.string(from: self as! NSNumber)!
    }
}

private let _pointThree: NumberFormatter = {
    let retval = NumberFormatter()
    retval.minimumIntegerDigits = 1
    retval .minimumFractionDigits = 3
    retval.maximumFractionDigits  = 3
    return retval
}()

private let _pointFive: NumberFormatter = {
    let retval = NumberFormatter()
    retval.minimumIntegerDigits = 1
    retval .minimumFractionDigits = 5
    retval.maximumFractionDigits  = 5
    return retval
}()

private let _rounded: NumberFormatter = {
    let retval = NumberFormatter()
    retval.minimumIntegerDigits = 1
    retval .minimumFractionDigits = 0
    retval.maximumFractionDigits  = 0
    return retval
}()

extension BinaryFloatingPoint {
    var pointThree: String {
        _pointThree.string(from: self as! NSNumber)!
    }

    var pointFive: String {
        _pointFive.string(from: self as! NSNumber)!
    }

   /// Render a `BinaryFloatingPoint` (_e.g._`Double`) as a spelled-out `String`
    var spelled: String {
        let asSeconds = Int(Double(self).rounded())
        return asSeconds.spelled
    }

    var rounded: String {
        _rounded.string(from: self as! NSNumber)!
    }
}

private let isoFormatter: ISO8601DateFormatter = {
    let retval = ISO8601DateFormatter()
    retval.formatOptions = .withInternetDateTime
    return retval
}()

extension Date {
    public var iso: String {
        isoFormatter.string(from: self)
    }

    static let y1960: Date = {
        let gregorian = Calendar(identifier: .gregorian)
        let components = DateComponents(
            calendar: gregorian,
            timeZone: TimeZone(abbreviation: "GMT"),
            year: 1960)
        guard let y1960 = gregorian.date(from: components) else {
            fatalError("\(#function) - couldn't get date since 1960.")
        }
        return y1960
    }()

    public var timeIntervalSince1960: TimeInterval {
        return Date().timeIntervalSince(Self.y1960)
    }
}

extension String {
    public var addControlCharacters: String {
        // first, newlines
        let nlLines = self.split(separator: "|", omittingEmptySubsequences: false)
        let nlJoined = nlLines.joined(separator: "\n")

        let tabLines = nlJoined.split(separator: "^", omittingEmptySubsequences: false)
        let tabJoined = tabLines.joined(separator: "\t")

        return tabJoined
    }
}
