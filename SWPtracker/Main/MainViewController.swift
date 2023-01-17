//
//  ViewController.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/5/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import Combine
import UIKit


class MainViewController: UIViewController {

    lazy var contentView: MainView = MainView()

    private let trackingService = TrackingService(refreshInterval: 1.0)
    @Published private(set) var tbcDict: [String: TrackingBarController] = [:]
    private var listNames: [String] = []
    private var anyCancallables: Set<AnyCancellable> = []
    let defaultTableTimeSpan: TimeInterval = 10.0


    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupTrackingBars()
        setupObserving()
        trackingService.restoreTracking()
    }

	@objc
    func willEnterForeground(_ notif: Notification) {
        trackingService.restoreTracking()
	}

	@objc
    func willResignActive(_ notif: Notification) {
        trackingService.pauseTracking()
    }
}


extension MainViewController {

    func setupActions() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        contentView.resetBtn.addTarget(self, action: #selector(handleResetTap), for: .touchUpInside)
        contentView.startBtn.addTarget(self, action: #selector(handleStartTap), for: .touchUpInside)
        contentView.addBtn.addTarget(self, action: #selector(handleAddTap), for: .touchUpInside)
    }

    func setupObserving() {
        trackingService.$timeSpan
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateUI()
            }
            .store(in: &anyCancallables)
        $tbcDict
            .receive(on: RunLoop.main)
            .map { !$0.keys.isEmpty }
            .sink { [weak self] shouldEnable in
                self?.contentView.enableStartBtn(shouldEnable)
            }
            .store(in: &anyCancallables)
    }

	@objc
    func handleStartTap(_ sender: UIButton) {
        if trackingService.state == .active {
            handleEndTap()
        } else {
            presentStartTrackingAlert()
        }
	}
    private func handleEndTap() {
        if let listName = trackingService.trackingListName {
            tbcDict[listName]?.saveRecord(startTime: trackingService.startTime ?? 0.0,
                                          endTime: (trackingService.startTime ?? 0.0) + (trackingService.timeSpan ?? 0.0))
        }
        trackingService.endTracking()
    }
    private func presentStartTrackingAlert() {
        let sheet = UIAlertController()
        for listName in listNames {
            let action = UIAlertAction(title: listName, style: .default) { [weak trackingService] (_) in
                trackingService?.startTracking(withTrackingListName: listName)
            }
            sheet.addAction(action)
        }
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(action)
        present(sheet, animated: true, completion: nil)
    }

	@objc
    func handleResetTap(_ sender: UIButton) {
        tbcDict.values.forEach {
            $0.deleteAllRecords()
            $0.updateUI()
        }
        trackingService.endTracking()
	}

	@objc
    func handleAddTap(_ sender: UIButton) {
		presentCreateNewTrackerAlert()
	}
	private func presentCreateNewTrackerAlert() {
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

    func handleTableLongPress(_ tbc: TrackingBarController) {
        presentConfirmListDeletionAlert(tbc)
    }
    private func presentConfirmListDeletionAlert(_ tbc: TrackingBarController) {
        let alertController = UIAlertController(title: "Delete this row?", message: "All records will be remvoed along with this list", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "OK", style: .default) { [weak self, weak tbc] (action) in
            guard let tbc = tbc else { return }
            self?.removeList(tbc)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        for action in [cancel,confirm] {
            alertController.addAction(action)
        }
        self.present(alertController, animated: true)
    }
    private func removeList(_ tbc: TrackingBarController) {
        if tbc.isBeingTracked {
            handleEndTap()
        }
        listNames.removeAll { $0 == tbc.trackingList.listName }
        tbcDict[tbc.trackingList.listName] = nil
        tbc.removeFromParent()
        tbc.contentView.removeFromSuperview()
        tbc.trackingList.delete()
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
    }

    func addTrackerBarController(_ trackingList: TrackingList) {
        let trackingController = TrackingBarController(trackingList: trackingList, trackingService: trackingService)
        tbcDict[trackingList.listName] = trackingController
        addChild(trackingController)
        trackingController.viewDidLoad()
        contentView.barStack.addArrangedSubview(trackingController.contentView)
        listNames.append(trackingList.listName)
    }

    func updateUI() {
        contentView.updateUI(mmssString: trackingService.timeSpan?.toMMSSString,
                             trackingListName: trackingService.trackingListName)
        tbcDict.values.forEach { $0.updateUI() }
	}
}
