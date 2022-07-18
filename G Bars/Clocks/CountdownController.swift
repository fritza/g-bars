//
//  CountdownController.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/15/22.
//

import Foundation
import Combine
import SwiftUI

enum CancellationReasons {
    case notCancelled, cancelled, ranOut
}

final class CountdownController: ObservableObject {
    @AppStorage(AppStorageKeys.walkInMinutes.rawValue) private var durationInMinutes: Int = 2
    @Published var isRunning: Bool = false
//    @Published var durationInMinutes: Int = dur

    @Published var timePublisher: MinutePublisher!
//    @Published var mmss: String
//    @Published var seconds: Int
//    @Published var minutes: Int
//    @Published var fraction: TimeInterval
//    @Published var halted: CancellationReasons

    private var cancellables: Set<AnyCancellable> = []

    init() {
        self.isRunning = false
        let publisher = MinutePublisher(
            after: TimeInterval(durationInMinutes * 60))
        timePublisher = publisher
    }

    func prepareSubscribers(for deadline: Int) {
        timePublisher = MinutePublisher(
            after: TimeInterval(deadline * 60))
        timePublisher.completedSubject
            .sink { didRunOut in
                // Now do whatever is needed by the views.
            }
            .store(in: &cancellables)
    }

    func startCounting() {
        timePublisher.start()
        isRunning = true
    }

    func stopCounting(timeRanOut: Bool = true) {
        guard timePublisher != nil else {
            assertionFailure("\(#function) - Attempt to stop a counter that does not exist")
            return
        }
        timePublisher.stop(exhausted: timeRanOut)
    }
}
