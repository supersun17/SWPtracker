//
//  Helpers.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/5/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import UIKit

func generateRandomColor() -> UIColor {
	let red = CGFloat(arc4random_uniform(1000)) / 1000
	let green = CGFloat(arc4random_uniform(1000)) / 1000
	let blue = CGFloat(arc4random_uniform(1000)) / 1000
	return UIColor.init(red: red, green: green, blue: blue, alpha: 1)
}

func getRanbowColors() -> [UIColor] {
	return [
		UIColor.init(hexString: "#FF0000"),
		UIColor.init(hexString: "#FF7F00"),
		UIColor.init(hexString: "#FFFF00"),
		UIColor.init(hexString: "#00FF00"),
		UIColor.init(hexString: "#0000FF"),
		UIColor.init(hexString: "#4B0082"),
		UIColor.init(hexString: "#8B00FF")
	]
}

extension UIColor {
	//// Copied as it is from Stack link
	/// Not moved values to constant as it would be difficult to name them
	convenience init(hexString: String) {
		let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int = UInt32()
		Scanner(string: hex).scanHexInt32(&int)
		let a, r, g, b: UInt32
		switch hex.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (255, 0, 0, 0)
		}
		self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
	}
}

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
