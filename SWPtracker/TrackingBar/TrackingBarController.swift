//
//  TrackingBarController.swift
//  SWPtracker
//
//  Created by Ming Sun on 1/4/21.
//  Copyright © 2021 Ming Sun. All rights reserved.
//

import UIKit



protocol TrackingBarDelegate: NSObjectProtocol {
    var topRowTimeSpan: TimeInterval { get }
    func isTracking(_ trackingListName: String) -> Bool
    func rowHeight(totalHeight: CGFloat, _ timePeriod: TimeInterval) -> CGFloat
}


class TrackingBarController: UIViewController {

    lazy var contentView: TrackingBar = TrackingBar()

    let ranbowColors: [UIColor] = [
        UIColor(hexString: "#fb131b"),
        UIColor(hexString: "#fb5713"),
        UIColor(hexString: "#fba213"),
        UIColor(hexString: "#fbdb13"),
        UIColor(hexString: "#f3fb13"),
        UIColor(hexString: "#c7fb13"),
        UIColor(hexString: "#91fb13"),
        UIColor(hexString: "#13fb18"),
        UIColor(hexString: "#13fbbd"),
        UIColor(hexString: "#13fbf9"),
        UIColor(hexString: "#13d1fb"),
        UIColor(hexString: "#13a6fb"),
        UIColor(hexString: "#1375fb"),
        UIColor(hexString: "#1320fb"),
        UIColor(hexString: "#5413fb"),
        UIColor(hexString: "#9a13fb"),
        UIColor(hexString: "#cf13fb"),
        UIColor(hexString: "#fb13e8"),
        UIColor(hexString: "#fb13a2")
    ]
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
        view = contentView
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
        let additionalTimeFragment = isTracking ? delegate.topRowTimeSpan : 0.0
        let totalTime = trackingList.totalLength + additionalTimeFragment
        contentView.subTitle.text = String(format: "%1$@\n%2$@", trackingList.listName, totalTime.toMMSSString)
    }
}


extension TrackingBarController: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        contentView.table.delegate = self
        contentView.table.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let activeRow = delegate.isTracking(trackingList.listName) ? 1 : 0
        return trackingList.numberOfRecords + activeRow
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0..<trackingList.numberOfRecords:
            let record = trackingList.sortedRecords[indexPath.row]
            return delegate.rowHeight(totalHeight: contentView.table.bounds.height, record.end - record.start)
        default:
            return delegate.rowHeight(totalHeight: contentView.table.bounds.height, delegate.topRowTimeSpan)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
        cell.backgroundColor = ranbowColors[indexPath.row % ranbowColors.count]
        return cell
    }
}

