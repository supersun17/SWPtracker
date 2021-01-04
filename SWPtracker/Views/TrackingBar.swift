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
        tbv.backgroundColor = .secondarySystemBackground
        tbv.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        tbv.translatesAutoresizingMaskIntoConstraints = false
        return tbv
    }()
    private(set) lazy var subTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


private extension TrackingBar {
    func setupViews() {
        addSubview(table)
        addSubview(subTitle)
    }

    func setupConstraints() {
        var constraints: [NSLayoutConstraint] = []
        constraints += [
            table.topAnchor.constraint(equalTo: topAnchor),
            table.leadingAnchor.constraint(equalTo: leadingAnchor),
            table.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]
        constraints += [
            subTitle.topAnchor.constraint(equalTo: table.bottomAnchor),
            subTitle.leadingAnchor.constraint(equalTo: leadingAnchor),
            subTitle.bottomAnchor.constraint(equalTo: bottomAnchor),
            subTitle.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
