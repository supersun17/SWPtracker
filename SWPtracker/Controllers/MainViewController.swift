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

	private var timer: Timer?
	private let state = TrackingState()

    override func loadView() {
        view = MainView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        recover()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
	}

	@objc func willEnterForeground(_ notif: Notification) {
		resumeTracking()
	}

	@objc func willResignActive(_ notif: Notification) {
		endTrackingTimer()
	}
}


extension MainViewController {

    func setupActions() {
        contentView.resetBtn.addTarget(self, action: #selector(handleResetTap), for: .touchUpInside)
        contentView.startBtn.addTarget(self, action: #selector(handleStartTap), for: .touchUpInside)
        contentView.addBtn.addTarget(self, action: #selector(handleAddTap), for: .touchUpInside)
    }

	func recover() {
		let allList = TrackingList.fetchAllList()
		for trackingList in allList {
            constructTracker(trackingList)
		}
        resumeTracking()
        contentView.reloadTrackingBars()
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
        contentView.reloadTrackingBars()
	}

	@objc
    func handleAddTap(_ sender: UIButton) {
		popTrackerCreation()
	}

	func reset() {
        for trackingBar in contentView.trackingBars {
			if let records = trackingBar.trackingList.records {
                trackingBar.trackingList.removeFromRecords(records)
			}
		}
		state.clear()
	}

	func popStartTracking() {
		guard !contentView.trackingBars.isEmpty else { return }
		let sheet = UIAlertController()
		for trackingBar in contentView.trackingBars {
            let listName = trackingBar.trackingList.listName ?? ""
            let action = UIAlertAction(title: listName, style: .default) { [weak self] (_) in
                self?.startTracking(listName)
            }
            sheet.addAction(action)
		}

		let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		sheet.addAction(action)
		present(sheet, animated: true, completion: nil)
	}

	func popTrackerCreation() {
		let alertController = UIAlertController.init(title: "Create a new tracker", message: "Give it a name", preferredStyle: .alert)

		alertController.addTextField { $0.placeholder = "Name of the tracker" }

		let confirm = UIAlertAction.init(title: "OK", style: .default) { [weak self] (action) in
			if let newListName = alertController.textFields?.first?.text,
               !newListName.isEmpty {
                guard let trackingList = TrackingList.factory(with: newListName) else { return }
                self?.constructTracker(trackingList)
			} else {
				self?.popErrorMessage("Invalid tracker name")
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

// MARK: - Tracking control
extension MainViewController {
    func constructTracker(_ trackingList: TrackingList) {
        let trackingBar = TrackingBar(trackingList: trackingList, dataSource: self)
        contentView.addTrackingBar(trackingBar: trackingBar)
    }

	func startTracking(_ listName: String) {
		state.start(trackingListName: listName)
		resumeTracking()
	}

	func resumeTracking() {
		if state.isTracking {
			startTrackingTimer()
		}
	}

	func endTracking() {
		endTrackingTimer()
		if let listName = state.trackingListName,
           let newRecord = TrackingRecord.factory(with: listName, state.startTime ?? 0.00, (state.startTime ?? 0.00) + timeSpanSinceTrackingStarted) {
            contentView.trackingBar(withTrackingListName: listName)?.trackingList.addToRecords(newRecord)
            contentView.reloadTrackingBars()
		}
        state.clear()
        contentView.updateUI(hhmmString: nil, trackingListName: nil)
	}

	func startTrackingTimer() {
		timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
		timer?.fire()
	}

    func endTrackingTimer() {
        timer?.invalidate()
        timer = nil
    }

	@objc
    func updateUI() {
        contentView.updateUI(hhmmString: gethhmmStringFromTimeInterval(timeSpanSinceTrackingStarted), trackingListName: state.trackingListName)
        contentView.reloadTrackingBars()
	}
}

// MARK: - TrackingBarDataSource
extension MainViewController: TrackingBarDataSource {
    var timeSpanSinceTrackingStarted: TimeInterval {
        guard let startTime = state.startTime else { return 0.0 }
        let startDate = Date(timeIntervalSince1970: startTime)
        let now = Date()
        return now.timeIntervalSince(startDate)
    }

    func isTracking(_ trackingListName: String) -> Bool {
        return state.trackingListName == trackingListName
    }
    
    func scaledHeight(totalHeight: CGFloat, _ timePeriod: TimeInterval) -> CGFloat {
        let longestTime: TimeInterval = contentView.trackingBars.reduce(0.0) { max($0, $1.trackingList.timeFragmentsTotalLength) }
        let timeCap: TimeInterval = max(longestTime, 2.0 * 3600.0)
        let timeScale: TimeInterval = timePeriod / timeCap
        return totalHeight * CGFloat(timeScale)
	}
}

