//
//  SubjectID.swift
//  G Bars
//
//  Created by Fritz Anderson on 6/30/22.
//

import Foundation
import SwiftUI

/*
 I haven’t figured out how or whether to make the subjectID an @Environment variable.

 It's View-scoped anyway; no effect outside a View struct.
 */
private struct SubjectIDEnvironmentKey: EnvironmentKey {
    static let defaultValue: String = ""
}

extension EnvironmentValues {
    var subjectID: String {
        get { self[SubjectIDEnvironmentKey.self] }
        set { self[SubjectIDEnvironmentKey.self] = newValue }
    }
}

/*
 Stage hierarchy
 (great temptation to make a ResultBuilder of this,
 but I'd never use it. Better to have each series and
 the upper layer do their own sequencing.

 SubjectID sheet (if there is no subject ID)
 {
    Onboard Series
        Page numbers
    - or -
    Return Series
        Page numbers   (page back and forth)
 }

 BACKGROUND: Collect the previous week's pedometry.

 Walk Series    NO(?) suspensions, resets the whole series
                Therefore the right-up arrows from walks
                should be taken as suspensions
    intro           ↰   (paging)
    countdown_1     ⬏
    walk_1          ⇥
    interstitial    ↰   (paging)
    countdown_2     ⬏
    walk_2          ⇥
    Dismissal           (paging? Series complete.)
                        There's no cancellation here,
                        and no do-over for the whole series
   (optional) debug-review page (no do-over

 DASI Series
    intro
    questions           (paging)
    dismissal           (backing? Series complete.)

 Usability Series
     intro              (no exit)
     questions          (paging)
     "free-form"        May be paging.
     dismissal          (no backing? Series complete.)

 General dismissal.

 BACKGROUND: Aggregate all results, then transmit.
             I HAVE A PROBLEM in that I'd really prefer
             doing an upload rather than a data transfer.
             It's insurance against network faults.
             HOWEVER: You can rely on the subject restarting
             the app, and therefore provide an opportunity
             to catch up with unfinished files.
 */


/*
 ONE IDEA: Standardize the stages (e.g. protocol)
 so each container reports to its parent how it ended.
 The parent can then handle normal/exceptional staging.
 */

protocol StageContaining { // no associated
    func substageCompleted(id: Int, normal: Bool)
}

protocol StageContainment { // no associated
    associatedtype Substage
    func substage(_: Substage, completedNormally: Bool)
}

protocol Contained {
    associatedtype GoodResult
    // maybe a status? Result<V>?
}

// Can there be a non-associated-type way to do this?
protocol ContainmentStaging {
    func substage<T>(type: T.Type,
                     completedNormally: Bool)
    where T: Contained
}

protocol AnyStaging {
    associatedtype GoodResult
    func substage<Sub>(_: Sub,
                     completed: Result<Sub.GoodResult, Error>)
    where Sub: Contained
}
// Suppose there are more than one substage types.
// Suppose they have different GoodResult types.


/*
 Additional question:
 Can this hierarchical principle figure out cancellations?
 */


enum AppStorageKeys: String {
    // FIXME: Big mess.
    //        MinutePublisher sometimes wants seconds, sometimes minutes.
    /// How long the timed walk is to last, in _minutes,_ e.g. 6.
    case walkInMinutes
    /// The frequency in Hertz (e.g. 120) for sampling the accelerometer.
    case walkSamplingRate
    /// If `false`, report acceleration in three axes; otherwise as the vector magnitude.
    case reportAsMagnitude
    /// Whether to include the timed walk
    case includeWalk
    /// Whether to include the DASI survey
    case includeSurvey
    /// The last known subject ID.
    case subjectID

    case wantsSpeech

    /// Array of raw values of ApplicationState to persist the user's progress
    case stateCompletion
    case selectedTab

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
