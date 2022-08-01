//
//  SubjectID.swift
//  G Bars
//
//  Created by Fritz Anderson on 6/30/22.
//

import Foundation
import SwiftUI
import Combine

enum AppStorageKeys: String {
    // FIXME: Big mess.
    //        MinutePublisher sometimes wants seconds, sometimes minutes.
    /// How long the timed walk is to last, in _minutes,_ e.g. 6.
    case walkInMinutes
    /// The frequency in Hertz (e.g. 120) for sampling the accelerometer.
    case walkSamplingRate
    /// If `false`, report acceleration in three axes; otherwise as the vector magnitude.
    case reportAsMagnitude
    /// The email address to receive report archive files.
    case reportingEmail
    /// Whether to include the timed walk
    case includeWalk
    /// Whether to include the DASI survey
    case includeSurvey
    /// The last known subject ID.
    case subjectID

    case wantsSpeech

    static let dasiWalkRange = (1...10)
}


final class SubjectID: ObservableObject {
    static let shared = SubjectID()

    @Published var subjectID: String? {
        didSet {
            UserDefaults.standard
                .set(subjectID,
                     forKey: AppStorageKeys.subjectID.rawValue)
        }
    }

    private init() {
        subjectID = UserDefaults.standard
            .string(forKey: AppStorageKeys.subjectID.rawValue)
        ?? "N/A"
    }
}
