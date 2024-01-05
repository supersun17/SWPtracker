//
//  TouchEnlargedButton.swift
//  SWPtracker
//
//  Created by Ming Sun on 1/5/24.
//  Copyright © 2024 Ming Sun. All rights reserved.
//

import UIKit



class TouchEnlargedButton: UIButton {

    /// 1, 1, 1, 1 means enlarge each sides for 1px
    var enlargedTouchInsets: UIEdgeInsets = .zero

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newRect = CGRect(x: 0.0 - enlargedTouchInsets.left,
                             y: 0.0 - enlargedTouchInsets.top,
                             width: frame.size.width + enlargedTouchInsets.left + enlargedTouchInsets.right,
                             height: frame.size.height + enlargedTouchInsets.top + enlargedTouchInsets.bottom)
        return newRect.contains(point)
    }
}
