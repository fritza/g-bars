//
//  DigitalTimerView.swift
//  No EO
//
//  Created by Fritz Anderson on 7/19/22.
//

import SwiftUI
import Combine

/*
 Back off and consider what you want to do.

 If the user wants speech, speak. If not, don't.
 Transition to does-want -> Don't speak immediately, you don't want "one minute, ten seconds" to pop in arbitrarily.
 Transition to doesn't-want -> Halt current speech. Do not respond to further ∆spoken-time.

 I have a dependency cycle among controller, speaker, and view.

 */


// FIXME: For demonstration purposes only
let countdown_TMP_Duration = 70.0
let countdown_TMP_Interval = 10
let sweep_TMP_Duration = 5.0



// MARK: - DigitalTimerView
private let digitalNarrative = """
What the digital (walking) clock would show, and what would be spoken.

There's still a bug in picking up the initial value in the spoken version of the timer. The ten-second interval is for demonstration purposes.
"""

struct DigitalTimerView: View {
    @EnvironmentObject var controller: CountdownController
    @State private var wantsSpeech = false
    @State private var amRunning: Bool = false

    var body: some View {
        GeometryReader { proxy in
            VStack {
                // Instructions
                Text(digitalNarrative)
                Spacer()

                // Numerical time
                Text("\(controller.minuteColonSecond.description)").font(.system(size: 120, weight: .ultraLight))
                    .monospacedDigit()

                #if false
                // Speech: text to speak and whether to speak
                // TODO: Consider making this section a separate view.
                HStack {
//                    Text("“\(controller.speakableTime.description)”")
                    Spacer()
                    Divider()
                    Spacer()
                    Toggle("Speech", isOn: $controller.shouldSpeak)
                        .frame(width: proxy.size.width * 0.4)
                }
#endif
                Spacer()
                // Start/stop
                TimerStartStopButton(running: $amRunning) { newRunning in
                    print(newRunning ? "RUNNING" : "STOPPED")
                    print()
                    if newRunning {
                        controller.startCounting(
                            reassembling: true, duration: countdown_TMP_Duration)
                    }
                    else {
                        controller.stopCounting(timeRanOut: false)
                    }
                }
                Spacer()
            }.padding()
        }
        .navigationTitle("Digital")
    }
}

// MARK: - Preview
struct DigitalTimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DigitalTimerView()
                .padding()
                .environmentObject(CountdownController(duration: 120))
        }
    }
}
