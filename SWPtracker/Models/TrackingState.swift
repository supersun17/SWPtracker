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

	var currentlyDoing: String? {
		get {
			return UserDefaults.standard.value(forKey: "currentlyDoing") as? String
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "currentlyDoing")
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
}

