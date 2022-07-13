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

@main
struct G_BarsApp: App {
    @State var selectedTab: Int = 0
    @State var yesNoState: Int = 1

    var body: some Scene {
        // Create a WindowGroup depicting the single view
        WindowGroup {

#if true
            NavigationView {
                //  SurveyContainerView()
                UsabilityContainer()
            }
            .navigationBarBackButtonHidden(true)
            .environmentObject(dasiPages)
            .environmentObject(rootResponseStatus)
            .environmentObject(UsabilityController())
#elseif false
            TabView(selection: $selectedTab) {
                NavigationView { AcccelerometryView() }
                    .tabItem { Label("Acceleration", systemImage: "arrow.up.arrow.down") }

                NavigationView { SurveyContainerView() }
                    .tabItem { Label("DASI", systemImage: "checkmark.square") }


            }
#elseif false
            NavigationView {
                DASIQuestionView()
            }
            .environmentObject(DASIResponseStatus())
            .environmentObject(SubjectID.shared)
#else
            TabView(selection: $selectedTab) {
                ContentView()
                    .tabItem {
                        Label("Acceleration", systemImage: "move.3d")
                    }
                Text("For rent")
                    .tabItem {
                        Label("Empty", systemImage: "square")
                    }
            }
#endif
        }
    }
}
