//
//  TrackingService.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/5/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import Combine
import Foundation


class TrackingService {

    enum State {
        case inactive
        case active
        case paused
    }

    // Published
    @Published var timeSpan: TimeInterval? = nil
    @Published var state: State = .inactive

    // Stored Data
	var trackingListName: String? {
		get { UserDefaults.standard.value(forKey: "trackingListName") as? String }
		set { UserDefaults.standard.set(newValue, forKey: "trackingListName") }
	}
	var startTime: Double? {
		get { UserDefaults.standard.value(forKey: "startTime") as? Double }
		set { UserDefaults.standard.set(newValue, forKey: "startTime") }
	}

    // Var
    private var wasTracking: Bool { startTime != nil }
    private let refreshInterval: TimeInterval
    private var trackingTimer: Timer?


    init(refreshInterval: TimeInterval) {
        self.refreshInterval = refreshInterval
    }

    func startTracking(withTrackingListName listName: String) {
        trackingListName = listName
        startTime = Date().timeIntervalSince1970
        trackingTimer = Timer.scheduledTimer(timeInterval: refreshInterval,
                                             target: self,
                                             selector: #selector(send),
                                             userInfo: nil,
                                             repeats: true)
        trackingTimer?.fire()
        state = .active
    }
    @objc
    private func send() {
        timeSpan = Date.now.timeIntervalSince1970 - (startTime ?? 0.0)
    }

    func pauseTracking() {
        endTrackingTimer()
        state = .paused
    }

    func restoreTracking() {
        guard wasTracking else { return }
        trackingTimer = Timer.scheduledTimer(timeInterval: refreshInterval,
                                             target: self,
                                             selector: #selector(send),
                                             userInfo: nil,
                                             repeats: true)
        trackingTimer?.fire()
        state = .active
    }

    func endTracking() {
        endTrackingTimer()
        clear()
        state = .inactive
    }

    func resetTracking() {
        endTrackingTimer()
//        for tbc in tbcDict.values { tbc.deleteAllRecords() }
        clear()
        state = .inactive
    }

    private func endTrackingTimer() {
        trackingTimer?.invalidate()
        trackingTimer = nil
    }

    private func clear() {
        trackingListName = nil
        startTime = nil
        timeSpan = nil
    }
}

