//
//  CountdownContainerView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/15/22.
//

import SwiftUI

/**
 ## Topics

 ### Properties
 - ``body``
 */

struct CountdownContainerView: View {
    // FIXME: Detach the controller from the wrapper view
    //        (assuming the wrapper will ever be used).
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
            .environmentObject(CountdownController(duration: 10))
        }
    }
}
