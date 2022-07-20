//
//  SweepSecondView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import SwiftUI
import Combine

/// A `View` that displays a circle containing a sweep-second hand and a digit, representing a countdown in seconds.
struct SweepSecondView: View {
    @Environment(\.colorScheme) private static var colorScheme: ColorScheme
    @EnvironmentObject /*private*/ var controller: CountdownController

    @State private var seconds: Int

    private var cancellables: Set<AnyCancellable> = []

    init() {
//        hasCompleted = false
        seconds = 0
//        controller.$seconds.assign(to: \.seconds, on: self).store(in: &cancellables)
    }

    func numericOverlay(representing: Int, edge: CGFloat) -> some View {
        Text("\(representing)")
            .font(.system(size: edge, weight: .semibold))
            .monospacedDigit()
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                // A circle/bezel, under a sweep hand, under numeral seconds.
                ZStack(alignment: .center) {
                    // TODO: Should clock face → its own view?
                    Circle()
                        .stroke(lineWidth: 1.0)
                        .foregroundColor(.gray)

                    SubsecondHandView()
                        .foregroundColor((Self.colorScheme == .light) ? .black : .gray)
                    
                    numericOverlay(
                        representing: controller.isRunning ?
                        controller.seconds+1 :
                            0,
                        edge: proxy.size.short * 0.6
                    )
                }
                .navigationTitle("Seconds")
                .frame(width:  proxy.size.short * 0.95,
                       height: proxy.size.short * 0.95,
                   alignment: .center)
                Spacer()
                Button(controller.isRunning ? "Cancel" : "Start") {
                    if controller.isRunning {
                        controller.stopCounting(timeRanOut: false)
                    }
                    else {
                        controller.reassemble(newDuration: 5.0)
                        controller.startCounting()
                    }
                }
            }
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
            CountdownController(duration: 10)
        )
    }
}
