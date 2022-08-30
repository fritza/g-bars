//
//  G_BarsApp.swift
//  G Bars
//
//  Created by Fritz Anderson on 6/29/22.
//

import SwiftUI


/*

 FIXME: SwiftUI @Environment(\.managedObjectContext)
        It's get/set, seems to have no clients but the coder.



 */

enum Constants {
#if DEBUG
    static let countdownDuration    = 15.0
#else
    static let countdownDuration    = 120.0
#endif

    static let countdownInterval    = 10
    static let sweepDuration        = 5.0
}

enum LastPassCreds {
    static let userID      = "iosuser"
    static let password    = "Daf4Df24fshfg"
    static let lastPassName = "ios-s3-apidev"

    static let methodName = "POST"

    static let uploadString    = "https://ios-s3-apidev.uchicago.edu/api/upload"
    static let uploadURL = URL(fileURLWithPath: uploadString)

    static let reviewPage = "https://ios-s3-apidev.uchicago.edu/files/"
    static let reviewURL = URL(fileURLWithPath: reviewPage)
}

// FIXME: Reconstitute from whatever storage we use.
let rootResponseStatus =  DASIResponseStatus()
let dasiPages = DASIPages()

import Accelerate
// MARK: - App
@main
struct G_BarsApp: App {
    // TODO: Remove?
    @AppStorage(AppStorageKeys.wantsSpeech.rawValue) private var app_speech = true

    init() {
        app_speech = true
    }

    //    var selectedTab = 0
    @State var selectedTab: Int = 0
    @State var timerRunning = false

    func accelerometerTestData() -> Store2D {
        let timePerTick = 1.0 / 60.0
        let ts = vDSP.ramp(withInitialValue: 0.0, increment: timePerTick, count: 1000)
        let vs = vDSP.ramp(withInitialValue: 3.22, increment: 0.02, count: 1000)
        let sines = vForce.sin(vs)
        let boostSines = vDSP.multiply(6.6, sines)
        let testData = zip(ts, boostSines).map { Datum2D(t: $0.0, x: $0.1) }
        return Store2D(testData)
    }

    var body: some Scene {
        // Create a WindowGroup depicting the single view
        WindowGroup {
#if false
            NavigationView {
                WalkingContainerView()
                .padding()
                .navigationTitle("Walking Info")
            }
#else
            TabView(selection: $selectedTab) {
                // MARK: Walking workflow
//                NavigationView {
//                    WalkingContainerView()
//                    // FIXME: Move padding to container view
//                        .padding()
//                        .navigationTitle("Walking Info")
//                }

                    WalkingContainerView()
                    // FIXME: Move padding to container view
                        .padding()
                        .navigationTitle("Walking Info")

                .tabItem {
                    Label("Walking",
                          systemImage: "figure.walk")
                }


                // MARK: DASI Survey
                NavigationView { SurveyContainerView() }
                    .tabItem { Label("DASI",
                                     systemImage: "checkmark.square") }

                // MARK: Usability Survey
                NavigationView { UsabilityContainer() }
                    .tabItem { Label("Usability",
                                     systemImage: "checkmark.circle")
                    }
            }
            .symbolRenderingMode(.hierarchical)
            .navigationBarBackButtonHidden(true)

            .environmentObject(ApplicationState())
            .environmentObject(dasiPages)
            .environmentObject(rootResponseStatus)
            .environmentObject(UsabilityController())
            .environmentObject(SubjectID.shared)
#endif
        }
        }
}
