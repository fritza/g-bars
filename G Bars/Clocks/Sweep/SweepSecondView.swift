//
//  SweepSecondView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import SwiftUI
import Combine

/**
 ## Topics

 ### Properties
 - ``isRunning``
 - ``body``
 */


/// A `View` that displays a circle containing a sweep-second hand and a digit, representing a countdown in seconds.
///
/// Note that the timer can't be paused, only canceled. After cancellation, the only thing to be done is to create a new timer, and assign it the full duration.
struct SweepSecondView: View {
    /*
    enum SpeakWalkSpeak: String, CaseIterable {
        // On appearance, "begin walking in n seconds"
        case sayOpening
        // that speech ends. (There's a callback for the utterance) the countdown runs.
        case perform
        // transition to the next WalkingContainerView subject
        // presumably this is just a callback. to the container.
    }
     */
    
    @Environment(\.colorScheme) private static var colorScheme: ColorScheme
    @ObservedObject var timer: TimeReader
    /// The current minute/second/fraction value of the countdown.
    @State private  var minSecFrac: MinSecAndFraction?
    @State private  var wholeSeconds: Int

    private let completionCallback: (() -> Void)

    init(duration: TimeInterval,
         onCompletion: @escaping (()->Void),
         function: String = #function,
         fileID: String = #file,
         line: Int = #line
    ) {
//        print("SweepSecondView.init called from", function, "\(fileID):\(line)")

        timer = TimeReader(interval: sweep_TMP_Duration, by: 0.075)
        wholeSeconds = Int(duration)
        completionCallback = onCompletion
    }

    /// Whether the clock is running, as set by ``TimerStartStopButton``.
    /// - note: Stopping the countdown does not pause it.  When `isRunning` changes to `true`, its controller is completely restarted.
//    @State var isRunning: Bool = false

    private var cancellables: Set<AnyCancellable> = []

    var stringForSeconds: String {
        if let seconds = self.minSecFrac?.second, seconds >= 0 {
            return String(describing: seconds+1)
        }
        else { return "*" }
    }

    /// A digit to be overlaid on the clock face, intended to indicate seconds remaining.
    @ViewBuilder private func numericOverlay(edge: CGFloat) -> some View {
        Text(stringForSeconds)
            .font(.system(size: edge, weight: .semibold))
            .monospacedDigit()
    }

    @ViewBuilder private func clockFace(fitting size: CGSize) -> some View {
        ZStack(alignment: .center) {
            Circle()
                .stroke(lineWidth: 1.0)
                .foregroundColor(.gray)

            SubsecondHandView(fractionalSecond: minSecFrac?.fraction ?? 0.0)
                .foregroundColor((Self.colorScheme == .light) ? .black : .gray)

            numericOverlay(
                edge: size.short * 0.6
            )
        }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                clockFace(fitting: proxy.size)
                    .frame(width:  proxy.size.short * 0.95,
                           height: proxy.size.short * 0.95,
                           alignment: .center)
                Spacer()
                Text("""
Remember to unmute your phone and turn up the audio!
""")
                .font(.callout)
                .minimumScaleFactor(0.5)
//                Spacer()
//                TimerStartStopButton(
//                    label: (isRunning) ? "Reset" : "Start",
//                    running: $isRunning)
            }
            .padding()

            // MARK: Change isRunning
//            .onChange(of: isRunning, perform:
            .onChange(of: timer.status, perform:
                        { newValue in
                switch newValue {
//                case .ready:
//                    timer.start()
                case .cancelled, .expired:
                    // Timer's already completed, hence status
                    completionCallback()
                default: break
                }
            })

            // MARK: Time subscription -> sweep second
            // Change of mm:ss.fff - sweep angle
            .onReceive(timer.timeSubject) { mmssff in
                self.minSecFrac = mmssff
            }

            // MARK: Seconds -> Overlay + speech
            // Change of :ss. (speak seconds)
            .onReceive(timer.secondsSubject) {
                secs in
                self.wholeSeconds = secs
                CallbackUtterance(string: "\(secs+1)")
                    .speak()
            }

            .onAppear() {
                CallbackUtterance(string: "Start walking in \(wholeSeconds.spelled) seconds") { utterance in
                    timer.start()
//                    isRunning = true
                }
                .speak()
            }
            .navigationTitle("Seconds")
        }
    }
}

struct SweepSecondView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SweepSecondView(duration: sweep_TMP_Duration) {

            }
                .frame(width: 300)
        }
    }
}
