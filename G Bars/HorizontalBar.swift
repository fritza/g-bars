//
//  HorizontalBar.swift
//  G Bars
//
//  Created by Fritz Anderson on 6/30/22.
//

import SwiftUI


struct HorizontalBar: View {
    let value: Double
    let scaler: LogViewSizing
    let barColor: Color

    init(_ value: Double, minValue: Double, maxValue: Double, ofColor color: Color = .blue) {
        self.value = value
        self.barColor = color
        scaler = LogViewSizing(min: minValue, max: maxValue)
    }

    // FIXME: Share these with SimpleBarView
    /// A `Gradient` to draw behind the bars.
    private let backGradient = Gradient(colors: [
        Color(UIColor(white: 0.95, alpha: 1.0).cgColor),
        Color(UIColor(white: 0.80, alpha: 1.0).cgColor)
        ]
    )

    var gradientBackground: some View {
        Rectangle()
            .fill (
            .linearGradient(
                backGradient,
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1))
            )
    }

    func bar(in size: CGSize) ->  some View {
        let scaledValue = scaler.scale(value, within: size.width)
        let inset = 0.25

        return Rectangle()
            .frame(width : scaledValue       ,
                   height: (1.0 - inset) * size.height,
                   alignment: .center)
            .foregroundColor(barColor)
    }


    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                gradientBackground
                bar(in: proxy.size)
            }
        }
    }
}

struct HorizontalBar_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalBar(1.0, minValue: 0.5, maxValue: 3.3, ofColor: .green)
            .frame(width: 300, height: 86)
        HorizontalBar(3.0, minValue: 0.5, maxValue: 3.3, ofColor: .red)
            .frame(width: 300, height: 86)
    }
}
