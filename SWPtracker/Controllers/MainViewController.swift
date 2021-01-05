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
    private var tbcDict: [String: TrackingBarController] = [:]
    private let refreshInterval: TimeInterval = 1
    private let timePeriodCap: TimeInterval = 2.0 * 3600.0
    var timeSpanSinceTrackingStarted: TimeInterval {
        guard let startTime = state.startTime else { return 0.0 }
        let startDate = Date(timeIntervalSince1970: startTime)
        let now = Date()
        return now.timeIntervalSince(startDate)
    }

    override func loadView() {
        view = MainView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupTrackingBars()
        if state.isTracking {
            startTrackingTimer()
        }
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
	}

	@objc func willEnterForeground(_ notif: Notification) {
        if state.isTracking {
            startTrackingTimer()
        }
	}

	@objc func willResignActive(_ notif: Notification) {
        if state.isTracking {
            endTrackingTimer()
        }
	}
}


extension MainViewController {
    func setupActions() {
        contentView.resetBtn.addTarget(self, action: #selector(handleResetTap), for: .touchUpInside)
        contentView.startBtn.addTarget(self, action: #selector(handleStartTap), for: .touchUpInside)
        contentView.addBtn.addTarget(self, action: #selector(handleAddTap), for: .touchUpInside)
    }

	@objc
    func handleStartTap(_ sender: UIButton) {
		if state.isTracking {
			endTracking()
		} else {
			presentStartTrackingAlert()
		}
	}

	@objc
    func handleResetTap(_ sender: UIButton) {
        resetTracking()
	}

	@objc
    func handleAddTap(_ sender: UIButton) {
		presentCreateNewTrackerAlert()
	}

	func presentStartTrackingAlert() {
		let sheet = UIAlertController()
        for listName in tbcDict.keys {
            let action = UIAlertAction(title: listName, style: .default) { [weak self] (_) in
                self?.startTracking(listName)
            }
            sheet.addAction(action)
		}
		let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		sheet.addAction(action)
		present(sheet, animated: true, completion: nil)
	}

	func presentCreateNewTrackerAlert() {
		let alertController = UIAlertController(title: "Create a new tracker", message: "Give it a name", preferredStyle: .alert)
		alertController.addTextField {
            $0.autocapitalizationType = .allCharacters
            $0.placeholder = "Name of the tracker"
        }
		let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] (action) in
			if let newListName = alertController.textFields?.first?.text,
               !newListName.isEmpty {
                guard let trackingList = TrackingList.factory(with: newListName) else { return }
                self?.addTrackerBarController(trackingList)
                self?.updateUI()
			} else {
				self?.presentError("Invalid tracker name")
			}
		}
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		for action in [cancel,confirm] {
			alertController.addAction(action)
		}

		self.present(alertController, animated: true)
	}

	func presentError(_ message: String) {
		let alertController = UIAlertController(title: "Error occurred", message: message, preferredStyle: .alert)
		self.present(alertController, animated: true, completion: nil)
	}
}

// MARK: - Tracking control
extension MainViewController {
    func setupTrackingBars() {
        let allList = TrackingList.fetchAllList()
        for trackingList in allList {
            addTrackerBarController(trackingList)
        }
        contentView.enableStart(!tbcDict.keys.isEmpty)
    }

    func addTrackerBarController(_ trackingList: TrackingList) {
        let trackingController = TrackingBarController(trackingList: trackingList, delegate: self)
        tbcDict[trackingList.listName] = trackingController
        addChild(trackingController)
        contentView.addTrackingBar(trackingBar: trackingController.contentView)
    }

	func startTracking(_ listName: String) {
		state.start(trackingListName: listName)
        startTrackingTimer()
	}

	func endTracking() {
		endTrackingTimer()
		if let listName = state.trackingListName {
            tbcDict[listName]?.saveRecord(startTime: state.startTime ?? 0.0, endTime: (state.startTime ?? 0.0) + timeSpanSinceTrackingStarted)
		}
        state.clear()
        updateUI()
	}

    func resetTracking() {
        endTrackingTimer()
        for tbc in tbcDict.values { tbc.deleteAllRecords() }
        state.clear()
        updateUI()
    }

	func startTrackingTimer() {
		timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
		timer?.fire()
	}

    func endTrackingTimer() {
        timer?.invalidate()
        timer = nil
    }

	@objc
    func updateUI() {
        contentView.enableStart(!tbcDict.keys.isEmpty)
        contentView.updateUI(mmssString: state.isTracking ? toMMSS(timeSpanSinceTrackingStarted) : nil, trackingListName: state.trackingListName)
        tbcDict.values.forEach { $0.updateUI() }
	}
}

// MARK: - TrackingBarDelegate
extension MainViewController: TrackingBarDelegate {
    func topRowHeight() -> TimeInterval {
        return timeSpanSinceTrackingStarted
    }

    func isTracking(_ trackingListName: String) -> Bool {
        return state.trackingListName == trackingListName
    }
    
    func rowHeight(totalHeight: CGFloat, _ timePeriod: TimeInterval) -> CGFloat {
        let longestTime: TimeInterval = tbcDict.values.reduce(0.0) { max($0, $1.trackingList.totalLength) }
        let timeCap: TimeInterval = max(longestTime, timePeriodCap)
        let timeScale: TimeInterval = timePeriod / timeCap
        return totalHeight * CGFloat(timeScale)
	}
}

