//
//  ViewController.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/5/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var contentView: MainView { view as! MainView }

    var currentDoingLabel: UILabel { contentView.currentlyDoing }
    var timeSpentLabel: UILabel { contentView.timeSpent }
    var barsStack: UIStackView { contentView.barStack }
    var resetBtn: UIButton { contentView.resetBtn }
    var startBtn: UIButton { contentView.startBtn }
    var addBtn: UIButton { contentView.addBtn }
	var trackingTVCs: [String:TrackingController] = [:]

	var timer: Timer?
	let state = TrackingState()

    override func loadView() {
        view = MainView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		recover()
		NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
	}

	@objc func willEnterForeground(_ notif: Notification) {
		resumeTracking()
	}

	@objc func willResignActive(_ notif: Notification) {
		pauseTracking()
	}
}


extension MainViewController {

    func setupActions() {
        resetBtn.addTarget(self, action: #selector(handleResetTap), for: .touchUpInside)
        startBtn.addTarget(self, action: #selector(handleStartTap), for: .touchUpInside)
        addBtn.addTarget(self, action: #selector(handleAddTap), for: .touchUpInside)
    }

	func recover() {
		let allList = TrackingList.fetchAllList()
		for list in allList {
			constructTracker(list)
		}
        resumeTracking()
		renderStateToTracker()
	}

	func renderStateToTracker(_ listName: String? = nil) {
		if let listName = listName {
			trackingTVCs[listName]?.reloadData()
		} else {
			for trackingTVC in trackingTVCs.values {
				trackingTVC.reloadData()
			}
		}
	}

	@objc
    func handleStartTap(_ sender: UIButton) {
		if state.isTracking {
			endTracking()
		} else {
			popStartTracking()
		}
	}

	@objc
    func handleResetTap(_ sender: UIButton) {
		reset()
		renderStateToTracker()
	}

	@objc
    func handleAddTap(_ sender: UIButton) {
		popTrackerCreation()
	}

	func reset() {
		for trackingTVC in trackingTVCs.values {
			if let records = trackingTVC.trackingList.records {
				trackingTVC.trackingList.removeFromRecords(records)
			}
		}
		state.startTime = nil
		state.currentlyDoing = nil
	}

	func popStartTracking() {
		if trackingTVCs.keys.count == 0 { return }
		let sheet = UIAlertController()
		for trackingTVC in trackingTVCs.values {
			let listName = trackingTVC.trackingList.listName!
			let action = UIAlertAction.init(title: listName, style: .default) { (_) in
				self.startTracking(listName)
			}
			sheet.addAction(action)
		}

		let action = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
		sheet.addAction(action)

		present(sheet, animated: true, completion: nil)
	}

	func popTrackerCreation() {
		let alertController = UIAlertController.init(title: "Create a new tracker", message: "Give it a name", preferredStyle: .alert)

		alertController.addTextField { $0.placeholder = "Name of the tracker" }

		let confirm = UIAlertAction.init(title: "OK", style: .default) { (action) in
			if let text = alertController.textFields?.first?.text, !text.isEmpty {
				self.addTracker(text)
			} else {
				self.popErrorMessage("Invalid tracker name")
			}
		}
		let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
		for action in [cancel,confirm] {
			alertController.addAction(action)
		}

		self.present(alertController, animated: true)
	}

	func popErrorMessage(_ message: String) {
		let alertController = UIAlertController.init(title: "Error occurred", message: message, preferredStyle: .alert)
		self.present(alertController, animated: true, completion: nil)
	}
}

extension MainViewController {
	func startTracking(_ listName: String) {
		state.currentlyDoing = listName
		state.startTime = convertDateToTime(Date())

		resumeTracking()
	}

	func resumeTracking() {
		if state.isTracking {
			currentDoingLabel.text = state.currentlyDoing
			startBtn.setTitle("End", for: .normal)
            if let listName = state.currentlyDoing {
                trackingTVCs[listName]?.dynamicTrackingTime = getTrackedSpentTime()
            }
			startUpdateTimeSpentLabel()
		}
	}

	func pauseTracking() {
		timer?.invalidate()
		timer = nil
	}

	func endTracking() {
		pauseTracking()

		if let listName = state.currentlyDoing,
           let newRecord = TrackingRecord.factory(with: "listName", state.startTime ?? 0.00, (state.startTime ?? 0.00) + getTrackedSpentTime()) {
			trackingTVCs[listName]?.trackingList.addToRecords(newRecord)
            trackingTVCs[listName]?.dynamicTrackingTime = 0
			renderStateToTracker(listName)
		}
		state.currentlyDoing = nil
		state.startTime = nil
		startBtn.setTitle("Start", for: .normal)
		currentDoingLabel.text = "None"
		timeSpentLabel.text = "00:00"
	}

	func startUpdateTimeSpentLabel() {
		timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTimeSpentUI), userInfo: nil, repeats: true)
		timer?.fire()
	}

	@objc
    func updateTimeSpentUI() {
		let date = Date.init(timeIntervalSince1970: state.startTime ?? 0.00)
		timeSpentLabel.text = getStringForElapsedTime(by: date)

        if let listName = state.currentlyDoing {
            trackingTVCs[listName]?.dynamicTrackingTime = getTrackedSpentTime()
            renderStateToTracker(listName)
        }
	}

	func getTrackedSpentTime() -> TimeInterval {
		let date = Date.init(timeIntervalSince1970: state.startTime ?? 0.00)
		let now = Date()
		return now.timeIntervalSince(date)
	}
}

extension MainViewController: TrackingControllerHelper {
	func convertTimePeriodToHeight(_ timePeriod: TimeInterval) -> CGFloat {
		var tableViewHeight: CGFloat = 0
		let timeArray: [TimeInterval] = trackingTVCs.values.map {
			tableViewHeight = max(tableViewHeight,$0.tableView.frame.height)
			return $0.trackingList.getTimeFragmentsTotalLength()
		}
		var maxTime: TimeInterval = 8 * 3600
		for time in timeArray {
			maxTime = max(maxTime,time)
		}
		return tableViewHeight * CGFloat(timePeriod / maxTime)
	}

	func addTracker(_ listName: String) {
		guard let trackingList = TrackingList.factory(with: listName) else { return }

		constructTracker(trackingList)
	}

	func constructTracker(_ trackingList: TrackingList) {
		let holderView = UIView()
		barsStack.addArrangedSubview(holderView)

		let tableView = UITableView()
		tableView.separatorInset = UIEdgeInsets.zero
		tableView.backgroundColor = .secondarySystemBackground
		tableView.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)

		let labelView = UILabel()
		labelView.textAlignment = .center
		labelView.numberOfLines = 2

		let views: Dictionary<String,UIView> = [
			"tableView": tableView,
			"labelView": labelView
		]
		for view in views.values {
			holderView.addSubview(view)
			view.translatesAutoresizingMaskIntoConstraints = false
		}

		var constraints: [NSLayoutConstraint] = []
		constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: .directionMask, metrics: nil, views: views))
		constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[labelView]|", options: .directionMask, metrics: nil, views: views))
		constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView][labelView(==66)]|", options: .directionMask, metrics: nil, views: views))
		NSLayoutConstraint.activate(constraints)

		let trackingController = TrackingController()
		trackingController.setup(trackingList: trackingList, tableView: tableView, label: labelView, helper: self)

		trackingTVCs[trackingList.listName] = trackingController
	}
}

