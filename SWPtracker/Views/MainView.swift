//
//  MainView.swift
//  SWPtracker
//
//  Created by Ming Sun on 2020/10/29.
//  Copyright © 2020 Ming Sun. All rights reserved.
//

import UIKit



class MainView: UIView {
    private(set) var trackingListName: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.text = "None"
        l.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight(rawValue: 500))
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private(set) var timeSpent: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.text = "00:00"
        l.font = UIFont.systemFont(ofSize: 60.0, weight: UIFont.Weight(rawValue: 600))
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private var barStack: UIStackView = {
        let s = UIStackView()
        s.distribution = .fillEqually
        s.alignment = .fill
        s.axis = .horizontal
        s.spacing = 8.0
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    private(set) var resetBtn: UIButton = {
        let b = UIButton()
        b.setTitle("Reset", for: .normal)
        b.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private(set) var startBtn: UIButton = {
        let b = UIButton()
        b.setTitle("Start", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private(set) var addBtn: UIButton = {
        let b = UIButton()
        b.setTitle("Add", for: .normal)
        b.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    var trackingBars: [TrackingBar] { barStack.arrangedSubviews.map { $0 as? TrackingBar }.compactMap { $0 } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateUI(hhmmString: String?, trackingListName tln: String? = nil) {
        if let hhmmString = hhmmString {
            startBtn.setTitle("End", for: .normal)
            timeSpent.text = hhmmString
            if let tln = tln {
                trackingListName.text = tln
            }
        } else {
            startBtn.setTitle("Start", for: .normal)
            timeSpent.text = "00:00"
            trackingListName.text = "None"
        }
    }

    func addTrackingBar(trackingBar: TrackingBar) {
        barStack.addArrangedSubview(trackingBar)
    }

    func trackingBar(withTrackingListName listName: String) -> TrackingBar? {
        return trackingBars.first { $0.trackingList.listName == listName }
    }

    func reloadTrackingBars() {
        trackingBars.forEach { $0.reloadData() }
    }

}


private extension MainView {
    func setupViews() {
        addSubview(trackingListName)
        addSubview(timeSpent)
        addSubview(barStack)
        addSubview(resetBtn)
        addSubview(startBtn)
        addSubview(addBtn)
    }

    func setupConstraints() {
        var constraints: [NSLayoutConstraint] = []
        constraints += [
            trackingListName.centerYAnchor.constraint(equalTo: timeSpent.centerYAnchor),
            trackingListName.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            trackingListName.trailingAnchor.constraint(equalTo: timeSpent.leadingAnchor)
        ]
        constraints += [
            timeSpent.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            timeSpent.heightAnchor.constraint(equalToConstant: 80.0),
            timeSpent.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        ]
        constraints += [
            barStack.topAnchor.constraint(equalTo: timeSpent.bottomAnchor, constant: 15.0),
            barStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 60.0),
            barStack.bottomAnchor.constraint(equalTo: startBtn.topAnchor, constant: -1.0 * 30.0),
            barStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -1.0 * 60.0)
        ]
        constraints += [
            resetBtn.centerYAnchor.constraint(equalTo: startBtn.centerYAnchor),
            resetBtn.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            resetBtn.trailingAnchor.constraint(equalTo: startBtn.leadingAnchor)
        ]
        constraints += [
            startBtn.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            startBtn.heightAnchor.constraint(equalToConstant: 80.0),
            startBtn.widthAnchor.constraint(equalToConstant: 80.0),
            startBtn.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -1.0 * 25.0),
        ]
        constraints += [
            addBtn.centerYAnchor.constraint(equalTo: startBtn.centerYAnchor),
            addBtn.leadingAnchor.constraint(equalTo: startBtn.trailingAnchor),
            addBtn.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
