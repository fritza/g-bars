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
    @EnvironmentObject /*private*/ var controller: CountdownController

    @State private var hasCompleted: Bool = false
    @State private var seconds: Int

    private var cancellables: Set<AnyCancellable> = []

    init() {
        hasCompleted = false
        seconds = 0
        controller.$seconds.assign(to: \.seconds, on: self).store(in: &cancellables)
    }

    func numericOverlay(representing: Int, edge: CGFloat) -> some View {
        Text("\(representing)")
            .font(.system(size: edge, weight: .semibold, design: .default))
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                ZStack(alignment: .center) {
                    Circle()
                        .stroke(lineWidth: 1.0)
                        .foregroundColor(.gray)
                    SubsecondHandView()

                    numericOverlay(
                        representing: hasCompleted ?
                        0 :
                            controller.seconds+1,
                        edge: proxy.size.short * 0.6)
                }
                .navigationTitle("Seconds")

                // TODO: Track a published Bool for completion.
                .onReceive(controller.$isRunning) { stillRunning in
                    hasCompleted = true
                }
                .frame(width: proxy.size.short * 0.95,
                       height: proxy.size.short * 0.95,
                   alignment: .center)
                Spacer()
                Button("Cancel") {
                    controller.stopCounting(timeRanOut: false)
                }
            }
            .onAppear {
                controller.startCounting()
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
            CountdownController(forCountdown: true)
        )
    }
}
