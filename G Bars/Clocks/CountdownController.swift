//
//  CountdownController.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/15/22.
//

import Foundation
import Combine

final class CountdownController: ObservableObject {
    var durationInMinutes: Int
    var isRunning: Bool
    private var timePublisher: MinutePublisher!
    private var cancellables: Set<AnyCancellable> = []

    internal init(durationInMinutes: Int) {
        self.durationInMinutes = durationInMinutes
        self.isRunning = false
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

    private func startCounting(minutes: Int) {
        timePublisher.start()
        isRunning = true
    }

    private func stopCounting() {
        guard timePublisher != nil else {
            assertionFailure("\(#function) - Attempt to stop a counter that does not exist")
            return
        }
        timePublisher.stop(exhausted: false)
    }
}
