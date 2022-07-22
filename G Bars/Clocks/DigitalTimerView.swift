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


/*
// MARK: - DigitSpeaker
final class DigitSpeaker: ObservableObject {

    private var cancellables: Set<AnyCancellable> = []
    private weak var controller: CountdownController?

    var shouldSpeak = false

    // Add whatever is needed for the speaker class
    // to operate.

    internal init(controller: CountdownController) {
        self.controller = controller
    }

    private var currentSpeechTask: Task<ReasonStoppedSpeaking, Never>?

    /// Client code has to
    func setUpCombine() {
        // Needed?
        cancellables.forEach { $0.cancel() }

        // TODO: shouldn't ∆ speakableTime be observed by controller?
        controller?.$speakableTime
            .print("speakable time")
            .filter { [weak self] _ in

                self?.controller?.shouldSpeak ?? false
                // prevent speaking if the controller
                // is paused.
            }
            .sink { [weak self] str in
                guard let self = self else { return }
                self.currentSpeechTask = Task {
                    await controller?.digitSpeaker.
                }
            }
            .store(in: &cancellables)
    }

    func stopSpeaking() {
        // TODO: Can TimeSpeaker cancel or interrupt?
        currentSpeechTask?.cancel()
    }
}
*/

// MARK: - DigitalTimerView
private let digitalNarrative = """
What the digital (walking) clock would show, and what would be spoken.

There's still a bug in picking up the initial value in the spoken version of the timer. The ten-second interval is for demonstration purposes.
"""

struct DigitalTimerView: View {
    @EnvironmentObject var controller: CountdownController
    @State private var wantsSpeech = false

//    @State var speaker: DigitSpeaker

    // HOW DO I DO THIS?
    // I think making speaker a @StateObject variable is
//    = {
//        let retval = DigitSpeaker(controller: controller)
//        return retval
//    }()

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
                    Text("“\(controller.speakableTime.description)”")
                    Spacer()
                    Divider()
                    Spacer()
                    Toggle("Speech", isOn: $controller.shouldSpeak)
                        .frame(width: proxy.size.width * 0.4)
                }
                #endif
//                .padding()
//                .background {
//                    Rectangle()
//                        .frame(width: proxy.size.width, height: proxy.size.height)
//                        .foregroundColor(Color(.sRGB, white: 0.95, opacity: 1))
//                }
//                .padding()
//                .minimumScaleFactor(0.5)
//                    .frame(height: proxy.size.height * 0.1)
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
            }.padding()
        }
        .onAppear {
//            speaker = DigitSpeaker(controller: controller)
//            speaker.setUpCombine()
//
            controller.reassemble(newDuration: 120)
            controller.startCounting()
        }
        .onChange(of: wantsSpeech) { nowWants in
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
