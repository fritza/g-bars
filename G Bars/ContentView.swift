//
//  ContentView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/10/22.
//

import SwiftUI
import CoreMotion

extension CMAcceleration: CustomStringConvertible {
    public var description: String {
        "Acc(\(x.pointThree), \(y.pointThree), \(z.pointThree))"
    }
}

final class CMWatcher: ObservableObject {
    @Published var reading: CMAccelerometerData
    static var census: Int = 0
    private var motionManager: MotionManager

    init() {
//        motionManager = MotionManager(interval: 1.0)
        // FIXME: The sampling rate should be configurable.
        motionManager = MotionManager()

        reading = CMAccelerometerData()

        Task {
            do {
                for try await datum in motionManager {
                    reading = datum
                    CMWatcher.census = await motionManager.count()
                }
            }
            catch {
                motionManager.cancelUpdates()
            }
        }
    }
}

struct ContentView: View {
    static let hzOverride: TimeInterval = 1.0/60.0

    enum Errors: Error {
        case collectionCancelled
    }
    @State private var isCollecting = false
    // FIXME: The sampling rate should be configurable.
    private var motionManager = MotionManager()

    @State var reading: CMAccelerometerData = CMAccelerometerData()
    var bufferCount: String = ""
    mutating func updateCount(_ n: Int) {
        bufferCount = String(n)
    }

    var labels: (status: String, button: String) {
        guard motionManager.accelerometryAvailable else {
            return (status: "Not available", button: "")
        }

        return isCollecting ? (status: reading.acceleration.description, button: "Stop") : (status: "Idle", button: "Start")
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20.0) {
            Spacer()
            Text("Async Accelerometry")
                .font(.largeTitle)
            HStack {
                Text(labels.status)
                Spacer()
                Button(labels.button) {
                    isCollecting.toggle()
                }
                .disabled(labels.button.isEmpty)
            }
            .padding()
            if isCollecting {
                SimpleBarView(
                    [
                        abs(reading.acceleration.x),
                        abs(reading.acceleration.y),
                        abs(reading.acceleration.z)
                    ],
                    spacing: 0.20, color: .teal, reservedMax: 1.25)
                    .animation(
                        .easeInOut(duration: Self.hzOverride),
                        value: reading.acceleration.x)
            }
            Spacer()
        }
        .padding()
        .task {
            do {
                for try await datum in motionManager {
                    reading = datum
                }
            }
            catch {
                motionManager.cancelUpdates()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
