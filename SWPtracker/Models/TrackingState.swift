//
//  TrackingState.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/5/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import Foundation

class TrackingState {
	var isTracking: Bool {
		if startTime == nil {
			return false
		} else {
			return true
		}
	}

	var trackingListName: String? {
		get {
			return UserDefaults.standard.value(forKey: "trackingListName") as? String
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "trackingListName")
		}
	}
	
	var startTime: Double? {
		get {
			return UserDefaults.standard.value(forKey: "startTime") as? Double
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "startTime")
		}
	}

    func start(trackingListName tln: String) {
        trackingListName = tln
        startTime = Date().timeIntervalSince1970
    }

    func clear() {
        trackingListName = nil
        startTime = nil
    }
}

