//
//  SubsecondHandView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/20/22.
//

import SwiftUI
import CoreGraphics

struct SubsecondHandView: View {
    @EnvironmentObject private var controller: CountdownController


    func midpoint(within proxy: GeometryProxy) -> CGPoint {
        let middle = proxy.size.short / 2.0
        return CGPoint(x: middle, y: middle)
    }

    func fractionOf360() -> Double {
//        let c = controller
//        let t = c.timePublisher
//        let f = t.fraction
        let f = controller.fraction
        let retval = f * 360.0
        return retval
    }

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .rotation(
                    Angle(
                        degrees:
                            180.0 +
                        (
                            controller.fraction
                            * 360.0
//                            fractionOf360()
                        )
                    ),
                    anchor: UnitPoint(x: 0.5, y: 0.05))
                .offset(midpoint(within: proxy))
                .frame(width: 2.0, height: proxy.size.short/2.0, alignment: .center)
        }
        .onAppear {
            if !controller.isRunning {
                controller.startCounting()
            }
        }
    }
}

struct SubsecondHandView_Previews: PreviewProvider {
    static var previews: some View {
        SubsecondHandView()
            .foregroundColor(.red)
            .frame(width: 100, height: 100, alignment: .center)
            .border(.green, width: 0.5)
            .environmentObject(
                CountdownController(forCountdown: true)
            )
    }
}
