//
//  DigitalTimerView.swift
//  No EO
//
//  Created by Fritz Anderson on 7/19/22.
//

import SwiftUI
import Combine


let countdown_TMP_Duration = 25.0 // 120.0




let countdown_TMP_Interval = 10




let sweep_TMP_Duration = 5.0




// MARK: - DigitalTimerView
private let digitalNarrative = """
The interval is read out at \(countdown_TMP_Interval)-second intervals, the better to demonstrate the feature.
"""

/**
 ## Topics

 ### Properties
 - ``text``
 -  ``size``
 - ``shouldSpeak``

 ### Initializer
 - ``init(toggling:size:label:)``
 */

@available(*, unavailable,
            message: "Do not use, no replacement")
struct SpeechOnOffView: View {
    // Don't use AppStorage for this,
    // it obscures the dependency up through DigitalTimerView..
    let text: String?
    @Binding var speechValue: Bool
    let size: CGSize

    init(toggling: Binding<Bool>, size: CGSize, label: String? = nil) {
        self.text = label
        self._speechValue = toggling
        self.size = size
    }

    var body: some View {
        HStack(alignment: .center) {
            if let text = text {
                Text("\(text)")
                    .minimumScaleFactor(0.5)
                Spacer(); Divider()
            }
            Spacer()
            Toggle("Speech", isOn: $speechValue)
                .frame(width: size.width * 0.4)
        }.frame(height: 50)
    }
}

/**
 ## Topics

 ### Properties
 - ``controller``
 - ``body``
 */

/*
 How do we work the MotionManager iterator?
 Should DigitalTimerView bother accepting data at all?
 Put that in a "manager?"

 In time, it should not be responsible for cancellation. Except… we do that already for TimeReader
 */

struct DigitalTimerView: View {
    static var dtvSerial = 100
    let serialNumber: Int

    @AppStorage(AppStorageKeys.wantsSpeech.rawValue) var wantsSpeech = true
    @ObservedObject var timer: TimeReader
    @State private var minSecfrac: MinSecAndFraction?

    private let expirationCallback: (() -> Void)?

    init(duration: TimeInterval, immediately
         completion: (() -> Void)? = nil,
         function: String = #function,
         fileID: String = #file,
         line: Int = #line) {
        serialNumber = Self.dtvSerial
        Self.dtvSerial += 1

//        print("DigitalTimerView.init", serialNumber,
//              "called from", function, "\(fileID):\(line)")

        let tr =  TimeReader(interval: duration)
        self.timer = tr
        expirationCallback = completion
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                // Instructions
                Text(digitalNarrative)
                    .foregroundColor(.red)
                Spacer()
                // MM:SS to screen
                Text(minSecfrac?.clocked ?? "--:--" )
                    .font(.system(size: 120, weight: .ultraLight))
                    .monospacedDigit()

                // Start/stop
                Button("Cancel") {
                    timer.cancel()
                }
                Spacer()
            }
            .padding()
        }
        .onAppear {
            timer.start()
        }
        .onReceive(timer.$status, perform: { stat in
            if stat == .expired {
                playSound(named: "Klaxon",
                          thenSay: "Stop walking.")
                expirationCallback?()
            }
            else if stat == .running {
                playSound(named: "Klaxon",
                          thenSay: "Start walking.")
            }
        })
        .onReceive(timer.timeSubject, perform: { newTime in
            self.minSecfrac = newTime
        })
        .onReceive(timer.mmssSubject) { newTime in
            CallbackUtterance(
                string: newTime.spoken)
            .speak()
        }
        .navigationTitle("Digital")
    }

//    func start() {
//        timer.start()
//    }
}

// MARK: - Preview
struct DigitalTimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DigitalTimerView(duration: countdown_TMP_Duration)
                .padding()
        }
    }
}
