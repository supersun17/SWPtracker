//
//  Helpers.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/5/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import UIKit
import CoreData


extension UIColor {
	//// Copied as it is from Stack link
	/// Not moved values to constant as it would be difficult to name them
	convenience init(hexString: String) {
		let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
		let a, r, g, b: UInt64
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


extension TimeInterval {

    var toHHMMString: String {
        let secondsPast = self
        let hours = Int(secondsPast / 3600)
        let minutes = Int((secondsPast - 3600 * TimeInterval(hours)) / 60)
        return String(format: "%02d:%02d", hours, minutes)
    }

    var toMMSSString: String {
        let secondsPast = self
        let minutes = Int(secondsPast / 60)
        let seconds = Int(secondsPast - 60 * TimeInterval(minutes))
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
