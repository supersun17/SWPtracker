//
//  Helpers.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/5/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import Foundation

func convertDateToTime(_ date: Date) -> TimeInterval {
	return date.timeIntervalSince1970
}

func getString(from date: Date) -> String {
	let fmt = DateFormatter()
	fmt.dateFormat = "HH:mm"
	return fmt.string(from: date)
}

func getStringForElapsedTime(by date: Date) -> String {
	let now = Date()
	let secondsPast = now.timeIntervalSince(date)
	let hours = Int(secondsPast / 3600)
	let minutes = Int((secondsPast - 3600 * TimeInterval(hours)) / 60)
	return String.init(format: "%02d:%02d", hours, minutes)
}

func getStringForTimeInterval(_ time: TimeInterval) -> String {
	let secondsPast = time
	let hours = Int(secondsPast / 3600)
	let minutes = Int((secondsPast - 3600 * TimeInterval(hours)) / 60)
	return String.init(format: "%02d:%02d", hours, minutes)
}
