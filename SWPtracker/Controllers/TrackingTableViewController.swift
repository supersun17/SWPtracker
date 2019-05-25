//
//  TrackingTableViewController.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/22/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import UIKit

protocol TrackingControllerHelper: NSObjectProtocol {
	func convertTimePeriodToHeight(_ timePeriod: TimeInterval) -> CGFloat
}

class TrackingController: NSObject {
	private let reusableCellIdentifier: String = "TrackingListCell"

	var trackingList: TrackingList!
	weak var tableView: UITableView!
	weak var label: UILabel!
	weak var helper: TrackingControllerHelper?

	func setup(trackingList: TrackingList, tableView: UITableView, label: UILabel, helper: TrackingControllerHelper) {
		self.trackingList = trackingList
		self.tableView = tableView
		self.tableView.separatorStyle = .none
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.isScrollEnabled = false
		self.tableView.allowsSelection = false
		self.label = label
		self.helper = helper
	}

	func reloadData() {
		tableView?.reloadData()

		label.text = "\(trackingList.listName!)\n\(getStringForTimeInterval(trackingList.getTimeFragmentsTotalLength()))"
	}
}

extension TrackingController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return trackingList.getRecordsArray().count
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let record = trackingList.getRecordsArray()[indexPath.row]
		if let height = helper?.convertTimePeriodToHeight(record.end - record.start) {
			return height
		} else {
			return tableView.estimatedRowHeight
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellIdentifier) {
			return cell
		} else {
			let cell = UITableViewCell.init(style: .default, reuseIdentifier: reusableCellIdentifier)
			cell.backgroundColor = getRanbowColors()[indexPath.row % 7]
			return cell
		}
	}
}
