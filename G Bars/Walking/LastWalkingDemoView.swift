//
//  LastWalkingDemoView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/19/22.
//

import SwiftUI

/*
 Further plan for demo walking:

 (deprecated) The min:sec view has to create/hook up with a MotionManager.
 A consumer for AccelerometerItems has to be created, then hook up with a MotionManager.
 The Items are stored as they come in from the manager.

 The consumer can be anything that appends `AcceleratorItem`s. Append to an array, write to file, whatever.

 The MotionManager can be abandoned when the count is done (though in fact it will survive as a global)
 The TimeWatcher, if any can be shared out of the view that already consumes time updates. The Consumet needs only to detect start and finish. I _think_ this is a good idea, rather than have everybody remember to start/stop the consumer.


 Updates in MotionManager start at MotionManager.makeAsyncIterator. So right when you start the async read loop. Is that wise? It may work out that way — don't go into the for loop until you're ready to accept the elements.

 Remember to MotionManager.cancelUpdates()
 */



// Remember at the end of each walk to preserve the CSV/data from the observer before resetting it.
// How do we do that? This View consumes it, and the WalkingContainerView has to harvest them at the end of .walk_1 and .walk_2

// `WalkingState` being `AppStages`, it's Hashable, therefore can be keys for `Dictionary`s.

// See WalkingState.csvPrefix for the dataset prefix. WalkingContainerView knows about it.
// Added WalkingState .demoSummary


struct LastWalkingDemoView: View, HasVoidCompletion {
    internal let completion: (() -> Void)

    init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    @State var currentURL: URL?

    func contents(forStage state: WalkingState) -> String {
        guard TimedWalkObserver.filePaths.count == 2 else {
            return "NO PATHS!"
        }
        let index = (state == .walk_1) ? 0 : 1
        let path = TimedWalkObserver.filePaths[index]
        currentURL = URL(fileURLWithPath: path)
        do {
            let str = try String(contentsOfFile: path)
            return str
        }
        catch {
            print("Error (\(error))\n\tretrieving", path)
            return "N/A"
        }
    }

    @State var fileContent: [String] = []

    func contentLines(forStage state: WalkingState) -> [String] {
        let lumped = contents(forStage: state)
        let retval = lumped.split(separator: "\r\n")
            .map { String($0) }
        return retval
    }

    var allLineData: Data {
        let rejoined = fileContent.joined(separator: "\r\n")
        let data = rejoined.data(using: .utf8)!
        return data
    }

    @State var shouldShowActivity = false

    var body: some View {
        VStack {
            Text("Both walks are complete. Browse the accelerometer contents here.").font(.title3)
            Text("(\(fileContent.count) records)").font(.caption)
            ScrollView() {
                LazyVStack(alignment: .leading) {
                    ForEach(fileContent, id: \.self) { line in
                        Text(line).font(.caption2.monospaced())
                    }
                }
            }
            Spacer()

            HStack {
                Spacer()
                Button() {
                    completion()
                }
            label: {
                Label("Repeat", systemImage: "arrow.counterclockwise")
            }
                Spacer()
                Button { shouldShowActivity = true }
            label: {
                Label("Export…", systemImage: "square.and.arrow.up")
            }
                Spacer()

            }
            .sheet(isPresented: $shouldShowActivity, content: {
                if currentURL != nil {
                    ActivityUIController(url: currentURL!,
                                         text: "\(allLineData.count) bytes")
                }
            })
            .navigationTitle("Summary")
        }
        .onAppear {
            if fileContent.isEmpty {
                fileContent = contentLines(forStage: .walk_1)
            }
        }
    }
}


struct LastWalkingDemoView_Previews: PreviewProvider {
    static var previews: some View {
        LastWalkingDemoView() {
            print("for rent")
        }
    }
}
