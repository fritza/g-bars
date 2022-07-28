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
    @EnvironmentObject private var controller: CountdownController

    @Binding var isRunning: Bool
    private let callback: ((Bool) -> Void)?

    init(running: Binding<Bool>, callback: ((Bool) -> Void)? = nil) {
        _isRunning = running
        self.callback = callback
    }

    var body: some View {
        Button(isRunning ? "Cancel" : "Start") {
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
            TimerStartStopButton(
                running: ssState.$running)
            Text("is \(ssState.running ? "" : "NOT") running")
        }
        .environmentObject(
            CountdownController(duration: 5, forCountdown: true)
        )
    }
}
