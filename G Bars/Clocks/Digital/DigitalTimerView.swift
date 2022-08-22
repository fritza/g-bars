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

    var walkingState: WalkingState

    private let expirationCallback: (() -> Void)?

    var observer = TimedWalkObserver(title: "some Timer")

    init(duration: TimeInterval,
         walkingState: WalkingState,
         immediately completion: (() -> Void)? = nil,
         function: String = #function,
         fileID: String = #file,
         line: Int = #line) {
        assert(walkingState == .walk_1 || walkingState == .walk_2,
        "\(fileID):\(line): Unexpected walking state: \(walkingState)"
        )
        self.walkingState = walkingState
        serialNumber = Self.dtvSerial
        Self.dtvSerial += 1

//        print("DigitalTimerView.init", serialNumber,
//              "called from", function, "\(fileID):\(line)")

        let tr =  TimeReader(interval: duration)
        self.timer = tr
        expirationCallback = completion
    }

    fileprivate func timerStateDidChange(_ stat: TimeReader.TimerStatus) {
        if stat == .expired {
            playSound(named: "Klaxon",
                      thenSay: "Stop walking.")
            expirationCallback?()
        }
        else if stat == .running {
            playSound(named: "Klaxon",
                      thenSay: "Start walking.")
        }

        // If the timer halts, stop collecting.
        switch timer.status {
        case .cancelled, .expired: observer.stop()
            // Now that it's stopped, you're ready to write a CSV file
            // Do not call reset or clearRecords, you need those for writing.

        default: break
        }
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
        .task {
            await self.observer.start()
            // This appends CMAccelerometerData to
            // the observer's consumer list.
        }
        .onAppear {
            timer.start()
        }
        .onReceive(timer.$status, perform: { stat in
            timerStateDidChange(stat)
            try {
                // TODO: Make the view aware of its stage.
                // Remember that WalkingState has a prefix property.

                observer.write(withPrefix: "walk_normal",
                               to: "\(Date().iso).csv")
            }
            catch {
                print("Writing the file failed:", error)
                print()
            }
            // TODO: Then harvest and save.
            // Is this handler really the best place?


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
            DigitalTimerView(duration: countdown_TMP_Duration,
                             walkingState: .walk_2)
                .padding()
        }
    }
}
