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
/// Uses a  `CountdownController` as an `@EnvironmentObject`.
struct SweepSecondView: View {
    @Environment(\.colorScheme) private static var colorScheme: ColorScheme
    @EnvironmentObject private var controller: CountdownController

    /// Whether the clock is running, as set by ``TimerStartStopButton``.
    /// - note: Stopping the countdown does not pause it.  When `isRunning` changes to `true`, its controller is completely restarted.
    @State var isRunning: Bool = false

    private var cancellables: Set<AnyCancellable> = []

    /// A digit to be overlaid on the clock face, intended to indicate seconds remaining.
    private func numericOverlay(edge: CGFloat) -> some View {
        // plus-one because I think people want to
        // see a "1" in the final go-round when
        // the app just said "one."
        let rep = controller.seconds+1
        return Text("\(rep)")
            .font(.system(size: edge, weight: .semibold))
            .monospacedDigit()
    }

    @ViewBuilder private func clockFace(fitting size: CGSize) -> some View {
        ZStack(alignment: .center) {
            Circle()
                .stroke(lineWidth: 1.0)
                .foregroundColor(.gray)

            SubsecondHandView(fractionalSecond: controller.fraction)
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
On a 5-second countdown, the first sweep should be labeled “4” and the last “0” (4.9 and 0.9 seconds remaining). This might be confusing, because when the voice says “1,” the display shows “0.” This clock adds 1 to the overlay.
""")
                .font(.callout)
                .minimumScaleFactor(0.5)
                Spacer()
                TimerStartStopButton(running: $isRunning)
            }
            .padding()
            .onChange(of: isRunning, perform: { newValue in
                if isRunning {
                    controller.startCounting()
                }
                else {
                    controller.stopCounting(timeRanOut: false) // AND reset cancel button
                }
            })
            .onChange(of: controller.seconds, perform: { newSecs in
                guard CallbackUtterance.shouldSpeak else {
                    return
                }
                CallbackUtterance(string: "\(newSecs+1)")
                    .speak()
            })
            .navigationTitle("Seconds")
        }
    }
}

struct SweepSecondView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SweepSecondView()
                .frame(width: 300)
        }
        .environmentObject(
            CountdownController(duration: Int(sweep_TMP_Duration))
        )
    }
}
