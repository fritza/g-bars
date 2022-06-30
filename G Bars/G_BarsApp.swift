//
//  G_BarsApp.swift
//  G Bars
//
//  Created by Fritz Anderson on 6/29/22.
//

import SwiftUI



@main
struct G_BarsApp: App {
    @State var selectedTab: Int = 0
    var body: some Scene {
        // Create a WindowGroup depicting the single view
        WindowGroup {
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
        }
    }
}
