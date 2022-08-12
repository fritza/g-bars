//
//  AcccelerometryView.swift
//  Async Accel
//
//  Created by Fritz Anderson on 3/10/22.
//


// TODO: Rename this.

import SwiftUI
import CoreMotion

// MARK: - CMAcceleration description
extension CMAcceleration: CustomStringConvertible {
    public var description: String {
        "Acc(\(x.pointThree), \(y.pointThree), \(z.pointThree))"
    }

    public var scalar: Double {
        sqrt(x*x + y*y + z*z)
    }
}

extension CMAccelerometerData {
    // MARK: - Acceleration magnitude
    public var scalar: Double { acceleration.scalar }
}

/*
/// A shim between ``MotionManager`` (data source) and data consumers via a published cuttent datum.
final class CMWatcher: ObservableObject {
    /// The current data point
    @Published var reading: CMAccelerometerData
    /// Count of acceleration data reported by ``CMMotionManager`` via ``MotionManager``.
    ///
    /// Mostly for debugging.
    static var census: Int = 0
    /// The source for ``CMAccelerometerData``
    private var motionManager: MotionManager

    /// Set up the data source and prepare to read from it.
    init() {
        // FIXME: The sampling rate should be configurable.
        motionManager = MotionManager()
        reading = CMAccelerometerData()

        Task {
            do {
                /// Capture each new datum into the published `reading`, for clients to act on.
                for try await datum in motionManager {
                    // FIXME: Isn't CMWatcher redundant of the for-try-await in AcccelerometryView?
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
 */

/// A three-axis display of acceleration components from ``CMAccelerometerData``,
struct AcccelerometryView: View {
    /// A null initializer, as a hook for debugging messages.
    init() {
        print("entry to AcccelerometryView() (debug only)")
    }

    // MARK: Properties
    /// The default frequency of readings.
    ///
    /// It should be possible to override this (60 Hz), but there's no option.
    static let hzOverride: TimeInterval = 1.0/60.0
    // FIXME: Respond to color scheme in the other views.
    @Environment(\.colorScheme) private var colorScheme

    enum Errors: Error {
        case collectionCancelled
    }
    /// Should the vertical axis be logarithmic?
    @State private var logarithmicGraph = false
    /// Is collection in progress?
    @State private var isCollecting = false
    /// Source for accelerometry readings.
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

    // MARK: - Body
    var body: some View {
        VStack(alignment: .center, spacing: 20.0) {

            // MARK: Title block
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

            // MARK: Max/min a⃑
            VStack {
                Text("Max acceleration: \(accelerationStore.xMax?.pointThree.description ?? "N/A")")
                Text("Min acceleration: \(accelerationStore.xMin?.pointThree.description ?? "N/A")")
            }
            .padding()

            /// MARK: Component bar graph
            if isCollecting {
                // MARK: - Active
                VStack {
                    SimpleBarView(
                        [
                            abs(reading.acceleration.x),
                            abs(reading.acceleration.y),
                            abs(reading.acceleration.z)
                        ],
                        spacing: 0.20, color: .teal, reservedMax: 1.25)
                }
                // MARK: |a| bar
                HorizontalBar(reading.acceleration.scalar,
                              minValue: 0.05, maxValue: 8.0)
                .frame(height: 40, alignment: .leading)
            }
            else {
                // MARK: - Idle
                VStack {
                    ZStack(alignment: .center) {
                        Rectangle()
                            .foregroundColor(
                                Color(.sRGB,
                                      white: (colorScheme == .light) ? 0.95 : 0.4,
                                      opacity: 1.0))
                        if accelerationStore.isEmpty {
                            // MARK: No-data plot
                            Text("No data").font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                        else {
                            // MARK: Data plot
                            AccelerometryPlotView(
                                logarithmicGraph ?
                                accelerationStore.applying { log10(Swift.max($0, 0.01)) }
                                : accelerationStore,
                                lineColor: .red)
                        }
                    }
                    .frame(height: 360)
                    // MARK: Log/linear scale
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
        // MARK: - Fetch components
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

// MARK: - Previews
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
