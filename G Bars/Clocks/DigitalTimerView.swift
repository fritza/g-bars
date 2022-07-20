//
//  DigitalTimerView.swift
//  No EO
//
//  Created by Fritz Anderson on 7/19/22.
//

import SwiftUI
import Combine

final class DigitSpeaker {
    private var cancellables: Set<AnyCancellable> = []
    private weak var controller: CountdownController?

    // Add whatever is needed for the speaker class
    // to operate.

    internal init(controller: CountdownController) {
        self.controller = controller
    }

    /// Client code has to
    func setUpCombine() {
        // Needed?
        cancellables.forEach { $0.cancel() }

        controller?.$speakableTime
            .sink { str in
                // say something: Put it in the queue for the voice
                // remember to use @MainActor if necessary
            }
            .store(in: &cancellables)
    }

}

private let digitalNarrative = """
What the digital (walking) clock would show, and what would be spoken.

There's still a bug in picking up the initial value in the spoken version of the timer. The ten-second interval is for demonstration purposes.
"""

struct DigitalTimerView: View {
    @EnvironmentObject var controller: CountdownController
    @State private var wantsSpeech = false

    var body: some View {
        GeometryReader { proxy in
            VStack {
                // Instructions
                Text(digitalNarrative)
                Spacer()

                // Numerical time
                Text("\(controller.minuteColonSecond.description)").font(.system(size: 120, weight: .ultraLight))
                    .monospacedDigit()

                // Speech: text to speak and whether to speak
                // TODO: Consider making this section a separate view.
                HStack {
                    Text("“\(controller.speakableTime.description)”")
                    Spacer()
                    Divider()
                    Spacer()
                    Toggle("Speech", isOn: $wantsSpeech)
                                            .frame(width: proxy.size.width * 0.4)
                }.minimumScaleFactor(0.5)
                    .frame(height: proxy.size.height * 0.1)
                Spacer()
                // Start/stop
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
        }
        .onAppear {
            controller.reassemble(newDuration: 120)
            controller.startCounting()
        }
        .navigationTitle("Digital")
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
