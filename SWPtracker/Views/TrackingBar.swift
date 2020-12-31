//
//  TrackingBar.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/22/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import UIKit

protocol TrackingBarDataSource: NSObjectProtocol {
    var timeSpanSinceTrackingStarted: TimeInterval { get }
    func isTracking(_ trackingListName: String) -> Bool
	func scaledHeight(totalHeight: CGFloat, _ timePeriod: TimeInterval) -> CGFloat
}


class TrackingBar: UIView {
    private(set) lazy var recordsList: UITableView = {
        let tbv = UITableView()
        tbv.delegate = self
        tbv.dataSource = self
        tbv.separatorStyle = .none
        tbv.isScrollEnabled = false
        tbv.allowsSelection = false
        tbv.separatorInset = UIEdgeInsets.zero
        tbv.backgroundColor = .secondarySystemBackground
        tbv.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
        tbv.translatesAutoresizingMaskIntoConstraints = false
        return tbv
    }()
    private(set) lazy var totalTimeSpan: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    private let cellID: String = "TrackingListCell"
    weak var dataSource: TrackingBarDataSource!

    let trackingList: TrackingList

    init(frame: CGRect = .zero, trackingList tkl: TrackingList, dataSource dts: TrackingBarDataSource) {
        trackingList = tkl
        dataSource = dts
        super.init(frame: frame)
        reloadTotalTime()
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadData() {
        recordsList.reloadData()
        reloadTotalTime()
    }
}


private extension TrackingBar {
    func setupViews() {
        addSubview(recordsList)
        addSubview(totalTimeSpan)
    }

    func setupConstraints() {
        var constraints: [NSLayoutConstraint] = []
        constraints += [
            recordsList.topAnchor.constraint(equalTo: topAnchor),
            recordsList.leadingAnchor.constraint(equalTo: leadingAnchor),
            recordsList.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]
        constraints += [
            totalTimeSpan.topAnchor.constraint(equalTo: recordsList.bottomAnchor),
            totalTimeSpan.leadingAnchor.constraint(equalTo: leadingAnchor),
            totalTimeSpan.bottomAnchor.constraint(equalTo: bottomAnchor),
            totalTimeSpan.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func reloadTotalTime() {
        let isTracking = dataSource.isTracking(trackingList.listName)
        let additionalTimeFragment = isTracking ? dataSource.timeSpanSinceTrackingStarted : 0.0
        let totalTime = trackingList.timeFragmentsTotalLength + additionalTimeFragment
        totalTimeSpan.text = String(format: "%1$@\n%2$@", trackingList.listName, gethhmmStringFromTimeInterval(totalTime))
    }
}


extension TrackingBar: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let activeRow = dataSource.isTracking(trackingList.listName) ? 1 : 0
		return trackingList.sortedRecords.count + activeRow
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0..<trackingList.numberOfRecords:
            let record = trackingList.sortedRecords[indexPath.row]
            return dataSource.scaledHeight(totalHeight: recordsList.bounds.height, record.end - record.start)
        default:
            return dataSource.scaledHeight(totalHeight: recordsList.bounds.height, dataSource.timeSpanSinceTrackingStarted)
        }
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
        cell.backgroundColor = ranbowColors[indexPath.row % ranbowColors.count]
        return cell
	}
}
