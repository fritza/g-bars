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
    @Environment(\.colorScheme) private static var colorScheme: ColorScheme
    @ObservedObject var timer: TimeReader
    /// The current minute/second/fraction value of the countdown.
    @State private  var minSecFrac: MinSecAndFraction?

    @State private  var wholeSeconds: Int

    init(duration: TimeInterval) {
        timer = TimeReader(interval: sweep_TMP_Duration, by: 0.075)
        wholeSeconds = Int(duration)
    }

    /// Whether the clock is running, as set by ``TimerStartStopButton``.
    /// - note: Stopping the countdown does not pause it.  When `isRunning` changes to `true`, its controller is completely restarted.
    @State var isRunning: Bool = false

    private var cancellables: Set<AnyCancellable> = []

    /// A digit to be overlaid on the clock face, intended to indicate seconds remaining.
    private func numericOverlay(edge: CGFloat) -> some View {
        // plus-one because I think people want to
        // see a "1" in the final go-round when
        // the app just said "one."

        // TODO: Why use this instead of the .seconds component of .minSecFrac?
        let rep = "\(wholeSeconds.description)"
        return Text(rep)
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
Countdown only. You can repeat the countdown by tapping "Start" twice.

In production, there would be only a Cancel button.
""")
                .font(.callout)
                .minimumScaleFactor(0.5)
                Spacer()
                TimerStartStopButton(
                    label: (isRunning) ? "Reset" : "Start",
                    running: $isRunning)
            }
            .padding()
            .onChange(of: isRunning, perform: { newValue in
                if isRunning {
                    timer.start()
                }
                else {
                    timer.cancel() // AND reset cancel button
                }
            })

            // Change of mm:ss.fff - sweep angle
            .onReceive(timer.timeSubject) { mmssff in
                self.minSecFrac = mmssff
            }
            // Change of :ss. (speak seconds)
            .onReceive(timer.secondsSubject) {
                secs in
                self.wholeSeconds = secs
                if CallbackUtterance.shouldSpeak {
                    CallbackUtterance(string: "\(secs+1)")
                        .speak()
                }
            }
            .navigationTitle("Seconds")
        }
    }
}

struct SweepSecondView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SweepSecondView(duration: sweep_TMP_Duration)
                .frame(width: 300)
        }
    }
}
