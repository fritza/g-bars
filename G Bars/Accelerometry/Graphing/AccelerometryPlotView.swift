//
//  AccelerometryPlotView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/14/22.
//

import SwiftUI

struct AccelerometryPlotView: View {
    let series: Store2D
    let lineColor: Color
    let lineWidth: CGFloat

    init(_ series: Store2D,
         lineColor: Color = .black,
         lineWidth: CGFloat = 1.0) {
        (self.series, self.lineColor, self.lineWidth) =
        (series, lineColor, lineWidth)
    }

    var body: some View {
        VStack {
            GeometryReader { proxy in
                series.path(within: proxy.size)
                    .stroke(lineWidth: lineWidth)
                    .foregroundColor(lineColor)
            }
        }
    }
}

import Accelerate
struct AccelerometryPlotView_Previews: PreviewProvider {
    static let timePerTick = 1.0 / 60.0
    static let testData: [Datum2D] = {
        let ts = vDSP.ramp(withInitialValue: 0.0, increment: timePerTick, count: 1000)
        let vs = vDSP.ramp(withInitialValue: 3.22, increment: 0.02, count: 1000)
        let sines = vForce.sin(vs)
        let boostSines = vDSP.multiply(6.6, sines)
        let data = zip(ts, boostSines).map { Datum2D(t: $0.0, x: $0.1) }
        return data
    }()

    static let store = Store2D(testData)

    static var previews: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                    AccelerometryPlotView(
                        Store2D(testData),
                        lineColor: .white,
                        lineWidth: 2.0)

                }
                .frame(width: 400, height: 200)
            }

            .navigationBarBackButtonHidden(true)
        }
    }
}
