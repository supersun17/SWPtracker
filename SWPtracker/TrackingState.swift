//
//  TrackingState.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/5/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import Foundation

enum Items: String, CaseIterable {
	case Study, Work, Play
}

class TrackingState {
	var isTracking: Bool {
		if startTime == nil {
			return false
		} else {
			return true
		}
	}

	var caculatedStudy: Double {
		get {
			return UserDefaults.standard.value(forKey: Items.Study.rawValue) as? Double ?? 0.00
		}
		set {
			UserDefaults.standard.set(newValue, forKey: Items.Study.rawValue)
		}
	}
	var caculatedWork: Double {
		get {
			return UserDefaults.standard.value(forKey: Items.Work.rawValue) as? Double ?? 0.00
		}
		set {
			UserDefaults.standard.set(newValue, forKey: Items.Work.rawValue)
		}
	}
	var caculatedPlay: Double {
		get {
			return UserDefaults.standard.value(forKey: Items.Play.rawValue) as? Double ?? 0.00
		}
		set {
			UserDefaults.standard.set(newValue, forKey: Items.Play.rawValue)
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

