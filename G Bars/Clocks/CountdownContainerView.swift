//
//  CountdownContainerView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/15/22.
//

import SwiftUI

/*
 Chicken-and-egg

 You need a view, a controller, and a timer.
 The timer belongs in the controller.

 Usability:
 The view accepts the controller as an EnvironmentObject. It has no responsibility for initializing it or taking direct notice of the responses. The controller is a shell for what the UI elements reflect. The view is a shell for how the state is reflected.
 */

/**
 ## Topics

 ### Properties
 - ``body``
 */

struct CountdownContainerView: View {
    @EnvironmentObject private var controller: CountdownController

    var body: some View {
        VStack {
            // Countdown setup belongs in the container view.
            // The setup and countdown views observe the
            // controller properties (current time, duration
            // etc.)
            // the controller.
            CountdownSetupView(// secondsToDeadline,
                unit: .seconds) { mins in
//                    secondsToDeadline = mins
//                    controller.startCounting()
//                    running = true
                }
                .padding()
            if controller.isRunning {
                SweepSecondView()
            }
        }
    }

    
}

struct CountdownContainerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CountdownContainerView(
            )
                .environmentObject(
                    CountdownController(duration: 10)
                )
        }
    }
}
