//
//  ViewController.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/5/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var currentDoingLabel: UILabel!
	@IBOutlet weak var timeSpentLabel: UILabel!
	@IBOutlet weak var playBarHeight: NSLayoutConstraint!
	@IBOutlet weak var playBarLabel: UILabel!
	@IBOutlet weak var workBarHeight: NSLayoutConstraint!
	@IBOutlet weak var workBarLabel: UILabel!
	@IBOutlet weak var studyBarHeight: NSLayoutConstraint!
	@IBOutlet weak var studyBarLabel: UILabel!
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var barsStack: UIStackView!

	var timer: Timer?
	let state = TrackingState()

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		recover()
		NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
	}

	@objc func willEnterForeground(_ notif: Notification) {
		recover()
	}

	@objc func willResignActive(_ notif: Notification) {
		timer?.invalidate()
		timer = nil
	}

	func recover() {
		renderStateToBars()
		recoverTracking()
	}

	func renderStateToBars() {
		playBarHeight.constant = convertTimeToHeight(state.caculatedPlay)
		workBarHeight.constant = convertTimeToHeight(state.caculatedWork)
		studyBarHeight.constant = convertTimeToHeight(state.caculatedStudy)

		playBarLabel.text = "Play \n \(getStringForTimeInterval(state.caculatedPlay))"
		workBarLabel.text = "Work \n \(getStringForTimeInterval(state.caculatedWork))"
		studyBarLabel.text = "Study \n \(getStringForTimeInterval(state.caculatedStudy))"
	}

	@IBAction func startButton(_ sender: UIButton) {
		if state.isTracking {
			endTracking()
		} else {
			popActionSheet()
		}
	}

	@IBAction func resetButton(_ sender: UIButton) {
		reset()
		renderStateToBars()
	}

	func reset() {
		state.caculatedStudy = 0
		state.caculatedPlay = 0
		state.caculatedWork = 0
		state.startTime = nil
		state.currentlyDoing = nil
	}

	func popActionSheet() {
		let sheet = UIAlertController()
		for item in Items.allCases {
			let action = UIAlertAction.init(title: item.rawValue, style: .default) { (_) in
				self.startTracking(item)
				self.startButton.setTitle("End", for: .normal)
			}
			sheet.addAction(action)
		}
		let action = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
		sheet.addAction(action)
		present(sheet, animated: true, completion: nil)
	}

	func convertTimeToHeight(_ time: TimeInterval) -> CGFloat {
		let maxHeight: CGFloat = barsStack.frame.height
		let maxTime: TimeInterval = 8 * 3600
		return maxHeight * CGFloat(time / maxTime)
	}
}

extension ViewController {
	func startTracking(_ item: Items) {
		state.currentlyDoing = item.rawValue
		state.startTime = convertDateToTime(Date())
		currentDoingLabel.text = item.rawValue
		startUpdateTimeSpentLabel()
	}

	func recoverTracking() {
		if state.isTracking {
			currentDoingLabel.text = state.currentlyDoing
			startButton.setTitle("End", for: .normal)
			startUpdateTimeSpentLabel()
		}
	}

	func endTracking() {
		if let itemString = state.currentlyDoing, let item = Items.init(rawValue: itemString) {
			switch item {
			case .Study:
				state.caculatedStudy += getTrackedSpentTime()
				break
			case .Work:
				state.caculatedWork += getTrackedSpentTime()
				break
			case .Play:
				state.caculatedPlay += getTrackedSpentTime()
				break
			}
		}
		renderStateToBars()
		state.currentlyDoing = nil
		state.startTime = nil
		startButton.setTitle("Start", for: .normal)
		currentDoingLabel.text = "None"
		timer?.invalidate()
		timer = nil
		timeSpentLabel.text = "00:00"
	}

	func startUpdateTimeSpentLabel() {
		timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTimeSpentLabel), userInfo: nil, repeats: true)
		timer?.fire()
	}

	@objc func updateTimeSpentLabel() {
		let date = Date.init(timeIntervalSince1970: state.startTime ?? 0.00)
		timeSpentLabel.text = getStringForElapsedTime(by: date)
	}

	func getTrackedSpentTime() -> TimeInterval {
		let date = Date.init(timeIntervalSince1970: state.startTime ?? 0.00)
		let now = Date()
		return now.timeIntervalSince(date)
	}
}

