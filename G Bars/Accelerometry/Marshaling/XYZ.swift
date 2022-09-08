//
//  XYZ.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/13/22.
//

import Foundation
import CoreMotion
//import CoreMotion



public protocol CSVRepresentable {
    var csvLine: String { get }
}


// MARK: - Timestamped
extension CMLogItem {
    @objc
    public var csvLine: String {
        timestamp.csvLine
    }
}

public protocol Timestamped {
    var timestamp: TimeInterval { get }
}

extension Double: CSVRepresentable {
    public var csvLine: String { self.pointFive }
}

extension Float: CSVRepresentable {
    public var csvLine: String { Double(self).csvLine }
}

extension String: CSVRepresentable {
    public var csvLine: String {
        #""\#(self)""#
    }
}

// MARK: - XYZ
public protocol XYZ: CSVRepresentable {
    var x: Double { get }
    var y: Double { get }
    var z: Double { get }
}

extension XYZ {
    var csvLine: String {
        [x, y, z].map(\.csvLine).joined(separator: ",")
    }
}


extension Array where Element: CSVRepresentable {
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



/*
 public protocol CSVRepresentable {
    var csvLine: String { get }
}

*/
