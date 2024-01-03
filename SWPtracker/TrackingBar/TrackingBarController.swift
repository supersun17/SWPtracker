//
//  TrackingBarController.swift
//  SWPtracker
//
//  Created by Ming Sun on 1/4/21.
//  Copyright © 2021 Ming Sun. All rights reserved.
//

import UIKit


class TrackingBarController: UIViewController {

    lazy var contentView: TrackingBar = TrackingBar()

    let ranbowColors: [UIColor] = [
        UIColor(hexString: "#1320fb"),
        UIColor(hexString: "#5413fb"),
        UIColor(hexString: "#9a13fb"),
        UIColor(hexString: "#cf13fb"),
        UIColor(hexString: "#fb13e8"),
        UIColor(hexString: "#fb13a2"),
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
        UIColor(hexString: "#1375fb")
    ].reversed()
    private let cellID: String = "TrackingListCell"

    weak var trackingService: TrackingService?
    weak var db: TrackingDataBase?
    weak var mainVC: MainViewController? { parent as? MainViewController }
    let trackingList: TrackingList
    var isBeingTracked: Bool {
        guard let trackingListName = trackingService?.trackingListName else { return false }
        return trackingList.listName == trackingListName
    }
    var trackingTimeSpan: TimeInterval {
        guard isBeingTracked else { return 0.0 }
        return trackingService?.timeSpan ?? 0.0
    }


    init(trackingList: TrackingList, trackingService: TrackingService?, db: TrackingDataBase?) {
        self.trackingList = trackingList
        self.trackingService = trackingService
        self.db = db
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
        setupTable()
        setupActions()
        reloadSubTitle()
    }

    private func setupActions() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        contentView.table.addGestureRecognizer(longPress)
    }

    @objc
    private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            mainVC?.handleTableLongPress(self)
        default:
            break
        }
    }

    func updateUI() {
        contentView.table.reloadData()
        reloadSubTitle()
    }

    private func reloadSubTitle() {
        let totalTime = trackingList.totalLength + trackingTimeSpan
        contentView.subTitle.text = String(format: "%1$@\n%2$@", trackingList.listName, totalTime.toMMSSString)
    }
}


extension TrackingBarController: UITableViewDelegate, UITableViewDataSource {

    private func setupTable() {
        contentView.table.delegate = self
        contentView.table.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let activeRow = (trackingService?.state == .active) && isBeingTracked ? 1 : 0
        return trackingList.numberOfRecords + activeRow
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0..<trackingList.numberOfRecords:
            let record = trackingList.sortedRecords[indexPath.row]
            return rowHeight(byTimePeriod: record.end - record.start)
        default:
            return rowHeight(byTimePeriod: trackingTimeSpan)
        }
    }
    private func rowHeight(byTimePeriod timePeriod: TimeInterval) -> CGFloat {
        guard let mainVC else { return 0.0 }
        let tbcDict = mainVC.tbcDict
        let tableHeight = contentView.table.bounds.height
        let defaultTableTimeSpan: TimeInterval = mainVC.defaultTableTimeSpan
        let longestTime: TimeInterval = tbcDict.values.reduce(defaultTableTimeSpan) {
            let finalTotalLength = $1.trackingList.totalLength + $1.trackingTimeSpan
            return max($0, finalTotalLength)
        }
        let timeScale: TimeInterval = timePeriod / longestTime
        return tableHeight * CGFloat(timeScale) * 0.9
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
        cell.backgroundColor = ranbowColors[indexPath.row % ranbowColors.count]
        return cell
    }
}

