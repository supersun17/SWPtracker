//
//  MainView.swift
//  SWPtracker
//
//  Created by Ming Sun on 2020/10/29.
//  Copyright © 2020 Ming Sun. All rights reserved.
//

import UIKit



class MainView: UIView {
    private var trackingListName: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.text = "NONE"
        l.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight(rawValue: 500))
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private var timeSpent: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.text = "00:00"
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 60.0, weight: UIFont.Weight(rawValue: 600))
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private(set) var barStack: UIStackView = {
        let s = UIStackView()
        s.distribution = .fillEqually
        s.alignment = .fill
        s.axis = .horizontal
        s.spacing = 8.0
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    private(set) var resetBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("RESET", for: .normal)
        b.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private(set) var startBtn: UIButton = {
        let b = UIButton(type: .system)
        b.layer.cornerRadius = 40.0
        b.setTitle("START", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.setTitleColor(.gray, for: .disabled)
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private(set) var addBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("ADD", for: .normal)
        b.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func enableStartBtn(_ enable: Bool) {
        startBtn.isEnabled = enable
        startBtn.backgroundColor = enable ? .systemBlue : .white
    }

    func updateUI(mmssString: String?, trackingListName tln: String? = nil) {
        if let hhmmString = mmssString {
            startBtn.setTitle("END", for: .normal)
            timeSpent.text = hhmmString
            if let tln = tln {
                trackingListName.text = tln
            }
        } else {
            startBtn.setTitle("START", for: .normal)
            timeSpent.text = "00:00"
            trackingListName.text = "NONE"
        }
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
