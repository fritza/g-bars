//
//  CountdownContainerView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/15/22.
//

import SwiftUI

struct CountdownContainerView: View {
    @EnvironmentObject private var timer: MinutePublisher
    @State private var secondsToDeadline: Int
    @State private var running: Bool

    init(seconds: Int) {
        secondsToDeadline = seconds
        running = false
    }

    var body: some View {
        VStack {
            CountdownSetupView(secondsToDeadline, unit:  .seconds) { mins in
                secondsToDeadline = mins
                timer.start()
                running = true
            }
            .padding()
            if running {
                SweepSecondView()
            }
        }
    }

    
}

struct CountdownContainerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CountdownContainerView(seconds: 5)
                .environmentObject(
                    MinutePublisher(after: 5)
                )
        }
    }
}
