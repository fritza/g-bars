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

@main
struct G_BarsApp: App {
    @State var selectedTab: Int = 0
    @State var yesNoState: Int = 1
    @AppStorage("REPLACE subject id") var subjectID = "1234"

//    @State var responseStatus = DASIResponseStatus(from: [ .yes, .yes, .no, .no, .yes, .no ])


    var body: some Scene {
        // Create a WindowGroup depicting the single view
        WindowGroup {
#if true
            NavigationView {
                SurveyContainerView()
                /*
                VStack {
                    DASIQuestionView()
                    YesNoStack(boundState: $yesNoState)
                    Text("Integer state = \(yesNoState)")

                    // NOTE WELL:
                    // .onChange is executed _after_ the following
                    // Text accesses .currentValue. This means the
                    // displayed current value lags the most-recently-changed
                    // value by one tap in the YesNoStack.
                    Text("Transmitted state = \(rootResponseStatus.currentValue.description)")
                }
                .onChange(of: yesNoState) { newValue in
                    rootResponseStatus.currentValue =
                    (newValue == 1) ? .yes : .no
                }
                 */
            }
            .environmentObject(dasiPages)
            .environmentObject(rootResponseStatus)
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
                        Label("Acceleration", systemImage: "arrow.up.arrow.down")
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
