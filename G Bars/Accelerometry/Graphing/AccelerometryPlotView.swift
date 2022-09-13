//
//  AccelerometryPlotView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/14/22.
//

import SwiftUI

/// A bare-bones view that plots a series (``Store2D``) of `t`, `x` data points.
///
/// Included here as an example of a consumer
struct AccelerometryPlotView: View {
    @Environment(\.colorScheme) static private var colorScheme: ColorScheme
    let series: Store2D
    let lineColor: Color
    let lineWidth: CGFloat

    /// The line color according to light/dark mode. The `versus` (overriding) parameter defaults to `nil`.
    static func preferredColor(versus other: Color? = nil) -> Color {
        return other ?? (colorScheme == .light ? .black : .white)
    }

    /// Initialize from a data series to plot; the color (if any) to enforce on the line, and its width.
    init(_ series: Store2D,
         lineColor color: Color? = nil,
         lineWidth: CGFloat = 1.0) {

        self.series = series
        self.lineWidth = lineWidth
        self.lineColor = Self.preferredColor(versus: color)
    }

    /// View adoption
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
    static let unfilteredData: [Datum2D] = {
        let ts = vDSP.ramp(withInitialValue: 0.0, increment: timePerTick, count: 1000)
        let vs = vDSP.ramp(withInitialValue: 3.22, increment: 0.02, count: 1000)
        let sines = vForce.sin(vs)
        let boostSines = vDSP.multiply(6.6, sines)
        let data = zip(ts, boostSines).map { Datum2D(t: $0.0, x: $0.1) }
        return data
    }()

    static let absData: [Datum2D] = {
        return unfilteredData
            .applying(abs)
    }()

    static let logData: [Datum2D] = {
        return unfilteredData.applying { log10(abs($0)) }
    }()

    static let store = Store2D(absData)

    static var previews: some View {
        NavigationView {
            VStack {
                ZStack {
                    AccelerometryPlotView(
                        Store2D(unfilteredData),
                        lineWidth: 2.0)


                    AccelerometryPlotView(
                        Store2D(logData),
                        lineColor: .red,
                        lineWidth: 2.0)
                }
                .frame(width: 400, height: 200)
            }

            .navigationBarBackButtonHidden(true)
        }
    }
}
