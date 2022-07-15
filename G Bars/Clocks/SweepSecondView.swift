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
//    @EnvironmentObject var timer: WrappedTimer
    @EnvironmentObject var timer: MinutePublisher
    @State private var hasCompleted: Bool = false

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
                        representing: hasCompleted ? 0 : timer.seconds+1,
                        edge: proxy.size.short * 0.6)
                }
                .navigationTitle("Seconds")
                .onReceive(timer.completedSubject, perform: { normally in
                    hasCompleted = true
                })
                .frame(width: proxy.size.short * 0.95,
                       height: proxy.size.short * 0.95,
                   alignment: .center)
                Spacer()
                Button("Cancel") {
                    timer.stop(exhausted: false)
                }
            }
        }
    }
}

struct SweepSecondView_Previews: PreviewProvider {
//    static func previewWrappedTimer() -> WrappedTimer {
//        return WrappedTimer(5)
//    }

    static func mTimer() -> MinutePublisher {
        let retval = MinutePublisher(after: 5.0)
        retval.start()
        return retval
    }

    static var previews: some View {
        NavigationView {
            SweepSecondView()
                .frame(width: 300)
                .environmentObject(
                    //    previewWrappedTimer()
                    mTimer()
                )
        }
    }
}
