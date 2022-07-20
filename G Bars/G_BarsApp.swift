//
//  G_BarsApp.swift
//  G Bars
//
//  Created by Fritz Anderson on 6/29/22.
//

import SwiftUI


// FIXME: Reconstitute from whatever storage we use.
let rootResponseStatus =  DASIResponseStatus()
let dasiPages = DASIPages()

//let countdownController = CountdownController(forCountdown: true)

//@AppStorage(AppStorageKeys.subjectID.rawValue) var subjectID = "Subject ID not for publication."



import Accelerate
// MARK: - App
@main
struct G_BarsApp: App {
    let countdownController: CountdownController

    init() {
        #warning("initialization of CountdownController belongs elsewhere")
        countdownController = CountdownController(duration: 10)
    }

//    var selectedTab = 0
    @State var selectedTab: Int = 0

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
                VStack {
                    Text("DigitalTimerView goes here")
                }
                .navigationTitle("Digital Countdown")
                .environmentObject(countdownController)
            }
#elseif false
            NavigationView {
                VStack {
                    SweepSecondView()
                }
                .environmentObject(
                    countdownController
                )
            }
#else
            TabView(selection: $selectedTab) {
                // MARK: Acceleration Bars
                NavigationView { AcccelerometryView() }
                    .tabItem { Label("Acceleration",
                                     systemImage: "move.3d") }

                // MARK: DASI Survey
                NavigationView { SurveyContainerView() }
                    .tabItem { Label("DASI",
                                     systemImage: "checkmark.square") }

                // MARK: Usability Survey
                NavigationView { UsabilityContainer() }
                    .tabItem { Label("Usability",
                                     systemImage: "checkmark.circle")
                    }

                // MARK: Sweep-second disk
                NavigationView { SweepSecondView() }
                    .tabItem { Label("Sweep",
                                     systemImage: "timer")
                    }

                // MARK: Digital countdown
                NavigationView {
                    DigitalTimerView()
//                    Text("MinuteCountdownView goes here")
                }
                    .tabItem { Label("Digital",
                                     systemImage: "clock")
                    }
            }
            .symbolRenderingMode(.hierarchical)
            .navigationBarBackButtonHidden(true)

            .environmentObject(dasiPages)
            .environmentObject(rootResponseStatus)
            .environmentObject(UsabilityController())

            .environmentObject(countdownController)
            .environmentObject(SubjectID.shared)
#endif
        }
    }
}
