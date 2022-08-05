//
//  AcccelerometryView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/10/22.
//


// TODO: Rename this.

import SwiftUI
import CoreMotion

extension CMAcceleration: CustomStringConvertible {
    public var description: String {
        "Acc(\(x.pointThree), \(y.pointThree), \(z.pointThree))"
    }

    public var scalar: Double {
        sqrt(x*x + y*y + z*z)
    }
}

extension CMAccelerometerData {
    public var scalar: Double { acceleration.scalar }
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

#if LOGGER
import os.log
#endif

struct AcccelerometryView: View {

    init() {
#if LOGGER
        gLogger.log("Initializing AccelerometryView?!")
#endif
        print("entry to AcccelerometryView()")
        print("(debug only)")
    }


    static let hzOverride: TimeInterval = 1.0/60.0
    // FIXME: Respond to color scheme in the other views.
    @Environment(\.colorScheme) private var colorScheme

    enum Errors: Error {
        case collectionCancelled
    }
    @State private var logarithmicGraph = false
    @State private var isCollecting = false
    // FIXME: The sampling rate should be configurable.
    private var motionManager = MotionManager()

    @State var reading: CMAccelerometerData = CMAccelerometerData()
    var bufferCount: String = ""
    mutating func updateCount(_ n: Int) {
        bufferCount = String(n)
    }

    @StateObject var accelerationStore = Store2D()

    var labels: (status: String, button: String) {
        guard motionManager.accelerometryAvailable else {
            return (status: "Not available", button: "")
        }

        return isCollecting ?
        ( status: reading.acceleration.description, button: "Stop")
        : (status: "Idle", button: "Start")
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20.0) {
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

            VStack {
                Text("Max acceleration: \(accelerationStore.xMax?.pointThree.description ?? "N/A")")
                Text("Min acceleration: \(accelerationStore.xMin?.pointThree.description ?? "N/A")")
            }
            .padding()

            if isCollecting {
                VStack {
                    SimpleBarView(
                        [
                            abs(reading.acceleration.x),
                            abs(reading.acceleration.y),
                            abs(reading.acceleration.z)
                        ],
                        spacing: 0.20, color: .teal, reservedMax: 1.25)
                }
                HorizontalBar(reading.acceleration.scalar,
                              minValue: 0.05, maxValue: 8.0)
                .frame(height: 40, alignment: .leading)
            }
            else {
                VStack {
                    ZStack(alignment: .center) {
                        Rectangle()
                            .foregroundColor(
                                Color(.sRGB,
                                      white: (colorScheme == .light) ? 0.95 : 0.4,
                                      opacity: 1.0))
                        if accelerationStore.isEmpty {
                            Text("No data").font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                        else {
                            AccelerometryPlotView(
                                logarithmicGraph ?
                                accelerationStore.applying { log10(Swift.max($0, 0.01)) }
                                : accelerationStore,
                                lineColor: .red)
                        }
                    }
                    .frame(height: 360)
                    Button(action: {
                        logarithmicGraph.toggle()
                    }, label: {
                        Text("\(logarithmicGraph ? "Logarithmic" : "Linear") scale")
                            .font(.caption)
                    })
                }
            }
        }
        .padding()
        .task {
            do {
                for try await datum in motionManager {
                    reading = datum

                    let aBar = datum.scalar
                    let stamp = datum.timestamp
                    let record: Datum2D
                    if isCollecting {
                        record = Datum2D(t: stamp, x: aBar)
                        accelerationStore.append(record)
                    }
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
        ForEach(["iPhone SE (3rd generation)", "iPhone 12"],
                id: \.self) { name in
            AcccelerometryView()
                .previewDevice(PreviewDevice(rawValue: name))
                .previewDisplayName(name)
        }
    }
}
