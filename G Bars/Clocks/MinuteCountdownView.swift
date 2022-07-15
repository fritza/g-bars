//
//  MinuteCountdownView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/15/22.
//

import SwiftUI

struct MinuteCountdownView: View {
    @EnvironmentObject private var timer: MinutePublisher
    @State private var hasCompleted: Bool = false
    private let durationInMinutes: Int
    @State private var numeralColor: Color = .black

    internal init(durationInMinutes: Int) {
        self.durationInMinutes = durationInMinutes
    }

    var body: some View {
        VStack {
            Spacer()
            Text(timer.minuteColonSecond)
                .font(.system(size: 120, weight: .ultraLight))
                .monospacedDigit()
                .foregroundColor(numeralColor)
            Spacer()
            Button("Cancel") {
                timer.stop(exhausted: false)
            }
        }
        .onReceive(timer.completedSubject, perform: { why in
            hasCompleted = true
            // FIXME: Why doesn't this turn green?
            //        upon exhaustion
            numeralColor = why ? .green : .red
        })
        .navigationTitle(("\(durationInMinutes.spelled.capitalized) Minute Walk"))
    }
}

struct MinuteCountdownView_Previews: PreviewProvider {
    static let duration = 2.0 * 60.0
    static func mTimer() -> MinutePublisher {
        let retval = MinutePublisher(after: duration)
        retval.start()
        return retval
    }

    static var previews: some View {
        NavigationView {
            MinuteCountdownView(durationInMinutes: Int(duration)/60)
                .environmentObject(
                    //    previewWrappedTimer()
                    mTimer())
        }
    }
}
