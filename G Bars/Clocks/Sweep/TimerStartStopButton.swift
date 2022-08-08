//
//  TimerStartStopButton.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/25/22.
//

import SwiftUI

/**
 ## Topics

 ### Initialization
 - ``init(running:callback:)``

 ### Properties
 - ``isRunning``
 - ``body``
 */

/// A **Start**/**Cancel** button that triggers a callback closure when tapped.
///
/// Used by ``DigitalTimerView`` and ``SweepSecondView``. A ``CountdownController`` is used as an `@EnvironmentObject`
struct TimerStartStopButton: View {
    @Binding var isRunning: Bool
    @State var label: String
    private let callback: ((Bool) -> Void)?

    init(label: String, running: Binding<Bool>, callback: ((Bool) -> Void)? = nil) {
        _isRunning = running
        self.callback = callback
        self.label    = label
    }

    var body: some View {
//        Button(isRunning ? "Cancel" : "Start")
        Button(label)
        {
            isRunning.toggle()
            callback?(isRunning)
        }
    }
}

struct TimerStartStopButton_Previews: PreviewProvider {
    final class StartStopWatch: ObservableObject {
        @State var running: Bool = false
    }

    static let ssState = StartStopWatch()
    static var previews: some View {
        VStack {
            TimerStartStopButton(label: "filler",
                running: ssState.$running)
            Text("is \(ssState.running ? "" : "NOT") running")
        }
    }
}
