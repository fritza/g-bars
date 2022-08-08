//
//  TimeReader.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/5/22.
//

import Foundation
import Combine

#if LOGGER
import os.log
let logger = Logger()
let signposter = OSSignposter(subsystem: "com.wt9t.G-Bars",
                              category: .pointsOfInterest)
#endif


final class TimeReader: ObservableObject {
    enum TerminationErrors: Error, CustomStringConvertible {
        case cancelled
        case expired

        var description: String {
            switch self {
            case .expired  : return "the timer expired"
            case .cancelled: return "the count was cancelled"
            }
        }
    }

    enum TimerStatus: String {
        case ready, running, cancelled, expired
    }


    @Published var currentTime: MinSecAndFraction = .zero
    @Published var status: TimerStatus = .ready

    var startingDate, endingDate: Date
    let totalInterval: TimeInterval
    let tickInterval: TimeInterval
    let tickTolerance: TimeInterval

    var timeSubject = PassthroughSubject<MinSecAndFraction, Never>()
    var secondsSubject = PassthroughSubject<Int, Never>()

    var intervalState: OSSignpostIntervalState

    init(interval: TimeInterval, by tickSize: TimeInterval = 0.01) {
        let spIS = signposter.beginInterval("TimeReader init")
        intervalState = spIS

        tickInterval = tickSize
        tickTolerance = tickSize / 20.0

        let currentDate = Date()
        totalInterval = interval
        startingDate = currentDate
        endingDate = Date().addingTimeInterval(interval)
        signposter.endInterval("TimeReader init", spIS)
    }


    var sharedTimer: AnyPublisher<MinSecAndFraction, Error>!
    var timeCancellable: AnyCancellable!
    var secondsCancellable: AnyCancellable!
    func cancel() {
        assert(status == .running)
        status = .cancelled

        timeCancellable = nil
        secondsCancellable = nil
        sharedTimer = nil
    }

    func start() {
        assert(status == .ready,
        "attempt to restart a timer")

        startingDate = Date()
        endingDate = Date().addingTimeInterval(totalInterval)
        status = .running
        sharedTimer = setUpCombine().share().eraseToAnyPublisher()

        timeCancellable = sharedTimer
            .sink { completion in
                switch completion {
                case .finished: print("Tell the world it worked.")
                    self.status = .expired
                case .failure(let error):
                    guard let err = error as? TerminationErrors else {
                        print("other error: \(error).")
                        return
                    }
                    switch err {
                    case .expired: print("Clock ran out")
                    case .cancelled: print("was cancelled")
                        self.status = .cancelled
                    }
                }
            } receiveValue: { msf in
                self.timeSubject.send(msf)
            }

        secondsCancellable = sharedTimer
            .map { $0.second }
            .removeDuplicates()
            .assertNoFailure()
            .sink { secInteger in
                self.secondsSubject.send(secInteger)
            }
    }

    static let roundingScale = 100.0

    private func setUpCombine() -> AnyPublisher<MinSecAndFraction, Error>
    {
        let retval = Timer.publish(every: tickInterval,
                                   tolerance: tickTolerance,
                                   on: .main, in: .common)
            .autoconnect()
            .tryMap {
                (date: Date) -> TimeInterval in
                guard date <= self.endingDate else {
                    self.status = .expired
                    throw TerminationErrors.expired
                }
                return self.endingDate.timeIntervalSince(date)
            }
            .map { rawInterval in
                let scaled = Self.roundingScale * rawInterval
                let trimmed = round(scaled)
                let rescaled = trimmed / Self.roundingScale
                return rescaled
            }
            .map {
                (tInterval: TimeInterval) -> MinSecAndFraction in
                let intInterval = Int(round(tInterval))
                return MinSecAndFraction(
                    minute: intInterval / 60,
                    second: intInterval % 60,
                    fraction: tInterval - trunc(tInterval)
                )
            }
            .eraseToAnyPublisher()
        return retval
    }
}

