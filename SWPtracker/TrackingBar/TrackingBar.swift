//
//  TrackingBar.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/22/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import UIKit


class TrackingBar: UIView {

    private(set) lazy var table: UITableView = {
        let tbv = UITableView()
        tbv.separatorStyle = .none
        tbv.isScrollEnabled = false
        tbv.allowsSelection = false
        tbv.separatorInset = UIEdgeInsets.zero
        tbv.backgroundColor = .lightGray
        tbv.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        tbv.layer.cornerRadius = 8.0
        tbv.translatesAutoresizingMaskIntoConstraints = false
        return tbv
    }()
    private lazy var tableWidthConstraint: NSLayoutConstraint = {
        return table
            .widthAnchor.constraint(equalToConstant: windowBounds.width / 5.0)
            .withPriority(.defaultHigh)
    }()
    private(set) lazy var subTitle: UILabel = {
        let lbl = UILabel()
        lbl.adjustsFontSizeToFitWidth = true
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    private(set) lazy var tableMask: MaskView = {
        let mask = MaskView()
        mask.translatesAutoresizingMaskIntoConstraints = false
        return mask
    }()


    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableWidthConstraint.isActive = true
    }
}


private extension TrackingBar {

    func setupViews() {
        addSubview(table)
        addSubview(tableMask)
        addSubview(subTitle)
    }

    func setupConstraints() {
        var constraints: [NSLayoutConstraint] = []
        constraints += [
            table.centerXAnchor.constraint(equalTo: centerXAnchor),
            table.topAnchor.constraint(equalTo: topAnchor),
            table.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            table.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ]
        constraints += [
            tableMask.heightAnchor.constraint(equalTo: table.heightAnchor, multiplier: 0.2),
            tableMask.topAnchor.constraint(equalTo: table.topAnchor),
            tableMask.leadingAnchor.constraint(equalTo: table.leadingAnchor),
            tableMask.trailingAnchor.constraint(equalTo: table.trailingAnchor)
        ]
        constraints += [
            subTitle.heightAnchor.constraint(equalToConstant: 40.0),
            subTitle.topAnchor.constraint(equalTo: table.bottomAnchor),
            subTitle.leadingAnchor.constraint(equalTo: leadingAnchor),
            subTitle.bottomAnchor.constraint(equalTo: bottomAnchor),
            subTitle.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
