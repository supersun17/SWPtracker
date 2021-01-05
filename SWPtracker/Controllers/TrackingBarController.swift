//
//  TrackingBarController.swift
//  SWPtracker
//
//  Created by Ming Sun on 1/4/21.
//  Copyright © 2021 Ming Sun. All rights reserved.
//

import UIKit



protocol TrackingBarDelegate: NSObjectProtocol {
    var timeSpanSinceTrackingStarted: TimeInterval { get }
    func isTracking(_ trackingListName: String) -> Bool
    func scaledHeight(totalHeight: CGFloat, _ timePeriod: TimeInterval) -> CGFloat
}


class TrackingBarController: UIViewController {
    var contentView: TrackingBar { view as! TrackingBar }
    weak var delegate: TrackingBarDelegate!
    private let cellID: String = "TrackingListCell"
    let trackingList: TrackingList

    init(trackingList tkl: TrackingList, delegate dlg: TrackingBarDelegate) {
        trackingList = tkl
        delegate = dlg
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = TrackingBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        reloadSubTitle()
    }

    func saveRecord(startTime: TimeInterval, endTime: TimeInterval) {
        if let newRecord = TrackingRecord.factory(with: trackingList.listName, startTime, endTime) {
            trackingList.addToRecords(newRecord)
        }
    }

    func deleteAllRecords() {
        if let records = trackingList.records {
            trackingList.removeFromRecords(records)
        }
    }

    func updateUI() {
        contentView.table.reloadData()
        reloadSubTitle()
    }

    private func reloadSubTitle() {
        let isTracking = delegate.isTracking(trackingList.listName)
        let additionalTimeFragment = isTracking ? delegate.timeSpanSinceTrackingStarted : 0.0
        let totalTime = trackingList.totalLength + additionalTimeFragment
        contentView.subTitle.text = String(format: "%1$@\n%2$@", trackingList.listName, toMMSS(totalTime))
    }
}


extension TrackingBarController: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        contentView.table.delegate = self
        contentView.table.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let activeRow = delegate.isTracking(trackingList.listName) ? 1 : 0
        return trackingList.sortedRecords.count + activeRow
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0..<trackingList.numberOfRecords:
            let record = trackingList.sortedRecords[indexPath.row]
            return delegate.scaledHeight(totalHeight: contentView.table.bounds.height, record.end - record.start)
        default:
            return delegate.scaledHeight(totalHeight: contentView.table.bounds.height, delegate.timeSpanSinceTrackingStarted)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
        cell.backgroundColor = ranbowColors[indexPath.row % ranbowColors.count]
        return cell
    }
}

