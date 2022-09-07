//
//  XYZ.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/22.
//

import Foundation
//import CoreMotion



protocol CSVRepresentable {
    var csvLine: String { get }
}


/*
 // MARK: - Timestamped
 public protocol Timestamped: CSVConvertible {
 var timestamp: TimeInterval { get }
 }

 extension Timestamped {
 public var csvLine: String {
 timestamp.csvLine
 }
 }

public protocol CSVConvertible {
    var csvLine: String { get }
}

// MARK: - XYZ
public protocol XYZ: CSVConvertible {
    var x: Double { get }
    var y: Double { get }
    var z: Double { get }
}

extension XYZ {
    var csvLine: String {
        [x, y, z].map(\.csvLine).joined(separator: ",")
    }
}

extension Double: CSVConvertible {
    public var csvLine: String { self.pointFive }
}

extension Float: CSVConvertible {
    public var csvLine: String { Double(self).csvLine }
}

extension String: CSVConvertible {
    public var csvLine: String {
        #""\#(self)""#
    }
}

extension Array where Element: CSVConvertible {
    public var csvLine: String {
        let consolidated = self.map { element -> String in
            switch element {
            case is String:
                return element as! String
            default: return element.csvLine
            }
        }
        return consolidated.joined(separator: ",")
    }
}
*/
