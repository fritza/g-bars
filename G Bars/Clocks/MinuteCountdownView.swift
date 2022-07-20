//
//  MinuteCountdownView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/15/22.
//

import SwiftUI

struct MinuteCountdownView: View {
    @EnvironmentObject private var controller: CountdownController

//    @EnvironmentObject private var timer: MinutePublisher
    @State private var hasCompleted: Bool = false
    @State private var numeralColor: Color = .black

    var body: some View {
        VStack {
            #if true
            Button("Start") {
                controller.startCounting()
            }
            #endif
            Spacer()
            Text("Hello? Anything?")
//            Text(controller.timePublisher.minuteColonSecond)
                .font(.system(size: 120, weight: .ultraLight))
                .monospacedDigit()
                .foregroundColor(numeralColor)
            Spacer()
            Button("Cancel") {
                controller.stopCounting(timeRanOut: false)
            }
        }
        .onReceive(controller.timePublisher.completedSubject, perform: { why in
            hasCompleted = true
            // FIXME: Why doesn't this turn green?
            //        upon exhaustion
            numeralColor = why ? .green : .red
        })
        .navigationTitle(("\((controller.durationInSeconds / 60).spelled.capitalized) Minute Walk"))
    }
}

struct MinuteCountdownView_Previews: PreviewProvider {
    static let duration = 2.0 * 60.0
    static let countdownController = CountdownController(forCountdown: false)
    static var previews: some View {
        NavigationView {
            VStack {
                MinuteCountdownView()
            }
            .environmentObject(countdownController)
        }
    }
}
