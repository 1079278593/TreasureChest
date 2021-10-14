//
//  UIImageView+Extension.swift
//  MemoryKing
//
//  Created by ming on 2020/2/29.
//  Copyright © 2020 雏虎科技. All rights reserved.
//

import UIKit

public extension UIImageView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        // also  set(newValue)
        set {
            layer.cornerRadius = newValue
        }
    }
}
