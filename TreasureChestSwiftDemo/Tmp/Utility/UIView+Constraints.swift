//
//  UIView+Constraints.swift
//  MemoryKing
//
//  Created by ming on 2019/9/15.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

//https://blog.csdn.net/allanGold/article/details/57083070
//AutoLayout的适配是在调用N次（子控件个数）控制器的viewDidLayoutSubviews:方法后才完成的，在stackoverflow上也有人建议在此方法中做操作。但是如果像是自定义的cell这么去做，肯定不方便，再者关键是viewDidLayoutSubviews:会调用多次，会影响用户体验和性能。

extension UIView {
    @objc public func refreshConstraintsImmediately() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

