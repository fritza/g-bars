//
//  UsabilityQuestions.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/11/22.
//

import Foundation
import UIKit

struct UsabilityQuestion: Decodable, Identifiable {
    // MARK: - Type properties
    private static let baseFileName = "USurveyQuestions"

    static let startIndex = 0
    static var endIndex: Int { allQuestions.count }
    static private(set) var indexRange = 0..<endIndex

    static let startID = 1
    static var endID: Int { endIndex + 1 }
    static private(set) var idRange = 0..<endID
    static var count = allQuestions.count


    // I'm not going to get in trouble by referencing the indices
    // before allQuestions loads, am I?
    static let allQuestions: [UsabilityQuestion] = {
        guard let fileURL = Bundle.main.url(forResource: baseFileName, withExtension: "json") else {
            assertionFailure("\(#function) - could not find \(baseFileName).json")
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let retval = try JSONDecoder()
                .decode([UsabilityQuestion].self, from: data)
            return retval
        }
        catch {
            fatalError("OS-level trouble finding/decoding \(baseFileName).json: \(error.localizedDescription)")
        }
    }()

    static subscript(id: Int) -> UsabilityQuestion {
        allQuestions.first(where: { $0.id == id } )!
    }

    // MARK: - Instance properties
    let id: Int
    let text: String
}


