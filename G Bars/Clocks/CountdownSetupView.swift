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
    @AppStorage(AppStorageKeys.walkInMinutes.rawValue) private var durationInMinutes: Int = 2

    private let units: CountdownUnit
//    @State private var deadlineInMinutes: Int
    private let callback:   (Int) -> Void
    private let testing: Bool

//    init(_ deadline: Int,
    init(
         unit: CountdownUnit,
         testing: Bool = false, callback: @escaping (Int) -> Void) {
        self.units = unit
//        self.deadlineInMinutes = deadline
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
                        value: $durationInMinutes,
                        format: .number.precision(.fractionLength(0)))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: proxy.size.width * 0.25)
                }
                .frame(width: proxy.size.width, alignment: .leading)
                Button("Start") {

// FIXME: what's the callback used for, again?

                    callback(durationInMinutes)
                }
//                Text("Value is \(deadlineInMinutes)")
                Divider()

                if testing {
                    Text("\(durationInMinutes) \(units.rawValue)")
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
//                    numberSelected,
                    unit: .seconds,
                testing: true) { units in
                    numberSelected = units
                }
            }
            .padding()
        }
        .environmentObject(CountdownController(duration: 45))
    }
}
