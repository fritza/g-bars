//
//  SubsecondHandView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import SwiftUI
import CoreGraphics

struct SubsecondHandView: View {
//    @EnvironmentObject var timer: WrappedTimer
    @EnvironmentObject var timer: MinutePublisher

    func midpoint(within proxy: GeometryProxy) -> CGPoint {
        let middle = proxy.size.short / 2.0
        return CGPoint(x: middle, y: middle)
    }

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .rotation(
                    Angle(
                        degrees: 180.0 + (
//                            timer.fractionalSeconds
                            timer.fraction
                            * 360.0)),
                    anchor: UnitPoint(x: 0.5, y: 0.05))
                .offset(midpoint(within: proxy))
                .frame(width: 2.0, height: proxy.size.short/2.0, alignment: .center)
        }
    }
}

struct SubsecondHandView_Previews: PreviewProvider {
/*
     static func previewWT() -> WrappedTimer {
        let retval = WrappedTimer(5.0)
        return retval
    }
*/
    static func mTimer() -> MinutePublisher {
        let retval = MinutePublisher(after: 5.0)
        retval.start()
        return retval
    }

    static var previews: some View {
        SubsecondHandView()
            .foregroundColor(.red)
            .frame(width: 100, height: 100, alignment: .center)
            .border(.green, width: 0.5)
            .environmentObject(
//                previewWT()
                mTimer()
            )
    }
}
