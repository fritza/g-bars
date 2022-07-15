//
//  CountdownSetupView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/15/22.
//

import SwiftUI

enum CountdownUnit: String {
    case minutes, seconds
}

struct CountdownSetupView: View {
    private let units: CountdownUnit
    @State private var deadlineInMinutes: Int
    private let callback:   (Int) -> Void
    private let testing: Bool
    init(_ deadline: Int, unit: CountdownUnit,
         testing: Bool = false, callback: @escaping (Int) -> Void) {
        self.units = unit
        self.deadlineInMinutes = deadline
        self.testing = testing
        self.callback = callback
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center) {
                HStack() {
                    Text("Duration (\(units.rawValue)):")
                    Spacer()
                    TextField(
                        "Minutes to Deadline",
                        value: $deadlineInMinutes,
                        format: .number.precision(.fractionLength(0)))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: proxy.size.width * 0.25)
                }
                .frame(width: proxy.size.width, alignment: .leading)
                Button("Start") {
                    callback(deadlineInMinutes)
                }
//                Text("Value is \(deadlineInMinutes)")
                Divider()

                if testing {
                    Text("\(deadlineInMinutes) \(units.rawValue)")
                }
            }
        }
    }
}

struct CountdownSetupView_Previews: PreviewProvider {
    @State static var numberSelected = 2
    static var previews: some View {
        NavigationView {
            ZStack {
                CountdownSetupView(
                    numberSelected, unit: .seconds,
                testing: true) { units in
                    numberSelected = units
                }
            }
            .padding()
        }
    }
}
