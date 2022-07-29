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

/**
 ## Topics
 
 ### Properties
 - ``text``
 -  ``size``
 - ``shouldSpeak``

 ### Initializer
 - ``init(toggling:size:label:)``
 */

struct SpeechOnOffView: View {
    let text: String?
    @Binding var shouldSpeak: Bool
    let size: CGSize

    init(toggling: Binding<Bool>, size: CGSize, label: String? = nil) {
        self.text = label
        self._shouldSpeak = toggling
        self.size = size
    }

    var body: some View {
        HStack(alignment: .center) {
            if let text = text {
                Text("\(text)")
//                Text("Many minutes many seconds. Too much time to account for really.")
                    .minimumScaleFactor(0.5)
                Spacer(); Divider()
            }
            Spacer()
            Toggle("Speech", isOn: $shouldSpeak)
                .frame(width: size.width * 0.4)
        }.frame(height: 50)
    }
}

/**
 ## Topics

 ### Properties
 - ``controller``
 - ``body``
 */

struct DigitalTimerView: View {
    @EnvironmentObject var  controller  : CountdownController
    @State private var      wantsSpeech = false
    @State private var      amRunning   :  Bool = false
    @State private var      minSeconds  = MinSecondPair(seconds: Int(countdown_TMP_Duration))

    var body: some View {
        GeometryReader { proxy in
            VStack {
                // Instructions
                Text(digitalNarrative)
                Spacer()
                //
                // mCS STARTS at ""
                // Where is it initialized?
                //
                // Numerical time
                Text("\(controller.mmssToDisplay)")
                    .font(.system(size: 120, weight: .ultraLight))
                    .monospacedDigit()

                SpeechOnOffView(toggling: $controller.shouldSpeak,
                                size: proxy.size,
                                label: controller.currentSpeakable)

                Spacer()
                // Start/stop
                TimerStartStopButton(running: $amRunning) { newRunning in
                    if newRunning {
                        controller.startCounting()
                    }
                    else {
                        controller.stopCounting(
                                timeRanOut: false)
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
                .environmentObject(CountdownController(duration: Int(countdown_TMP_Duration)))
        }
    }
}
