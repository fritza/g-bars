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

//@AppStorage(AppStorageKeys.subjectID.rawValue) var subjectID = "Subject ID not for publication."

// MARK: - App
@main
struct G_BarsApp: App {
    @State var selectedTab: Int = 0
//    @State var yesNoState: Int = 1

    var body: some Scene {
        // Create a WindowGroup depicting the single view
        WindowGroup {
            TabView(selection: $selectedTab) {
                // MARK: Acceleration Bars
                NavigationView { AcccelerometryView() }
                    .tabItem { Label("Acceleration", systemImage: "move.3d") }

                // MARK: DASI Survey
                NavigationView { SurveyContainerView() }
                    .tabItem { Label("DASI", systemImage: "checkmark.square") }

                // MARK: Usability Survey
                NavigationView { UsabilityContainer() }
                    .tabItem { Label("Usability",
                                     systemImage: "checkmark.circle")
                    .symbolRenderingMode(.hierarchical)
                    }
            }
            .navigationBarBackButtonHidden(true)
            .environmentObject(dasiPages)
            .environmentObject(rootResponseStatus)
            .environmentObject(UsabilityController())
            .environmentObject(SubjectID.shared)
        }
    }
}
