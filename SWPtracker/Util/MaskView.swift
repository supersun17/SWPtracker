//
//  MaskView.swift
//  SWPtracker
//
//  Created by Ming Sun on 1/3/24.
//  Copyright © 2024 Ming Sun. All rights reserved.
//

import UIKit


class MaskView: UIView {

    override class var layerClass: AnyClass { return CAGradientLayer.self }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let layer = layer as? CAGradientLayer else { return }
        layer.colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0.0).cgColor]
    }
}
