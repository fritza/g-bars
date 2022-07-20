//
//  DigitalTimerView.swift
//  No EO
//
//  Created by Fritz Anderson on 7/19/22.
//

import SwiftUI

final class DigitSpeaker {
    internal init(controller: CountdownController) {
        self.controller = controller
    }
    
    var controller: CountdownController
}

struct DigitalTimerView: View {
    @EnvironmentObject var controller: CountdownController

    var body: some View {
        VStack {
            Text("""
What the digital (walking) clock would show, and what would be spoken.

There's still a bug in picking up the initial value in the spoken version of the timer. The ten-second interval is for demonstration purposes.
""")
            Spacer()
            Text("\(controller.minuteColonSecond.description)").font(.system(size: 120, weight: .ultraLight))
                .monospacedDigit()

            Text("\(controller.speakableTime.description)")
            Spacer()
            Button(controller.isRunning ? "Stop" : "Start") {
                if self.controller.isRunning {
                    controller.stopCounting(timeRanOut: false)
                }
                else {
                    controller.reassemble(newDuration: 65)
                    controller.startCounting()
                }
            }
            Spacer()
        }
        .onAppear {
            controller.reassemble(newDuration: 120)
            controller.startCounting()
        }
        .navigationTitle("Minimal Example")
    }
}

struct DigitalTimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DigitalTimerView()
                .padding()
                .environmentObject(CountdownController(duration: 120))
        }
    }
}
